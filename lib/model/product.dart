class Product {
  final int id;
  final String name;
  final String category;
  final double cost;
  final int discountPct;
  final double rating;
  final String ecom;
  final String ecomLogo;
  final String imageUrl;
  final String websiteUrl;
  final bool inStock;

  Product({
    this.id,
    this.name,
    this.category,
    this.cost,
    this.discountPct,
    this.rating,
    this.ecom,
    this.ecomLogo,
    this.imageUrl,
    this.websiteUrl,
    this.inStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
      discountPct: json['discount_pct'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      ecom: json['ecom'] ?? '',
      ecomLogo: json['ecom_logo'] ?? '',
      imageUrl: json['image_url'] ?? '',
      websiteUrl: json['website_url'] ?? '',
      inStock: json['in_stock'] ?? false,
    );
  }
}
