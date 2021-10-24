import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:noisereduction/backend/file_create.dart';
import 'package:noisereduction/details/details_screen.dart';

String temp_path = path;
final FlutterFFmpeg flutterFFmpeg = new FlutterFFmpeg();
file_handling file = file_handling();
//file.createFolder('rnnoise');
//print('loading library ........');
final ffi.DynamicLibrary rnnoise = Platform.isAndroid
    ? ffi.DynamicLibrary.open("librnnoise.so")
    : ffi.DynamicLibrary.process();
// print('library loaded successfully');
final void Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>) noMoreNoise = rnnoise
    .lookup<
        ffi.NativeFunction<
            ffi.Void Function(
                ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>('no_more_noise')
    .asFunction();

Future<String> convert_input(String input) async {
  file_handling file = file_handling();
  file.createFolder('rnnoise');
  //if (input.contains('.wav', input.length - 5)) {}
  //input = input.replaceAll(" ", "\ ");
  String output = input.split('/').last;
  //    input.split('/').last = output;
  print(input);
  output = output.replaceRange(output.length - 4, output.length, "");
  output = "$temp_path/$output.wav";
  print(output);
  //input = 'storage/emulated/0/rnnoise/test.wav';
  //output = 'storage/emulated/0/rnnoise/test_cleaned.wav'
  await flutterFFmpeg
      .execute("-i '$input' -ar 48000 -ac 1 '$output'")
      .then((rc) => print("FFmpeg process exited with rc $rc"));
  print('completed');
  return output;
}

void denoise(Noise_cancelling args) async {
  print('denoising ....... ');
  noMoreNoise(Utf8.toUtf8(args.input), Utf8.toUtf8(args.output));
  print('no more noise................');
}

Future<void> convert_output(String input) async {
  print("-f s16le -ar 48k -ac 1 -i '$input' -o '$input.wav'");
  //input = input.replaceRange(input.length - 4, input.length, "");
  await flutterFFmpeg
      .execute("-f s16le -ar 48k -ac 1 -i '$input' '$input.wav'")
      .then((rc) => print("FFmpeg process exited with rc $rc"));
}

Future<void> save_output(String input, String output) async {}

class Noise_cancelling {
  final String input;
  final String output;

  Noise_cancelling(this.input, this.output);
}
