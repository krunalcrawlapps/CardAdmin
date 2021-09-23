import 'package:card_app_admin/screens/common/profile_screen.dart';
import 'package:card_app_admin/screens/super_admin/admin/admin_list_screen.dart';
import 'package:card_app_admin/screens/super_admin/category/category_list_screen.dart';
import 'package:card_app_admin/screens/super_admin/sub-category/sub_category_list_screen.dart';
import 'package:card_app_admin/screens/super_admin/vendor/vendor_list_screen.dart';
import 'package:flutter/material.dart';

class SuperAdminHome extends StatefulWidget {
  const SuperAdminHome({Key? key}) : super(key: key);

  @override
  _SuperAdminHomeState createState() => _SuperAdminHomeState();
}

class _SuperAdminHomeState extends State<SuperAdminHome> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    AdminListScreen(),
    VendorListScreen(),
    CategoryListScreen(),
    SubCategoryListScreen(),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admins',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Vendors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'SubCategory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'My Profile',
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
