import 'dart:convert';

import 'package:buoi8/app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:buoi8/app/data/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Page1 extends StatefulWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      User user = User.userEmpty();
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strUser = pref.getString('user')!;
      user = User.fromJson2(jsonDecode(strUser));
      print(user.accountId);
      print(strUser);
      List<Map<String, dynamic>> categories =
          await APIRepository().getCateList(user.accountId!);
      setState(() {
        _items = categories;
      });
    } catch (error) {
      print("Failed to fetch categories: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CRUD CREATE"),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(item['imageURL']),
              ),
              title: Text(item['name']),
              subtitle: Text(item['description']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // edit
                      _editItem(context, index);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      //  xoa
                      _deleteCate(context,_items[index]['id'],index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewItem(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addNewItem(BuildContext context) {
    String name = '';
    String description = '';
    String imageURL = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Item'),
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
                decoration: InputDecoration(labelText: 'imageURL'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                _createNewCate(context, name, description, imageURL);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _editItem(BuildContext context, int index) {
    String name = _items[index]['name'];
    String description = _items[index]['description'];
    String imageURL = _items[index]['imageURL'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                decoration: InputDecoration(labelText: 'Name'),
                controller: TextEditingController(text: name),
              ),
              TextField(
                onChanged: (value) => description = value,
                decoration: InputDecoration(labelText: 'Description'),
                controller: TextEditingController(text: description),
              ),
              TextField(
                onChanged: (value) => imageURL = value,
                decoration: InputDecoration(labelText: 'imageURL'),
                controller: TextEditingController(text: imageURL),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _editCate(index, context, name, description, imageURL);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _editCate(int index, BuildContext context, String name,
      String description, String imageURL) async {
    try {
      User user = User.userEmpty();
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strUser = pref.getString('user')!;
      user = User.fromJson2(jsonDecode(strUser));
      String status = await APIRepository().editCate(
          _items[index]['id'], name, description, imageURL, user.accountId!);

      if (status == "ok") {
        setState(() {
          _items[index]['name'] = name;
          _items[index]['description'] = description;
          _items[index]['imageURL'] = imageURL;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Category edited successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to edit category")),
        );
      }
    } catch (error) {
      print("Error editing category: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while editing category")),
      );
    }
  }

  void _createNewCate(BuildContext context, String name, String description,
      String imageURL) async {
    try {
      // Get user account ID
      User user = User.userEmpty();
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strUser = pref.getString('user')!;
      user = User.fromJson2(jsonDecode(strUser));

      String status = await APIRepository()
          .createNewCate(name, description, imageURL, user.accountId!);
      print(status);
      setState(() {
        _items.add({
          'name': name,
          'description': description,
          'imageURL': imageURL,
        });
      });
      Navigator.of(context).pop();
    } catch (error) {
      print("Failed to create category: $error");
    }
  }

  void _deleteCate(BuildContext context, int categoryID, int index) async {
    try {
      // Get user account ID
      User user = User.userEmpty();
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strUser = pref.getString('user')!;
      user = User.fromJson2(jsonDecode(strUser));
      print(categoryID);
      print(user.accountId!);
      String status =await APIRepository().deleteCate(categoryID,user.accountId!);
      print(status);
      setState(() {
        _items.removeAt(index);
      });
      
    } catch (error) {
      print("Failed to delete category: $error");
    }
  }
}
