import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../history/history_screen.dart';
import '../predictor/predictor_screen.dart';
import '../profile/profile_screen.dart';
import '../wallet/wallet_screen.dart';
import 'dashboard_screen.dart';

/// Bottom navigation host. Keeps each tab alive via IndexedStack.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    DashboardScreen(),
    PredictorScreen(),
    HistoryScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final UserProvider user = context.watch<UserProvider>();
    final bool admin = user.isAdmin;

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (int v) => setState(() => _index = v),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flight_takeoff_rounded),
              label: 'Predictor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: admin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.accent,
              icon: const Icon(Icons.shield_moon_rounded),
              label: const Text('Admin'),
              onPressed: () => Navigator.of(context).pushNamed('/admin'),
            )
          : null,
    );
  }
}
