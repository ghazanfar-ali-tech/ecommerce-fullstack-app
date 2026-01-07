import 'package:ecommerceapp/views/home_screen/home_screen.dart';
import 'package:ecommerceapp/views/whileList/favourite_screen.dart';
import 'package:ecommerceapp/views/profile_screen/profile_screen.dart';
import 'package:ecommerceapp/views/store_screen/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}
class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    HomeScreen(),
    StoreScreen(),
    FavouriteScreen(),
    ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index); 
        },
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
         
          margin: EdgeInsets.only(
            bottom: height * 0.015,
            left: width * 0.05,
            right: width * 0.05,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.015,
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
          ),
          child: GNav(
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              _pageController.jumpToPage(index);
            },
            gap: width * 0.02,
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.012,
            ),
            color: Colors.white70,
            activeColor: Colors.black,
            tabBackgroundColor: const Color(0xFFD9F99D),
            iconSize: width * 0.06,
            tabBorderRadius: 15,
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.storefront_sharp, text: 'Store'),
              GButton(icon: Iconsax.heart, text: 'Wishlist'),
              GButton(icon: Icons.person, text: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
