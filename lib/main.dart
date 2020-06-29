import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String _platformVersion = 'Unknown';
  String _headphoneState = '';
  String _userState = '';
  String _userLocation = '';
  List<String> _userPlaces = [];

  Map<String, String> _data = {
    'platformVersion' : '',
    'headphoneState'  : '',
    'userState'       : '',
    'userLocation'    : '',
  };
  
  @override
  void initState(){
    super.initState();
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
    List<String> result = await _channel.invokeMethod('getUserPlace');
    return result;
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
                print(result);
                setState(() {
                  _userPlaces = result;
                });
              },
            ),
            Text(_platformVersion),
            Text(_headphoneState),
            Text(_userState),
            Text(_userLocation),
          ],
        ),
      ),
    );
  }
}