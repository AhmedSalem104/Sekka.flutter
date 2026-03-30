import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/sekka_bottom_nav.dart';
import '../../../orders/presentation/screens/orders_list_screen.dart';
import '../../../settlements/presentation/screens/settlements_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'contacts_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  late final List<Widget> _screens = [
    HomeScreen(onAvatarTap: _openProfile),
    const OrdersListScreen(),
    const ContactsScreen(),
    const WalletScreen(),
    const SettlementsScreen(),
  ];

  final _navItems = [
    SekkaBottomNavItem(
      icon: IconsaxPlusLinear.home_2,
      activeIcon: IconsaxPlusBold.home_2,
      label: 'الرئيسية',
    ),
    SekkaBottomNavItem(
      icon: IconsaxPlusLinear.clipboard_text,
      activeIcon: IconsaxPlusBold.clipboard_text,
      label: 'الطلبات',
    ),
    SekkaBottomNavItem(
      icon: IconsaxPlusLinear.profile_2user,
      activeIcon: IconsaxPlusBold.profile_2user,
      label: 'جهات الاتصال',
    ),
    SekkaBottomNavItem(
      icon: IconsaxPlusLinear.wallet_2,
      activeIcon: IconsaxPlusBold.wallet_2,
      label: 'المحفظة',
    ),
    SekkaBottomNavItem(
      icon: IconsaxPlusLinear.calculator,
      activeIcon: IconsaxPlusBold.calculator,
      label: AppStrings.accountHandover,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SekkaBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: _navItems,
            ),
          ),
        ],
      ),
    );
  }
}
