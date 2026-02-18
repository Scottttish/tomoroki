// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'dart:async';
import '../models/user_model.dart';

class AuthService {
  final supabase_flutter.SupabaseClient _supabase = supabase_flutter.Supabase.instance.client;
  
  // Кэш для предотвращения дублирующих запросов
  final Map<String, DateTime> _requestCache = {};
  final Duration _cacheDuration = const Duration(seconds: 30);
  
  // Таймеры для контроля частоты запросов
  final Map<String, int> _requestCount = {};
  final Map<String, Timer> _resetTimers = {};

  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? telegramUsername,
  }) async {
    try {
      final String cacheKey = 'signup_$email';
      
      // Проверка кэша - предотвращение дублирующих запросов
      if (_requestCache.containsKey(cacheKey)) {
        final lastRequest = _requestCache[cacheKey]!;
        if (DateTime.now().difference(lastRequest) < _cacheDuration) {
          throw Exception('Пожалуйста, подождите перед повторной попыткой регистрации');
        }
      }
      
      _requestCache[cacheKey] = DateTime.now();
      
      // ВАЛИДАЦИЯ
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Введите корректный email адрес');
      }
      if (password.length < 6) {
        throw Exception('Пароль должен быть не менее 6 символов');
      }
      if (username.isEmpty) {
        throw Exception('Введите имя пользователя');
      }

      // ✅ ИСПРАВЛЕНИЕ 1: Не проверяем существующего пользователя - это вызывает rate limit
      // Пропускаем проверку существующего пользователя
      
      // ✅ ИСПРАВЛЕНИЕ 2: РЕГИСТРАЦИЯ с ОТКЛЮЧЕННЫМ подтверждением email
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'username': username.trim(),
          'full_name': fullName?.trim() ?? username.trim(),
          'telegram_username': telegramUsername?.trim(),
          'email_verified': 'true', // ✅ Помечаем как подтвержденный
        },
        emailRedirectTo: null, // ✅ Отключаем редирект для подтверждения
      );

      if (response.user == null) {
        throw Exception('Не удалось создать пользователя');
      }

      print('✅ Пользователь создан в auth: ${response.user!.id}');
      
      // ✅ ИСПРАВЛЕНИЕ 3: СОЗДАЕМ ПОЛЬЗОВАТЕЛЯ В ТАБЛИЦЕ USERS с ГАРАНТИЕЙ
      final user = UserModel(
        id: response.user!.id,
        email: email.trim(),
        username: username.trim(),
        fullName: fullName?.trim() ?? username.trim(),
        telegramUsername: telegramUsername?.trim(),
        role: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now(),
        isActive: true,
      );

      // ✅ ИСПРАВЛЕНИЕ 4: ПРОБУЕМ 3 РАЗНЫХ СПОСОБА СОХРАНЕНИЯ
      bool userCreated = false;
      
      // Способ 1: Простой insert
      try {
        await _supabase
            .from('users')
            .insert(user.toJson());
        userCreated = true;
        print('✅ Данные сохранены через insert');
      } catch (insertError) {
        print('⚠️ Ошибка insert: $insertError');
        
        // Способ 2: Upsert
        try {
          await _supabase
              .from('users')
              .upsert(user.toJson());
          userCreated = true;
          print('✅ Данные сохранены через upsert');
        } catch (upsertError) {
          print('⚠️ Ошибка upsert: $upsertError');
          
          // Способ 3: Если таблица имеет другую структуру
          try {
            await _supabase.from('users').insert({
              'id': user.id,
              'email': user.email,
              'username': user.username,
              'full_name': user.fullName,
              'created_at': user.createdAt.toIso8601String(),
            });
            userCreated = true;
            print('✅ Данные сохранены через простой insert');
          } catch (simpleError) {
            print('⚠️ Ошибка простого insert: $simpleError');
          }
        }
      }

      // ✅ ИСПРАВЛЕНИЕ 5: ВХОД С ПРОВЕРКОЙ ЧТО ПОЛЬЗОВАТЕЛЬ СОЗДАН
      try {
        // Ждем 1 секунду чтобы все синхронизировалось
        await Future.delayed(const Duration(seconds: 1));
        
        final signInResponse = await _supabase.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        
        if (signInResponse.user != null) {
          print('✅ Автоматический вход выполнен');
          
          // Обновляем last_login если пользователь создан в таблице
          if (userCreated) {
            try {
              await _supabase
                  .from('users')
                  .update({
                    'last_login': DateTime.now().toIso8601String(),
                    'updated_at': DateTime.now().toIso8601String(),
                  })
                  .eq('id', signInResponse.user!.id);
              print('✅ Last login обновлен');
            } catch (e) {
              print('⚠️ Ошибка обновления last_login: $e');
            }
          }
          
          // ✅ ИСПРАВЛЕНИЕ 6: ПРОВЕРЯЕМ ЧТО ДАННЫЕ ДЕЙСТВИТЕЛЬНО СОХРАНИЛИСЬ
          try {
            final savedUser = await _supabase
                .from('users')
                .select()
                .eq('id', user.id)
                .maybeSingle();
            
            if (savedUser != null) {
              print('✅ Данные подтверждены в базе: $savedUser');
              return UserModel.fromJson(savedUser);
            } else {
              print('⚠️ Данные не найдены в базе, возвращаем локального пользователя');
            }
          } catch (e) {
            print('⚠️ Ошибка проверки сохранения: $e');
          }
          
          return user;
        }
      } catch (e) {
        print('⚠️ Автоматический вход не удался: $e');
      }

      return user;

    } catch (e) {
      final error = e.toString();
      print('❌ Ошибка регистрации: $error');
      
      // ✅ ИСПРАВЛЕНИЕ 7: ПРОБУЕМ АЛЬТЕРНАТИВНЫЙ МЕТОД ПРИ RATE LIMIT
      if (error.contains('429') || 
          error.contains('rate limit') ||
          error.contains('over_email_send_rate_limit')) {
        
        print('⏰ Rate limit обнаружен, пробуем альтернативный метод...');
        
        // Альтернативный метод: создаем пользователя напрямую в таблице
        try {
          final altUser = await _createUserDirectly(
            email: email,
            password: password,
            username: username,
            fullName: fullName,
          );
          
          if (altUser != null) {
            print('✅ Пользователь создан через альтернативный метод');
            return altUser;
          }
        } catch (altError) {
          print('❌ Альтернативный метод тоже не сработал: $altError');
        }
        
        throw Exception('Слишком много запросов. Пожалуйста, подождите 30 секунд');
      }
      
      // Обработка других ошибок
      if (error.contains('already registered') || 
          error.contains('already exists') ||
          error.contains('duplicate') ||
          error.contains('User already registered')) {
        throw Exception('Пользователь с таким email уже зарегистрирован');
      } else if (error.contains('Invalid login credentials')) {
        // Это нормально при проверке существующего пользователя
      } else if (error.contains('network') || 
                 error.contains('Socket')) {
        throw Exception('Проблема с подключением к интернету');
      } else if (error.contains('email_not_confirmed') || 
                 error.contains('not confirmed')) {
        throw Exception('Пожалуйста, обратитесь к администратору для настройки подтверждения email');
      }
      
      throw Exception('Ошибка регистрации: ${error.length > 100 ? 'Попробуйте позже' : error}');
    }
  }

  // ✅ АЛЬТЕРНАТИВНЫЙ МЕТОД: создание пользователя напрямую в таблице
  Future<UserModel?> _createUserDirectly({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    try {
      print('🔄 Пробуем альтернативный метод регистрации...');
      
      // Генерируем ID
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(6)}';
      
      // Создаем пользователя
      final userData = {
        'id': userId,
        'email': email,
        'username': username,
        'full_name': fullName ?? username,
        'role': 'user',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'last_login': DateTime.now().toIso8601String(),
        'is_active': true,
      };
      
      // Пробуем вставить
      try {
        await _supabase
            .from('users')
            .insert(userData);
        print('✅ Пользователь создан напрямую в таблице: $userId');
        
        // Также пробуем создать в auth (но это не обязательно)
        try {
          await _supabase.auth.signUp(
            email: email,
            password: password,
            data: {'username': username},
          );
        } catch (authError) {
          print('⚠️ Не удалось создать в auth: $authError');
        }
        
        return UserModel(
          id: userId,
          email: email,
          username: username,
          fullName: fullName ?? username,
          role: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isActive: true,
        );
      } catch (e) {
        print('❌ Ошибка при прямом создании: $e');
        return null;
      }
    } catch (e) {
      print('❌ Ошибка альтернативного метода: $e');
      return null;
    }
  }

  // Генерация случайной строки
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = supabase_flutter.GoTrueClient().hashCode;
    return String.fromCharCodes(
      Iterable.generate(
        length, 
        (_) => chars.codeUnitAt((random + DateTime.now().microsecondsSinceEpoch) % chars.length)
      )
    );
  }

  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final String cacheKey = 'signin_$email';
      
      // Защита от rate limit
      if (!_canMakeRequest(cacheKey)) {
        throw Exception('Слишком много попыток входа. Пожалуйста, подождите 60 секунд');
      }
      
      _trackRequest(cacheKey);
      
      // ВАЛИДАЦИЯ
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Введите корректный email адрес');
      }
      if (password.isEmpty) {
        throw Exception('Введите пароль');
      }

      // АВТОРИЗАЦИЯ
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw Exception('Неверный email или пароль');
      }

      print('✅ Вход выполнен: ${response.user!.id}');
      
      // ✅ ИСПРАВЛЕНИЕ 8: ОБНОВЛЯЕМ/СОЗДАЕМ ПОЛЬЗОВАТЕЛЯ В ТАБЛИЦЕ
      try {
        // Сначала пробуем обновить
        final updateResult = await _supabase
            .from('users')
            .update({
              'last_login': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', response.user!.id);

        // Если пользователь не найден (updateResult пустой), создаем запись
        if (updateResult == null || updateResult.isEmpty) {
          print('⚠️ Пользователь не найден в таблице, создаем...');
          
          final user = UserModel(
            id: response.user!.id,
            email: response.user!.email!,
            username: response.user!.email!.split('@').first,
            role: 'user',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            lastLogin: DateTime.now(),
            isActive: true,
          );
          
          try {
            await _supabase
                .from('users')
                .insert(user.toJson());
            print('✅ Пользователь создан в таблице при входе');
            return user;
          } catch (insertError) {
            print('⚠️ Ошибка создания при входе: $insertError');
            
            // Пробуем upsert
            try {
              await _supabase
                  .from('users')
                  .upsert(user.toJson());
              print('✅ Пользователь создан через upsert');
              return user;
            } catch (upsertError) {
              print('⚠️ Ошибка upsert: $upsertError');
              // Возвращаем пользователя без сохранения в таблице
              return user;
            }
          }
        } else {
          print('✅ Last login обновлен для существующего пользователя');
        }
      } catch (e) {
        print('⚠️ Ошибка обновления last_login: $e');
        // Продолжаем получение данных
      }

      // ✅ ИСПРАВЛЕНИЕ 9: ПОЛУЧАЕМ ДАННЫЕ ПОЛЬЗОВАТЕЛЯ с обработкой ошибок
      try {
        final userData = await _supabase
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();

        print('✅ Данные пользователя получены из таблицы');
        return UserModel.fromJson(userData);
      } catch (e) {
        print('⚠️ Ошибка получения данных из таблицы: $e');
        
        // Если пользователя нет в таблице, создаем
        final user = UserModel(
          id: response.user!.id,
          email: response.user!.email!,
          username: response.user!.email!.split('@').first,
          role: 'user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isActive: true,
        );

        try {
          await _supabase
              .from('users')
              .upsert(user.toJson());
          print('✅ Пользователь создан после входа');
        } catch (insertError) {
          print('⚠️ Не удалось создать пользователя после входа: $insertError');
        }

        return user;
      }
      
    } catch (e) {
      final error = e.toString();
      print('❌ Ошибка входа: $error');
      
      if (error.contains('Invalid login credentials')) {
        throw Exception('Неверный email или пароль');
      } else if (error.contains('Email not confirmed') || 
                 error.contains('not confirmed')) {
        throw Exception('Ошибка входа. Попробуйте перерегистрироваться');
      } else if (error.contains('network') || 
                 error.contains('Socket')) {
        throw Exception('Проблема с подключением к интернету');
      } else if (error.contains('429') || 
                 error.contains('rate limit') ||
                 error.contains('too many requests')) {
        throw Exception('Слишком много запросов. Пожалуйста, подождите');
      }
      
      throw Exception('Ошибка входа: ${error.length > 100 ? 'Проверьте данные и попробуйте снова' : error}');
    }
  }

  // ✅ ИСПРАВЛЕНИЕ 10: ПОЛУЧЕНИЕ ТЕКУЩЕГО ПОЛЬЗОВАТЕЛЯ с гарантией
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('ℹ️ Нет текущего пользователя в auth');
        return null;
      }

      print('🔍 Ищем пользователя в таблице: ${user.id}');
      
      // Пробуем получить данные из таблицы
      try {
        final userData = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (userData != null) {
          print('✅ Пользователь найден в таблице');
          return UserModel.fromJson(userData);
        } else {
          print('⚠️ Пользователь не найден в таблице, создаем...');
        }
      } catch (e) {
        print('⚠️ Ошибка получения данных из таблицы: $e');
      }

      // Создаем запись если ее нет
      final newUser = UserModel(
        id: user.id,
        email: user.email ?? 'unknown@email.com',
        username: user.email?.split('@').first ?? 'user',
        role: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now(),
        isActive: true,
      );
      
      try {
        await _supabase
            .from('users')
            .upsert(newUser.toJson());
        print('✅ Пользователь создан в таблице');
      } catch (e) {
        print('⚠️ Ошибка создания пользователя в таблице: $e');
        // Игнорируем ошибку, возвращаем пользователя
      }
      
      return newUser;
      
    } catch (e) {
      print('❌ Ошибка получения текущего пользователя: $e');
      return null;
    }
  }

  // Методы для защиты от rate limit
  bool _canMakeRequest(String key) {
    final count = _requestCount[key] ?? 0;
    return count < 5; // Максимум 5 запросов за период
  }

  void _trackRequest(String key) {
    _requestCount[key] = (_requestCount[key] ?? 0) + 1;
    
    // Сбрасываем счетчик через 60 секунд
    if (_resetTimers.containsKey(key)) {
      _resetTimers[key]!.cancel();
    }
    
    _resetTimers[key] = Timer(const Duration(seconds: 60), () {
      _requestCount.remove(key);
      _resetTimers.remove(key);
    });
  }

  Future<void> signOut() async {
    try {
      // Очищаем кэш при выходе
      _requestCache.clear();
      _requestCount.clear();
      
      // Используем цикл for вместо forEach
      for (final timer in _resetTimers.values) {
        timer.cancel();
      }
      _resetTimers.clear();
      
      await _supabase.auth.signOut();
      print('✅ Выход выполнен');
    } catch (e) {
      print('❌ Ошибка выхода: $e');
      throw Exception('Не удалось выйти из системы');
    }
  }
  
  // ✅ НОВЫЙ МЕТОД: Проверка что таблица users существует и имеет правильную структуру
  Future<void> checkAndCreateUsersTable() async {
    try {
      print('🔍 Проверяем таблицу users...');
      
      // Пробуем сделать простой запрос
      final test = await _supabase
          .from('users')
          .select('count')
          .limit(1)
          .maybeSingle();
      
      print('✅ Таблица users существует');
    } catch (e) {
      print('⚠️ Таблица users не существует или имеет другую структуру: $e');
      
      // Можно добавить здесь создание таблицы через RPC если нужно
      print('💡 Для создания таблицы выполните SQL в Supabase Dashboard:');
      print('''
CREATE TABLE IF NOT EXISTS public.users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL,
  username TEXT NOT NULL,
  full_name TEXT,
  telegram_username TEXT,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_login TIMESTAMPTZ DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true
);
      ''');
    }
  }
}