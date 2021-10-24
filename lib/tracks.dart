import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'dart:isolate';
import 'package:noisereduction/overlays/denoise_overlay.dart';
//import 'package:noisereduction/loading/loading.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:noisereduction/details/details_screen.dart';
import 'package:noisereduction/music_player.dart';
import 'package:noisereduction/backend/checking.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:noisereduction/overlays/getting_tacks.dart';
import 'package:noisereduction/overlays/output_overlay.dart';
import 'package:percent_indicator/percent_indicator.dart';
//import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:loader_overlay/loader_overlay.dart';
//import 'package:square_percent_indicater/square_percent_indicater.dart';

double progress_value;
bool want_cancel = false;
StreamSubscription sub;
String songname;
double estimated_size;
String temp_path = path;

class Tracks extends StatefulWidget {
  _TracksState createState() => _TracksState();
}

class _TracksState extends State<Tracks> {
  final number = new ValueNotifier<double>(0.0);
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  List<SongInfo> songs = [];
  int currentIndex = 0;
  //noise_cancelling noise = noise_cancelling();
  MusicPlayerState state = MusicPlayerState();
  final GlobalKey<MusicPlayerState> key = GlobalKey<MusicPlayerState>();
  void initState() {
    super.initState();
    state.player.stop();
    state.player2.stop();
    getTracks();
  }

  void dispose() {
    super.dispose();
    state.player?.dispose();
    state.player2?.dispose();
  }

  void getTracks() async {
    context.loaderOverlay.show(widget: Gettracks());
    songs = await audioQuery.getSongs();
    setState(() {
      songs = songs;
    });
    state.player.stop();
    state.player2.stop();
    context.loaderOverlay.hide();
  }

  // void changeTrack(bool isNext) {
  //   if (isNext) {
  //     if (currentIndex != songs.length - 1) {
  //       currentIndex++;
  //     }
  //   } else {
  //     if (currentIndex != 0) {
  //       currentIndex--;
  //     }
  //   }
  //   key.currentState.setSong(songs[currentIndex]);
  // }

  Widget build(context) {
    //ProgressDialog pd = ProgressDialog(context: context);
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            //FilePicker pick = FilePicker();
            FilePickerResult result = await FilePicker.platform
                .pickFiles(type: FileType.audio, allowMultiple: false);
            if (result != null) {
              File file = File(result.files.single.path);
              String path = result.files.single.path;
              songname = path.split('/').last;
              songname = songname.replaceRange(
                  songname.length - 4, songname.length, "");
              String song_path = path;
              print(song_path);
              String output_path = "$temp_path/${songname}_cleaned";
              print(output_path);
              String input2;

              //convering input with ffmpeg
              context.loaderOverlay.show(widget: Input_convert());

              await convert_input(song_path).then((value) => input2 = value);
              //input conversion completed

              // Creating a port for communication with isolate and arguments for entry point
              final port = ReceivePort();
              final args = Noise_cancelling(input2, output_path);

              //calculating time estimation based on file size of output .wav file
              print('demo percent/sec $demo_time');
              print('temporary directory $input2');
              File temp_dir = new File(input2);
              estimated_size = 1.0 * temp_dir.lengthSync();
              // temp_dir
              //     .length()
              //     .then((value) => estimated_size = value * (1.0));
              print('estimated size $estimated_size');
              double percent_per_second = (demo_time / estimated_size);
              print('percent per second $percent_per_second');
              //updating percentage of completion in overlay loading variable
              //         const oneSec = const Duration(seconds: 1);
              double current_percent = 0.0;

              //pd.show(max: 100, msg: 'denoising');
              print('spawing started');
              context.loaderOverlay.hide();
              try {
                Isolate.spawn<Noise_cancelling>(denoise, args,
                    onError: port.sendPort, onExit: port.sendPort);
                // context.loaderOverlay.show(
                //     widget: DenoiseOverlay(
                //         number, songname, sub, current_percent));
                context.loaderOverlay.show(
                    widget:
                        DenoiseOverlay(number, songname, sub, current_percent));

                while (true) {
                  current_percent = current_percent + percent_per_second;
                  print('number value${current_percent}');
                  await Future.delayed(const Duration(milliseconds: 1700));

                  if (current_percent >= 0.98) {
                    current_percent = 0.98;
                    context.loaderOverlay.show(
                        widget: DenoiseOverlay(
                            number, songname, sub, current_percent));
                    break;
                  }

                  context.loaderOverlay.show(
                      widget: DenoiseOverlay(
                          number, songname, sub, current_percent));
                }

                sub = port.listen((_) async {
                  // Cancel a subscription after message received called
                  print("hellooooo... $_");
                  await sub?.cancel();
                  context.loaderOverlay.hide();
                  context.loaderOverlay.show(
                      widget: OutputOverlay(
                          number, songname, sub, current_percent));
                  final dir = Directory(input2);
                  dir.deleteSync(recursive: true);
                  //converting output
                  await convert_output(output_path);

                  final dir2 = Directory(output_path);
                  dir2.deleteSync(recursive: true);
                  //pd.close();
                  // Navigator.of(context).pop(
                  //     [songs[currentIndex], "$output_path.wav", false, key]);
                  var non;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  //Navigator.of(context).popAndPushNamed('routeName')
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LoaderOverlay(
                          useDefaultLoading: false,
                          overlayWidget: Center(
                            child: SpinKitCubeGrid(
                              color: Colors.black,
                              size: 50.0,
                            ),
                          ),
                          overlayOpacity: 0.9,
                          child: MusicPlayer(
                              //changeTrack: changeTrack,
                              songInfo: non,
                              song2: "$output_path.wav",
                              fromhome: false,
                              frompicker: true,
                              pickerpath: song_path,
                              key: key))));
                });
              } catch (e) {
                AlertDialog(
                  content: Text(
                    'No such file existed',
                    textAlign: TextAlign.center,
                  ),
                  contentTextStyle: TextStyle(
                      color: Colors.black87, fontFamily: 'NewTegomin'),
                );
              }
            } else {
              print('file not selected');
            }

            //file[0].
          },
          tooltip: 'Increment',
          child: Icon(Icons.file_upload),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios_sharp, color: Colors.black)),
          title: Text('Music App', style: TextStyle(color: Colors.black)),
        ),
        body: ValueListenableBuilder<double>(
            valueListenable: number,
            builder: (context, value, child) {
              return Container(
                child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: songs.length,
                  itemBuilder: (context, index) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage: songs[index].albumArtwork == null
                            ? AssetImage('assets/images/music_gradient.jpg')
                            : FileImage(File(songs[index].albumArtwork)),
                      ),
                      title: Text(songs[index].title),
                      subtitle: Text(songs[index].artist),
                      onTap: () async {
                        currentIndex = index;
                        SongInfo song = songs[currentIndex];

                        //for estimating time taken for denoising

                        songname = song.title;
                        String song_path = song.filePath;
                        print(song_path);
                        String output_path = "$temp_path/${song.title}_cleaned";
                        print(output_path);
                        String input2;

                        //convering input with ffmpeg
                        context.loaderOverlay.show(widget: Input_convert());

                        await convert_input(song_path)
                            .then((value) => input2 = value);
                        //input conversion completed

                        // Creating a port for communication with isolate and arguments for entry point
                        final port = ReceivePort();
                        final args = Noise_cancelling(input2, output_path);

                        //calculating time estimation based on file size of output .wav file
                        print('demo percent/sec $demo_time');
                        print('temporary directory $input2');
                        File temp_dir = new File(input2);
                        estimated_size = 1.0 * temp_dir.lengthSync();
                        // temp_dir
                        //     .length()
                        //     .then((value) => estimated_size = value * (1.0));
                        print('estimated size $estimated_size');
                        double percent_per_second =
                            (demo_time / estimated_size);
                        print('percent per second $percent_per_second');
                        //updating percentage of completion in overlay loading variable
                        //         const oneSec = const Duration(seconds: 1);
                        double current_percent = 0.0;

                        //pd.show(max: 100, msg: 'denoising');
                        print('spawing started');
                        context.loaderOverlay.hide();
                        try {
                          Isolate.spawn<Noise_cancelling>(denoise, args,
                              onError: port.sendPort, onExit: port.sendPort);
                          // context.loaderOverlay.show(
                          //     widget: DenoiseOverlay(
                          //         number, songname, sub, current_percent));
                          context.loaderOverlay.show(
                              widget: DenoiseOverlay(
                                  number, songname, sub, current_percent));

                          while (true) {
                            current_percent =
                                current_percent + percent_per_second;
                            print('number value${current_percent}');
                            await Future.delayed(
                                const Duration(milliseconds: 1700));

                            if (current_percent >= 0.98) {
                              current_percent = 0.98;
                              context.loaderOverlay.show(
                                  widget: DenoiseOverlay(
                                      number, songname, sub, current_percent));
                              break;
                            }

                            context.loaderOverlay.show(
                                widget: DenoiseOverlay(
                                    number, songname, sub, current_percent));
                          }

                          sub = port.listen((_) async {
                            // Cancel a subscription after message received called
                            print("hellooooo... $_");
                            await sub?.cancel();
                            context.loaderOverlay.hide();
                            context.loaderOverlay.show(
                                widget: OutputOverlay(
                                    number, songname, sub, current_percent));
                            final dir = Directory(input2);
                            dir.deleteSync(recursive: true);
                            //converting output
                            await convert_output(output_path);

                            final dir2 = Directory(output_path);
                            dir2.deleteSync(recursive: true);
                            //pd.close();

                            // Navigator.of(context).pop(
                            //     [songs[currentIndex], "$output_path.wav", false, key]);
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            //Navigator.of(context).popAndPushNamed('routeName')
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LoaderOverlay(
                                    useDefaultLoading: false,
                                    overlayWidget: Center(
                                      child: SpinKitCubeGrid(
                                        color: Colors.black,
                                        size: 50.0,
                                      ),
                                    ),
                                    overlayOpacity: 0.9,
                                    child: MusicPlayer(
                                        //changeTrack: changeTrack,
                                        songInfo: songs[currentIndex],
                                        song2: "$output_path.wav",
                                        fromhome: false,
                                        frompicker: false,
                                        pickerpath: "$output_path.wav",
                                        key: key))));
                          });
                        } catch (e) {
                          AlertDialog(
                            content: Text(
                              'No such file existed',
                              textAlign: TextAlign.center,
                            ),
                            contentTextStyle: TextStyle(
                                color: Colors.black87,
                                fontFamily: 'NewTegomin'),
                          );
                        }
                      }),
                ),
              );
            }));
  }
}

class Input_convert extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          height: 300,
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 20),
              SpinKitThreeBounce(
                color: Colors.black,
                size: 50.0,
              ),
              SizedBox(height: 12),
              Text('Thinking ...',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    AlertDialog(
                      content: Text(
                        'Cancelled',
                        textAlign: TextAlign.center,
                      ),
                      contentTextStyle: TextStyle(
                          color: Colors.black87, fontFamily: 'NewTegomin'),
                    );
                    flutterFFmpeg.cancel();
                    sub?.cancel();
                    //context.loaderOverlay.hide();
                    Navigator.of(context).pop();
                  })
            ],
          ),
        ),
      );
}

class Gettracks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return new WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          height: size.height * 0.3,
          width: size.width * 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              SpinKitSquareCircle(
                color: Colors.black,
                size: 20.0,
              ),
              Text('Scanning for Audio...',
                  style: TextStyle(
                    fontFamily: 'NewTegomin',
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
