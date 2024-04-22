import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:buoi8/app/data/api.dart';

class OrderDetailsWidget extends StatefulWidget {
  final String orderId;

  const OrderDetailsWidget({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailsWidgetState createState() => _OrderDetailsWidgetState();
}

class _OrderDetailsWidgetState extends State<OrderDetailsWidget> {
  final APIRepository _apiRepository = APIRepository();
  List<Map<String, dynamic>> _orderDetails = [];
  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      _orderDetails = await _apiRepository.getOrderDetail(widget.orderId);
      print(_orderDetails);
    } catch (error) {
      print("Failed to fetch order details: $error");
    }
    if (mounted) {
      setState(() {}); // Update the UI after fetching data
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalMoney = _orderDetails.fold<double>(0, (previousValue, item) {
      return previousValue + (item['count'] * item['price']) as double;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: ListView.builder(
        itemCount: _orderDetails.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> product = _orderDetails[index];
          int quantity = product['count'];

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
                product['productName'],
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
          ],
        ),
      ),
    );
  }
}
