import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Gettracks extends StatelessWidget {
  @override
  String saved_song;
  bool saved;
  Gettracks({this.saved_song, this.saved});
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
              Text('Saving ....',
                  style: TextStyle(
                    fontFamily: 'NewTegomin',
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  )),
              saved
                  ? Text("")
                  : Container(
                      child: Column(children: [
                        SizedBox(height: 15),
                        Text(
                          "song saved in $saved_song",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RaisedButton(
                          onPressed: () {},
                          child: Text('Ok..!'),
                        )
                      ]),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
