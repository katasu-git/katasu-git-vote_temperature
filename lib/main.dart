import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import './view/loginPage.dart';  //ログインページ

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// 更新可能なデータ
class UserState with ChangeNotifier {
  User user;
  void setUser(User newUser) {
    user = newUser;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  // ユーザーの情報を管理するデータ
  final UserState userState = UserState();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserState>.value(
        value: userState,
        child: MaterialApp(
          // 右上に表示される"debug"ラベルを消す
          debugShowCheckedModeBanner: false,
          // アプリ名
          title: 'ChatApp',
          theme: ThemeData(
            // テーマカラー
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          // ログイン画面を表示
          home: LoginPage(),
        ));
  }
}