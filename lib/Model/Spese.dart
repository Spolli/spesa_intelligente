import 'dart:ui';

final String tableSpese = "spese";
final String columnId = "id";
final String columnDtSpesa = "dt_spesa";
final String columnDescr = "descrizione_spesa";
final String columnCosto = "costo_spesa";

class Spesa {
  int _id;
  String _descrizione;
  String _dt_spesa;
  double _costo;
  Image _img;


  Spesa(this._dt_spesa, this._costo, this._descrizione);

  Spesa.fromMap(dynamic obj) {
    this._dt_spesa = obj[columnDtSpesa];
    this._costo = obj[columnCosto];
    this._descrizione = obj[columnDescr];
  }
  /*
  Spesa fromMap(dynamic obj){
    this._dt_spesa = obj[columnDtSpesa];
    this._costo = obj[columnCosto];
    this._descrizione = obj[columnDescr];
  }
  */
  Map<int, Spesa> toSpesa(){
    var map = new Map<int, dynamic>();
    map[_id] = new Spesa(_dt_spesa, _costo, _descrizione);
    return map;
  }


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map[columnDtSpesa] = _dt_spesa;
    map[columnCosto] = _costo;
    map[columnDescr] = _descrizione;
    map[columnId] = _id;
    return map;
  }

  void setSpesaId(int id) {
    this.id = id;
  }

  //Getter & Setter

  String get descrizione => _descrizione;

  set descrizione(String value) {
    _descrizione = value;
  }

  String get dt_spesa => _dt_spesa;

  set dt_spesa(String value) {
    _dt_spesa = value;
  }

  double get costo => _costo;

  set costo(double value) {
    _costo = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  Image get img => _img;

  set img(Image value) {
    _img = value;
  }
}