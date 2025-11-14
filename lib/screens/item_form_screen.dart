import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rosegoldsmith/services/item_service.dart';
import 'package:rosegoldsmith/widgets/item_code_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ItemFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;

  const ItemFormScreen({super.key, this.item});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> form = {};
  File? imageFile;
  bool uploading = false;

  // Controllers for pre-filling
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController supplierPriceController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController stockQuantityController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController soldPriceController = TextEditingController();

  // Dropdown options
  static const List<String> categories = ['ME', 'LE', 'HE', 'MN', 'LN', 'KN', 'MB', 'LB', 'KB', 'A'];

  static const List<String> metalTypes = ['SILVER', 'GOLD', 'STAINLESS'];

  static const List<String> karats = ['92.5 ITALY SILVER', '22 KARAT GOLD', '18 KARAT GOLD', '10 KARAT GOLD', 'FANCY GOLD'];

  String? selectedCategory;
  String? selectedMetalType;
  String? selectedKarat;
  DateTime? selectedDate;
  String generatedCode = '';
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      isEditing = true;
      // Pre-fill fields
      generatedCode = widget.item!['itemCode'] ?? '';
      itemNameController.text = widget.item!['itemName'] ?? '';
      descriptionController.text = widget.item!['description'] ?? '';
      selectedCategory = widget.item!['category'];
      selectedMetalType = widget.item!['metalType'];
      selectedKarat = widget.item!['karat'];
      weightController.text = widget.item!['weight']?.toString() ?? '';
      lengthController.text = widget.item!['length']?.toString() ?? '';
      sizeController.text = widget.item!['size'] ?? '';
      priceController.text = widget.item!['price']?.toString() ?? '';
      supplierPriceController.text = widget.item!['supplierPrice']?.toString() ?? '';
      supplierController.text = widget.item!['supplier'] ?? '';
      stockQuantityController.text = widget.item!['stockQuantity']?.toString() ?? '';
      remarksController.text = widget.item!['remarks'] ?? '';
      soldPriceController.text = widget.item!['soldPrice']?.toString() ?? '';
      form['imageUrl'] = widget.item!['imageUrl'];
      if (widget.item!['dateAdded'] != null) {
        selectedDate = DateTime.parse(widget.item!['dateAdded']);
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => imageFile = File(picked.path));
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => uploading = true);
    String? imageUrl = form['imageUrl']; // Keep existing if editing
    if (imageFile != null) {
      debugPrint('Starting image upload...');
      imageUrl = await ItemService.uploadImage(imageFile!);
      debugPrint('Image URL: $imageUrl');
    }
    form['imageUrl'] = imageUrl ?? '';
    form['itemCode'] = generatedCode;
    form['category'] = selectedCategory;
    form['metalType'] = selectedMetalType;
    form['karat'] = selectedKarat;
    form['dateAdded'] = selectedDate?.toIso8601String() ?? '';
    debugPrint('Saving item with data: $form');
    try {
      if (isEditing) {
        await ItemService.updateItem(generatedCode, form);
      } else {
        await ItemService.addItem(form);
      }
      setState(() => uploading = false);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => uploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save item: $e')),
      );
    }
  }

  String _getCategoryName(String code) {
    switch (code) {
      case 'ME': return 'Men Earrings';
      case 'LE': return 'Ladies Earrings';
      case 'HE': return 'Hypo Earrings';
      case 'MN': return 'Mens Necklace';
      case 'LN': return 'Ladies Necklace';
      case 'KN': return 'Kids Necklace';
      case 'MB': return 'Mens Bracelet';
      case 'LB': return 'Ladies Bracelet';
      case 'KB': return 'Kids Bracelet';
      case 'A': return 'Anklet';
      default: return code;
    }
  }

  @override
  void dispose() {
    itemNameController.dispose();
    descriptionController.dispose();
    weightController.dispose();
    lengthController.dispose();
    sizeController.dispose();
    priceController.dispose();
    supplierPriceController.dispose();
    supplierController.dispose();
    stockQuantityController.dispose();
    remarksController.dispose();
    soldPriceController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Jewelry Item' : 'Add Jewelry Item'),
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black,
      ),
      body: uploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section at the top
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'Item Image',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: imageFile != null
                                  ? Image.file(imageFile!, fit: BoxFit.cover)
                                  : (form['imageUrl'] != null && form['imageUrl'].isNotEmpty)
                                      ? CachedNetworkImage(
                                          imageUrl: form['imageUrl'],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => const Center(child: Text('Image load failed')),
                                        )
                                      : const Center(child: Text('No image selected')),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Tooltip(
                                message: 'Upload an image of the item',
                                child: Semantics(
                                  label: 'Upload item image',
                                  button: true,
                                  child: ElevatedButton.icon(
                                    onPressed: pickImage,
                                    icon: const Icon(Icons.image),
                                    label: const Text('Upload Image'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Item Code Section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Item Identification',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            ItemCodeGenerator(
                              onItemCodeChanged: (code) => setState(() => generatedCode = code),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: itemNameController,
                              decoration: const InputDecoration(
                                labelText: 'Item Name',
                                hintText: 'e.g. Rose Gold Hoop',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.label),
                              ),
                              onSaved: (v) => form['itemName'] = v,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                hintText: 'Short description or special notes',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                              onSaved: (v) => form['description'] = v,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category and Type Section
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
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              initialValue: selectedCategory,
                              items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(_getCategoryName(cat)))).toList(),
                              onChanged: (value) => setState(() => selectedCategory = value),
                              validator: (value) => value == null ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Metal Type',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.build),
                              ),
                              initialValue: selectedMetalType,
                              items: metalTypes.map((metal) => DropdownMenuItem(value: metal, child: Text(metal))).toList(),
                              onChanged: (value) => setState(() => selectedMetalType = value),
                              validator: (value) => value == null ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Specifications Section
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
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Karat',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.star),
                              ),
                              initialValue: selectedKarat,
                              items: karats.map((karat) => DropdownMenuItem(value: karat, child: Text(karat))).toList(),
                              onChanged: (value) => setState(() => selectedKarat = value),
                              validator: (value) => value == null ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                    child: TextFormField(
                                    controller: weightController,
                                    decoration: const InputDecoration(
                                      labelText: 'Weight (g)',
                                      hintText: 'e.g. 1.5',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.scale),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onSaved: (v) => form['weight'] = double.tryParse(v ?? ''),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: TextFormField(
                                    controller: lengthController,
                                    decoration: const InputDecoration(
                                      labelText: 'Length (mm)',
                                      hintText: 'Optional - e.g. 25',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.straighten),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onSaved: (v) => form['length'] = double.tryParse(v ?? ''),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: sizeController,
                              decoration: const InputDecoration(
                                labelText: 'Size',
                                hintText: 'e.g. 6.5 (ring size) or mm',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.aspect_ratio),
                              ),
                              onSaved: (v) => form['size'] = v,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Pricing Section
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
                                  child: TextFormField(
                                    controller: priceController,
                                    decoration: const InputDecoration(
                                      labelText: 'Selling Price (₱)',
                                      hintText: 'e.g. 1500.00',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.attach_money),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onSaved: (v) => form['price'] = double.tryParse(v ?? ''),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: supplierPriceController,
                                    decoration: const InputDecoration(
                                      labelText: 'Cost Price (₱)',
                                      hintText: 'Optional',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.business),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onSaved: (v) => form['supplierPrice'] = double.tryParse(v ?? ''),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: soldPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Price Sold (₱)',
                                hintText: 'Optional - price when sold',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.sell),
                              ),
                              keyboardType: TextInputType.number,
                              onSaved: (v) => form['soldPrice'] = double.tryParse(v ?? ''),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Supplier and Stock Section
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
                            TextFormField(
                              controller: supplierController,
                              decoration: const InputDecoration(
                                labelText: 'Supplier',
                                hintText: 'Optional - supplier name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                              onSaved: (v) => form['supplier'] = v,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: stockQuantityController,
                              decoration: const InputDecoration(
                                labelText: 'Stock Quantity',
                                hintText: 'e.g. 10',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.inventory),
                              ),
                              keyboardType: TextInputType.number,
                              onSaved: (v) => form['stockQuantity'] = int.tryParse(v ?? ''),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Date and Remarks Section
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedDate != null
                                        ? '${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.year.toString().substring(2)}'
                                        : 'Select Date Added (mm/dd/yy)',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: pickDate,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFD700),
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text('Pick Date'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: remarksController,
                              decoration: const InputDecoration(
                                labelText: 'Remarks',
                                hintText: 'Short note e.g. reserved for client',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.notes),
                              ),
                              onSaved: (v) => form['remarks'] = v,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save Item', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
