import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

final Firestore _firestore = Firestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseUser _loggedUser;
String emailLoggedUser;

class ChatScreen extends StatefulWidget {
  static const String id = '/chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageTextController = TextEditingController();
  bool _showSpinner = false;
  String message;

  @override
  void initState() {
    super.initState();
    _auth.currentUser().then((user) {
      emailLoggedUser = user.email;
      _loggedUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () =>
                _auth.signOut().then((value) => Navigator.pop(context)),
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
              MessagesStream(),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: this._messageTextController,
                        onChanged: (value) => this.message = value,
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        this._messageTextController.clear();
                        setState(() => this._showSpinner = true);
                        _firestore
                            .collection('messages')
                            .add(
                              {
                                'sender': emailLoggedUser,
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

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
              child:
                  CircularProgressIndicator(backgroundColor: Colors.lightBlue));
        List<MessageBubble> messages = [];
        snapshot.data.documents.forEach((document) {
          messages.add(
            MessageBubble(
              sender: document['sender'],
              text: document['text'],
              isMe: document['sender'] == emailLoggedUser,
            ),
          );
        });
        return Expanded(
          child: ListView(
            reverse: true,
            children: messages,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({this.sender, this.text, this.isMe});
  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            this.sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: this.isMe ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
