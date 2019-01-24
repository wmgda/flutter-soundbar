import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:letsdeal_soundboard/config.dart';
import 'package:sensors/sensors.dart';

void main() async {
  final config = await loadConfig();
  runApp(MyApp(config: config));
}

Future<String> _loadConfigAsset() async {
  return await rootBundle.loadString('assets/config.json');
}

Future loadConfig() async {
  String jsonString = await _loadConfigAsset();
  final jsonResponse = json.decode(jsonString);
  return new Config.fromJson(jsonResponse);
}

class MyApp extends StatelessWidget {
  final Config config;

  const MyApp({Key key, this.config}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Letsdeal Soundboard', config: config),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.config}) : super(key: key);

  final Config config;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioCache _audioCache = new AudioCache();
  bool _allItemsAreVisible = false;
  Timer timer;
  int tick = 5;

  _MyHomePageState() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      var x = event.x;
      var y = event.y;
      var z = event.z;

      const threshold = 35.0;
      const gravitation = 9.81;
      var delta = pow(x * x + y * y + z * z, 0.5) - gravitation;
      delta = delta < 0 ? delta * -1 : delta;

      if (delta > threshold) {
        // magic here

        setState(() {
          _allItemsAreVisible = true;
        });

        if (timer != null) {
          setState(() {
            tick = 5;
          });
          timer.cancel();
        }

        timer = new Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            tick--;
            if (tick <= 0) {
              _allItemsAreVisible = false;
              tick = 5;
            }
          });
        });
      }
    });
  }

  void _playSound(String file) async {
    _audioCache.play(file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(children: _buildItems()));
  }

  List<Widget> _buildItems() {
    print(widget.config);

    return widget.config.sounds
        .where((sound) => _allItemsAreVisible || sound.isVisible)
        .map((sound) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _playSound(sound.file),
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Row(mainAxisSize: MainAxisSize.max,children: (() {
                if (!sound.isVisible) {
                  return [
                    Expanded(flex: 1, child: Text(sound.label)),
                    Align(
                      child: Text(
                        "$tick",
                        textAlign: TextAlign.right,
                      ),
                      alignment: Alignment.centerRight,
                    )
                  ];
                } else {
                  return [Text(sound.label)];
                }
              })()),
            )))
        .toList();
  }
}
