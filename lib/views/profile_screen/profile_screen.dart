import 'package:ecommerceapp/view_model/profile_view_model.dart';
import 'package:ecommerceapp/view_model/setting_view_model.dart';
import 'package:ecommerceapp/views/profile_screen/address_screen/address_screen.dart';
import 'package:ecommerceapp/views/profile_screen/edit_profile_screen.dart';
import 'package:ecommerceapp/views/profile_screen/settings_screen.dart';
import 'package:ecommerceapp/views/profile_screen/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch profile when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SettingViewModel>(context, listen: false).fetchUserProfile();
    });

    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Consumer<SettingViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Account'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              )
            ],
          ),
          body: viewModel.isLoading
              ? _buildShimmerLoading()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: viewModel.profilePhotoUrl != null
                            ? NetworkImage(viewModel.profilePhotoUrl!)
                            : null,
                        child: viewModel.profilePhotoUrl == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey[400],
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        viewModel.username ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        viewModel.userGamil ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: viewModel,
                                child: EditProfileScreen(),
                              ),
                            ),
                          );
                        },
                        child: const Text('Edit Profile'),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.shopping_bag_outlined),
                        title: const Text('My Orders'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Navigate to Orders screen
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: const Text('Shipping Address'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddressScreen()));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('Help Center'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Navigate to Help Center screen
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          await profileViewModel.logout(context);
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Avatar Shimmer
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 10),
            // Username Shimmer
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            // Email Shimmer
            Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 15),
            // Edit Profile Button Shimmer
            Container(
              width: 120,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            // List Tiles Shimmer
            buildShimmerListTile(),
            buildShimmerListTile(),
            buildShimmerListTile(),
            buildShimmerListTile(),
          ],
        ),
      ),
    );
  }


}