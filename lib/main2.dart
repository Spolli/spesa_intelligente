/************************************/

import 'package:flutter/material.dart';
import 'package:spesa_intelligente/Utility/DBHelper.dart';
import 'dart:async';
import 'package:spesa_intelligente/Model/Spese.dart';

void main() {
  runApp(MaterialApp(
    title: 'Home',
    home: MyApp(),
    theme: ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.lightBlue[800],
      accentColor: Colors.cyan[600],
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => new _State();
}

class _State extends State<MyApp> {
  static var listView;
  bool _vis = false;
  DBHelper _db;
  List<int> _del;

  @override
  void initState() {
    super.initState();
    this._del = new List<int>();
    this._vis = false;
    _getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Null> _getData() async {
    this._db = new DBHelper();
    var values = new List<Spesa>();
    values = await _db.getAll();
    //await new Future.delayed(new Duration(seconds: 1));
    listView = createListView(context, values);
    //return values;
  }

  List<Spesa> _getAll() {
    _getData().then((value) {
      print("DB Result: " + value.toString());
      return value;
    }).catchError((error) {
      print(error.toString());
    });
    return null;
  }

  void insertRecord(Spesa temp) async {
    _db = new DBHelper();
    _db.insert(temp);
  }

  /*
  void _updateRecord() {
    _db = new DBHelper();
    _db.getRecordById(_del.first).then(
            (value) => print(value)
    ).catchError(
            (error) => print(error.toString())
    );
    _db.close();
  }
  */
  void _deleteRecord() {
    _db = new DBHelper();
    for (int i in _del) {
      _db.delete(i);
    }
    _getData();
  }

  @override
  Widget build(BuildContext context) {


    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Spesa Intelligente"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                //_refreshRecord();
              }
          ),
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                //_updateRecord();
              }
          ),
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteRecord();
              }
          ),
        ],
      ),
      body: listView,
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => new _FormInput()),
          );
        },
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }

  Widget createListView(BuildContext context, List<Spesa> values) {
    List<bool> _checkList = new List<bool>(values.length);

    //bool _vis = false;
    for(int i = 0; i < _checkList.length; i++){
      _checkList[i] = false;
    }

    return new ListView.builder(
      padding: new EdgeInsets.all(8.0),
      itemCount: values.length,
      itemBuilder: (BuildContext contex, int index){
        return new Card(
          child: new ListTile(
            leading: new Checkbox(value: _checkList[index], onChanged: (bool value){
              setState(() {
                if(value){
                  this._del.add(values[index].id);
                  this._vis = true;
                } else{
                  this._del.remove(values[index].id);
                  if(this._del.length == 0) {
                    this._vis = false;
                  }
                }
                _checkList[index] = value;
              });
            }),
            title: new Text(values[index].dt_spesa),
            trailing: new Text(values[index].costo.toString() + "\€"),
            subtitle: new Text(values[index].descrizione),
            onLongPress: (){
              setState(() {
                _checkList[index] = true;
                this._del.add(values[index].id);
                this._vis = true;
              });
            },
          ),
        );
      },
    );
  }
}



class _FormInput extends StatefulWidget {
  @override
  _FormInputState createState() {
    return new _FormInputState();
  }
}

class _FormInputState extends State<_FormInput> {
  final _formKey = GlobalKey<FormState>();
  Spesa _data = new Spesa(null, null, null);
  DateTime _date = new DateTime.now();
  DBHelper db;


  Key dt = new GlobalKey(debugLabel: 'inputText');
  Key costo = new GlobalKey(debugLabel: 'inputText');
  Key descr = new GlobalKey(debugLabel: 'inputText');

  void insert(Spesa s) async{
    db = new DBHelper();
    await db.insert(s);
    db.close();
  }

  Future<Null> selectDate(BuildContext contex) async{
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: new DateTime.now().subtract(new Duration(days: 30)),
      lastDate: new DateTime.now().add(new Duration(days: 30)),
    );

    if(picked != null && picked != _date){
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Add Record"),
      ),
      body: new Center(
          child: new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                padding: new EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  new TextFormField(
                    key: dt,
                    decoration: new InputDecoration(
                      icon: new IconButton(
                        icon: new Icon(Icons.calendar_today),
                        onPressed: (){
                          selectDate(context);
                        },
                      ),
                      hintText: 'Enter Date',
                      labelText: 'Date',
                    ),
                    keyboardType: TextInputType.datetime,
                    initialValue: _date.toIso8601String().substring(0, 10),
                    onSaved: (String value) {
                      this._data.dt_spesa = value;
                    },
                  ),
                  new TextFormField(
                    key: costo,
                    decoration: new InputDecoration(
                      icon: new Icon(Icons.monetization_on),
                      hintText: 'Enter Costo Spesa',
                      labelText: '\$',
                    ),
                    keyboardType: TextInputType.number,

                    onSaved: (String value) {
                      this._data.costo = double.tryParse(value);
                    },
                  ),
                  new TextFormField(
                    key: descr,
                    decoration: new InputDecoration(
                      icon: new Icon(Icons.edit),
                      hintText: 'Enter Descrizione Spesa',
                      labelText: 'Descrizione',
                    ),
                    keyboardType: TextInputType.text,
                    onSaved: (String value) {
                      this._data.descrizione = value;
                    },
                  ),
                  new Divider(
                    color: Colors.white,
                  ),
                  new Container(
                      width: screenSize.width,
                      child: new RaisedButton(
                        child: new Text('Submit'),
                        onPressed: (){
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            DBHelper _db = new DBHelper();
                            _db.insert(_data);
                            Navigator.pop(context);
                          }
                        },
                      )),
                  new Divider(
                    color: Colors.white,
                  ),
                  new Container(
                      width: screenSize.width,
                      child: new RaisedButton(
                        child: new Text('Cancel'),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      )),
                ],
              ))),
    );
  }

}
