import 'dart:async';
import 'package:dio/dio.dart';
import 'package:bookstore/shared/constant.dart';
import 'package:bookstore/data/spref/spref.dart';
import 'package:bookstore/shared/model/user_data.dart';
import 'package:bookstore/data/remote/user_service.dart';

class UserRepo {
  late UserService _userService;

  UserRepo({required UserService userService}) : _userService = userService;

  Future<UserData> signIn(String phone, String password) async {
    Completer<UserData> completer = Completer<UserData>();

    try {
      Response response = await _userService.userLogin(phone, password);

      if (response.data['status'] == 200) {
        UserData user = UserData.fromJson(response.data['data']);

        if (user.token != null) {
          SPref.instance.set(SPrefCache.KEY_TOKEN, user.token);
          completer.complete(user);
        }
        print(user.token);
      } else {
        completer.completeError(response.data['messages']);
      }
    } on DioError catch (e) {
      completer.completeError('Dio: Login fail.');
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  Future<UserData> signUp(String name, String pass, String phone) async {
    Completer<UserData> completer = Completer<UserData>();

    try {
      Response response = await _userService.signUp(name, phone, pass);

      if (response.data['status'] == 200) {
        UserData userData = UserData.fromJson(response.data['data']);
        completer.complete(userData);
      } else {
        print(response.data['messages']);
      }
    } on DioError catch (e) {
      completer.completeError('Dio: Create User fail');
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }
}
