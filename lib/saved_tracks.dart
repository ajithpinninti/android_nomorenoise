import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'overlays/getting_tacks.dart';

class SavedTracks extends StatefulWidget {
  @override
  _SavedTracksState createState() => _SavedTracksState();
}

class _SavedTracksState extends State<SavedTracks> {
  List<FileSystemEntity> _songs = [];
  void getTracks() async {
    _songs = [];
    //context.loaderOverlay.show(widget: Gettracks());
    Directory dir = Directory('/storage/emulated/0/rnnoise');
    String mp3Path = dir.toString();
    print(mp3Path);
    List<FileSystemEntity> _files;

    bool is_playing = false;
    _files = dir.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity entity in _files) {
      String path = entity.path;
      _songs.add(entity);
    }

    print(_songs.elementAt(2).toString());
    //context.loaderOverlay.hide();
    is_playing = false;
  }

  void initState() {
    super.initState();
    getTracks();
  }

  void dispose() {
    super.dispose();
    player?.dispose();
  }

  bool is_playing = false;
  final AudioPlayer player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    //is_playing;
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.blueAccent,
        //leading: ,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.black)),
        centerTitle: true,
        titleTextStyle: TextStyle(fontFamily: 'NewTegomin'),
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: is_playing
                    ? Row(
                        children: [
                          Icon(
                            Icons.pause_circle_filled,
                            size: 60,
                            color: Colors.teal[200],
                          ),
                          Text(
                            'playing...',
                            style: TextStyle(fontSize: 13, color: Colors.green),
                          )
                        ],
                      )
                    : Row(
                        children: [
                          Icon(
                            Icons.play_circle_filled,
                            size: 60,
                            color: Colors.redAccent,
                          ),
                          Text(
                            'stopped.!',
                            style: TextStyle(fontSize: 13, color: Colors.blue),
                          )
                        ],
                      ),
                onTap: () {
                  if (is_playing) {
                    player.stop();
                    setState(() {
                      is_playing = !is_playing;
                    });
                  }
                },
              ),
              Text('Cleaned Audios', style: TextStyle(color: Colors.black)),
            ]),
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: _songs.length,
        itemBuilder: (context, index) => ListTile(
            selected: false,
            leading: CircleAvatar(
                backgroundImage:
                    AssetImage('assets/images/music_gradient.jpg')),
            title: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    child: Text(
                      _songs
                          .elementAt(index)
                          .toString()
                          .split("'")[1]
                          .split('/')
                          .last,
                    ),
                    onTap: () async {
                      player.stop();

                      //player.setUrl(url)
                      print(
                          "uri is ${Uri.file(_songs.elementAt(index).toString()).toString().replaceAll("File%3A%20", "")}");
                      print("element at ${_songs.elementAt(index).toString()}");

                      await player.setUrl(Uri.file(
                              _songs.elementAt(index).toString().split("'")[1])
                          .toString());

                      //.setFilePath(_songs.elementAt(index).toString());
                      player.play();
                      setState(() {
                        print('playin gsarted');
                        is_playing = true;
                      });
                    },
                  ),
                  GestureDetector(
                    child: Icon(Icons.delete_forever),
                    onTap: () {
                      print('tapped delete');
                      print(
                          'deleting .. ${_songs.elementAt(index).toString().split("'")[1]}');
                      File dir = File(
                          _songs.elementAt(index).toString().split("'")[1]);
                      dir.deleteSync();
                      setState(() {
                        getTracks();
                      });
                    },
                  ),
                ]),
            //subtitle: Text(songs[index].artist),
            onTap: () async {
              player.stop();

              //player.setUrl(url)
              print(
                  "uri is ${Uri.file(_songs.elementAt(index).toString()).toString().replaceAll("File%3A%20", "")}");
              print("element at ${_songs.elementAt(index).toString()}");

              await player.setUrl(
                  Uri.file(_songs.elementAt(index).toString().split("'")[1])
                      .toString());

              //.setFilePath(_songs.elementAt(index).toString());
              player.play();
              setState(() {
                print('playing started');
                is_playing = true;
              });
            }),
      ),
    );
  }
}
