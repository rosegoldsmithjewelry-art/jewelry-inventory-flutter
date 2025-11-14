import 'package:flutter/material.dart';
import 'package:rosegoldsmith/services/item_service.dart';
import 'package:rosegoldsmith/screens/item_form_screen.dart';
import 'package:rosegoldsmith/screens/pos_screen.dart';
import 'package:rosegoldsmith/screens/product_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  List items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() => loading = true);
    items = await ItemService.getItems();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/rosegoldsmith.png',
              width: 36,
              height: 36,
            ),
            const SizedBox(width: 12),
            const Text('Jewelry Inventory'),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadItems,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: item['imageUrl'] != null && item['imageUrl'] != ''
                                  ? Hero(
                                      tag: 'item-image-${item['itemCode']}',
                                      child: CachedNetworkImage(
                                        imageUrl: item['imageUrl'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                      ),
                                    )
                                  : Hero(
                                      tag: 'item-image-${item['itemCode']}',
                                      child: Container(
                                        color: Colors.grey[200],
                                        child: const Center(child: Icon(Icons.image, size: 50)),
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['itemName'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₱${item['price']}',
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stock: ${item['stockQuantity'] ?? 0}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailScreen(item: item),
                                      ),
                                    );
                                    if (result == true) {
                                      loadItems();
                                    } else if (result is Map && result['addToCart'] == true) {
                                      // Switch to POS tab with item
                                      // For now, navigate to POS
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => PosScreen(initialItem: result['item'])),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.visibility),
                                  label: const Text('View'),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      final edited = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ItemFormScreen(item: item),
                                        ),
                                      );
                                      if (edited == true) loadItems();
                                    } else if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Item'),
                                          content: const Text('Are you sure you want to delete this item?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (!mounted) return;
                                      if (confirm == true) {
                                        if (!mounted) return;
                                        try {
                                          await ItemService.deleteItem(item['itemCode']);
                                          loadItems();
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Failed to delete: $e')),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ItemFormScreen(),
            ),
          );
          if (added == true) loadItems();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
