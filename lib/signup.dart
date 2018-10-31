import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.lightGreenAccent,
      body: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Image(
            image: new AssetImage("assets/login_bk.jpg"),
            fit: BoxFit.cover,
            color: Colors.black87,
            colorBlendMode: BlendMode.darken,
          ),
          SingleChildScrollView(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Padding(padding: EdgeInsets.only(top: 40.0)),
                  new Image(
                    image: new AssetImage("assets/medical_flat.jpg"),
                    width: 100.0,
                    height: 100.0,
                  ),
                  new Form(
                    child: Theme(
                      data: new ThemeData(
                        brightness: Brightness.dark,
                        primarySwatch: Colors.teal,
                        inputDecorationTheme: new InputDecorationTheme(
                            labelStyle: new TextStyle(
                          color: Colors.teal,
                          fontSize: 30.0,
                        )),
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(
                            bottom: 40.0, left: 40.0, right: 40.0, top: 20.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            new TextFormField(
                              controller: _firstNameController,
                              decoration: new InputDecoration(
                                  hintText: "First Name",
                                  contentPadding: const EdgeInsets.only(
                                      left: 40.0,
                                      top: 10.0,
                                      right: 40.0,
                                      bottom: 10.0),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(32.0),
                                  )),
                              keyboardType: TextInputType.text,
                            ),
                            new Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                            ),
                            new TextFormField(
                              controller: _lastNameController,
                              decoration: new InputDecoration(
                                  hintText: "Last Name",
                                  contentPadding: const EdgeInsets.only(
                                      left: 40.0,
                                      top: 10.0,
                                      right: 40.0,
                                      bottom: 10.0),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(32.0),
                                  )),
                              keyboardType: TextInputType.text,
                            ),
                            new Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                            ),
                            new TextFormField(
                              controller: _emailController,
                              decoration: new InputDecoration(
                                  hintText: "Email",
                                  contentPadding: const EdgeInsets.only(
                                      left: 40.0,
                                      top: 10.0,
                                      right: 40.0,
                                      bottom: 10.0),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(32.0),
                                  )),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            new Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                            ),
                            new TextFormField(
                              controller: _passwordController,
                              decoration: new InputDecoration(
                                  hintText: "Password",
                                  contentPadding: const EdgeInsets.only(
                                      left: 40.0,
                                      top: 10.0,
                                      right: 40.0,
                                      bottom: 10.0),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(32.0),
                                  )),
                              keyboardType: TextInputType.text,
                              obscureText: true,
                            ),
                            new Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                            ),
                            new RaisedButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0)),
                                padding: const EdgeInsets.only(
                                    left: 40.0,
                                    right: 40.0,
                                    top: 12.0,
                                    bottom: 12.0),
                                textColor: Colors.white,
                                color: Colors.teal,
                                child: new Text("Sign Up"),
                                onPressed: () {
                                  String firstname, lastName, email, password;
                                  firstname = _firstNameController.text;
                                  lastName = _lastNameController.text;
                                  email = _emailController.text;
                                  password = _passwordController.text;
                                  FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                          email: email, password: password)
                                      .then((user) {
                                    UserUpdateInfo info = UserUpdateInfo();
                                    String displayname =
                                        firstname + " " + lastName;
                                    info.displayName = displayname.trim();
                                    user.updateProfile(info).then((onValue) {
                                      user.reload().then((onValue) {
                                        FirebaseAuth.instance
                                            .currentUser()
                                            .then((updateduser) {
                                          user = updateduser;
                                          Firestore.instance
                                              .collection("users")
                                              .document(user.uid)
                                              .setData(
                                                  {'name': user.displayName,'email':user.email});
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DashboardPage(user)));
                                        });
                                      });
                                    });
                                  }).catchError((e) {showInSnackBar(e.message);});
                                }),
                            new Padding(
                              padding: const EdgeInsets.only(bottom: 50.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
