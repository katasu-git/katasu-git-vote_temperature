import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './chatPage.dart';  //チャットページ

// ログイン画面用Widget
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //メッセージ表示用
  String infoText = '';

  //入力したメアド・パス
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //メアド入力
          TextFormField(
            decoration: InputDecoration(labelText: 'メールアドレス'),
            onChanged: (String value) {
              setState(() {
                email = value;
              });
            },
          ),
          // パスワード入力
          TextFormField(
            decoration: InputDecoration(labelText: 'パスワード'),
            obscureText: true,
            onChanged: (String value) {
              setState(() {
                password = value;
              });
            },
          ),
          Container(
            padding: EdgeInsets.all(8),
            // メッセージ表示
            child: Text(infoText),
          ),
          Container(
            width: double.infinity,
            // ユーザー登録ボタン
            child: RaisedButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('ユーザー登録'),
              onPressed: () async {
                try {
                  // メール/パスワードでユーザー登録
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  final UserCredential result =
                      await auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  final User user = result.user;
                  // ユーザー登録に成功した場合
                  // チャット画面に遷移＋ログイン画面を破棄
                  await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) {
                      // 次のページに変数を渡す
                      return ChatPage(user);
                    }),
                  );
                } catch (e) {
                  // ユーザー登録に失敗した場合
                  setState(() {
                    infoText = "登録に失敗しました：${e.message}";
                  });
                }
              },
            ),
          ),
          Container(
            width: double.infinity,
            // ログイン登録ボタン
            child: OutlineButton(
              textColor: Colors.blue,
              child: Text('ログイン'),
              onPressed: () async {
                try {
                  // メール/パスワードでログイン
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  final UserCredential result =
                      await auth.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  final User user = result.user;
                  // ログインに成功した場合
                  // チャット画面に遷移＋ログイン画面を破棄
                  await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) {
                      return ChatPage(user);
                    }),
                  );
                } catch (e) {
                  // ログインに失敗した場合
                  setState(() {
                    infoText = "ログインに失敗しました：${e.message}";
                  });
                }
              },
            ),
          ),
        ],
      ),
    )));
  }
}