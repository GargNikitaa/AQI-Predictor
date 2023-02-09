import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/networking.dart';
import 'card.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String currentAddress = '';
  Position? currentposition;
  dynamic aqiData;
  bool isLoading=false;
  var aqi=null;
  List<String> impurities = [
    'CO',
    'NO',
    'NO2',
    'O3',
    'SO2',
    'PM2_5',
    'PM10',
    'NH3',
  ];
  var composition = Map();

  Future<dynamic> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      setState(() {
        isLoading = true;
        currentposition = position;
        currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
    if (currentposition != Null) {
      NetworkHelper networkhelper = NetworkHelper(currentposition);
      aqiData = await networkhelper.getData();
    }
    return aqiData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Air Quality Determination', style: TextStyle(color: Colors.black))),
        backgroundColor: Colors.greenAccent.withOpacity(0.5),
      ),
      body: Container(
        color: Colors.greenAccent.withOpacity(0.1),
        child: Center(
            child: Column(
              children: [
                aqi!=null
                ?Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('AQI: $aqi', style: const TextStyle(fontSize: 50, color: Colors.green), ),
                )
                : Container(),
                Text(currentAddress, style: const TextStyle(fontSize: 15)),
                currentposition != null
                    ? Text('Latitude = ${currentposition!.latitude}', style: TextStyle(fontSize: 15))
                    : Container(),
                currentposition != null
                    ? Text('Longitude = ${currentposition!.longitude}', style: const TextStyle(fontSize: 15))
                    : Container(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                      onPressed: () async {
                        aqiData = await _determinePosition();
                        setState(() {
                          aqi = aqiData['list'][0]['main']['aqi'];
                          composition['CO'] = aqiData['list'][0]['components']['co'];
                          composition['NO'] = aqiData['list'][0]['components']['no'];
                          composition['NO2'] = aqiData['list'][0]['components']['no2'];
                          composition['O3'] = aqiData['list'][0]['components']['o3'];
                          composition['SO2'] = aqiData['list'][0]['components']['so2'];
                          composition['PM2_5'] = aqiData['list'][0]['components']['pm2_5'];
                          composition['PM10'] = aqiData['list'][0]['components']['pm10'];
                          composition['NH3'] = aqiData['list'][0]['components']['nh3'];
                        });
                      },
                    style: ButtonStyle(
                      backgroundColor:  MaterialStateProperty.all<Color>(Colors.greenAccent.withOpacity(0.1)),
                    ),
                    child: const Text('Locate me', style: TextStyle(fontSize: 20, color: Colors.black))),
                ),
                MyCardWidget(impurities: impurities, composition: composition, isLoading: isLoading, aqi: aqi),
              ],
            )),
      ),
    );
  }
}