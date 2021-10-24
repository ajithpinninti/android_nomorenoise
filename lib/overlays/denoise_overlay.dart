import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
//import 'package:square_percent_indicater/square_percent_indicater.dart';

class DenoiseOverlay extends StatelessWidget {
  final ValueListenable<double> number;
  final String songname;
  final double progress;
  StreamSubscription sub;
  DenoiseOverlay(this.number, this.songname, this.sub, this.progress);
  //const DenoiseOverlay({Key key, this.number}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

              SpinKitWave(
                type: SpinKitWaveType.center,
                color: Colors.black,
                size: 50.0,
              ),
              Text('Denoising...',
                  style: TextStyle(
                    fontFamily: 'NewTegomin',
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: 15),

              //circular
              new CircularPercentIndicator(
                  radius: 60.0,
                  lineWidth: 8.0,
                  percent: progress,
                  center: new Text(
                    "", //${(progress * 100).roundToDouble()}%",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  circularStrokeCap: CircularStrokeCap.square,
                  backgroundColor: Colors.white,
                  progressColor: Colors.black),
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
                child: Text(
                  "  Don't go back .. you may lost progress !.....",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ), //fontFamily: 'NewTegomin'),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(
                height: 50,
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
