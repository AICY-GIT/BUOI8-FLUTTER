import 'dart:convert';

import 'package:buoi8/app/data/api.dart';
import 'package:buoi8/app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buoi8/app/page/product/productDetail.dart';
import 'shoppingCart.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _itemsCate = [];
  int selectedCategoryID = 0;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCategories();
    _fetchCartCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for products...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {      
                      },
                    ),
                  ),
                 Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_cart),
                        onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShoppingCartPage()),
                          );  
                        },
                      ),
                      if (_cartCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 10,
                            child: Text(
                              _cartCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  //hien san pham
  Widget _buildProductCard(int index) {
    if (index >= _items.length) {
      return Container();
    }

    Map<String, dynamic> product = _items[index];
    String productName = product['name'];
    double productPrice = (product['price'] as int).toDouble();
    String productImage = product['imageURL'];
    int categoryId = product['categoryID'];

    String categoryName = _getCategoryName(categoryId);

    return GestureDetector(
       onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                child: Image.network(
                  productImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                    SizedBox(height: 4.0),
                  Text(
                    'Category: $categoryName',
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    '\$$productPrice',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 14.0,
                    ),
                  ),
                
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  //lay name tu danh sach category
  String _getCategoryName(int categoryId) {
    Map<String, dynamic>? category = _itemsCate.firstWhere(
      (category) => category['id'] == categoryId,
      orElse: () => <String, dynamic>{},
    );
    return category != null ? category['name'] : 'Unknown';
  }

  Future<void> _fetchProducts() async {
    try {
      User user = User.userEmpty();
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strUser = pref.getString('user')!;
      user = User.fromJson2(jsonDecode(strUser));
      List<Map<String, dynamic>> products =
          await APIRepository().getProList(user.accountId!);
      setState(() {
        _items = products;
      });
    } catch (error) {
      print("Failed to fetch product: $error");
    }
  }
   Future<void> _fetchCartCount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? cartCount = prefs.getInt('cartCount');
      if (cartCount != null) {
        setState(() {
          _cartCount = cartCount;
        });
      }
    } catch (error) {
      print('Failed to fetch cart count: $error');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      User user = User.userEmpty();
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strUser = pref.getString('user')!;
      user = User.fromJson2(jsonDecode(strUser));
      List<Map<String, dynamic>> categories =
          await APIRepository().getCateList(user.accountId!);
      setState(() {
        _itemsCate = categories;
      });
    } catch (error) {
      print("Failed to fetch categories: $error");
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeWidget(),
  ));
}
