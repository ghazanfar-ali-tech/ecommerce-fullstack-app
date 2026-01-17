import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authViewModel.logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, Admin!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Email: ${authViewModel.email}'),
                    Text('User ID: ${authViewModel.userId}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'User Management',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final userData = users[index].data() as Map<String, dynamic>;
                      final userId = users[index].id;
                      final username = userData['username'] ?? 'Unknown';
                      final email = userData['email'] ?? 'No email';
                      final role = userData['role'] ?? 'user';
                      final userImage = userData['profilePhotoUrl'] ?? 'https://t3.ftcdn.net/jpg/16/27/33/06/360_F_1627330643_pLZLDh7zIgLLsuBMhNgiWxoP4BjzRIfx.jpg';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: role == 'admin'
                                ? Colors.red
                                : Colors.blue,
                            
                            backgroundImage:role == 'admin' ? NetworkImage(  "https://thumbs.dreamstime.com/b/portrait-handsome-smiling-young-man-folded-arms-smiling-joyful-cheerful-men-crossed-hands-isolated-studio-shot-172869765.jpg"
                            ):NetworkImage(userImage),
                            
                          ),
                          title: Text(username),
                          subtitle: Text(email),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'make_admin') {
                                await _updateUserRole(userId, 'admin');
                              } else if (value == 'make_user') {
                                await _updateUserRole(userId, 'user');
                              } else if (value == 'delete') {
                                await _deleteUser(context, userId);
                              }
                            },
                            itemBuilder: (context) => [
                              if (role != 'admin')
                                const PopupMenuItem(
                                  value: 'make_admin',
                                  child: Row(
                                    children: [
                                      Icon(Icons.admin_panel_settings),
                                      SizedBox(width: 8),
                                      Text('Make Admin'),
                                    ],
                                  ),
                                ),
                              if (role == 'admin')
                                const PopupMenuItem(
                                  value: 'make_user',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person),
                                      SizedBox(width: 8),
                                      Text('Make User'),
                                    ],
                                  ),
                                ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete User', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'role': newRole});
    } catch (e) {
      print('Error updating role: $e');
    }
  }

  Future<void> _deleteUser(BuildContext context, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      } catch (e) {
        print('Error deleting user: $e');
      }
    }
  }
}