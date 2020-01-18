import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ChatScreen extends StatefulWidget {
  static const String id = '/chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _showSpinner = false;
  FirebaseUser loggedInUser;
  String message;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() =>
      this._auth.currentUser().then((user) => this.loggedInUser = user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () =>
                this._auth.signOut().then((value) => Navigator.pop(context)),
          ),
        ],
        title: Text('⚡️Chat'),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: ModalProgressHUD(
        inAsyncCall: this._showSpinner,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: this._firestore.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  List<Text> messages = [];
                  snapshot.data.documents.forEach((document) {
                    messages.add(Text(
                        '${document.data['text']} from ${document.data['sender']}'));
                  });
                  return Column(children: messages);
                },
              ),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        onChanged: (value) => this.message = value,
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() => this._showSpinner = true);
                        this
                            ._firestore
                            .collection('messages')
                            .add(
                              {
                                'sender': this.loggedInUser.email,
                                'text': this.message,
                              },
                            )
                            .then((value) =>
                                setState(() => this._showSpinner = false))
                            .catchError((error) {
                              setState(() => this._showSpinner = false);
                              print('Error: $error');
                            });
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
