class Product {
  final int id;
  final String title;
  final String image;
  final double price;
  final double rating;
  final String category;   // Add the category field
  final String description; // Add the description field

  Product({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
    required this.category,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      price: json['price'].toDouble(),
      rating: json['rating']['rate'].toDouble(),
      category: json['category'],       // Parse the category
      description: json['description'], // Parse the description
    );
  }
}
