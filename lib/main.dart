import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:battery/battery.dart';
import 'package:sensors/sensors.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Method Channel Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const MethodChannel _channel =
  const MethodChannel('com.example.flutter_awareness_api_test');

  String _platformVersion = '';
  String _headphoneState = '';
  String _userState = '';
  String _userLocation = '';
  List<String> _userPlaces = [];
  String _batteryLevel = '';

  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
  <StreamSubscription<dynamic>>[];

  @override
  void initState(){
    super.initState();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));



    _checkPermission();
  }

  _checkPermission() async {
    await PermissionHandler().requestPermissions([PermissionGroup.location, PermissionGroup.activityRecognition]);
  }

  Future<String> getPlatformVersion() async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<String> getHeadphoneState() async {
    final String result = await _channel.invokeMethod('getHeadphoneState');
    return result;
  }

  Future<String> getUserState() async {
    final String result = await _channel.invokeMethod('getUserState');
    return result;
  }

  Future<String> getUserLocation() async {
    final String result = await _channel.invokeMethod('getUserLocation');
    return result;
  }

  Future<List<String>> getUserPlace() async {
    var result = await _channel.invokeMethod('getUserPlace');
    return result;
  }

  Future<int> getBattery() async {
    var battery = Battery();
    int batteryLevel = await battery.batteryLevel;
    return batteryLevel;
  }

  Widget _buildUserPlaces(){
    return ListView.builder(
        itemCount: _userPlaces.length,
        itemBuilder: (BuildContext _context, int i){
      return ListTile(
        title: Text(_userPlaces[i])
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> accelerometer =
    _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> gyroscope =
    _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Method Channel Test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text("Get Platform Version"),
              onPressed: () async {
                String result = await getPlatformVersion();
                setState(() {
                  _platformVersion = result;
                });
              },
            ),
            RaisedButton(
              child: Text("헤드폰 상태 확인"),
              onPressed: () async {
                String result = await getHeadphoneState();
                setState(() {
                  _headphoneState = result;
                });
              },
            ),
            RaisedButton(
              child: Text("사용자 상태 확인"),
              onPressed: () async {
                String result = await getUserState();
                setState(() {
                  _userState = result;
                });
              },
            ),
            RaisedButton(
              child: Text("사용자 위치 확인"),
              onPressed: () async {
                String result = await getUserLocation();
                setState(() {
                  _userLocation = result;
                });
              },
            ),
            RaisedButton(
              child: Text("사용자 장소 확인"),
              onPressed: () async {
                List<String> result = await getUserPlace();
                setState(() {
                  _userPlaces = result;
                });
              },
            ),
            RaisedButton(
              child: Text("배터리 잔량 확인"),
              onPressed: () async {
                int result = await getBattery();
                setState(() {
                  _batteryLevel ="배터리 잔량 $result%";
                });
              },
            ),
            Text(_platformVersion),
            Text(_headphoneState),
            Text(_userState),
            Text(_userLocation),
            Text("배터리: " + _batteryLevel),
            Text('Accelerometer: $accelerometer'),
            Text('UserAccelerometer: $userAccelerometer'),
            Text('Gyroscope: $gyroscope'),
          ],
        ),
      ),
    );
  }
}