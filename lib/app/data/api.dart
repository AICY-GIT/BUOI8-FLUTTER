import 'dart:convert';

import 'package:buoi8/app/model/register.dart';
import 'package:buoi8/app/model/user.dart';
import 'package:dio/dio.dart';
import 'package:buoi8/app/data/sharepre.dart';
import 'package:shared_preferences/shared_preferences.dart';

class API {
  final Dio _dio = Dio();
  String baseUrl = "https://huflit.id.vn:4321";

  API() {
    _dio.options.baseUrl = "$baseUrl/api";
  }

  Dio get sendRequest => _dio;
}

class APIRepository {
  API api = API();

  Map<String, dynamic> header(String token) {
    return {
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Authorization': 'Bearer $token'
    };
  }

  Future<String> register(Signup user) async {
    try {
      final body = FormData.fromMap({
        "numberID": user.numberID,
        "accountID": user.accountID,
        "fullName": user.fullName,
        "phoneNumber": user.phoneNumber,
        "imageURL": user.imageUrl,
        "birthDay": user.birthDay,
        "gender": user.gender,
        "schoolYear": user.schoolYear,
        "schoolKey": user.schoolKey,
        "password": user.password,
        "confirmPassword": user.confirmPassword
      });
      Response res = await api.sendRequest.post('/Student/signUp',
          options: Options(headers: header('no token')), data: body);
      if (res.statusCode == 200) {
        print("ok");
        return "ok";
      } else {
        print("fail");
        return "signup fail";
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<String> login(String accountID, String password) async {
    try {
      final body =
          FormData.fromMap({'AccountID': accountID, 'Password': password});
      Response res = await api.sendRequest.post('/Auth/login',
          options: Options(headers: header('no token')), data: body);
      if (res.statusCode == 200) {
        final tokenData = res.data['data']['token'];
        print("ok login");
        return tokenData;
      } else {
        return "login fail";
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<String> forgetPass(
      String accountID, String numberID, String newPass) async {
    try {
      final body = FormData.fromMap(
          {'AccountID': accountID, 'numberID': numberID, 'newPass': newPass});
      Response res = await api.sendRequest.put('/Auth/forgetPass',
          options: Options(headers: header('no token')), data: body);
      if (res.statusCode == 200) {
        print("ok");
        return "ok";
      } else {
        print("fail");
        return "forgetPass fail";
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCateList(String accountID) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strtoken = pref.getString('token')!;
      Map<String, dynamic> param = {'accountID': accountID};
      Response res = await api.sendRequest.get(
        '/Category/getList',
        options: Options(headers: header(strtoken)),
        queryParameters: param,
      );
      if (res.statusCode == 200) {
        List<Map<String, dynamic>> categories = [];
        List<dynamic> responseData = res.data;
        responseData.forEach((category) {
          categories.add({
            'id': category['id'],
            'name': category['name'],
            'imageURL': category['imageURL'],
            'description': category['description'],
          });
        });
        return categories;
      } else {
        print("Request failed with status code ${res.statusCode}");
        print(res.data);
        throw "Failed to fetch categories";
      }
    } catch (ex) {
      print("An error occurred: $ex");
      rethrow;
    }
  }

  Future<String> createNewCate(String Name, String Description, String ImageURL,
      String AccountID) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strtoken = pref.getString('token')!;
      final body = FormData.fromMap({
        'Name': Name,
        'Description': Description,
        'ImageURL': ImageURL,
        'AccountID': AccountID
      });
      Response res = await api.sendRequest.post('/addCategory',
          options: Options(headers: header(strtoken)), data: body);
      if (res.statusCode == 200) {
        print("ok");
        return "ok";
      } else {
        print("fail");
        return "create fail";
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<String> editCate(int id, String Name, String Description,
      String ImageURL, String AccountID) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strtoken = pref.getString('token')!;
      final body = FormData.fromMap({
        'id': id,
        'Name': Name,
        'Description': Description,
        'ImageURL': ImageURL,
        'AccountID': AccountID
      });
      print(body);
      Response res = await api.sendRequest.put('/updateCategory',
          options: Options(headers: header(strtoken)), data: body);
      if (res.statusCode == 200) {
        print("ok");
        return "ok";
      } else {
        print("fail");
        return "edit fail";
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<String> deleteCate(int categoryID, String accountID) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strtoken = pref.getString('token')!;
      final body = FormData.fromMap({
        'categoryID': categoryID,
        'accountID': accountID,
      });
      print(body);
      Response res = await api.sendRequest.delete('/removeCategory',
          options: Options(headers: header(strtoken)), data: body);
      if (res.statusCode == 200) {
        print("ok");
        return "ok";
      } else {
        print("fail");
        return "delete fail";
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getProList(String accountID) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strtoken = pref.getString('token')!;
      Map<String, dynamic> param = {'accountID': accountID};
      Response res = await api.sendRequest.get(
        '/Product/getList',
        options: Options(headers: header(strtoken)),
        queryParameters: param,
      );
      if (res.statusCode == 200) {
        List<Map<String, dynamic>> products = [];
        List<dynamic> responseData = res.data;
        responseData.forEach((product) {
          products.add({
            'id': product['id'],
            'name': product['name'],
            'description': product['description'],
            'imageURL': product['imageURL'],
            'price': product['price'],
            'categoryID': product['categoryID'],
            'categoryName': product['categoryName'],
          });
        });
        return products;
      } else {
        print("Request failed with status code ${res.statusCode}");
        print(res.data);
        throw "Failed to fetch products";
      }
    } catch (ex) {
      print("An error occurred: $ex");
      rethrow;
    }
  }

  Future<String> createNewPro(String Name, String Description, String ImageURL,
      double Price, int CategoryID) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strtoken = pref.getString('token')!;
      final body = FormData.fromMap({
        'Name': Name,
        'Description': Description,
        'ImageURL': ImageURL,
        'Price': Price,
        'CategoryID': CategoryID,
      });
      Response res = await api.sendRequest.post(
        '/addProduct',
        options: Options(headers: header(strtoken)),
        data: body,
      );

      if (res.statusCode == 200) {
        print("ok");
        return "ok";
      } else {
        print("fail");
        return "create fail";
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<String> editPro(int id, String Name, String Description,
      String ImageURL, double Price, int CategoryID, String accountID) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strtoken = pref.getString('token')!;
      final body = FormData.fromMap({
        'id': id,
        'Name': Name,
        'Description': Description,
        'ImageURL': ImageURL,
        'Price': Price,
        'CategoryID': CategoryID,
        'accountID': accountID
      });
      Response res = await api.sendRequest.put(
        '/updateProduct',
        options: Options(headers: header(strtoken)),
        data: body,
      );
      if (res.statusCode == 200) {
        print("ok");
        return "ok";
      } else if (res.statusCode == 400) {
        final responseData = jsonDecode(res.data.toString());
        final errors = responseData['errors'];
        final errorMessage = _parseErrorMessage(errors);
        print(errorMessage);
        return errorMessage;
      } else {
        print("fail");
        return "update fail";
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<String> deletePro(int productID, String accountID) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strtoken = pref.getString('token')!;
      final body =
          FormData.fromMap({'productID': productID, 'accountID': accountID});
      Response res = await api.sendRequest.delete(
        '/removeProduct',
        options: Options(headers: header(strtoken)),
        data: body,
      );
      if (res.statusCode == 200) {
        print("ok");
        return "ok";
      } else if (res.statusCode == 400) {
        final responseData = jsonDecode(res.data.toString());
        final errors = responseData['errors'];
        final errorMessage = _parseErrorMessage(errors);
        print(errorMessage);
        return errorMessage;
      } else {
        print("fail");
        return "delete fail";
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<String> createNewOrder(String Order) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strtoken = pref.getString('token')!;
      Response res = await api.sendRequest.post(
        '/Order/addBill',
        options: Options(headers: header(strtoken)),
        data: Order,
      );
      if (res.statusCode == 200) {
        print("ok");
        return "ok";
      } else {
        print("fail");
        return "create fail";
      }
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

Future<List<Map<String, dynamic>>> getOrderHistory() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strtoken = pref.getString('token')!;
      Response res = await api.sendRequest.get(
        '/Bill/getHistory',
        options: Options(headers: header(strtoken)),
      );
      if (res.statusCode == 200) {
        List<dynamic> data = res.data;
        List<Map<String, dynamic>> orders = data.cast<Map<String, dynamic>>();
        return orders;
      } else {
        throw Exception('Failed to fetch order history');
      }
    } catch (ex) {
      throw Exception('Failed to fetch order history: $ex');
    }
  }
 Future<List<Map<String, dynamic>>> getOrderDetail(String billID) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String strtoken = pref.getString('token')!;
      Map<String, dynamic> param = {'billID': billID};
      Response res = await api.sendRequest.post(
        '/Bill/getByID',
        options: Options(headers: header(strtoken)),
        queryParameters: param,
      );
      if (res.statusCode == 200) {
        List<dynamic> data = res.data;
        List<Map<String, dynamic>> orderDetails =
            data.cast<Map<String, dynamic>>();
        return orderDetails;
      } else {
        throw Exception('Failed to fetch order details');
      }
    } catch (ex) {
      print("An error occurred: $ex");
      rethrow;
    }
  }
  String _parseErrorMessage(Map<String, dynamic> errors) {
    final List<String> errorMessages = [];
    errors.forEach((key, value) {
      final List<dynamic> messages = value;
      errorMessages.addAll(messages.cast<String>());
    });
    return errorMessages.join('\n');
  }

  Future<User> current(String token) async {
    try {
      Response res = await api.sendRequest
          .get('/Auth/current', options: Options(headers: header(token)));
      print(res.data);
      return User.fromJson(res.data);
    } catch (ex) {
      rethrow;
    }
  }
}
