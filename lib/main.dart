import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

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
          Container(
            padding: EdgeInsets.all(8),
            child: Text('ログイン情報：${user.email}'),
          ),
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
              return AddPostPage(user);
            }),
          );
        },
      ),
    );
  }
}

// 投稿画面用Widget
class AddPostPage extends StatefulWidget {
  // 引数からユーザー情報を受け取る
  AddPostPage(this.user);
  // ユーザー情報
  final User user;
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  // 入力した投稿メッセージ
  String messageText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チャット投稿'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 投稿メッセージ入力
              TextFormField(
                decoration: InputDecoration(labelText: '投稿メッセージ'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    messageText = value;
                  });
                },
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: Text('投稿'),
                  onPressed: () async {
                    final date =
                        DateTime.now().toLocal().toIso8601String(); // 現在の日時
                    final email = widget.user.email; // AddPostPage のデータを参照
                    // 投稿メッセージ用ドキュメント作成
                    await FirebaseFirestore.instance
                        .collection('posts') // コレクションID指定
                        .doc() // ドキュメントID自動生成
                        .set({
                      'text': messageText,
                      'email': email,
                      'date': date
                    });
                    // 1つ前の画面に戻る
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
