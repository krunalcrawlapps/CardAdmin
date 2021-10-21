import 'package:card_app_admin/screens/admin/cards/cards_screen.dart';
import 'package:card_app_admin/screens/admin/customer/customer_screen.dart';
import 'package:card_app_admin/screens/admin/orders/direct_charge_orders.dart';
import 'package:card_app_admin/screens/admin/orders/orders_screen.dart';
import 'package:card_app_admin/screens/admin/prices/prices_screen.dart';
import 'package:card_app_admin/screens/common/profile_screen.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    CustomerScreen(),
    CardsScreen(),
    OrdersScreen(),
    DirectChargeOrders(),
    PricesScreen(),
    ProfileScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: AppTranslations.of(context)!.text('Customers'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: AppTranslations.of(context)!.text('Cards'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_sharp),
            label: AppTranslations.of(context)!.text('Orders'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: AppTranslations.of(context)!.text('Direct Charge'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.price_check_sharp),
            label: AppTranslations.of(context)!.text('Prices'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: AppTranslations.of(context)!.text('My Profile'),
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
