import 'package:flutter/material.dart';
import 'package:medicare/dashboard.dart';
import 'package:medicare/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';

void main() => runApp(new MyApp());
FirebaseUser currUser;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: FutureBuilder(
          future: FirebaseAuth.instance.currentUser(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == null)
                return new LoginPage();
              else
                return new DashboardPage(snapshot.data);
            }
            return new CircularProgressIndicator();
          }),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // final DocumentReference documentReference = Firestore.instance.document("users/details");
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _emailEditController = new TextEditingController();
  final _passwordEditController = new TextEditingController();
  final _forgotEmailEditController = new TextEditingController();
  bool _isLogging = false;
  bool _forgotPassword = false;
  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.blueGrey,
      body: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Image(
            image: new AssetImage("assets/login_bk.jpg"),
            fit: BoxFit.cover,
            color: Colors.black87,
            colorBlendMode: BlendMode.darken,
          ),
          new Column(mainAxisAlignment: MainAxisAlignment.center, children: <
              Widget>[
            new Image(
              image: new AssetImage("assets/medical_flat.jpg"),
              width: 120.0,
              height: 120.0,
            ),
            new Form(
              child: Theme(
                data: new ThemeData(
                  brightness: Brightness.dark,
                  primarySwatch: Colors.teal,
                  inputDecorationTheme: new InputDecorationTheme(
                      labelStyle:
                          new TextStyle(color: Colors.teal, fontSize: 20.0)),
                ),
                child: Container(
                  padding: const EdgeInsets.only(
                      bottom: 40.0, left: 40.0, right: 40.0, top: 40.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      new TextFormField(
                        controller: _emailEditController,
                        decoration: new InputDecoration(
                            icon: Icon(Icons.account_box),
                            hintText: "Email",
                            contentPadding: const EdgeInsets.only(
                                left: 20.0,
                                top: 10.0,
                                right: 40.0,
                                bottom: 10.0),
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(32.0),
                            )),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                      ),
                      new TextFormField(
                        controller: _passwordEditController,
                        decoration: new InputDecoration(
                            icon: Icon(Icons.lock),
                            hintText: "Password",
                            contentPadding: const EdgeInsets.only(
                                left: 20.0,
                                top: 10.0,
                                right: 40.0,
                                bottom: 10.0),
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(32.0),
                            )),
                        keyboardType: TextInputType.text,
                        obscureText: true,
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                      ),
                      new RaisedButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(32.0)),
                        padding: const EdgeInsets.only(
                            left: 40.0, right: 40.0, top: 12.0, bottom: 12.0),
                        color: Colors.teal,
                        textColor: Colors.white,

                        child: new Text(_isLogging
                            ? "Validating credentials...."
                            : "Login"),
                        // onPressed: _add,
                        onPressed: _isLogging
                            ? null
                            : () {
                                setState(() {
                                  _isLogging = true;
                                });
                                FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                        email: _emailEditController.text.trim(),
                                        password:
                                            _passwordEditController.text.trim())
                                    .then((onValue) {
                                  if (onValue != null) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DashboardPage(onValue)));
                                  }
                                }).catchError((e) {
                                  print(e.message);
                                  showInSnackBar(e.message);
                                  setState(() {
                                    _isLogging = false;
                                  });
                                });
                              },
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                      ),
                      new OutlineButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(32.0)),
                          color: Colors.transparent,
                          padding: const EdgeInsets.only(
                              left: 40.0, right: 40.0, top: 12.0, bottom: 12.0),
                          textColor: Colors.teal,
                          highlightColor: Colors.white,
                          borderSide:
                              BorderSide(color: Colors.teal, width: 2.0),
                          child: new Text("Sign Up"),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupPage()));
                          })
                    ],
                  ),
                ),
              ),
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(text: 'Forgot '),
              TextSpan(
                  text: 'Password',
                  style:
                      TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        _forgotPassword = true;
                      });
                    }),
              TextSpan(text: '? ')
            ])),
          ]),
          _forgotPassword
              ? Center(
                  child: Container(
                    color: Colors.white,
                    height: 225.0,
                    width: 300.0,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Verification link will be sent to registered email id",
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10.0),
                        TextFormField(
                          controller: _forgotEmailEditController,
                          decoration: new InputDecoration(
                              icon: Icon(Icons.account_box),
                              hintText: "Emailid",
                              contentPadding: const EdgeInsets.only(
                                  left: 12.0,
                                  top: 11.0,
                                  right: 14.0,
                                  bottom: 11.0),
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(32.0),
                              )),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        RaisedButton(
                          child: Text('Reset Password'),
                          onPressed: () {
                            FirebaseAuth.instance
                                .sendPasswordResetEmail(
                                    email: _forgotEmailEditController.text)
                                .then((onValue) {
                              showInSnackBar("Mail Sent");
                            }).catchError((onError) {
                              showInSnackBar(onError.message);
                            });
                          },
                        ),
                        RaisedButton(
                          child: Text('Cancel'), 
                          onPressed: () {
                            setState(() {
                                                          _forgotPassword=false;
                                                        });
                          })
                      ],
                    ),
                  ),
                )
              : null
        ].where((c) => c != null).toList(),
      ),
    );
  }
}
