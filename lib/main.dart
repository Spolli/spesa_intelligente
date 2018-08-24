import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spesa_intelligente/Model/Spese.dart';
import 'package:spesa_intelligente/Utility/DBHelper.dart';

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
  List<int> _del = new List<int>();

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder(
      future: _getData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Center(
                child: new CircularProgressIndicator(),
              ),
            );
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return createListView(context, snapshot);
        }
      },
    );

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
                //_refreshRecord();
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
      body: futureBuilder,
      floatingActionButton: new FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  new _FormInput()),
          );
        },
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }

  Future<List<Spesa>> _getData() async {
    this._db = new DBHelper();
    var values = new List<Spesa>();
    values = await _db.getAll();
    //await new Future.delayed(new Duration(seconds: 1));
    return values;
  }

  void _deleteRecord() async{
    this._db = new DBHelper();
    for(int i in this._del){
      this._db.delete(i);
    }
    /*Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Record eliminati con successo")
    ));*/
  }

  void _spesaTotRecord() async{
    this._db = new DBHelper();
    this._db.spesaTot().then((value){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Caghi Soldi dal culo"),
            content: new Text("Spesa totale = " + value.toString() + "\€"),
          );
        },
      );
    });
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Spesa> values = snapshot.data;
    List<bool> _checkList = new List<bool>(values.length);

    //bool _vis = false;
    for(int i = 0; i < _checkList.length; i++){
      _checkList[i] = false;
    }

    return new ListView.builder(
      itemCount: values.length,
      itemBuilder: (BuildContext context, int index) {
        return new Column(
          children: <Widget>[
            new ListTile(
              leading: new Checkbox(
                  value: _checkList[index],
                  onChanged: (bool value){
                    setState(() {
                      _checkList[index] = value;
                    });
                    if(value){
                      _del.add(values[index].id);
                      //_vis = true;
                    } else{
                      _del.remove(values[index].id);
                      if(_del.length == 0) {
                        //_vis = false;
                      }
                    }
                  }),
              title: new Text(values[index].dt_spesa),
              trailing: new Text(values[index].costo.toString() + "\€"),
              subtitle: new Text(values[index].descrizione),
              onLongPress: (){
                _del.add(values[index].id);
                //_vis = true;
                setState(() {
                  _checkList[index] = true;
                });
              },
              selected: _checkList[index],
            ),
            new Divider(height: 2.0,),
          ],
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
                        color: Theme.of(context).accentColor,
                        splashColor: Colors.deepPurple,
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