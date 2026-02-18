import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE8EDF2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavButton(
                icon: Icons.home_rounded,
                label: 'Главная',
                index: 0,
              ),
              _buildNavButton(
                icon: Icons.explore_rounded,
                label: 'Рекомендации',
                index: 1,
              ),
              _buildCenterButton(),
              _buildNavButton(
                icon: Icons.chat_bubble_rounded,
                label: 'Сообщения',
                index: 3,
              ),
              _buildNavButton(
                icon: Icons.person_rounded,
                label: 'Профиль',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? const Color(0xFF5D7CF9) : const Color(0xFFBDC3C7),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isActive ? const Color(0xFF5D7CF9) : const Color(0xFFBDC3C7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5D7CF9), Color(0xFF7B6CF2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x335D7CF9),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}