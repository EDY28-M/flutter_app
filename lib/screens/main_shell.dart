import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'offers_screen.dart';
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
      context.read<FavoritesProvider>().load();
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
              OffersScreen(),
              CartScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: Consumer<CartProvider>(
            builder: (_, cart, __) => BottomNavigationBar(
              currentIndex: _current.index,
              onTap: (i) => setState(() => _current = NavItem.values[i]),
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.primary,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              items: [
                const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
                const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Pedidos'),
                const BottomNavigationBarItem(icon: Icon(Icons.local_offer_rounded), label: 'Ofertas'),
                BottomNavigationBarItem(
                  icon: cart.totalItemCount > 0
                      ? Badge(
                          label: Text('${cart.totalItemCount > 99 ? "99+" : cart.totalItemCount}'),
                          child: const Icon(Icons.shopping_cart_rounded),
                        )
                      : const Icon(Icons.shopping_cart_rounded),
                  label: 'Carrito',
                ),
                const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
              ],
            ),
          ),
        );
      },
    );
  }
}
