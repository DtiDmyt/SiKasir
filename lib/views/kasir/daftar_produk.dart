import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:si_kasir/views/kasir/update_produk.dart';
import 'package:si_kasir/views/kasir/create_produk.dart';
import 'package:si_kasir/views/kasir/scan_produk.dart';
import 'package:si_kasir/views/kasir/transaksi.dart';
import 'package:si_kasir/views/kasir/detail_produk.dart';

String formatPrice(double price) {
  return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String productId;
  final double buyPrice;
  final String imageUrl;
  final String barcode;
  final int stock;
  final String category;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.barcode,
    required this.price,
    required this.buyPrice,
    required this.imageUrl,
    required this.productId,
    required this.stock,
    required this.category,
    this.quantity = 0,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      productId: data['productId'] ?? '',
      name: data['namaProduk'] ?? '',
      description: data['deskripsi'] ?? '',
      price: (data['hargaJual'] ?? 0).toDouble(),
      buyPrice: (data['hargaBeli'] ?? 0).toDouble(),
      barcode: data['barcode'] ?? '',
      imageUrl: data['gambarUrl'] ?? '',
      stock: data['stok'] ?? 0,
      category: data['kategori'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'buyPrice': buyPrice,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'stock': stock,
      'category': category,
      'quantity': quantity,
    };
  }
}

class DaftarProdukScreen extends StatefulWidget {
  const DaftarProdukScreen({super.key});

  @override
  _DaftarProdukScreenState createState() => _DaftarProdukScreenState();
}

class _DaftarProdukScreenState extends State<DaftarProdukScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  double totalAmount = 0;
  bool showTotal = false;
  int _currentTabIndex = 0;
  String searchQuery = '';
  Map<String, List<Product>> categoryProducts = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('produk')
          .where('email', isEqualTo: user.email)
          .get();

      Map<String, List<Product>> tempCategories = {};

      for (var doc in querySnapshot.docs) {
        Product product = Product.fromFirestore(doc);
        if (!tempCategories.containsKey(product.category)) {
          tempCategories[product.category] = [];
        }
        tempCategories[product.category]!.add(product);
      }

      setState(() {
        categoryProducts = tempCategories;
      });
    }
  }

  void updateTotal() {
    double total = 0;
    bool hasItems = false;

    categoryProducts.forEach((category, products) {
      for (var product in products) {
        total += product.price * product.quantity;
        if (product.quantity > 0) hasItems = true;
      }
    });

    setState(() {
      totalAmount = total;
      showTotal = hasItems;
    });
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('produk').doc(productId).delete();
      await _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF133E87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari produk kamu di sini',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.black),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.black, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Daftar Produk'),
                Tab(text: 'Pindai Produk'),
              ],
              labelColor: const Color(0xFF133E87),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF133E87),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductList(),
                ScanProdukScreen(
                  onProductScanned: (product) {
                    setState(() {
                      bool productExists = false;

                      categoryProducts.forEach((category, products) {
                        final existingProductIndex =
                            products.indexWhere((p) => p.id == product.id);
                        if (existingProductIndex != -1) {
                          if (products[existingProductIndex].quantity <
                              products[existingProductIndex].stock) {
                            products[existingProductIndex].quantity++;
                            productExists = true;
                          }
                        }
                      });

                      if (!productExists) {
                        bool categoryFound = false;
                        categoryProducts.forEach((category, products) {
                          if (category == product.category) {
                            products.add(product as Product);
                            categoryFound = true;
                          }
                        });

                        if (!categoryFound) {
                          categoryProducts[product.category] = [
                            product as Product
                          ];
                        }
                      }

                      updateTotal();
                    });
                  },
                ),
              ],
            ),
          ),
          if (showTotal)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: Rp${formatPrice(totalAmount)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransaksiScreen(
                            selectedProducts: getSelectedProducts(),
                            totalAmount: totalAmount,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF133E87),
                      foregroundColor: Colors.white,
                      minimumSize: Size(screenWidth * 0.3, 48),
                    ),
                    child: const Text('Bayar'),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: (_currentTabIndex == 0 && !showTotal)
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateProdukScreen(productId: ''),
                  ),
                );
                await _loadProducts();
              },
              backgroundColor: const Color(0xFF133E87),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildProductList() {
    if (categoryProducts.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada produk yang tersedia',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    List<Widget> categoryWidgets = [];
    bool hasProducts = false;

    categoryProducts.forEach((category, products) {
      final filteredProducts = products
          .where((product) =>
              product.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

      if (filteredProducts.isNotEmpty) {
        hasProducts = true;
        categoryWidgets.add(_buildCategoryTitle(category));
        categoryWidgets.add(_buildProductGrid(filteredProducts));
        categoryWidgets.add(const SizedBox(height: 16));
      }
    });

    if (!hasProducts) {
      return const Center(
        child: Text(
          'Tidak ada produk yang tersedia',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categoryWidgets,
        ),
      ),
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final screenWidth = MediaQuery.of(context).size.width;
    String imageUrl = product.imageUrl;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailProdukScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                    child: Image.network(
                      imageUrl,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.stock <= 10
                            ? const Color.fromARGB(255, 238, 198, 195)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Stok: ${product.stock}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: product.stock <= 10
                              ? Colors.red
                              : const Color(0xFF133E87),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _buildImprovedProductMenu(product),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Rp${formatPrice(product.price)}',
                        style: const TextStyle(
                          color: Color(0xFF133E87),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (product.quantity > 0)
                        Container(
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildQuantityButton(
                                Icons.remove,
                                () {
                                  setState(() {
                                    if (product.quantity > 0) {
                                      product.quantity--;
                                      updateTotal();
                                    }
                                  });
                                },
                              ),
                              Text(
                                '${product.quantity}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildQuantityButton(
                                Icons.add,
                                () {
                                  setState(() {
                                    if (product.quantity < product.stock) {
                                      product.quantity++;
                                      updateTotal();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      else if (product.stock == 0)
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Stok Kosong',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                product.quantity = 1;
                                updateTotal();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF133E87),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              minimumSize: Size(screenWidth * 0.3, 32),
                            ),
                            child: const Text('Tambah'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Improved product menu with better styling
  Widget _buildImprovedProductMenu(Product product) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'edit') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateProdukScreen(
                productId: product.id,
              ),
            ),
          );
          await _loadProducts();
        } else if (value == 'delete') {
          // Show improved delete confirmation dialog
          showImprovedDeleteConfirmationDialog(product);
        }
      },
      icon: const Icon(
        Icons.more_vert,
        size: 18,
        color: Color(0xFF133E87),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      offset: const Offset(0, 8),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.blue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Hapus',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Improved delete confirmation dialog
  Future<void> showImprovedDeleteConfirmationDialog(Product product) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Konfirmasi Hapus',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yakin ingin menghapus produk ini?',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tindakan ini tidak dapat dibatalkan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              deleteProduct(product.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF133E87)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: const Color(0xFF133E87)),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  List<Map<String, dynamic>> getSelectedProducts() {
    List<Map<String, dynamic>> selectedProducts = [];
    categoryProducts.forEach((category, products) {
      for (var product in products) {
        if (product.quantity > 0) {
          selectedProducts.add(product.toMap());
        }
      }
    });
    return selectedProducts;
  }
}
