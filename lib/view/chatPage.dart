import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './addVotePage.dart'; //投稿ページ
import './loginPage.dart'; //ログインページ

// チャット画面用Widget
class ChatPage extends StatelessWidget {
  // 引数からユーザー情報を受け取れるようにする
  ChatPage(this.user);
  // ユーザー情報
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チャット'),
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
          /*
          Container(
            padding: EdgeInsets.all(8),
            child: Text('ログイン情報：${user.email}'),
          ),
          */
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
                  var sum = docments.length;
                  var hot = 0;
                  var comfort = 0;
                  var cold = 0;

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
                            Text("暑い🥵" + perHot.toStringAsFixed(1) + "%"),
                            Text("快適🥰" + perComfort.toStringAsFixed(1) + "%"),
                            Text("寒い🥶" + perCold.toStringAsFixed(1) + "%"),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                /*
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data.docs;
                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      IconButton deleteIcon;
                      // 自分の投稿メッセージの場合は削除ボタンを表示
                      if (document['email'] == user.email) {
                        deleteIcon = IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            // 投稿メッセージのドキュメントを削除
                            await FirebaseFirestore.instance
                                .collection('posts')
                                .doc(document.id)
                                .delete();
                          },
                        );
                      }
                      return Card(
                        child: ListTile(
                          title: Text(document['text']),
                          subtitle: Text(document['email']),
                          trailing: deleteIcon,
                        ),
                      );
                    }).toList(),
                  );
                }
                */
                // データが読込中の場合
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // 投稿画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              // 引数からユーザー情報を渡す
              return AddVotePage(user);
            }),
          );
        },
      ),
    );
  }
}
