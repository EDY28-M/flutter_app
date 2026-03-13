import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'welcome_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  NavItem _current = NavItem.home;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadMyCarts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (!auth.isLoggedIn) {
          return const WelcomeScreen();
        }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: IndexedStack(
            index: _current.index,
            children: const [
              HomeScreen(),
              OrdersScreen(),
              _OffersPlaceholder(),
              CartScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: Consumer<CartProvider>(
            builder: (_, cart, __) => BottomNavBar(
              current: _current,
              onTap: (n) => setState(() => _current = n),
              cartCount: cart.totalItemCount,
            ),
          ),
        );
      },
    );
  }
}

class _OffersPlaceholder extends StatelessWidget {
  const _OffersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Ofertas'),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text('Próximamente', style: TextStyle(color: AppColors.slate500)),
      ),
    );
  }
}
