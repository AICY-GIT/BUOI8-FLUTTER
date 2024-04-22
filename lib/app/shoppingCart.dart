import 'dart:convert';
import 'package:buoi8/app/data/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
    _resetCartCount();
  }

  void _resetCartCount() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('cartCount', 0);
    });
  }
  void _resetCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cartItems');
    setState(() {
      _cartItems = [];
    });
  }


  void _fetchCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartItemsJson = prefs.getStringList('cartItems');
    if (cartItemsJson != null) {
      setState(() {
        _cartItems = [];
        Map<String, Map<String, dynamic>> mergedItems = {};

        for (String jsonString in cartItemsJson) {
          Map<String, dynamic> item = json.decode(jsonString);
          String key = '${item['id']}';
          if (mergedItems.containsKey(key)) {
            mergedItems[key]!['quantity'] += item['quantity'];
          } else {
            mergedItems[key] = item;
          }
        }
        _cartItems = mergedItems.values.toList();
      });
    }
  }

  void _placeOrder() {
    List<Map<String, dynamic>> orderList = [];
    for (var item in _cartItems) {
      orderList.add({
        'productID': item['id'],
        'count': item['quantity'],
      });
    }
    String orderJson = json.encode(orderList);
    print(orderJson);
    _createNewOrder(orderJson);
  }
    void _createNewOrder(String order) async {
    try {
      String status =await APIRepository().createNewOrder(order);
      print(status);
      setState(() {
      _resetCartItems();
      });
    } catch (error) {
      print("Failed to delete product: $error");
    }
  }
  @override
  Widget build(BuildContext context) {
    double totalMoney = _cartItems.fold<double>(0, (previousValue, item) {
      return previousValue + (item['quantity'] * item['price']) as double;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
      ),
      body: ListView.builder(
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> product = _cartItems[index];
          int quantity = product['quantity'];

          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: SizedBox(
                width: 60,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    product['imageURL'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                product['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Quantity: $quantity'),
              trailing: Text('\$${product['price']}'),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[300], // Gray background color
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'Total: \$${totalMoney.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  side: BorderSide(color: Colors.black),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Place Order',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
