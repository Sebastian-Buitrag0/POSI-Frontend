import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/products_provider.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({super.key, this.productId});

  /// null o 'new' → crear. Integer string → editar.
  final String? productId;

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool get _isEditing =>
      widget.productId != null && widget.productId != 'new';
  bool _barcodePrePopulated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_barcodePrePopulated) {
      final barcode = GoRouterState.of(context).uri.queryParameters['barcode'];
      if (barcode != null) {
        _barcodePrePopulated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _formKey.currentState?.fields['barcode']?.didChange(barcode);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(productFormProvider);
    final isSubmitting = formState is ProductFormLoading;

    ref.listen(productFormProvider, (_, next) {
      if (next is ProductFormSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Producto actualizado'
                : 'Producto creado'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
        context.pop();
      }
      if (next is ProductFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.message),
              backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nombre
              FormBuilderTextField(
                name: 'name',
                decoration:
                    const InputDecoration(labelText: 'Nombre del producto *'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                      errorText: 'El nombre es requerido'),
                  FormBuilderValidators.maxLength(200),
                ]),
              ),
              const SizedBox(height: 16),

              // Precio y Costo en fila
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'price',
                      decoration:
                          const InputDecoration(labelText: 'Precio *', prefixText: '\$'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                            errorText: 'Requerido'),
                        FormBuilderValidators.min(0.01,
                            errorText: 'Debe ser > 0'),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'cost',
                      decoration:
                          const InputDecoration(labelText: 'Costo', prefixText: '\$'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stock y Stock mínimo en fila
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'stock',
                      decoration:
                          const InputDecoration(labelText: 'Stock inicial *'),
                      keyboardType: TextInputType.number,
                      initialValue: '0',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                            errorText: 'Requerido'),
                        FormBuilderValidators.min(0,
                            errorText: 'No puede ser negativo'),
                        FormBuilderValidators.integer(),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'minStock',
                      decoration:
                          const InputDecoration(labelText: 'Stock mínimo'),
                      keyboardType: TextInputType.number,
                      initialValue: '0',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // SKU
              FormBuilderTextField(
                name: 'sku',
                decoration: const InputDecoration(labelText: 'SKU'),
              ),
              const SizedBox(height: 16),

              // Barcode con botón escanear
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'barcode',
                      decoration: const InputDecoration(
                          labelText: 'Código de barras'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => _scanBarcode(context),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Escanear'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Toggle activo
              FormBuilderSwitch(
                name: 'isActive',
                title: const Text('Producto activo'),
                initialValue: true,
              ),
              const SizedBox(height: 32),

              // Botones
              ElevatedButton(
                onPressed: isSubmitting ? null : _submit,
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isEditing ? 'Guardar cambios' : 'Crear producto'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final v = _formKey.currentState!.value;
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return;

    ref.read(productFormProvider.notifier).save(
          id: _isEditing ? int.tryParse(widget.productId!) : null,
          name: v['name'] as String,
          price: double.tryParse(v['price'] as String) ?? 0,
          stock: int.tryParse(v['stock'] as String) ?? 0,
          tenantId: auth.user.tenantId,
          sku: v['sku'] as String?,
          barcode: v['barcode'] as String?,
          cost: v['cost'] != null
              ? double.tryParse(v['cost'] as String)
              : null,
          isActive: v['isActive'] as bool? ?? true,
        );
  }

  Future<void> _scanBarcode(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => const _BarcodeScannerSheet(),
    );
    if (result != null && mounted) {
      _formKey.currentState?.fields['barcode']?.didChange(result);
    }
  }
}

class _BarcodeScannerSheet extends StatefulWidget {
  const _BarcodeScannerSheet();

  @override
  State<_BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<_BarcodeScannerSheet> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_scanned) return;
              final barcode = capture.barcodes.firstOrNull?.rawValue;
              if (barcode != null) {
                _scanned = true;
                Navigator.pop(context, barcode);
              }
            },
          ),
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 2)),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
