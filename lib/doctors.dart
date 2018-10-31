import 'package:flutter/material.dart';
import 'doctor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorsPage extends StatefulWidget {
  @override
  _DoctorsPageState createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  List<Doctor> _list = new List();
  List<Doctor> searchresult = new List();
  String _searchText = "";
  String sortParam = 'name';
  Widget appBarTitle = new Text(
    "Doctor Search",
  );
  Icon icon = new Icon(
    Icons.search,
  );
  final TextEditingController _controller = new TextEditingController();
  bool _isSearching;

  _DoctorsPageState() {
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchText = "";
        });
      } else {
        setState(() {
          _isSearching = true;
          _searchText = _controller.text;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _isSearching = false;
    Firestore.instance
        .collection("doctors")
        .orderBy(sortParam, descending: true)
        .getDocuments()
        .then((querySnapshot) {
      List<DocumentSnapshot> documentSnapshot = querySnapshot.documents;
      for (DocumentSnapshot ds in documentSnapshot) {
        setState(() {
          _list.add(Doctor(
              ds.data['name'], ds.data['specialist'], ds.data['degree']));
          sortParam = 'name';
        });
      }
    });
  }

  void searchOperation(String searchText) {
    searchresult.clear();
    if (_isSearching) {
      for (Doctor doc in _list) {
        if (doc.name.toLowerCase().contains(searchText)) searchresult.add(doc);
      }
    }
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.icon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = new Text(
        "Doctor Search",
        style: new TextStyle(color: Colors.white),
      );
      _isSearching = false;
      _controller.clear();
      searchresult.clear();
    });
  }

  List<String> choices = <String>[
    "name",
    "specialist",
    "name Desc",
    "specialist Desc"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
                child: searchresult.length != 0 || _controller.text.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchresult.length,
                        itemBuilder: (BuildContext context, int index) {
                          Doctor currDoc = searchresult[index];
                          return ListTile(
                            title: Text(currDoc.name),
                            subtitle: Text(currDoc.specialist),
                          );
                        },
                      )
                    : _list.length != 0
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: _list.length,
                            itemBuilder: (BuildContext context, int index) {
                              Doctor currDoc = _list[index];
                              return ListTile(
                                  title: Text(currDoc.name),
                                  subtitle: Text(currDoc.specialist));
                            },
                          )
                        : Center(
                            child: Text(
                              "No Records Or Data Is Being Fetched",
                              style: TextStyle(
                                  color: Color.fromRGBO(119, 136, 153, 1.0)),
                            ),
                          )),
          ],
        ),
      ),
      appBar: AppBar(
        title: appBarTitle,
        actions: <Widget>[
          IconButton(
              icon: icon,
              onPressed: () {
                setState(() {
                  if (this.icon.icon == Icons.search) {
                    this.icon = Icon(Icons.close);
                    this.appBarTitle = TextField(
                      controller: _controller,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      onChanged: searchOperation,
                    );
                    _handleSearchStart();
                  } else {
                    _handleSearchEnd();
                  }
                });
              }),
          PopupMenuButton(
            icon: Icon(Icons.sort),
            itemBuilder: (BuildContext context) {
              return choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice.toUpperCase()),
                );
              }).toList();
            },
            onSelected: (String choice) {
              setState(() {
                _list.sort((Doctor a, Doctor b) {
                  if (choice == "name")
                    return a.name.compareTo(b.name);
                  else if (choice == "specialist")
                    return a.specialist.compareTo(b.specialist);
                  else if (choice.split(" ")[0] == "name")
                    return b.name.compareTo(a.name);
                  else
                    return b.specialist.compareTo(a.specialist);
                });
              });
            },
          )
        ],
      ),
    );
  }
}
