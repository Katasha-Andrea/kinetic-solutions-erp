import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/app_user.dart';
import '../../presentation/widgets/shared_widgets.dart';

class InventoryFormPage extends StatefulWidget {
  final InventoryItem? item;
  const InventoryFormPage({super.key, this.item});
  @override
  State<InventoryFormPage> createState() => _InventoryFormPageState();
}

class _InventoryFormPageState extends State<InventoryFormPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabCtrl;

  // Controllers
  final _skuCtrl          = TextEditingController();
  final _nameCtrl         = TextEditingController();
  final _descCtrl         = TextEditingController();
  final _categoryCtrl     = TextEditingController();
  final _unitPriceCtrl    = TextEditingController();
  final _costPriceCtrl    = TextEditingController();
  final _quantityCtrl     = TextEditingController();
  final _reorderCtrl      = TextEditingController();
  final _supplierCtrl     = TextEditingController();
  final _barcodeCtrl      = TextEditingController();

  bool _isVatable = true;
  bool _loading   = false;
  String? _imagePath;

  bool get _isEdit => widget.item != null;

  static const _categories = [
    'Agriculture','Construction','IT & Electronics','Office Supplies',
    'Furniture','Vehicles','Raw Materials','Finished Goods','Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    if (_isEdit) {
      final i = widget.item!;
      _skuCtrl.text       = i.sku;
      _nameCtrl.text      = i.name;
      _descCtrl.text      = i.description;
      _categoryCtrl.text  = i.category;
      _unitPriceCtrl.text = i.unitPrice.toString();
      _costPriceCtrl.text = i.costPrice.toString();
      _quantityCtrl.text  = i.quantity.toString();
      _reorderCtrl.text   = i.reorderLevel.toString();
      _supplierCtrl.text  = i.supplierName;
      _barcodeCtrl.text   = i.barcode ?? '';
      _isVatable          = i.isVatable;
      _imagePath          = i.imageUrl;
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    for (final c in [_skuCtrl,_nameCtrl,_descCtrl,_categoryCtrl,_unitPriceCtrl,_costPriceCtrl,_quantityCtrl,_reorderCtrl,_supplierCtrl,_barcodeCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final item = InventoryItem(
      id:           _isEdit ? widget.item!.id : LocalDatabase.generateId(),
      sku:          _skuCtrl.text.trim(),
      name:         _nameCtrl.text.trim(),
      description:  _descCtrl.text.trim(),
      category:     _categoryCtrl.text.trim(),
      unitPrice:    double.tryParse(_unitPriceCtrl.text) ?? 0,
      costPrice:    double.tryParse(_costPriceCtrl.text) ?? 0,
      quantity:     int.tryParse(_quantityCtrl.text) ?? 0,
      reorderLevel: int.tryParse(_reorderCtrl.text) ?? 5,
      supplierName: _supplierCtrl.text.trim(),
      isVatable:    _isVatable,
      barcode:      _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim(),
      imageUrl:     _imagePath,
      createdAt:    _isEdit ? widget.item!.createdAt : DateTime.now(),
      updatedAt:    DateTime.now(),
    );

    await LocalDatabase.saveInventoryItem(item);
    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context);
    }
  }

  // ── Barcode scanner ──────────────────────────────────────────────────────
  Future<void> _scanBarcode() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: 400,
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Scan barcode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: MobileScanner(
              onDetect: (capture) {
                final barcode = capture.barcodes.first.rawValue;
                if (barcode != null) {
                  setState(() => _barcodeCtrl.text = barcode);
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ]),
      ),
    );
  }

  // ── Image picker ─────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add item photo'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgColor,
    appBar: AppBar(
      title: Text(_isEdit ? 'Edit item' : 'Add item'),
      bottom: TabBar(
        controller: _tabCtrl,
        tabs: const [
          Tab(text: 'Details'),
          Tab(text: 'Pricing'),
          Tab(text: 'Stock'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : _save,
          child: _loading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
    body: Form(
      key: _formKey,
      child: TabBarView(
        controller: _tabCtrl,
        children: [
          _DetailsTab(
            nameCtrl: _nameCtrl, skuCtrl: _skuCtrl, descCtrl: _descCtrl,
            categoryCtrl: _categoryCtrl, supplierCtrl: _supplierCtrl,
            barcodeCtrl: _barcodeCtrl, categories: _categories,
            imagePath: _imagePath,
            onScanBarcode: _scanBarcode, onPickImage: _pickImage,
          ),
          _PricingTab(
            unitPriceCtrl: _unitPriceCtrl, costPriceCtrl: _costPriceCtrl,
            isVatable: _isVatable,
            onVatableChanged: (v) => setState(() => _isVatable = v),
          ),
          _StockTab(
            quantityCtrl: _quantityCtrl, reorderCtrl: _reorderCtrl,
          ),
        ],
      ),
    ),
  );
}

// ── Tab: Details ─────────────────────────────────────────────────────────────
class _DetailsTab extends StatelessWidget {
  final TextEditingController nameCtrl, skuCtrl, descCtrl, categoryCtrl, supplierCtrl, barcodeCtrl;
  final List<String> categories;
  final String? imagePath;
  final VoidCallback onScanBarcode, onPickImage;

  const _DetailsTab({
    required this.nameCtrl, required this.skuCtrl, required this.descCtrl,
    required this.categoryCtrl, required this.supplierCtrl, required this.barcodeCtrl,
    required this.categories, required this.imagePath,
    required this.onScanBarcode, required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(children: [
      // Photo upload area
      GestureDetector(
        onTap: onPickImage,
        child: Container(
          width: double.infinity, height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor, width: 0.5),
          ),
          child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imagePath!, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, size: 40, color: AppTheme.textMuted))),
              )
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.photo_camera_outlined, size: 36, color: AppTheme.textMuted),
                const SizedBox(height: 8),
                const Text('Tap to add product photo', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 4),
                const Text('Camera or gallery', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ]),
        ),
      ),
      const SizedBox(height: 16),

      _Field(label: 'Item name *', child: TextFormField(
        controller: nameCtrl,
        decoration: const InputDecoration(hintText: 'e.g. Maize Meal 25kg'),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      )),
      const SizedBox(height: 14),
      _Field(label: 'SKU *', child: TextFormField(
        controller: skuCtrl,
        decoration: const InputDecoration(hintText: 'e.g. MM-25KG-001'),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      )),
      const SizedBox(height: 14),
      _Field(label: 'Category *', child: DropdownButtonFormField<String>(
        value: categories.contains(categoryCtrl.text) ? categoryCtrl.text : null,
        decoration: const InputDecoration(hintText: 'Select category'),
        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) => categoryCtrl.text = v ?? '',
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      )),
      const SizedBox(height: 14),
      _Field(label: 'Supplier', child: TextFormField(
        controller: supplierCtrl,
        decoration: const InputDecoration(hintText: 'Supplier name'),
      )),
      const SizedBox(height: 14),
      _Field(
        label: 'Barcode / QR',
        child: Row(children: [
          Expanded(child: TextFormField(
            controller: barcodeCtrl,
            decoration: const InputDecoration(hintText: 'Scan or enter manually'),
          )),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onScanBarcode,
            icon: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryColor),
            tooltip: 'Scan barcode',
          ),
        ]),
      ),
      const SizedBox(height: 14),
      _Field(label: 'Description', child: TextFormField(
        controller: descCtrl,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'Optional description…'),
      )),
    ]),
  );
}

// ── Tab: Pricing ─────────────────────────────────────────────────────────────
class _PricingTab extends StatelessWidget {
  final TextEditingController unitPriceCtrl, costPriceCtrl;
  final bool isVatable;
  final ValueChanged<bool> onVatableChanged;

  const _PricingTab({
    required this.unitPriceCtrl, required this.costPriceCtrl,
    required this.isVatable, required this.onVatableChanged,
  });

  @override
  Widget build(BuildContext context) {
    final unit = double.tryParse(unitPriceCtrl.text) ?? 0;
    final cost = double.tryParse(costPriceCtrl.text) ?? 0;
    final margin = unit > 0 ? ((unit - cost) / unit * 100) : 0.0;
    final vat = isVatable ? unit * AppConstants.vatRate : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        _Field(label: 'Selling price (ZMW) *', child: TextFormField(
          controller: unitPriceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: 'K ', hintText: '0.00'),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        )),
        const SizedBox(height: 14),
        _Field(label: 'Cost price (ZMW) *', child: TextFormField(
          controller: costPriceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: 'K ', hintText: '0.00'),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        )),
        const SizedBox(height: 14),

        // VAT toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor, width: 0.5),
          ),
          child: Row(children: [
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VAT applicable (16%)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Zambia Revenue Authority standard rate', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            )),
            Switch(value: isVatable, onChanged: onVatableChanged, activeColor: AppTheme.primaryColor),
          ]),
        ),
        const SizedBox(height: 20),

        // Calculated summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primary50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          child: Column(children: [
            const Text('Price summary', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 12),
            _PriceLine('Selling price', 'K ${unit.toStringAsFixed(2)}'),
            _PriceLine('Cost price', 'K ${cost.toStringAsFixed(2)}'),
            _PriceLine('Profit margin', '${margin.toStringAsFixed(1)}%', highlight: true),
            _PriceLine('VAT amount', 'K ${vat.toStringAsFixed(2)}'),
            const Divider(height: 16),
            _PriceLine('Price incl. VAT', 'K ${(unit + vat).toStringAsFixed(2)}', bold: true),
          ]),
        ),
      ]),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label, value;
  final bool highlight, bold;
  const _PriceLine(this.label, this.value, {this.highlight = false, this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: bold ? AppTheme.textPrimary : AppTheme.textSecondary))),
      Text(value, style: TextStyle(
        fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        color: highlight ? AppTheme.primaryColor : AppTheme.textPrimary,
      )),
    ]),
  );
}

// ── Tab: Stock ────────────────────────────────────────────────────────────────
class _StockTab extends StatelessWidget {
  final TextEditingController quantityCtrl, reorderCtrl;
  const _StockTab({required this.quantityCtrl, required this.reorderCtrl});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(children: [
      _Field(label: 'Opening quantity *', child: TextFormField(
        controller: quantityCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: '0'),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      )),
      const SizedBox(height: 14),
      _Field(label: 'Reorder level *', child: TextFormField(
        controller: reorderCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: '5', helperText: 'Alert when quantity falls to or below this number'),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      )),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.infoLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.infoColor.withOpacity(0.2)),
        ),
        child: const Row(children: [
          Icon(Icons.info_outline, color: AppTheme.infoColor, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text(
            'Use Stock In / Stock Out from the inventory list to adjust quantities after creation.',
            style: TextStyle(fontSize: 12, color: AppTheme.infoColor),
          )),
        ]),
      ),
    ]),
  );
}

// ── Shared field wrapper ──────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
      const SizedBox(height: 6),
      child,
    ],
  );
}
