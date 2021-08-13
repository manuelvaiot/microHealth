import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  FlutterBlue _ble = FlutterBlue.instance;
  List<ScanResult> result = List();
  bool isConnected = false;
  initState(){
    super.initState();
    scanning();
  }

  scanning(){
    _ble.startScan(scanMode: ScanMode.lowLatency);
    _ble.scanResults.listen((event) {
      result = event;
    });

  }


  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  TextEditingController controler = TextEditingController();

  TextEditingController controler1 = TextEditingController();
  TextEditingController controler2 = TextEditingController();
  TextEditingController controler3 = TextEditingController();

  TextEditingController controler4 = TextEditingController();
  TextEditingController controler5 = TextEditingController();

  BluetoothDevice _Device;

  List<List<int>> BluetoothResponse = List();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MiniHealth Connectado $isConnected"),
      ),
      body: Column(
        children: <Widget>[

      Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width/2,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("MAC:"),
                  TextFormField(

                    controller: controler,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  ],
                )
            ),
          ),
          FlatButton(onPressed:() {
            Connect();
          }
          , child: Text("Connectar"))
        ],
      ),
          SizedBox(height: 100,),
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width/2,
                child: Form(
                    key: _formKey1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Serviço:"
                        ),
                        TextFormField(
                          controller: controler1,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        Text(
                            "Caracteristica:"
                        ),
                        TextFormField(
                          controller: controler2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        Text(
                            "Comando:(separado por virgulas)"
                        ),
                        TextFormField(
                          controller: controler3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                      ],
                    )
                ),
              ),
              FlatButton(onPressed:() {
                sendComand();
              }
                  , child: Text("Enviar"))
            ],
          ),

          SizedBox(height: 100,),
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width/2,
                child: Form(
                    key: _formKey2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Serviço:"
                        ),
                        TextFormField(
                          controller: controler4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        Text(
                            "Caracteristica:"
                        ),
                        TextFormField(
                          controller: controler5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),

                      ],
                    )
                ),
              ),
              FlatButton(onPressed:() {
                readComand();
              }
                  , child: Text("Enviar"))
            ],
          ),
          Text("VALOR LIDO NA CARACTERISTICA"),
          Text("$BluetoothResponse")


        ],

      ),
    );
  }


  Connect() async {
    for(ScanResult _result  in result) {
      if (controler.value.text == _result.device.id.toString()) {
          _Device = _result.device;
          await _result.device.connect();
          setState(() {
            isConnected = true;
          });
      }
    }
  }

  sendComand()async {
    List<BluetoothService> service = await  _Device.discoverServices();
    for(BluetoothService _service in service){
      if(_service.uuid.toString().contains(controler1.text.toString())){
        for(BluetoothCharacteristic characteristic in _service.characteristics){
          if(characteristic.uuid.toString().contains(controler2.text.toString())){
            List<String> data= controler3.value.text.split(",");
            List<int> command = List();
            for(String _data  in data){
                  command.add(int.parse(_data));
            }
            characteristic.write(command);
          }
        }
      }
    }
  }


  readComand() async {
    List<BluetoothService> service = await _Device.discoverServices();
    for (BluetoothService _service in service) {
      if (_service.uuid.toString().contains(controler4.text.toString())) {
        for (BluetoothCharacteristic characteristic in _service
            .characteristics) {
          if (characteristic.uuid.toString().contains(
              controler5.text.toString())) {
            if (!characteristic.isNotifying) {
              characteristic.setNotifyValue(true);
              BluetoothResponse.add(await characteristic.value.last);
            }
          }
        }
      }
    }
  }



}
