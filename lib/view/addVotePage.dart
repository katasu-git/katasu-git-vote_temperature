import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './ChatPage.dart'; //チャットページ

// 投稿画面用Widget
class AddVotePage extends StatefulWidget {
  // 引数からユーザー情報を受け取る
  AddVotePage(this.user);
  // ユーザー情報
  final User user;
  @override
  _AddVotePageState createState() => _AddVotePageState();
}

class _AddVotePageState extends State<AddVotePage> {
  // 入力した投稿メッセージ
  int _voted = 0;

  void _onChanged(int voted) {
    setState(() {
      _voted = voted;
    });
    _saveVote();
  }

  void _saveVote() async {
    final date = DateTime.now().toLocal().toIso8601String(); // 現在の日時
    final email = widget.user.email; // AddPostPage のデータを参照
    // 投稿メッセージ用ドキュメント作成
    await FirebaseFirestore.instance
        .collection('posts') // コレクションID指定
        .doc() // ドキュメントID自動生成
        .set({'text': _voted, 'email': email, 'date': date});
    // 1つ前の画面に戻る
    //Navigator.of(context).pop();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        // 引数からユーザー情報を渡す
        return ChatPage(widget.user);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('投票画面'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 投稿メッセージ入力
              RadioListTile(
                  title: Text('暑い'),
                  value: 5,
                  groupValue: _voted,
                  onChanged: _onChanged),
              RadioListTile(
                  title: Text('少し暑い'),
                  value: 4,
                  groupValue: _voted,
                  onChanged: _onChanged),
              RadioListTile(
                  title: Text('快適'),
                  value: 3,
                  groupValue: _voted,
                  onChanged: _onChanged),
              RadioListTile(
                  title: Text('少し寒い'),
                  value: 2,
                  groupValue: _voted,
                  onChanged: _onChanged),
              RadioListTile(
                  title: Text('寒い'),
                  value: 1,
                  groupValue: _voted,
                  onChanged: _onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
