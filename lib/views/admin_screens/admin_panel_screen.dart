import 'package:ecommerceapp/view_model/admin_view_model.dart';
import 'package:ecommerceapp/views/admin_screens/app_setting_screen.dart';
import 'package:ecommerceapp/views/admin_screens/category_management_screen.dart';
import 'package:ecommerceapp/views/admin_screens/dash_borad_screens/dash_board_screen.dart';
import 'package:ecommerceapp/views/admin_screens/product_management_screens/all_products_screen.dart';
import 'package:ecommerceapp/views/admin_screens/user_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';

class AdminPanelContainerScreen extends StatelessWidget {
  AdminPanelContainerScreen({super.key});

  final List<Widget> screens = [
    DashBoardScreen(),
    AllProductsScreen(),
    CategoryManagementScreen(),
    UserManagementScreen(),
    AppSettingScreen()
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AdminViewModel>();
    
    return ZoomDrawer(
      controller: viewModel.drawerController,
      menuScreen: _buildMenuScreen(context),
      mainScreen: _buildMainScreen(context),
      borderRadius: 24.0,
      showShadow: true,
      angle: -12.0,
      menuBackgroundColor: Colors.blue.shade700,
      slideWidth: MediaQuery.of(context).size.width * 0.65,
      openCurve: Curves.easeInOut,
      closeCurve: Curves.easeInOut,
      duration: const Duration(milliseconds: 500),
      disableDragGesture: false,
    );
  }

  Widget _buildMainScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            context.read<AdminViewModel>().toggleDrawer();
          },
        ),
      ),
      body: Consumer<AdminViewModel>(
        builder: (context, model, child) {
          return IndexedStack(
            index: model.selectIndex,
            children: screens,
          );
        },
      ),
    );
  }

  Widget _buildMenuScreen(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.blue.shade700,
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    "https://thumbs.dreamstime.com/b/portrait-handsome-smiling-young-man-folded-arms-smiling-joyful-cheerful-men-crossed-hands-isolated-studio-shot-172869765.jpg",
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Admin Panel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "admin123@gmail.com",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _drawerTile(
                    Icons.home_filled,
                    "Dashboard",
                    Colors.white,
                    () {
                      final viewModel = context.read<AdminViewModel>();
                      viewModel.updateScreen(context, 0);
                      viewModel.closeDrawer();
                    },
                    context,
                    0,
                  ),
                  const SizedBox(height: 8),
                  _drawerTile(
                    Icons.shopping_cart_rounded,
                    "Products",
                    Colors.white,
                    () {
                      final viewModel = context.read<AdminViewModel>();
                      viewModel.updateScreen(context, 1);
                      viewModel.closeDrawer();
                    },
                    context,
                    1,
                  ),
                  const SizedBox(height: 8),
                  _drawerTile(
                    Icons.category,
                    "Category",
                    Colors.white,
                    () {
                      final viewModel = context.read<AdminViewModel>();
                      viewModel.updateScreen(context, 2);
                      viewModel.closeDrawer();
                    },
                    context,
                    2,
                  ),
                  const SizedBox(height: 8),
                  _drawerTile(
                    Icons.person,
                    "Users",
                    Colors.white,
                    () {
                      final viewModel = context.read<AdminViewModel>();
                      viewModel.updateScreen(context, 3);
                      viewModel.closeDrawer();
                    },
                    context,
                    3,
                  ),
                  const SizedBox(height: 8),
                  _drawerTile(
                    Icons.settings,
                    "Settings",
                    Colors.white,
                    () {
                      final viewModel = context.read<AdminViewModel>();
                      viewModel.updateScreen(context, 4);
                      viewModel.closeDrawer();
                    },
                    context,
                    4,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.read<AdminViewModel>().closeDrawer();
                    // Handle logout logic
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 16),
                        Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
    BuildContext context,
    int index,
  ) {
    return Consumer<AdminViewModel>(
      builder: (context, model, child) {
        final isSelected = model.selectIndex == index;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}