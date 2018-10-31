import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  final FirebaseUser currUser;
  ProfilePage(this.currUser);
  @override
  _ProfilePageState createState() => _ProfilePageState(this.currUser);
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseUser currUser;
  bool _isEnabled;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _nameEditingController;
  _ProfilePageState(FirebaseUser currUser) {
    this.currUser = currUser;
    _isEnabled = false;
    _nameEditingController = TextEditingController();
    _nameEditingController.text = currUser.displayName;
  }
  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: FutureBuilder(
          future: Firestore.instance.document("users/" + currUser.uid).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return profileBody(snapshot.data['name']);
            }
            return Center(child: CircularProgressIndicator());
          },
        ));
  }

  Widget profileBody(String name) {
    return SingleChildScrollView(
      child: new Column(
        children: <Widget>[
          SizedBox(
            height: 40.0,
          ),
          Column(
            children: <Widget>[
              CircleAvatar(
                child: Text(
                  name.substring(0, 1).toUpperCase(),
                  style: TextStyle(fontSize: 35.0),
                ),
                minRadius: 45.0,
              ),
              SizedBox(height: 15.0),
              _isEnabled
                  ? TextField(
                      style: TextStyle(fontSize: 25.0, color: Colors.black),
                      controller: _nameEditingController,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                          Text(
                            currUser.displayName,
                            style:
                                TextStyle(fontSize: 25.0, color: Colors.black),
                          ),
                          currUser.isEmailVerified
                              ? Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              : IconButton(
                                  icon: Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () {
                                    currUser
                                        .sendEmailVerification()
                                        .catchError((onError) {
                                      showInSnackBar(onError.message);
                                    }).then((onValue) {
                                      showInSnackBar("Email Sent!");
                                    });
                                  },
                                  tooltip: "Click To Send Verification Email!",
                                )
                        ])
            ],
          ),
          SizedBox(
            height: 80.0,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.deepPurple,
                    size: 45.0,
                  ),
                  onPressed: () {},
                  tooltip: 'Contact Admin',
                ),
                IconButton(
                  icon: !_isEnabled
                      ? Icon(
                          Icons.mode_edit,
                          color: Colors.green,
                          size: 45.0,
                        )
                      : Icon(
                          Icons.thumb_up,
                          color: Colors.green,
                          size: 45.0,
                        ),
                  onPressed: () {
                    if (_isEnabled) {
                      UserUpdateInfo info = UserUpdateInfo();
                      Firestore.instance
                          .document("users/" + currUser.uid)
                          .updateData(
                              {'name': _nameEditingController.text.toString()});
                      info.displayName = _nameEditingController.text.toString();
                      currUser.updateProfile(info).then((onValue) {
                        currUser.reload().then((onValue) {
                          FirebaseAuth.instance.currentUser().then((onValue) {
                            currUser = onValue;
                            setState(() {
                              _isEnabled = false;
                            });
                          });
                        });
                      });
                    } else {
                      setState(() {
                        _isEnabled = true;
                        _nameEditingController.text = currUser.displayName;
                      });
                    }
                  },
                  tooltip: !_isEnabled ? 'Edit Info' : 'Done',
                ),
                IconButton(
                  icon: Icon(
                    Icons.update,
                    color: Colors.deepPurple,
                    size: 45.0,
                  ),
                  onPressed: () {
                    currUser.reload().then((onValue) {
                      FirebaseAuth.instance.currentUser().then((user) {
                        setState(() {
                          currUser = user;
                        });
                      });
                    });
                  },
                  tooltip: 'Recent Appointments',
                ),
              ]),
          SizedBox(
            height: 40.0,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.question_answer,
                    color: Colors.green,
                    size: 45.0,
                  ),
                  onPressed: () {},
                  tooltip: 'FAQs',
                ),
                IconButton(
                  icon: Icon(
                    Icons.donut_small,
                    color: Colors.deepPurple,
                    size: 45.0,
                  ),
                  onPressed: () {},
                  tooltip: 'Analyze Reports ',
                ),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: Colors.green,
                    size: 45.0,
                  ),
                  onPressed: () {},
                  tooltip: 'Share App',
                ),
              ]),
          SizedBox(
            height: 40.0,
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.power_settings_new,
                  color: Color.fromRGBO(255, 0, 0, 1.0),
                  size: 45.0,
                ),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((onValue) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MyApp()));
                  });
                },
                splashColor: Colors.redAccent,
                tooltip: 'Sign Out',
              ),
            ],
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
          )
        ],
      ),
    );
  }
}
