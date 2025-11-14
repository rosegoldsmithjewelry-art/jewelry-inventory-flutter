import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onAdd;

  const ItemCard({super.key, required this.item, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final price = item['price']?.toString() ?? '';
    final name = item['itemName'] ?? '';
    final stock = item['stockQuantity']?.toString() ?? '0';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item['imageUrl'] != null && item['imageUrl'] != ''
                            ? CachedNetworkImage(
                                imageUrl: item['imageUrl'],
                                width: 84,
                                height: 84,
                                fit: BoxFit.cover,
                              )
                      : Container(
                          width: 72,
                          height: 72,
                          color: Colors.grey[900],
                          child: const Icon(Icons.image, size: 32, color: Colors.grey),
                        ),
                ),
                if ((item['stockQuantity'] ?? 0) <= 2)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                      child: const Text('LOW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('Stock: $stock', style: const TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Text('₱$price', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                minimumSize: const Size(64, 44),
              ),
              child: const Text('Add', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
