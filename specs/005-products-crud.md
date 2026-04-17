# SPEC 005 — Módulo de Productos (CRUD offline-first)

## Contexto
Flutter 3.41, Drift 2.20, Riverpod 2.6, proyecto POSI.
Directorio raíz: `/Users/sebastian-buitrago/Documents/Yo/POSI/POSI-Frontend`

## CRÍTICO — lo que ya existe y NO se debe tocar
- `lib/core/database/tables/products_table.dart` — tabla YA creada, NO modificar
- `lib/core/database/tables/categories_table.dart` — tabla YA creada, NO modificar
- `lib/core/database/app_database.dart` — se modifica SOLO en Task 5.2 para agregar dao
- `lib/core/database/sync_mixin.dart` — ya existe `SyncStatus` enum aquí
- Generated type de productos: `ProductsTableData`
- Generated type de categorías: `CategoriesTableData`
- Rutas `/products` y `/products/:id` ya existen en `AppRoutes`

## Patrón de providers establecido (seguir exactamente)
- Estado complejo → `sealed class` + `StateNotifierProvider`
- Streams reactivos de DB → `StreamProvider`
- Estado simple → `StateProvider`
- Acceder a DB → `ref.watch(databaseProvider)` (ya existe en `lib/core/database/database_provider.dart`)
- Acceder a usuario autenticado → `ref.watch(authProvider)` (ya existe, cast a `AuthAuthenticated`)

---

## TASK 5.1 — Entidad dominio + mapper

### `lib/features/products/domain/entities/product.dart`
```dart
import '../../../../core/database/sync_mixin.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.tenantId,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.sku,
    this.barcode,
    this.cost,
    this.minStock = 0,
    this.categoryId,
    this.isActive = true,
  });

  final int id;
  final String? remoteId;
  final String tenantId;
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final double? cost;
  final int stock;
  final int minStock;
  final int? categoryId;
  final bool isActive;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLowStock => stock <= minStock;
  double? get margin => cost != null && cost! > 0 ? ((price - cost!) / price) * 100 : null;

  Product copyWith({
    int? id,
    String? remoteId,
    String? tenantId,
    String? name,
    String? sku,
    String? barcode,
    double? price,
    double? cost,
    int? stock,
    int? minStock,
    int? categoryId,
    bool? isActive,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Product(id: $id, name: $name, price: $price, stock: $stock)';
}
```

### `lib/features/products/domain/mappers/product_mapper.dart`
```dart
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/sync_mixin.dart';
import '../entities/product.dart';

extension ProductMapper on ProductsTableData {
  Product toDomain() => Product(
        id: id,
        remoteId: remoteId,
        tenantId: tenantId,
        name: name,
        sku: sku,
        barcode: barcode,
        price: price,
        cost: cost,
        stock: stock,
        minStock: minStock,
        categoryId: categoryId,
        isActive: isActive,
        syncStatus: syncStatus,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension ProductToCompanion on Product {
  ProductsTableCompanion toCompanion() => ProductsTableCompanion(
        remoteId: Value(remoteId),
        tenantId: Value(tenantId),
        name: Value(name),
        sku: Value(sku),
        barcode: Value(barcode),
        price: Value(price),
        cost: Value(cost),
        stock: Value(stock),
        minStock: Value(minStock),
        categoryId: Value(categoryId),
        isActive: Value(isActive),
        syncStatus: Value(syncStatus),
        updatedAt: Value(DateTime.now()),
      );
}
```

**Validación:** 2 archivos creados, sin imports rotos.

---

## TASK 5.2 — DAO + actualizar AppDatabase

### `lib/features/products/data/daos/products_dao.dart`
```dart
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/sync_mixin.dart';
import '../../../../core/database/tables/products_table.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [ProductsTable])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(super.db);

  // Reactive stream — auto-actualiza la UI cuando cambia la DB
  Stream<List<ProductsTableData>> watchAll(String tenantId) =>
      (select(productsTable)
            ..where((t) => t.tenantId.equals(tenantId))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Stream<List<ProductsTableData>> watchSearch(
          String query, String tenantId) =>
      (select(productsTable)
            ..where((t) =>
                t.tenantId.equals(tenantId) &
                (t.name.like('%$query%') | t.barcode.like('%$query%')))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<ProductsTableData?> getById(int id) =>
      (select(productsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<ProductsTableData?> getByBarcode(
          String barcode, String tenantId) =>
      (select(productsTable)
            ..where((t) =>
                t.barcode.equals(barcode) & t.tenantId.equals(tenantId)))
          .getSingleOrNull();

  Future<int> upsertProduct(ProductsTableCompanion product) =>
      into(productsTable).insertOnConflictUpdate(product);

  Future<int> deleteById(int id) =>
      (delete(productsTable)..where((t) => t.id.equals(id))).go();

  Future<List<ProductsTableData>> getPendingSync(String tenantId) =>
      (select(productsTable)
            ..where((t) =>
                t.tenantId.equals(tenantId) &
                t.syncStatus.equals(SyncStatus.pending.index)))
          .get();
}
```

### Actualizar `lib/core/database/app_database.dart`
Reemplazar el contenido COMPLETO con:
```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/sales_table.dart';
import 'tables/sale_items_table.dart';
import '../../features/products/data/daos/products_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CategoriesTable,
    ProductsTable,
    SalesTable,
    SaleItemsTable,
  ],
  daos: [ProductsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'posi.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
```

**IMPORTANTE:** Después de crear estos 2 archivos, ejecutar en el directorio del proyecto:
```
flutter pub run build_runner build --delete-conflicting-outputs
```
Esto regenera `app_database.g.dart` y crea `products_dao.g.dart`.

**Validación:** `products_dao.g.dart` existe en `lib/features/products/data/daos/`.

---

## TASK 5.3 — Repository (interfaz + implementación local)

### `lib/features/products/domain/repositories/product_repository.dart`
```dart
import '../entities/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchAll(String tenantId);
  Stream<List<Product>> watchSearch(String query, String tenantId);
  Future<Product?> getById(int id);
  Future<Product?> getByBarcode(String barcode, String tenantId);
  Future<int> create(Product product);
  Future<int> update(Product product);
  Future<int> delete(int id);
  Future<List<Product>> getPendingSync(String tenantId);
}
```

### `lib/features/products/data/repositories/local_product_repository.dart`
```dart
import 'package:drift/drift.dart';
import '../../../../core/database/sync_mixin.dart';
import '../../domain/entities/product.dart';
import '../../domain/mappers/product_mapper.dart';
import '../../domain/repositories/product_repository.dart';
import '../daos/products_dao.dart';

class LocalProductRepository implements ProductRepository {
  const LocalProductRepository(this._dao);

  final ProductsDao _dao;

  @override
  Stream<List<Product>> watchAll(String tenantId) =>
      _dao.watchAll(tenantId).map((rows) => rows.map((r) => r.toDomain()).toList());

  @override
  Stream<List<Product>> watchSearch(String query, String tenantId) =>
      _dao.watchSearch(query, tenantId).map((rows) => rows.map((r) => r.toDomain()).toList());

  @override
  Future<Product?> getById(int id) async {
    final row = await _dao.getById(id);
    return row?.toDomain();
  }

  @override
  Future<Product?> getByBarcode(String barcode, String tenantId) async {
    final row = await _dao.getByBarcode(barcode, tenantId);
    return row?.toDomain();
  }

  @override
  Future<int> create(Product product) =>
      _dao.upsertProduct(product.copyWith(syncStatus: SyncStatus.pending).toCompanion());

  @override
  Future<int> update(Product product) =>
      _dao.upsertProduct(product.copyWith(syncStatus: SyncStatus.pending).toCompanion());

  @override
  Future<int> delete(int id) => _dao.deleteById(id);

  @override
  Future<List<Product>> getPendingSync(String tenantId) async {
    final rows = await _dao.getPendingSync(tenantId);
    return rows.map((r) => r.toDomain()).toList();
  }
}
```

### `lib/features/products/data/repositories/product_repository_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../domain/repositories/product_repository.dart';
import 'local_product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalProductRepository(db.productsDao);
});
```

**Validación:** 3 archivos creados.

---

## TASK 5.4 — Providers de productos

### `lib/features/products/presentation/providers/products_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/product_repository_provider.dart';
import '../../domain/entities/product.dart';

// Query de búsqueda actual
final productSearchQueryProvider = StateProvider<String>((ref) => '');

// Stream reactivo — se actualiza solo cuando cambia la DB
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return const Stream.empty();

  final query = ref.watch(productSearchQueryProvider);
  final repo = ref.watch(productRepositoryProvider);

  if (query.trim().isEmpty) {
    return repo.watchAll(auth.user.tenantId);
  }
  return repo.watchSearch(query.trim(), auth.user.tenantId);
});

// Estado para operaciones CRUD (crear/editar/eliminar)
sealed class ProductFormState {
  const ProductFormState();
}

class ProductFormIdle extends ProductFormState {
  const ProductFormIdle();
}

class ProductFormLoading extends ProductFormState {
  const ProductFormLoading();
}

class ProductFormSuccess extends ProductFormState {
  const ProductFormSuccess(this.product);
  final Product product;
}

class ProductFormError extends ProductFormState {
  const ProductFormError(this.message);
  final String message;
}

final productFormProvider =
    StateNotifierProvider.autoDispose<ProductFormNotifier, ProductFormState>(
        (ref) {
  return ProductFormNotifier(ref);
});

class ProductFormNotifier extends StateNotifier<ProductFormState> {
  ProductFormNotifier(this._ref) : super(const ProductFormIdle());

  final Ref _ref;

  Future<void> save({
    required String name,
    required double price,
    required int stock,
    required String tenantId,
    int? id,
    String? barcode,
    String? sku,
    double? cost,
    int? categoryId,
    bool isActive = true,
  }) async {
    state = const ProductFormLoading();
    try {
      final repo = _ref.read(productRepositoryProvider);
      final now = DateTime.now();

      final product = Product(
        id: id ?? 0,
        name: name,
        price: price,
        stock: stock,
        tenantId: tenantId,
        barcode: barcode,
        sku: sku,
        cost: cost,
        categoryId: categoryId,
        isActive: isActive,
        syncStatus: SyncStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      if (id != null) {
        await repo.update(product);
      } else {
        await repo.create(product);
      }
      state = ProductFormSuccess(product);
    } on Exception catch (e) {
      state = ProductFormError(e.toString());
    }
  }

  Future<void> delete(int id) async {
    state = const ProductFormLoading();
    try {
      await _ref.read(productRepositoryProvider).delete(id);
      state = const ProductFormIdle();
    } on Exception catch (e) {
      state = ProductFormError(e.toString());
    }
  }
}
```

Importar `SyncStatus` en este archivo:
`import '../../../../core/database/sync_mixin.dart';`

**Validación:** archivo creado.

---

## TASK 5.5 — Widgets compartidos

### `lib/shared/widgets/product_card.dart`
```dart
import 'package:flutter/material.dart';
import '../../features/products/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono / stock badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: product.isLowStock
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: product.isLowStock
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (product.barcode != null)
                      Text(product.barcode!,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StockBadge(stock: product.stock, isLow: product.isLowStock),
                        const SizedBox(width: 8),
                        if (!product.isActive)
                          _Badge(label: 'Inactivo', color: const Color(0xFF6B7280)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B82F6)),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Color(0xFFEF4444)),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock, required this.isLow});
  final int stock;
  final bool isLow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isLow ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Stock: $stock',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isLow ? const Color(0xFFD97706) : const Color(0xFF059669),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: color)),
    );
  }
}
```

### `lib/shared/widgets/empty_state.dart`
```dart
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: const Color(0xFFD1D5DB)),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: const Color(0xFF6B7280)),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: const Color(0xFF9CA3AF)),
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
```

**Validación:** 2 archivos creados en `lib/shared/widgets/`.

---

## TASK 5.6 — ProductListPage

### `lib/features/products/presentation/pages/product_list_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/product_card.dart';
import '../providers/products_provider.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar por nombre o código...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(productSearchQueryProvider.notifier).state = '';
                    },
                  ),
              ],
              onChanged: (value) =>
                  ref.read(productSearchQueryProvider.notifier).state = value,
            ),
          ),
        ),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) {
          if (products.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Sin productos',
              subtitle: _searchController.text.isNotEmpty
                  ? 'No hay resultados para "${_searchController.text}"'
                  : 'Agrega tu primer producto con el botón +',
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(productsStreamProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ProductCard(
                    product: product,
                    onTap: () => context.push(
                      AppRoutes.productDetail
                          .replaceAll(':id', '${product.id}'),
                    ),
                    onDelete: () => _confirmDelete(context, product.id, product.name),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.productDetail.replaceAll(':id', 'new')),
        icon: const Icon(Icons.add),
        label: const Text('Producto'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "$name"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(productFormProvider.notifier).delete(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
```

**Validación:** archivo creado.

---

## TASK 5.7 — ProductFormPage + actualizar router en main.dart

### `lib/features/products/presentation/pages/product_form_page.dart`
```dart
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
```

### Actualizar `lib/main.dart` — agregar rutas de productos
En el `GoRouter.routes`, reemplazar las dos rutas de productos placeholder:
```dart
// REEMPLAZAR estas líneas en main.dart:
GoRoute(
  path: AppRoutes.products,
  builder: (context, state) => const _PlaceholderPage('Productos'),
),

// CON:
GoRoute(
  path: AppRoutes.products,
  builder: (context, state) => const ProductListPage(),
),
GoRoute(
  path: AppRoutes.productDetail,
  builder: (context, state) {
    final id = state.pathParameters['id'];
    return ProductFormPage(productId: id);
  },
),
```

Agregar imports en `main.dart`:
```dart
import 'features/products/presentation/pages/product_list_page.dart';
import 'features/products/presentation/pages/product_form_page.dart';
```

**Validación final:** ejecutar `flutter analyze` — debe retornar "No issues found".

---

## Estructura final esperada
```
lib/
  features/
    products/
      data/
        daos/
          products_dao.dart
          products_dao.g.dart         ← generado
        repositories/
          local_product_repository.dart
          product_repository_provider.dart
      domain/
        entities/
          product.dart
        mappers/
          product_mapper.dart
        repositories/
          product_repository.dart
      presentation/
        pages/
          product_list_page.dart
          product_form_page.dart
        providers/
          products_provider.dart
  shared/
    widgets/
      product_card.dart
      empty_state.dart
```

## Notas para regenerar código Drift
Después de Task 5.2, ejecutar:
```
flutter pub run build_runner build --delete-conflicting-outputs
```
Esto regenera `app_database.g.dart` con el nuevo DAO y crea `products_dao.g.dart`.
