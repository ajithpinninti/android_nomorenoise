import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OutputOverlay extends StatelessWidget {
  final ValueListenable<double> number;
  final String songname;
  final double progress;
  StreamSubscription sub;
  OutputOverlay(this.number, this.songname, this.sub, this.progress);
  //const OutputOverlay({Key key, this.number}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("in child widget ${number.value}");
    Size size = MediaQuery.of(context).size;

    return new WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text(
                    'please click cancel if you want to cancel the operaion',
                    textAlign: TextAlign.center,
                  ),
                  contentTextStyle: TextStyle(
                      color: Colors.black87, fontFamily: 'NewTegomin'),
                ));
        return false;
      },
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          height: size.height * 0.8,
          width: size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 50),
              SpinKitCubeGrid(
                //type: SpinKitWaveType.center,
                color: Colors.black,
                size: 50.0,
              ),
              Text('Reconverting...',
                  style: TextStyle(
                    fontFamily: 'NewTegomin',
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: 15),
              Text('completed ${progress.round()}'),
              Text(
                  songname.length > 18
                      ? "Audio - ${songname.replaceRange(18, songname.length, '...')}"
                      : 'Audio - $songname',
                  style: TextStyle(
                    fontFamily: 'NewTegomin',
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: 15),
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: Text(" Don't  do back .. you may lost progress !.....",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ),
              SizedBox(
                height: 50,
              ),
              // ignore: deprecated_member_use
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
                    sub?.cancel();

                    Navigator.of(context).popUntil((route) => route.isFirst);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
