import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spesa_intelligente/Model/Spese.dart';
import 'package:spesa_intelligente/Utility/DBHelper.dart';
import 'package:spesa_intelligente/main.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

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
    final dateFormat = DateFormat("EEEE, MMMM d, yyyy");
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
                      this._data.dt_spesa = value.toIso8601String();
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