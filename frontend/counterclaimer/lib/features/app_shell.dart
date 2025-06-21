import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:counterclaimer/features/case_analysis/screens/legal_arguments_screen.dart';
import 'package:counterclaimer/features/document_view/screens/document_view_screen.dart';
// import 'package:bmw_legal_assistant/features/document_review/screens/document_review_screen.dart';
import 'package:counterclaimer/core/theme/colors.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  // Helper method to determine if we're on a mobile device
  bool _isMobileDevice(BuildContext context) {
    // Check if screen width is less than 600 (tablet breakpoint)
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    // Check if we're on a mobile platform (iOS or Android)
    final isMobilePlatform = !kIsWeb && (Platform.isIOS || Platform.isAndroid);
    
    // Return true if either condition is met
    return isSmallScreen || isMobilePlatform;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabIndex = ref.watch(selectedTabProvider);
    final isMobile = _isMobileDevice(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1D5A6C), // azzurro chiaro
              Color(0xFF004AAD), // blu intenso
            ],
          ),
        ),
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: isMobile
                  // Mobile layout without side navigation
                  ? IndexedStack(
                      index: selectedTabIndex,
                      children: const [
                        LegalArgumentsScreen(),
                        DocumentViewScreen(),
                        Placeholder(color: AppColors.lightGreen),
                      ],
                    )
                  // Desktop layout with side navigation
                  : Row(
                      children: [
                        _SideNavigation(
                          selectedIndex: selectedTabIndex,
                          onIndexChanged: (index) => ref.read(selectedTabProvider.notifier).state = index,
                        ),
                        Expanded(
                          child: IndexedStack(
                            index: selectedTabIndex,
                            children: const [
                              LegalArgumentsScreen(),
                              DocumentViewScreen(),
                              Placeholder(color: AppColors.lightGreen),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      // Show bottom navigation only for mobile
      bottomNavigationBar: isMobile ? _buildBottomNavBar(context, selectedTabIndex, ref) : null,
    );
  }

  // Bottom navigation bar for mobile
  Widget _buildBottomNavBar(BuildContext context, int selectedIndex, WidgetRef ref) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => ref.read(selectedTabProvider.notifier).state = index,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textMedium,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart_rounded),
          label: 'Case Analysis',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.text_snippet_rounded),
          label: 'Documents',
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Make top bar responsive
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isMobilePlatform = !kIsWeb && (Platform.isIOS || Platform.isAndroid);
    final isMobile = isSmallScreen || isMobilePlatform;

    return Container(
      // Aumenta l'altezza solo per dispositivi mobili
      height: isMobile ? 150 : 64,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        // Aggiunto padding verticale per il mobile
        vertical: isMobile ? 10 : 0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
  children: [
    // ARIA Logo only
    Image.asset(
      'assets/images/aria_logo.jpg',
      width: 120,
      height: 120,
    ),
  ],
),
    );
  }
}

class _SideNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const _SideNavigation({
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Width reduced from 80 to 60
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Navigation Items
          Expanded(
            child: Column(
              children: [
                _NavItem(
                  icon: Icons.pie_chart_rounded,
                  label: 'Case Analysis',
                  isSelected: selectedIndex == 0,
                  onTap: () => onIndexChanged(0),
                ),
                _NavItem(
                  icon: Icons.text_snippet_rounded,
                  label: 'Documents',
                  isSelected: selectedIndex == 1,
                  onTap: () => onIndexChanged(1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      preferBelow: false,
      verticalOffset: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.lightGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? AppColors.primaryGreen : AppColors.textMedium,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.neutralGradient,
        ),
      ),
      child: const Center(
        child: Text(
          'MK',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}