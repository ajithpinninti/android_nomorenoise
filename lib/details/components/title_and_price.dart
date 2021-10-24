import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

import 'package:noisereduction/constants.dart';
import 'package:noisereduction/music_player.dart';

class TitleAndPrice extends StatelessWidget {
  const TitleAndPrice({
    Key key,
    this.title,
    this.country,
    this.statement,
    this.size,
  }) : super(key: key);

  final String title, country;
  final String statement;
  final Size size;

  @override
  Widget build(BuildContext context) {
    //const height = size.height;
    //print(size.width)
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: size.height * 0.2,
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$title\n",
                      style: Theme.of(context).textTheme.headline4.copyWith(
                          color: kTextColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NewTegomin'),
                    ),
                    TextSpan(
                      text: country,
                      style: TextStyle(
                          fontSize: 20,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NewTegomin'),
                    ),
                  ],
                ),
              ),
              //Spacer(),
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    SongInfo a;
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MusicPlayer(
                              songInfo: a,
                              song2: '',
                              fromhome: true,
                            )));
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/sound_icon.png'),
                    radius: 50.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
