import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import 'package:flutter/services.dart'; // Import to change system UI style

class ProductDetailPage extends StatefulWidget {
  final int productId;

  ProductDetailPage({required this.productId});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<Product> product;
  bool isFavorite = false; // To track the heart icon status

  @override
  void initState() {
    super.initState();
    product = fetchProductDetails(widget.productId);

    // Change status bar appearance here
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Set the status bar to white
      statusBarIconBrightness: Brightness.dark, // Dark icons (for good contrast)
      statusBarBrightness: Brightness.light, // For iOS (light status bar)
    ));
  }

  Future<Product> fetchProductDetails(int id) async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products/$id'));
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar background color
        elevation: 0, // No shadow for AppBar
        title: Text(
          'Product Details',
          style: TextStyle(
            color: Colors.deepPurple, // Text color in the AppBar
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.deepPurple, // Icon color for the back button
          ),
          onPressed: () {
            Navigator.pop(context); // Back action
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: product,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitCircle(
                color: Colors.deepPurpleAccent,
                size: 30.0,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final product = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImageCard(product.image),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price}',
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Merriweather',
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Rating: ${product.rating.toString()} ⭐',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Merriweather',
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      product.title,
                      style: TextStyle(
                        fontFamily: 'Merriweather',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Category :",
                          style: TextStyle(
                            fontFamily: 'Merriweather',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            product.category.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Merriweather',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(child: _buildActionButton()),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProductImageCard(String imageUrl) {
    return Card(
      elevation: 4.0,
      child: ClipRRect(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          height: 300,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(child: Icon(Icons.error, color: Colors.red));
          },
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: 300,
      child: ElevatedButton(
        onPressed: () {
          print('Product added to cart');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Add to Cart',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
