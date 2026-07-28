import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:home_ideator_app/services/api_service.dart';
import 'package:home_ideator_app/model/product.dart';

class Shop extends StatefulWidget {
  @override
  _ShopState createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Items(),
    );
  }
}

class Items extends StatefulWidget {
  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  Future<List<Product>> getProduct() async {
    final data = await ApiService.getProducts();
    return data.map((json) => Product.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Product>>(
        future: getProduct(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text('Loading....'),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData || snapshot.data.isEmpty) {
            return const Center(child: Text('No products available.'));
          } else {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  final Product item = snapshot.data[index];
                  return Card(
                    child: InkWell(
                        onTap: () async {
                          if (await canLaunch(item.websiteUrl)) {
                            await launch(item.websiteUrl);
                          }
                        },
                        child: Column(
                            children: <Widget>[
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    if (item.imageUrl.isNotEmpty)
                                      Image.network(item.imageUrl, width: 100, height: 100)
                                    else
                                      const SizedBox(width: 100, height: 100, child: Icon(Icons.image)),
                                    Text('Rating: ${item.rating}'),
                                    if (item.ecomLogo.isNotEmpty)
                                      Image.network(item.ecomLogo, width: 50, height: 50)
                                    else
                                      Text(item.ecom),
                                  ]),
                              Text("Rs:${item.cost}"),
                            ])),
                  );
                });
          }
        },
      ),
    );
  }
}
