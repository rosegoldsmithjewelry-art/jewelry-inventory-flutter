import 'package:flutter/material.dart';

class ItemCodeGenerator extends StatefulWidget {
  final Function(String) onItemCodeChanged;

  const ItemCodeGenerator({super.key, required this.onItemCodeChanged});

  @override
  State<ItemCodeGenerator> createState() => _ItemCodeGeneratorState();
}

class _ItemCodeGeneratorState extends State<ItemCodeGenerator> {
  String? prefix;
  String sequenceNumber = '';
  String itemCode = '';

  final Map<String, String> prefixes = {
    'LR': 'Ladies Ring',
    'MR': 'Men’s Ring',
    'SE': 'Stud Earrings',
    'NK': 'Necklace',
    'BR': 'Bracelet',
  };

  void _updateItemCode() {
    if (prefix != null && sequenceNumber.isNotEmpty) {
      itemCode = '$prefix$sequenceNumber';
    } else {
      itemCode = '';
    }
    widget.onItemCodeChanged(itemCode);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Category Code',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: prefix,
          items: prefixes.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text('${entry.key} - ${entry.value}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              prefix = value;
            });
            _updateItemCode();
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Enter sequence (e.g. 001)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: (value) {
            sequenceNumber = value;
            _updateItemCode();
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'e.g. 001',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        const Text(
          'Generated Item Code',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: itemCode),
          readOnly: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }
}