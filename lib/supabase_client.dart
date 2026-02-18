// lib/supabase_client.dart
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'config/supabase_config.dart';

class SupabaseClient {
  static final SupabaseClient _instance = SupabaseClient._internal();
  factory SupabaseClient() => _instance;
  SupabaseClient._internal();

  late supabase_flutter.SupabaseClient _supabase;
  supabase_flutter.SupabaseClient get client => _supabase;

  Future<void> initialize() async {
    await supabase_flutter.Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _supabase = supabase_flutter.Supabase.instance.client;
  }

  static SupabaseClient get instance {
    return _instance;
  }
}

final supabase = supabase_flutter.Supabase.instance.client;