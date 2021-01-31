import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './loginPage.dart'; //ログインページ

// 投稿画面用Widget
class ChatPage extends StatefulWidget {
  // 引数からユーザー情報を受け取る
  // ユーザー情報
  ChatPage(this.user);
  // ユーザー情報
  final User user;
  @override
  _ChatPageState createState() => _ChatPageState();
}

// チャット画面用Widget
class _ChatPageState extends State<ChatPage> {

  String _userVote = "未投票";

    void _addUserVote(int vote) {
      if (vote == 5) {
        _userVote = "暑い";
      } else if (vote == 4) {
        _userVote = "少し暑い";
      } else if (vote == 3) {
        _userVote = "快適";
      } else if (vote == 2) {
        _userVote = "少し寒い";
      } else if (vote == 1) {
        _userVote = "寒い";
      } else {
        _userVote = "hello";
      }
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('結果'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () async {
              // ログアウト処理
              // 内部で保持しているログイン情報等が初期化される
              // （現時点ではログアウト時はこの処理を呼び出せばOKと、思うぐらいで大丈夫です）
              await FirebaseAuth.instance.signOut();
              // ログイン画面に遷移＋チャット画面を破棄
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            // FutureBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: StreamBuilder<QuerySnapshot>(
              // 投稿メッセージ一覧を取得（非同期処理）
              // 投稿日時でソート
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final docments = snapshot.data.docs;
                  var sum = docments.length * 2;
                  var hot = 0;
                  var comfort = 0;
                  var cold = 0;

                  docments.forEach((doc) {
                    if (widget.user.email == doc["email"]) {
                      _addUserVote(doc["text"]);
                    }
                  });

                  docments.forEach((doc) {
                    if (doc["text"] == 5) {
                      hot += 2;
                    } else if (doc["text"] == 4) {
                      hot += 1;
                      comfort += 1;
                    } else if (doc["text"] == 3) {
                      comfort += 2;
                    } else if (doc["text"] == 2) {
                      cold += 1;
                      comfort += 1;
                    } else if (doc["text"] == 1) {
                      cold += 2;
                    }
                  });

                  var perHot = hot / sum * 100;
                  var perComfort = comfort / sum * 100;
                  var perCold = cold / sum * 100;

                  return Scaffold(
                    body: Center(
                      child: Container(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("あなたの投票:" + _userVote),
                            Text("暑い🥵" + perHot.toStringAsFixed(1) + "%"),
                            Text("快適🥰" + perComfort.toStringAsFixed(1) + "%"),
                            Text("寒い🥶" + perCold.toStringAsFixed(1) + "%"),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                // データが読込中の場合
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
