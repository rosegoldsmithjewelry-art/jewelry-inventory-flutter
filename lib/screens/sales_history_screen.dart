import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rosegoldsmith/services/item_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  List sales = [];
  bool loading = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  Future<void> loadSales() async {
    setState(() => loading = true);
    sales = await ItemService.getSales();
    setState(() => loading = false);
  }

  List _filteredSales() {
    if (_startDate == null && _endDate == null) return sales;
    return sales.where((s) {
      final date = DateTime.tryParse(s['date'] ?? '') ?? DateTime.now();
      if (_startDate != null && date.isBefore(_startDate!)) return false;
      if (_endDate != null && date.isAfter(_endDate!)) return false;
      return true;
    }).toList();
  }

  Future<void> _exportSalesCsv() async {
    final list = _filteredSales();
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No sales to export')));
      return;
    }
    final buffer = StringBuffer();
    buffer.writeln('date,paymentMethod,total,items');
    for (var s in list) {
      final date = s['date'] ?? '';
      final payment = s['paymentMethod'] ?? '';
      final total = s['total'] ?? 0;
      final items = ((s['items'] as List?) ?? []).map((it) => '${it['itemCode']}|${it['quantity']}').join(';');
      buffer.writeln('"$date","$payment",$total,"$items"');
    }

    try {
      final bytes = buffer.toString().codeUnits;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/sales_export_${DateTime.now().toIso8601String()}.csv');
      await file.writeAsBytes(bytes);
      final xfile = XFile(file.path);
      await Share.shareXFiles([xfile], text: 'Sales export');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to ${file.path}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        actions: [
          IconButton(onPressed: _exportSalesCsv, icon: const Icon(Icons.download)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                            if (picked != null) setState(() => _startDate = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Start Date'),
                            child: Text(_startDate == null ? 'Any' : _startDate!.toLocal().toString().split(' ').first),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(context: context, initialDate: _endDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                            if (picked != null) setState(() => _endDate = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'End Date'),
                            child: Text(_endDate == null ? 'Any' : _endDate!.toLocal().toString().split(' ').first),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: () => setState(() {}), child: const Text('Filter')),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredSales().isEmpty
                      ? const Center(child: Text('No sales'))
                      : ListView.builder(
                          itemCount: _filteredSales().length,
                          itemBuilder: (context, i) {
                            final s = _filteredSales()[i];
                            final date = DateTime.tryParse(s['date'] ?? '') ?? DateTime.now();
                            return ListTile(
                              title: Text('₱${(s['total'] ?? 0).toString()} - ${s['paymentMethod'] ?? ''}'),
                              subtitle: Text('${date.toLocal().toString()}'),
                              onTap: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Sale Details'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Date: ${date.toLocal()}'),
                                        Text('Payment: ${s['paymentMethod'] ?? ''}'),
                                        const SizedBox(height: 8),
                                        const Text('Items:'),
                                        ...((s['items'] as List<dynamic>?) ?? []).map((it) => Text('- ${it['itemName']} x${it['quantity']} @ ${it['price']}')),
                                        const SizedBox(height: 8),
                                        Text('Total: ₱${s['total'] ?? 0}'),
                                      ],
                                    ),
                                  ),
                                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
