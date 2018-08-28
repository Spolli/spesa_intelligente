import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spesa_intelligente/Model/Spese.dart';
import 'package:spesa_intelligente/Utility/DBHelper.dart';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Spesa Intelligente',
      theme: new ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.pink[400],
        accentColor: Colors.pink[600],
      ),
      home: new MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DBHelper _db;
  static List<int> _del = new List<int>();
  static List<Spesa> _list;
  bool _vis = false;
  static List<bool> _checkList;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Spesa Intelligente"),
        actions: <Widget>[
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
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _refreshRecord();
              }
          ),
          IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                _spesaTotRecord();
              }
          ),
        ],
      ),
      body: createListView(context),
      floatingActionButton: new FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  new _FormInput()),
          );
        },
        tooltip: 'Add',
        child: new Icon(Icons.add),
      ),
    );
  }

  Future<Null> _getData() async {
    this._db = new DBHelper();
    var values = new List<Spesa>();
    values = await _db.getAll();
    setState(() {
      _list = values;
      _checkList = new List<bool>(_list.length);
      for(int i = 0; i < _checkList.length; i++){
        _checkList[i] = false;
      }
    });
    //await new Future.delayed(new Duration(seconds: 1));
  }

  void _deleteRecord() async{
    this._db = new DBHelper();
    for(int i in _del){
      await this._db.delete(i);
    }
    await _getData();
    /*Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Record eliminati con successo")
    ));*/
  }

  void _spesaTotRecord() async{
    this._db = new DBHelper();
    await this._db.spesaTot().then((value){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Caghi Soldi dal culo"),
            content: new Text("Spesa totale = " + value.toString() + "\€"),
          );
        },
      );
    }).catchError((error){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("ERROR"),
            content: new Text("Error\n" + error.toString()),
          );
        },
      );
    });
  }

  void _refreshRecord() async{
    this._db = new DBHelper();
    List<Spesa> values = await _db.getAll();
    String text = "";
    for(Spesa s in values){
      text += s.id.toString() + "\t|\t" + s.dt_spesa + "\t|\t" + s.costo.toString() + "\t|\t" + s.descrizione + "\n";
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("All Records"),
          content: new Text(text),
        );
      },
    );
  }

  Widget createListView(BuildContext context) {
    try{
      return new ListView.builder(
        itemCount: _list.length,
        itemBuilder: (BuildContext context, int index) {
          return new Column(
            children: <Widget>[
              new ListTile(
                leading: new Checkbox(
                    value: _checkList[index],
                    onChanged: (bool value){
                      setState(() {
                        if(value){
                          _del.add(_list[index].id);
                          _vis = true;
                        } else{
                          _del.remove(_list[index].id);
                          if(_del.length == 0) {
                            _vis = false;
                          }
                        }
                        _checkList[index] = value;
                      });

                    }),
                title: new Text(_list[index].dt_spesa),
                trailing: new Text(_list[index].costo.toString() + " \€"),
                subtitle: new Text(_list[index].descrizione),
                onLongPress: (){
                  setState(() {
                    if(_checkList[index]){
                      _checkList[index] = !_checkList[index];
                      _del.add(_list[index].id);
                      _vis = true;
                    } else{
                      _checkList[index] = !_checkList[index];
                      _del.remove(_list[index].id);
                      if(_del.length == 0) {
                        _vis = false;
                      }
                    }
                  });
                },
                selected: _checkList[index],
              ),
              new Divider(height: 2.0,),
            ],
          );
        },
      );
    } catch(e){
     return new Center(child: new CircularProgressIndicator());
    }
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

  Key dt = new GlobalKey(debugLabel: 'inputText');
  Key costo = new GlobalKey(debugLabel: 'inputText');
  Key descr = new GlobalKey(debugLabel: 'inputText');

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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
    final dateFormat = DateFormat("dd/MM/yyyy");
    DateTime nDate = new DateTime.now();

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
                  new DateTimePickerFormField(
                    key: dt,
                    decoration: new InputDecoration(
                      icon: new IconButton(
                        icon: new Icon(Icons.calendar_today),
                        onPressed: (){
                        },
                      ),
                      hintText: 'Enter Date',
                      labelText: 'Date',
                    ),
                    format: dateFormat,
                    keyboardType: TextInputType.datetime,
                    initialValue: nDate,
                    onChanged: (date) {
                      nDate = date;
                    },
                    onSaved: (DateTime value) {
                      this._data.dt_spesa = value.toIso8601String().substring(0, 10);
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
                        color: Theme.of(context).accentColor,
                        splashColor: Colors.deepPurple,
                        onPressed: (){
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            DBHelper _db = new DBHelper();
                            _db.insert(_data);
                            // Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  new MyHomePage()),
                            );
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
                        color: Theme.of(context).accentColor,
                        splashColor: Colors.amberAccent,
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      )),
                ],
              ))),
    );
  }

}