import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static String id = '/chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

Stream myStream;

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _store = FirebaseFirestore.instance;
  List<MessageBubble> messageBubbles = [];
  User currentUser;
  bool isMe = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   myStream = _store.collection('messages').orderBy('timestamp', descending: false).snapshots();
    getUser();
  }

  void getUser() {
    print(_auth.currentUser.email);
  }

  String messageText;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context); //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: myStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator(
                    backgroundColor: Colors.lightBlueAccent,
                  );
                } else {
                  final messages = snapshot.data.docs;
                  for (var message in messages) {
                    final messageText = message.data()['message'];
                    final messageSender = message.data()['sender'];
                    currentUser = _auth.currentUser;
                    if (currentUser.email != message.data()['sender']) {
                      isMe = false;
                    }
                    final textBubble = MessageBubble(
                      isMe: isMe,
                      sender: messageSender,
                      text: messageText,
                    );
                    messageBubbles.add(textBubble);
                  }
                  return Expanded(
                    child: ListView(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      children: messageBubbles,
                    ),
                  );
                }
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        messageText = value;

                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _store.collection('messages').add({
                        'message': messageText,
                        'sender': _auth.currentUser.email,
                      });
                      messageController.clear(); //Implement send functionality.
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
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {@required this.sender, @required this.text, @required this.isMe});
  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(color: Colors.white, fontSize: 10.0),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Material(
              borderRadius: BorderRadius.circular(20),
              elevation: 10,
              shadowColor: Colors.blueGrey,
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  text,
                  style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 15.0),
                ),
              ),
            ),
          ),
        ]);
  }
}
