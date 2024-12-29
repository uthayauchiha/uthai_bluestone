import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity package
import 'product_detail_page.dart';
import '../models/product.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> products = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  bool isOffline = false; // Flag to check internet connection
  String errorMessage = ''; // Error message to display when there's an issue

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    fetchProducts();
  }

  // Function to check internet connectivity
  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isOffline = true;
      });
    } else {
      setState(() {
        isOffline = false;
      });
    }
  }

  // Fetch products from API
  Future<void> fetchProducts() async {
    if (isLoading || isOffline) return; // Don't fetch if already loading or offline
    setState(() {
      isLoading = true;
      errorMessage = ''; // Clear any previous error messages
    });

    final url = 'https://fakestoreapi.com/products?limit=10&page=$currentPage';

    try {
      final response = await http.get(Uri.parse(url));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          setState(() {
            products.addAll(data.map((item) => Product.fromJson(item)).toList());
            currentPage++;
            isLoading = false;
            hasMore = data.length == 10; // Only allow loading more if 10 items were returned
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'No products found.';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load products. Please try again later.';
          isOffline = true; // Mark as offline if request fails
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load products. Please try again later.';
        isOffline = true; // Mark as offline if request fails
      });
    }
  }

  // Function to retry fetching products
  Future<void> retryFetch() async {
    await _checkInternetConnection(); // Recheck connectivity
    if (!isOffline) {
      await fetchProducts(); // Retry fetching products if online
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Exclusive Products',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              // Implement search functionality here if needed
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              // Show error or retry if there's no internet
              if (isOffline)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.signal_wifi_off, size: 50, color: Colors.red),
                      SizedBox(height: 10),
                      Text(
                        'No internet connection.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: retryFetch,
                        child: Text('Retry'),
                      ),
                      if (errorMessage.isNotEmpty) ...[
                        SizedBox(height: 10),
                        Text(
                          errorMessage,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // Product Grid
              if (!isOffline && errorMessage.isEmpty)
                Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: products.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == products.length) {
                            if (isLoading) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SpinKitCircle(
                                  color: Colors.transparent,
                                  size: 50.0,
                                ),
                              );
                            }
                            return SizedBox.shrink(); // Placeholder for no more data
                          }

                          final product = products[index];
                          return Card(
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            color: Colors.white,
                            shadowColor: Colors.transparent.withOpacity(0.3),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                        productId: product.id),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 28.0, bottom: 10),
                                          child: SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: Image.network(
                                              product.image,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child: SpinKitCircle(
                                                    color: Colors.deepPurpleAccent,
                                                    size: 30.0,
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Icon(Icons.error,
                                                      color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.deepPurple,
                                              fontFamily: 'Merriweather',
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 11.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '\$${product.price}',
                                                  style: TextStyle(
                                                    color:
                                                        Colors.green.shade700,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      color: Colors
                                                          .orange.shade600,
                                                      size: 14,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      '${product.rating}',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .orange.shade600,
                                                        fontSize: 12,
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
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

              // Center loader while initial data is loading
              if (isLoading && products.isEmpty && !isOffline)
                Center(
                  child: SpinKitCircle(
                    color: Colors.deepPurpleAccent,
                    size: 50.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
