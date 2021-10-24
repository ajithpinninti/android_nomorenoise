import 'package:flutter/material.dart';
import 'package:noisereduction/backend/checking.dart';
import 'package:noisereduction/details/components/body.dart';
import 'package:noisereduction/music_player.dart';
import 'package:noisereduction/splashscreen.dart';
import 'package:permission_handler/permission_handler.dart';

String path = dbPath;
// ignore: non_constant_identifier_names
double demo_time;

class Home extends StatefulWidget {
  String path;
  @override
  Home({this.path});
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  MusicPlayerState state = MusicPlayerState();
  Future<void> initiating() async {
    //await Permission.storage.request();
    Permission.storage.isDenied.then((value) async {
      if (value) {
        await Permission.storage.request();
        AlertDialog(
          content: Text(
            'please give permission for furthur process',
            textAlign: TextAlign.center,
          ),
          contentTextStyle:
              TextStyle(color: Colors.black87, fontFamily: 'NewTegomin'),
        );
      }
    });

    state.player.stop();
    state.player2.stop();
    print('init state......');
    final stopwatch = Stopwatch()..start();
    print(path);
    final args = Noise_cancelling("$path/test.wav", "$path/test");
    denoise(args);
    print('doSomething() executed in ${stopwatch.elapsed}');
    demo_time = 1372160 / (stopwatch.elapsed.inSeconds);
    stopwatch..stop();
  }

  void initState() {
    print('comming.........');
    super.initState();
    initiating();
    //demo_time = no.of data bytes processing per seconds
  }

  void dispose() {
    super.dispose();
    state.player?.dispose();
    state.player2?.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(elevation: 0, backgroundColor: Color(0xFFF9F8FE)),
      body: Body(),
    );
  }
}

// class Home extends StatelessWidget {
//   @override

// }
