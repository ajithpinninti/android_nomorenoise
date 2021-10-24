import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noisereduction/details/details_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:splashscreen/splashscreen.dart';

String dbPath;

class Mysplash extends StatefulWidget {
  Mysplash({Key key}) : super(key: key);

  @override
  _MysplashState createState() => _MysplashState();
}

class _MysplashState extends State<Mysplash> {
  @override
  Future<void> initiating() async {
    print('asking storage permission');
    await Permission.storage.request();
    print('premission asking completed');
    await Permission.storage.isDenied.then((value) async {
      print('premission denied');
      print('asking for re permission');
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

//   Directory directory = await getApplicationDocumentsDirectory();
// var dbPath = join(directory.path, "app.txt");
// ByteData data = await rootBundle.load("assets/test.wav");
// List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
// await File(dbPath).writeAsBytes(bytes);

    print('getting directory');
    Directory directory = await getApplicationDocumentsDirectory();
    //dbpath changed here
    // deleting files in temp path where saved, denoise intermediate files
    print('directory before delete ${directory.listSync()[0].path}');
    for (var dir in directory.listSync()) {
      print(dir.path);
      dir.delete();
    }
    //await directory.delete(recursive: true);
    print('directory after delete ${directory.list()}');
    //db path is directory path(changed in bottom of completion)
    dbPath = "${directory.path}/test.wav";

    //checking existance of test file for furthur denoising process in inititation of home
    if (FileSystemEntity.typeSync(dbPath) == FileSystemEntityType.notFound) {
      print('adding noised file to folder');
      ByteData data = await rootBundle.load("assets/test.wav");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes);
      print('file created');
    } else {
      print('file already existed');
    }
    dbPath = "${directory.path}";
  }

  Future<Widget> loadFromFuture() async {
    // <fetch data from server. ex. login>
    await initiating();
    return Future.value(new Home());
  }

  void initState() {
    super.initState();
    //WidgetsBinding.instance.addPostFrameCallback((_) => initiating());

    //initiating();
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Expanded(
      child: SplashScreen(
        //seconds: 2,
        navigateAfterFuture: loadFromFuture(),
        // loadingText: Text('Noise Less',
        //     style: TextStyle(
        //       fontSize: 20,
        //       fontFamily: 'NewTegomin',
        //       color: Colors.white,
        //     )),

        title: Text(
          'No More Noise',
          style: TextStyle(
              fontSize: 30,
              color: Color(0xffe3DBE29),
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              fontFamily: 'NewTegomin'),
        ),
        image: Image.asset(
          'assets/audio.png',
          height: size.height * 0.5,
        ),
        backgroundColor: Colors.black,
        photoSize: size.height * 0.2,
        loaderColor: Color(0xFFF7CD2E),
      ),
    );
  }
}
