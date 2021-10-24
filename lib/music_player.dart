import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:noisereduction/backend/checking.dart';
import 'package:noisereduction/components/icon_card2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:noisereduction/saved_tracks.dart';
import 'package:noisereduction/tracks.dart';
import 'package:noisereduction/details/details_screen.dart';
import 'package:ndialog/ndialog.dart';

String save_path; //
String title; //title of song
String demo_path = path; //path for demo audio at first time

class MusicPlayer extends StatefulWidget {
  SongInfo songInfo;
  String song2;
  bool fromhome;
  bool frompicker;
  String pickerpath;
  FlutterAudioQuery a = FlutterAudioQuery();
  //Function changeTrack;
  final GlobalKey<MusicPlayerState> key;
  MusicPlayer({
    this.songInfo,
    this.song2,
    this.fromhome,
    this.frompicker,
    this.pickerpath,
    this.key,
  }) : super(key: key);
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  double minimumValue = 0.0, maximumValue = 0.0, currentValue = 0.0;
  String currentTime = '', endTime = '';

  List<SongInfo> songs = [];
  bool isPlaying = false;
  bool isPlaying2 = false;
  bool isStopped = true;
  final AudioPlayer player = AudioPlayer();
  final AudioPlayer player2 = AudioPlayer();
  //noise_cancelling noise = noise_cancelling();
  String song_path = '';
  String output_path = '';

  void initiatingstate() async {}

  void initState() {
    super.initState();
    player.stop();
    player2.stop();
    if (widget.fromhome) {
      var a;
      setSong1(a, true);
      setSong2(a, a, true);
    } else if (widget.frompicker) {
      //initiatingstate();
      output_path = widget.song2;
      var a;
      setSong1(a, false, true);
      setSong2(a, output_path, false, true);
      save_path = output_path;
      title = widget.pickerpath.split('/').last;
      title = title.replaceRange(title.length - 4, title.length, "");
    } else {
      setSong1(widget.songInfo);

      song_path = widget.songInfo.filePath;
      output_path = widget.song2;
      // noise.denoise(song_path, output_path);
      setSong2(widget.songInfo, output_path);
      save_path = output_path;
      title = widget.songInfo.title;
    }
  }

  void dispose() {
    super.dispose();
    player?.dispose();
    player2?.dispose();
  }

  Future<void> setSong1(
      [SongInfo songInfo,
      bool fromhome = false,
      bool frompicker = false]) async {
    if (fromhome) {
      print('coming to setsong from home');
      //await player.setUrl(Uri.file('$demo_path/test.wav').toString());
      await player.setAsset('assets/test.wav');
    } else if (frompicker) {
      await player.setUrl(Uri.file(widget.pickerpath).toString());
    } else {
      widget.songInfo = songInfo;
      print(widget.songInfo.uri);
      print(widget.songInfo.filePath.split('/').last);

      await player.setUrl(widget.songInfo.uri);
      //String a = song_path;
    }

    currentValue = minimumValue;
    maximumValue = player.duration.inMilliseconds.toDouble() + 2;
    setState(() {
      currentTime = getDuration(currentValue);
      endTime = getDuration(maximumValue);
    });
    isPlaying = false;
    //changeStatus();
    player.positionStream.listen((duration) {
      currentValue = duration.inMilliseconds.toDouble();
      if (currentValue >= maximumValue - 1) {
        currentValue = minimumValue;
        player.stop();
        changeStatus();
      }
      setState(() {
        currentTime = getDuration(currentValue);

        //print('in 1st');
        //print(currentTime);
      });
    });
  }

  Future<void> setSong2(
      [SongInfo songInfo,
      String output_path,
      bool fromhome = false,
      bool frompicker = false]) async {
    if (fromhome) {
      await player2.setAsset('assets/test_denoise.wav');
    } else if (frompicker) {
      await player2.setUrl(Uri.file(output_path).toString());
      print('player2. setted');
    } else {
      widget.songInfo = songInfo;
      print("emitooo ... ${Uri.file(output_path).toString()}");
      //await player2.setFilePath("$output_path.wav");
      //await player2.setFilePath(output_path);

      await player2.setUrl(Uri.file(output_path).toString());
      print('player2. setted');
    }
    currentValue = minimumValue;
    maximumValue = player2.duration.inMilliseconds.toDouble() + 1;
    setState(() {
      currentTime = getDuration(currentValue);
      endTime = getDuration(maximumValue);
    });
    isPlaying2 = false;
    //changeStatus();
    player2.positionStream.listen((duration) {
      currentValue = duration.inMilliseconds.toDouble();
      if (currentValue >= maximumValue - 1) {
        currentValue = minimumValue;
        player2.stop();
        changeStatus2();
      }
      //print(getDuration(currentValue));
      setState(() {
        currentTime = getDuration(currentValue);
      });
    });
  }

  void changeStatus() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      //player2.pause();
      player.play();
      player2.stop();
      setState(() {
        isPlaying2 = false;
        isStopped = false;
      });
      isStopped = false;
    } else {
      player.pause();
      //player2.play();
    }
  }

  void changeStatus2() {
    setState(() {
      isPlaying2 = !isPlaying2;
    });
    if (isPlaying2) {
      //player.pause();
      player.stop();
      player2.play();
      setState(() {
        isPlaying = false;
        isStopped = true;
      });
    } else {
      player2.pause();
      //player.play();
    }
  }

  String getDuration(double value) {
    Duration duration = Duration(milliseconds: value.round());

    return [duration.inMinutes, duration.inSeconds]
        .map((element) => element.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  void showdialoguescreen(String message) {
    Center(
      child: Expanded(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              RaisedButton(
                child: Text('Audio',
                    style: TextStyle(
                      fontFamily: 'NewTegomin',
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              SizedBox(height: 10),
              RaisedButton(
                child: Text('$message',
                    style: TextStyle(
                      fontFamily: 'NewTegomin',
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget build(context) {
    Size size = MediaQuery.of(context).size;

    //print(currentValue);
    return new WillPopScope(
      onWillPop: () async {
        player.stop();
        player2.stop();
        Navigator.of(context).pop(); //Until((route) => route.isFirst);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.black)),
          title: Text('Make Noiseless', style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.fromLTRB(5, 15, 5, 0),
          child: Column(children: <Widget>[
            SizedBox(
              height: size.height * 0.25,
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        AssetImage('assets/images/music_gradient.jpg'),
                    radius: 45,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: widget.fromhome
                        ? Text(
                            'Demo Audio',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600),
                          )
                        : Text(
                            songname.length > 30
                                ? songname.replaceRange(
                                    30, songname.length, '...')
                                : songname,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: widget.fromhome || widget.frompicker
                        ? Text("")
                        : Text(
                            widget.songInfo.artist.length > 30
                                ? widget.songInfo.artist.replaceRange(
                                    30, widget.songInfo.artist.length, '...')
                                : widget.songInfo.artist,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500),
                          ),
                  ),
                  Slider(
                    inactiveColor: Colors.black12,
                    activeColor: Colors.black,
                    min: minimumValue,
                    max: maximumValue + 2,
                    value: currentValue,
                    onChanged: (value) {
                      currentValue = value;
                      isStopped
                          ? player2.seek(
                              Duration(milliseconds: currentValue.round()))
                          : player.seek(
                              Duration(milliseconds: currentValue.round()));
                      //player.seek(Duration(milliseconds: currentValue.round()));
                      //player2.seek(Duration(milliseconds: currentValue.round()));
                    },
                  ),
                  Container(
                    transform: Matrix4.translationValues(0, -15, 0),
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(currentTime,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500)),
                        Text(endTime,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.6,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(children: [
                          GestureDetector(
                            child: Icon(
                                isPlaying
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_fill_rounded,
                                color: Colors.black,
                                size: 85),
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              changeStatus();
                              //changeStatus2();
                            },
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: SvgPicture.asset('assets/icons/noise.svg',
                                height: size.height * 0.03,
                                color: Colors.black,
                                width: 20.0,
                                fit: BoxFit.cover),
                          ),
                          Text('Noised',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ]),
                        Column(
                          children: [
                            GestureDetector(
                              child: Icon(
                                  isPlaying2
                                      ? Icons.pause_circle_filled_rounded
                                      : Icons.play_circle_fill_rounded,
                                  color: Colors.black,
                                  size: 85),
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                //changeStatus();
                                changeStatus2();
                              },
                            ),
                            SvgPicture.asset('assets/icons/noiseless.svg',
                                height: size.height * 0.05,
                                //width: size.width * 0.1,
                                color: Colors.black,
                                width: 20.0,
                                fit: BoxFit.cover),
                            Text('Denoised',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: size.height * 0.001),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                print('came into saving');
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          content: Center(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.white,
                                              ),
                                              // height: size.height * 0.8,
                                              // width: size.width * 0.9,
                                              child: Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(height: 50),
                                                    RawMaterialButton(
                                                      child: Text('WAV',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      onPressed: () async {
                                                        print('wav clicked');

                                                        ProgressDialog
                                                            progressDialog =
                                                            ProgressDialog(
                                                          context,
                                                          message: Text(
                                                              "Loading .... "),
                                                          title: Text(""),
                                                          dialogTransitionType:
                                                              DialogTransitionType
                                                                  .Bubble,
                                                        );
                                                        progressDialog.show();

                                                        String output_path =
                                                            "storage/emulated/0/rnnoise";
                                                        try {
                                                          File f = File(
                                                              '$output_path/${title}_cleaned.wav');
                                                          await f.exists().then(
                                                              (value) => f
                                                                  .deleteSync());
                                                        } catch (e) {}

                                                        print(
                                                            "$output_path/${title}_cleaned.wav");
                                                        await flutterFFmpeg
                                                            .execute(
                                                                "-i '$save_path' '$output_path/${title}_cleaned.wav'")
                                                            .then((rc) {
                                                          print(
                                                              "FFmpeg process exited with rc $rc");
                                                        });

                                                        progressDialog.setTitle(
                                                            Text('Saved...!',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                )));
                                                        progressDialog
                                                            .setMessage(Text(
                                                                '$output_path/${title}_cleaned.wav'));
                                                        await Future.delayed(
                                                            Duration(
                                                                seconds: 3));
                                                        progressDialog
                                                            .dismiss();

                                                        //Navigator.pop(context);

                                                        //   Navigator.of(context)
                                                        //       .pop();
                                                        //   showdialoguescreen(
                                                        //       '$output_path/${title}_cleaned.wav');
                                                      },

                                                      elevation: 5.0,
                                                      //padding: EdgeInsets.all(3),
                                                      fillColor: Colors.green,
                                                      padding:
                                                          EdgeInsets.all(20.0),
                                                      shape: CircleBorder(),
                                                    ),
                                                    SizedBox(height: 15),
                                                    RawMaterialButton(
                                                      child: Text('MP3',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),

                                                      onPressed: () async {
                                                        print('mp3 clicked');
                                                        ProgressDialog
                                                            progressDialog =
                                                            ProgressDialog(
                                                          context,
                                                          message: Text(
                                                              "Loading .... "),
                                                          title: Text(""),
                                                          dialogTransitionType:
                                                              DialogTransitionType
                                                                  .Bubble,
                                                        );
                                                        progressDialog.show();
                                                        String output_path =
                                                            "storage/emulated/0/rnnoise";
                                                        try {
                                                          File f = File(
                                                              '$output_path/${title}_cleaned.mp3');
                                                          await f.exists().then(
                                                              (value) => f
                                                                  .deleteSync());
                                                        } catch (e) {
                                                          print(
                                                              'mp3 file not existed');
                                                        }
                                                        print(
                                                            "$output_path/${title}_cleaned.mp3");
                                                        await flutterFFmpeg
                                                            .execute(
                                                                "-i '$save_path' -acodec libmp3lame '$output_path/${title}_cleaned.mp3'")
                                                            .then((rc) {
                                                          print(
                                                              'conversion completed');
                                                          print(
                                                              "FFmpeg process exited with rc $rc");
                                                        });
                                                        progressDialog.setTitle(
                                                            Text('Saved...!',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                )));
                                                        progressDialog
                                                            .setMessage(Text(
                                                                '$output_path/${title}_cleaned.mp3'));
                                                        await Future.delayed(
                                                            Duration(
                                                                seconds: 3));
                                                        progressDialog
                                                            .dismiss();
                                                      },

                                                      elevation: 5.0,
                                                      //padding: EdgeInsets.all(3),
                                                      fillColor: Colors.blue,
                                                      padding:
                                                          EdgeInsets.all(20.0),
                                                      shape: CircleBorder(),
                                                    ),
                                                    SizedBox(height: 15),
                                                    RawMaterialButton(
                                                      child: Text('FLAC',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      onPressed: () async {
                                                        print('FLAC clicked');
                                                        ProgressDialog
                                                            progressDialog =
                                                            ProgressDialog(
                                                          context,
                                                          message: Text(
                                                              "Loading .... "),
                                                          title: Text(""),
                                                          dialogTransitionType:
                                                              DialogTransitionType
                                                                  .Bubble,
                                                        );
                                                        progressDialog.show();
                                                        String output_path =
                                                            "storage/emulated/0/rnnoise";
                                                        print(
                                                            "$output_path/${title}_cleaned.flac");
                                                        try {
                                                          File f = File(
                                                              '$output_path/${title}_cleaned.flac');
                                                          f.exists().then(
                                                              (value) => f
                                                                  .deleteSync());
                                                        } catch (e) {
                                                          print(
                                                              'file already exists');
                                                        }
                                                        await flutterFFmpeg
                                                            .execute(
//                                                              -i input.mp3 -c:a libvorbis output.ogg
                                                                "-i '$save_path' -af aformat=s16:44100 '$output_path/${title}_cleaned.flac'")
                                                            //"-i ' -c:a libvorbis '$output_path/${title}_cleaned.mp3'")
                                                            .then((rc) {
                                                          print(
                                                              'conversion completed');
                                                          print(
                                                              "FFmpeg process exited with rc $rc");
                                                        });
                                                        progressDialog.setTitle(
                                                            Text('Saved...!',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                )));
                                                        progressDialog
                                                            .setMessage(Text(
                                                                '$output_path/${title}_cleaned.flac'));
                                                        await Future.delayed(
                                                            Duration(
                                                                seconds: 3));
                                                        progressDialog
                                                            .dismiss();
                                                      },
                                                      elevation: 5.0,
                                                      //padding: EdgeInsets.all(3),
                                                      fillColor:
                                                          Colors.redAccent,
                                                      padding:
                                                          EdgeInsets.all(20.0),
                                                      shape: CircleBorder(),
                                                    ),
                                                    SizedBox(height: 15),
                                                    RawMaterialButton(
                                                      child: Text('OGG',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      onPressed: () async {
                                                        print('aac clicked');
                                                        String output_path =
                                                            "storage/emulated/0/rnnoise";
                                                        ProgressDialog
                                                            progressDialog =
                                                            ProgressDialog(
                                                          context,
                                                          message: Text(
                                                              "Loading .... "),
                                                          title: Text(""),
                                                          dialogTransitionType:
                                                              DialogTransitionType
                                                                  .Bubble,
                                                        );
                                                        progressDialog.show();
                                                        try {
                                                          File f = File(
                                                              '$output_path/${title}_cleaned.ogg');
                                                          f.exists().then(
                                                              (value) => f
                                                                  .deleteSync());
                                                        } catch (e) {
                                                          print(
                                                              'file ogg doesnt exist ');
                                                        }
                                                        print(
                                                            "$output_path/${title}_cleaned.ogg");
                                                        await flutterFFmpeg
                                                            .execute(
                                                                "-i '$save_path' -acodec libvorbis '$output_path/${title}_cleaned.ogg'")
                                                            //"-i '$save_path' -acodec libfaac '$output_path/${title}_cleaned.aac'")
                                                            .then((rc) {
                                                          print(
                                                              "FFmpeg process exited with rc $rc");
                                                        });
                                                        progressDialog.setTitle(
                                                            Text('Saved...!',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .blue,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                )));
                                                        progressDialog
                                                            .setMessage(Text(
                                                                '$output_path/${title}_cleaned.aac'));
                                                        await Future.delayed(
                                                            Duration(
                                                                seconds: 3));
                                                        progressDialog
                                                            .dismiss();
                                                      },
                                                      elevation: 5.0,
                                                      //padding: EdgeInsets.all(3),
                                                      fillColor:
                                                          Colors.redAccent,
                                                      padding:
                                                          EdgeInsets.all(20.0),
                                                      shape: CircleBorder(),
                                                    ),
                                                    SizedBox(height: 15),
                                                    RaisedButton(
                                                      onPressed: () {
                                                        print('backed ...');
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "Back",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ), //Text(
                                          //   'please click cancel if you want to cancel the operaion',
                                          //   textAlign: TextAlign.center,
                                          // ),
                                          contentTextStyle: TextStyle(
                                              color: Colors.black87,
                                              fontFamily: 'NewTegomin'),
                                        ));
                              },
                              child: IconCard(icon: "assets/icons/save.svg"),
                            ),
                            Text(
                              'Save',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NewTegomin'),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                player.stop();
                                player2.stop();
                                print('came to tacks');
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => LoaderOverlay(
                                        useDefaultLoading: false,
                                        overlayWidget: Center(
                                          child: SpinKitCubeGrid(
                                            color: Colors.red,
                                            size: 50.0,
                                          ),
                                        ),
                                        overlayOpacity: 0.9,
                                        child: Tracks())));
                                //player.pause();
                              },
                              child: IconCard(icon: "assets/icons/add.svg"),
                            ),
                            Text(
                              'Import',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NewTegomin'),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                print('Saved_files');
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => LoaderOverlay(
                                        useDefaultLoading: false,
                                        overlayWidget: Center(
                                          child: SpinKitCubeGrid(
                                            color: Colors.red,
                                            size: 50.0,
                                          ),
                                        ),
                                        overlayOpacity: 0.9,
                                        child: SavedTracks())));
                              },
                              child: IconCard(
                                  icon: "assets/icons/saved_audio.svg"),
                            ),
                            Text(
                              'Saved Files',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NewTegomin',
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                print('Go Pro');
                              },
                              child: IconCard(icon: "assets/icons/gopro.svg"),
                            ),
                            Text(
                              'Go Pro',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NewTegomin'),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}

class Saving extends StatelessWidget {
  final String saved_song;
  final bool saved;
  Saving(this.saved_song, this.saved);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return new WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          return false;
        },
        child: Expanded(
          child: Center(
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  // height: size.height * 0.3,
                  // width: size.width * 0.8,
                  child: saved
                      ? Center(
                          child: Expanded(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 50),
                                  Text('Audio Saved',
                                      style: TextStyle(
                                        fontFamily: 'NewTegomin',
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Text('$saved_song',
                                      style: TextStyle(
                                        fontFamily: 'NewTegomin',
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  RaisedButton(
                                      onPressed: () {
                                        context.loaderOverlay.hide();
                                      },
                                      child: Text('ok...!'))
                                ],
                              ),
                            ),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 50),
                            SpinKitSquareCircle(
                              color: Colors.black,
                              size: 20.0,
                            ),
                            Text('Saving ....',
                                style: TextStyle(
                                  fontFamily: 'NewTegomin',
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ))),
        ));
  }
}
