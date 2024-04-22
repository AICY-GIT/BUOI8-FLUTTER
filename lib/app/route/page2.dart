import 'dart:convert';
import 'package:buoi8/app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:buoi8/app/data/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _itemsCate = [];
  int selectedCategoryID = 0;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCategories().then((_) {
      if (_itemsCate.isNotEmpty) {
        setState(() {
          selectedCategoryID = _itemsCate.first['id'] as int;
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product CRUD"),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns
          crossAxisSpacing: 8.0, // Spacing between columns
          mainAxisSpacing: 8.0, // Spacing between rows
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return GestureDetector(
            onTap: () {
              _showEditBottomSheet(context, item, index);
            },
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8.0),
                        ),
                        child: Image.network(
                          item['imageURL'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            item['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            '\$${item['price']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewProduct(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addNewProduct(BuildContext context) {
    String name = '';
    String description = '';
    String imageURL = '';
    double price = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                onChanged: (value) => description = value,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                onChanged: (value) => imageURL = value,
                decoration: InputDecoration(labelText: 'ImageURL'),
              ),
              TextField(
                onChanged: (value) => price = double.parse(value),
                decoration: InputDecoration(labelText: 'Price'),
              ),
              SizedBox(
                height: 100.0,
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<int>(
                    value: selectedCategoryID, // gia tri dc chon
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedCategoryID = newValue!;
                      });
                    },
                    items: _itemsCate.map((item) {
                      return DropdownMenuItem<int>(
                        value: item['id'] as int,
                        child: Text(item['name']),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _createNewProduct(context, name, description, imageURL, price,
                    selectedCategoryID);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _createNewProduct(BuildContext context, String name, String description,
      String imageURL, double price, int CateID) async {
    try {
      String status = await APIRepository()
          .createNewPro(name, description, imageURL, price, CateID);
      print(status);
      setState(() {
        _items.add({
          'name': name,
          'description': description,
          'imageURL': imageURL,
          'price': price,
        });
      });
      Navigator.of(context).pop();
    } catch (error) {
      print("Failed to create product: $error");
    }
  }

  void _showEditBottomSheet(
      BuildContext context, Map<String, dynamic> product, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                // Border radius
                child: ElevatedButton(
                  onPressed: () {
                    dynamic productId = product['id'];
                    _navigateToEditProductScreen(context, productId, index);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white, // Text color of the button
                    padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0), // Padding of the button
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Border radius
                      side: BorderSide(
                        color: Colors.black, // Color of the border
                        width: 1.0, // Width of the border
                      ),
                    ),
                  ),
                  child: Text('Edit'),
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  dynamic productId = product['id'];
                  _deleteProduct(context, productId, index);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white, // Text color of the button
                  padding: EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0), // Padding of the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // Border radius
                    side: BorderSide(
                      color: Colors.black, // Color of the border
                      width: 1.0, // Width of the border
                    ),
                  ),
                ),
                child: Text('Delete'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteProduct(BuildContext context, int productId, int index) async {
    try {
      User user = User.userEmpty();
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strUser = pref.getString('user')!;
      user = User.fromJson2(jsonDecode(strUser));
      String status =
          await APIRepository().deletePro(productId, user.accountId!);
      print(status);
      setState(() {
        _items.removeAt(index);
      });
      Navigator.of(context).pop();
    } catch (error) {
      print("Failed to delete product: $error");
    }
  }

  void _navigateToEditProductScreen(
      BuildContext context, int productId, int index) async {
    String name = '';
    String description = '';
    String imageURL = '';
    double price = 0.0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                onChanged: (value) => description = value,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                onChanged: (value) => imageURL = value,
                decoration: InputDecoration(labelText: 'ImageURL'),
              ),
              TextField(
                onChanged: (value) => price = double.parse(value),
                decoration: InputDecoration(labelText: 'Price'),
              ),
              SizedBox(
                height: 100.0,
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<int>(
                    value: selectedCategoryID, // gia tri dc chon
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedCategoryID = newValue!;
                      });
                    },
                    items: _itemsCate.map((item) {
                      return DropdownMenuItem<int>(
                        value: item['id'] as int,
                        child: Text(item['name']),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _editPro(index, context, productId, name, description, imageURL,
                    price, selectedCategoryID);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _editPro(int index, BuildContext context, int id, String name,
      String description, String imageURL, double price, int CategoryID) async {
    try {
      User user = User.userEmpty();
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strUser = pref.getString('user')!;
      user = User.fromJson2(jsonDecode(strUser));
      String status = await APIRepository().editPro(
          id, name, description, imageURL, price, CategoryID, user.accountId!);
      if (status == "ok") {
        await _fetchProducts();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product edited successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to edit Product")),
        );
      }
    } catch (error) {
      print("Error editing Product: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while editing Product")),
      );
    }
  }
}
