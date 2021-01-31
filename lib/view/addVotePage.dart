import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String _voted = '未選択';

  void _onChanged(String voted) {
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
    Navigator.of(context).pop();
  }

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
              RadioListTile(
                  title: Text('暑い'),
                  value: '暑い',
                  groupValue: _voted,
                  onChanged: _onChanged),
              RadioListTile(
                  title: Text('快適'),
                  value: '快適',
                  groupValue: _voted,
                  onChanged: _onChanged),
              RadioListTile(
                  title: Text('寒い'),
                  value: '寒い',
                  groupValue: _voted,
                  onChanged: _onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
