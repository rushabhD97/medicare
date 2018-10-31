import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'medicine.dart';

class MedicinesPage extends StatefulWidget {
  @override
  _MedicinesPageState createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  List<Medicine> _list = new List();
  List<Medicine> searchresult = new List();
  String _searchText = "";
  String sortParam = 'name';

  Widget appBarTitle = new Text(
    "Medicines Search",
  );
  Icon icon = new Icon(
    Icons.search,
  );
  final TextEditingController _controller = new TextEditingController();
  bool _isSearching;

  _MedicinesPageState() {
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
        .collection("medicines")
        .getDocuments()
        .then((querySnapshot) {
      List<DocumentSnapshot> documentSnapshot = querySnapshot.documents;
      for (DocumentSnapshot ds in documentSnapshot) {
        setState(() {
          _list
              .add(Medicine(ds.data['name'], ds.data['cost'], ds.data['packSize']));
          sortParam = 'name';
        });
      }
    });
  }

  void searchOperation(String searchText) {
    searchresult.clear();
    if (_isSearching) {
      for (Medicine med in _list) {
        if (med.name.toLowerCase().contains(searchText)) searchresult.add(med);
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
        "Search Sample",
        style: new TextStyle(color: Colors.white),
      );
      searchresult.clear();
      _isSearching = false;
      _controller.clear();
    });
  }

  List<String> choices = <String>[
    "name",
    "cost",
    "packSize",
    "name desc",
    "cost desc",
    "packSize desc",
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
                          Medicine currMedicine = searchresult[index];
                          return ListTile(
                            title: Text(currMedicine.name),
                            subtitle:
                                Text("Price " + currMedicine.cost.toString()),
                          );
                        },
                      )
                    : _list.length != 0
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: _list.length,
                            itemBuilder: (BuildContext context, int index) {
                              Medicine currMedicine = _list[index];
                              return ListTile(
                                title: Text(currMedicine.name),
                                subtitle: Text("Packet Size "+currMedicine.size.toString()+"\n"+
                                    "Price " + currMedicine.cost.toString()),
                              );
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
            onSelected: (String choice){
              setState(() {
                _list.sort((Medicine a, Medicine b) {
                  if (choice == "name")
                    return a.name.compareTo(b.name);
                  else if (choice == "cost")
                    return a.cost.compareTo(b.cost);
                  else if(choice == "packSize")
                    return a.size.compareTo(b.size);
                  else if (choice.split(" ")[0] == "name")
                    return b.name.compareTo(a.name);
                  else if(choice.split(" ")[0] == "packSize")
                    return b.size.compareTo(a.size);
                  else
                    return b.cost.compareTo(a.cost);
                });
              });
  
            },
          )
        ],
      ),
    );
  }
}
