import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
//import 'package:noisereduction/loading/loading.dart';
import 'package:noisereduction/splashscreen.dart';
import 'package:noisereduction/details/details_screen.dart';
import 'package:noisereduction/music_player.dart';
import 'package:noisereduction/tracks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';

//import 'package:noisereduction/backend/file_create.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  SongInfo a;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'No Noise',
      initialRoute: '/',
      routes: {
        '/': (context) => Mysplash(),
        '/home': (context) => Home(),
        '/music_player': (context) => MusicPlayer(
              songInfo: a,
              song2: '',
              fromhome: true,
            ),
        '/home/music_player/tracks': (context) => Tracks(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
