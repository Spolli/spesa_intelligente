import 'package:flutter/material.dart';

class _FormInput extends StatefulWidget {
  @override
  _FormInputState createState() {
    return new _FormInputState();
  }
}

class _SubmitRecord{
  String dt = "";
  String costo = "";
  String descrizione = "";
}

class _FormInputState extends State<_FormInput> {
  final _formKey = GlobalKey<FormState>();
  _SubmitRecord _data = new _SubmitRecord();

  Key dt = new GlobalKey(debugLabel: 'inputText');
  Key costo = new GlobalKey(debugLabel: 'inputText');
  Key descr = new GlobalKey(debugLabel: 'inputText');

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
                          tooltip: 'Open Calendar',
                          onPressed: () => showDatePicker(
                            context: context,
                            initialDate: new DateTime.now(),
                            firstDate:
                            new DateTime.now().subtract(new Duration(days: 30)),
                            lastDate: new DateTime.now().add(new Duration(days: 30)),
                          ),
                      ),
                      hintText: 'Enter Date',
                      labelText: 'Date',
                    ),
                    keyboardType: TextInputType.datetime,
                    initialValue: new DateTime.now().toIso8601String().substring(0, 10),
                    onSaved: (String value) {
                      this._data.dt = value;
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
                      this._data.costo = value;
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
                            /*TODO salvare le informazioni sul database*/
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
