import 'package:flutter/material.dart';
import 'package:rosegoldsmith/services/item_service.dart';
import 'package:rosegoldsmith/widgets/item_card.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf;
import 'package:share_plus/share_plus.dart';
import 'package:rosegoldsmith/screens/sales_history_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import 'package:rosegoldsmith/screens/checkout_screen.dart';

class PosScreen extends StatefulWidget {
  final Map<String, dynamic>? initialItem;
  const PosScreen({super.key, this.initialItem});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List items = [];
  List displayedItems = [];
  List<Map<String, dynamic>> cart = [];
  bool loading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadItems();
    if (widget.initialItem != null) {
      // add initial item to cart after first frame
      Future.microtask(() => addToCart(widget.initialItem!));
    }
  }

  Future<void> loadItems() async {
    setState(() => loading = true);
    try {
      items = await ItemService.getItems();
      displayedItems = List.from(items);
    } catch (e) {
      // ignore for now, show empty list
      items = [];
      displayedItems = [];
    }
    setState(() => loading = false);
  }

  void addToCart(Map<String, dynamic> item) {
    final stock = int.tryParse(item['stockQuantity']?.toString() ?? '0') ?? 0;
    final existingIndex = cart.indexWhere((cartItem) => cartItem['itemCode'] == item['itemCode']);
    if (existingIndex != -1) {
      final existing = cart[existingIndex];
      if (existing['quantity'] + 1 > stock) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough stock')));
        return;
      }
      setState(() => existing['quantity'] += 1);
    } else {
      if (stock <= 0) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item out of stock')));
        return;
      }
      setState(() {
        cart.add({
          ...item,
          'quantity': 1,
        });
      });
    }
  }

  void removeFromCart(String itemCode) {
    setState(() {
      cart.removeWhere((item) => item['itemCode'] == itemCode);
    });
  }

  void updateQuantity(String itemCode, int quantity) {
    if (quantity <= 0) {
      removeFromCart(itemCode);
      return;
    }
    final item = cart.firstWhere((item) => item['itemCode'] == itemCode);
    final stock = int.tryParse(item['stockQuantity']?.toString() ?? '0') ?? 0;
    if (quantity > stock) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough stock')));
      return;
    }
    setState(() {
      item['quantity'] = quantity;
    });
  }

  double get total => cart.fold(0.0, (sum, item) => sum + (double.parse(item['price'].toString()) * item['quantity']));

  void _showReceiptPreview(String paymentMethod) {
    final now = DateTime.now();
    final buffer = StringBuffer();
    buffer.writeln('Rosegoldsmith Receipt');
    buffer.writeln('Date: ${now.toIso8601String()}');
    buffer.writeln('Payment: $paymentMethod');
    buffer.writeln('-------------------------');
    for (var it in cart) {
      buffer.writeln('${it['itemName']} x${it['quantity']}  ₱${(double.parse(it['price'].toString()) * it['quantity']).toStringAsFixed(2)}');
    }
    buffer.writeln('-------------------------');
    buffer.writeln('TOTAL: ₱${total.toStringAsFixed(2)}');

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receipt Preview'),
        content: SingleChildScrollView(child: Text(buffer.toString())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _exportPdfAndShare(paymentMethod);
            },
            child: const Text('Export PDF / Share'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt copied to clipboard (simulated)')));
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdfAndShare(String paymentMethod) async {
    final doc = pw.Document();
    final now = DateTime.now();
    final orderId = 'RGS-${now.toUtc().millisecondsSinceEpoch}';

    doc.addPage(
      pw.Page(
        pageFormat: pdf.PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Rosegoldsmith', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('Order: $orderId', style: pw.TextStyle(fontSize: 10)),
              pw.Text('Date: ${now.toLocal().toString()}', style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 6),
              pw.Text('Payment: $paymentMethod', style: pw.TextStyle(fontSize: 12)),
              pw.Divider(),
              pw.Column(
                children: cart.map((it) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text('${it['itemName']} x${it['quantity']}', style: pw.TextStyle(fontSize: 10))),
                    pw.Text('₱${(double.parse(it['price'].toString()) * it['quantity']).toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10)),
                  ],
                )).toList(),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text('₱${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text('Thank you for your purchase!', style: pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );

    final bytes = await doc.save();
    final fileName = 'receipt_${orderId}_${now.toIso8601String()}.pdf';
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      final xfile = XFile(file.path);
      await Share.shareXFiles([xfile], text: 'Rosegoldsmith Receipt');

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Receipt saved to ${file.path} and share sheet opened')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save/share PDF: $e')));
    }
  }

  void checkout() async {
    if (cart.isEmpty) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CheckoutScreen(cart: cart, total: total)),
    );
    if (result == true) {
      setState(() => cart.clear());
      await loadItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Sales History',
            icon: const Icon(Icons.receipt_long),
            onPressed: () async {
              if (!mounted) return;
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesHistoryScreen()));
            },
          ),
          IconButton(
            tooltip: 'Scan / Enter Item Code',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final code = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Enter Item Code'),
                  content: TextField(autofocus: true, decoration: const InputDecoration(hintText: 'Item code')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('OK')),
                  ],
                ),
              );
              if (!mounted) return;
              if (code != null && code.isNotEmpty) {
                final found = items.firstWhere((it) => it['itemCode'] == code, orElse: () => null);
                if (found != null) {
                  addToCart(found);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item not found')));
                }
              }
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 800;
                return narrow
                    ? Column(
                        children: [
                          Expanded(child: _itemsColumn()),
                          SizedBox(height: 360, child: _cartColumn()),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(flex: 2, child: _itemsColumn()),
                          Expanded(flex: 1, child: _cartColumn()),
                        ],
                      );
              },
            ),
    );
  }

  Widget _itemsColumn() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Available Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: searchController,
                decoration: const InputDecoration(hintText: 'Search items by name or category', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                onChanged: (value) {
                  final q = value.toLowerCase();
                  setState(() {
                    displayedItems = items.where((it) {
                      final name = (it['itemName'] ?? '').toString().toLowerCase();
                      final cat = (it['category'] ?? '').toString().toLowerCase();
                      return name.contains(q) || cat.contains(q);
                    }).toList();
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.8,
            ),
            itemCount: displayedItems.length,
            itemBuilder: (context, i) {
              final item = displayedItems[i];
              return ItemCard(item: item, onAdd: () => addToCart(item));
            },
          ),
        ),
      ],
    );
  }

  Widget _cartColumn() {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(children: [
                  IconButton(
                    tooltip: 'Clear cart',
                    onPressed: () => setState(() => cart.clear()),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ]),
              ],
            ),
          ),
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text('Cart is empty'))
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, i) {
                      final item = cart[i];
                      final stock = int.tryParse(item['stockQuantity']?.toString() ?? '0') ?? 0;
                      final over = item['quantity'] > stock;
                      return ListTile(
                        leading: item['imageUrl'] != null && item['imageUrl'] != ''
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(item['imageUrl'], width: 48, height: 48, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.image, size: 48),
                        title: Text(item['itemName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('₱${item['price']} x ${item['quantity']}'),
                            over ? const Text('Quantity exceeds stock!', style: TextStyle(color: Colors.red)) : const SizedBox(),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.remove), onPressed: () => updateQuantity(item['itemCode'], item['quantity'] - 1)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(6)),
                              child: Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            IconButton(icon: const Icon(Icons.add), onPressed: () => updateQuantity(item['itemCode'], item['quantity'] + 1)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('₱${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
