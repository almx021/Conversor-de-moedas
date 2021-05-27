import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=2d4a0cf1";

void main() async {
  runApp(MaterialApp(
    title: 'Conversor de moedas',
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double dolar;
  late double euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _clearAll(String label) {
    switch (label) {
      case "r":
        dolarController.text = "";
        euroController.text = "";
        break;
      case "d":
        realController.text = "";
        euroController.text = "";
        break;
      case "e":
        realController.text = "";
        dolarController.text = "";
        break;
    }
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll("r");
      return;
    }

    String clean = text.replaceAll(',', '.');
    double real = double.parse(clean);

    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll("d");
      return;
    }
    String clean = text.replaceAll(',', '.');
    double dolar = double.parse(clean);

    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll("e");
      return;
    }
    String clean = text.replaceAll(',', '.');
    double euro = double.parse(clean);

    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro) / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text(
                "Carregando dados",
                style: TextStyle(color: Colors.amber, fontSize: 25.0),
                textAlign: TextAlign.center,
              ));
            default:
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                  "Erro ao Carregar Dados :(",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              }
              dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
              euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
              return SingleChildScrollView(
                padding: EdgeInsets.all(10.0),
                //controller: snapshot,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(Icons.monetization_on,
                        size: 125.0, color: Colors.amber),
                    buildTextField(
                        "Reais", "R\$", realController, _realChanged),
                    Divider(color: Colors.transparent),
                    buildTextField(
                        "Dólares", "US\$", dolarController, _dolarChanged),
                    Divider(color: Colors.transparent),
                    buildTextField("Euros", "€", euroController, _euroChanged),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Widget buildTextField(String label, String prefix,
      TextEditingController inputController, Function f) {
    return TextField(
      controller: inputController,
      onChanged: (String text) {
        f(text);
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix,
      ),
      style: TextStyle(color: Colors.amber, fontSize: 25),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
  }
}
