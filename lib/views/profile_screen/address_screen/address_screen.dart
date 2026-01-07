import 'package:ecommerceapp/models/hive_models/shipping_address/address.dart';
import 'package:ecommerceapp/view_model/address_view_model.dart';
import 'package:ecommerceapp/views/profile_screen/address_screen/form_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';


class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.getUserId() == null) {
          return const Scaffold(body: Center(child: Text('Please log in to view addresses')));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Shipping Address'),
          ),
          body: viewModel.isLoading
              ? _buildShimmerList()
              : viewModel.addresses.isEmpty
                  ? const Center(child: Text('No addresses yet. Add one!'))
                  : ListView.builder(
                      itemCount: viewModel.addresses.length,
                      itemBuilder: (context, index) {
                        final address = viewModel.addresses[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.pink),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${address.name}${address.isDefault ? ' Default' : ''}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text('${address.street}, ${address.city}, ${address.state} ${address.zip}'),
                              Text(address.country),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _editAddress(context, address),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 4),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  GestureDetector(
                                    onTap: () => viewModel.deleteAddress(address.id),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete),
                                        SizedBox(width: 4),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      },
                    ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addAddress(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 200, height: 20, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: double.infinity, height: 16, color: Colors.white),
                const SizedBox(height: 4),
                Container(width: 100, height: 16, color: Colors.white),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(width: 80, height: 20, color: Colors.white),
                    const SizedBox(width: 32),
                    Container(width: 80, height: 20, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addAddress(BuildContext context) async {
    final viewModel = Provider.of<AddressViewModel>(context, listen: false);
    final newAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressFormScreen()),
    );
    if (newAddress != null) {
      viewModel.addAddress(newAddress);
    }
  }

  void _editAddress(BuildContext context, Address address) async {
    final viewModel = Provider.of<AddressViewModel>(context, listen: false);
    final updatedAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddressFormScreen(address: address)),
    );
    if (updatedAddress != null) {
      viewModel.updateAddress(updatedAddress);
    }
  }
}