import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rosegoldsmith/services/item_service.dart';
import 'package:rosegoldsmith/screens/item_form_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const ProductDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['itemName'] ?? 'Product Details'),
        actions: [
          IconButton(
            tooltip: 'Edit item',
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final edited = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ItemFormScreen(item: item)),
              );
              if (!context.mounted) return;
              if (edited == true) Navigator.pop(context, true);
            },
          ),
          IconButton(
            tooltip: 'Delete item',
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Item'),
                  content: const Text('Are you sure you want to delete this item?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  await ItemService.deleteItem(item['itemCode']);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted')));
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                }
              }
            },
          ),
        ],
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Center(
              child: Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Hero(
                  tag: 'item-image-${item['itemCode']}',
                  child: item['imageUrl'] != null && item['imageUrl'] != ''
                      ? CachedNetworkImage(
                          imageUrl: item['imageUrl'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                        )
                      : const Center(child: Icon(Icons.image, size: 100, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Basic Info
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['itemName'] ?? '',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Code: ${item['itemCode'] ?? ''}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['description'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Category & Type
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category & Type',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Category: ${item['category'] ?? ''}'),
                        ),
                        Expanded(
                          child: Text('Metal Type: ${item['metalType'] ?? ''}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Karat: ${item['karat'] ?? ''}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Specifications
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Specifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Weight: ${item['weight'] ?? ''} g'),
                        ),
                        Expanded(
                          child: Text('Length: ${item['length'] ?? ''} mm'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Size: ${item['size'] ?? ''}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Pricing
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pricing',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Price: ₱${item['price'] ?? ''}'),
                        ),
                        Expanded(
                          child: Text('Supplier Price: ₱${item['supplierPrice'] ?? ''}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Supplier & Stock
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Supplier & Stock',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('Supplier: ${item['supplier'] ?? ''}'),
                    const SizedBox(height: 8),
                    Text('Stock Quantity: ${item['stockQuantity'] ?? ''}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Additional Details
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('Date Added: ${item['dateAdded'] ?? ''}'),
                    const SizedBox(height: 8),
                    Text('Remarks: ${item['remarks'] ?? ''}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {'addToCart': true, 'item': item});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}