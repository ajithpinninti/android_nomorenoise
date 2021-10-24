import 'dart:ffi';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class file_handling {
  Future<Void> createFolder(String cow) async {
    final folderName = cow;
    final path = Directory("storage/emulated/0/$folderName");
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await path.exists())) {
      print(path.path);
    } else {
      path.create();
      print(path.path);
    }
  }
  // createFolder() async {
  //   final folderName = "rnnoise_c_ffi";
  //   await Permission.storage.request();
  //   final path = Directory("storage/emulated/0/$folderName");
  //   if ((await path.exists())) {
  //     // TODO:
  //     print("exist");
  //   } else {
  //     // TODO:
  //     print("not exist");
  //     path.create();
  //     print(path.path);
  //   }
  // }

}
