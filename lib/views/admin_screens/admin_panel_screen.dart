import 'package:ecommerceapp/view_model/admin_view_model.dart';
import 'package:ecommerceapp/views/admin_screens/app_setting_screen.dart';
import 'package:ecommerceapp/views/admin_screens/category_management_screen.dart';
import 'package:ecommerceapp/views/admin_screens/dash_board_screen.dart';
import 'package:ecommerceapp/views/admin_screens/product_management_screen.dart';
import 'package:ecommerceapp/views/admin_screens/user_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminPanelContainerScreen extends StatelessWidget {
   AdminPanelContainerScreen({super.key});

    final List<Widget> screens = [
    DashBoardScreen(),
    ProductManagementScreen(),
    CategoryManagementScreen(),
    UserManagementScreen(),
    AppSettingScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Pannel"),
        centerTitle: true,
      ),
      drawer: SafeArea(
        child: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Admin Panel",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    _drawerTile(Icons.home_filled, "Dashboard", Colors.blue, () {
                      Navigator.pop(context);
                      context.read<AdminViewModel>().updateScreen(context, 0);

                    }),
                    _drawerTile(Icons.shopping_cart_rounded, "Products", Colors.orange, () {
                      Navigator.pop(context);
                     context.read<AdminViewModel>().updateScreen(context, 1);
                    }),
                    _drawerTile(Icons.category, "Category", Colors.green, () {
                      Navigator.pop(context);
                      context.read<AdminViewModel>().updateScreen(context, 2);
                    }),
                    _drawerTile(Icons.person, "Users", Colors.purple, () {
                      Navigator.pop(context);
                      context.read<AdminViewModel>().updateScreen(context, 3);
                    }),
                    _drawerTile(Icons.settings, "Settings", Colors.grey, () {
                      Navigator.pop(context);
                      context.read<AdminViewModel>().updateScreen(context, 4);
                    }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle logout logic
                  },
                ),
              ),  
            ],
          ),
        ),
      ),
      body: Consumer(
        builder: (context, AdminViewModel model, child) {
          return IndexedStack(
          index: model.selectIndex,
          children: screens,
        ); 
        },
       
      )
    );
  }

  Widget _drawerTile(IconData icon, String label, Color color, VoidCallback onPressed) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onPressed,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Colors.grey.shade200,
    );
  }
}