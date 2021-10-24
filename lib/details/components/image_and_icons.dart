import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:noisereduction/constants.dart';
import 'package:noisereduction/music_player.dart';
import 'icon_card.dart';
import 'package:noisereduction/backend/checking.dart';

Future<void> checking() async {
  final args =
      Noise_cancelling('assets/test.wav', 'storage/emulated/0/rnnoise/test');
  denoise(args);
}

class ImageAndIcons extends StatefulWidget {
  const ImageAndIcons({
    Key key,
    @required this.size,
  }) : super(key: key);

  final Size size;

  @override
  _ImageAndIconsState createState() => _ImageAndIconsState();
}

class _ImageAndIconsState extends State<ImageAndIcons> {
  // void initstate() async {

  // }

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding * 2),
      child: SizedBox(
        height: widget.size.height * 0.58,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: kDefaultPadding * 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Align(
                    //   alignment: Alignment.topLeft,
                    //   child: IconButton(
                    //     padding:
                    //         EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    //     icon: SvgPicture.asset("assets/icons/back_arrow.svg"),
                    //     onPressed: () {
                    //       Navigator.pop(context);
                    //     },
                    //   ),
                    // ),

//                    IconCard(icon: "assets/icons/sheep.svg"),
                    GestureDetector(
                      onTap: () {
                        print('start');
                        SongInfo a;
                        //Navigator.pushNamed(context, '/music_player');
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MusicPlayer(
                                  songInfo: a,
                                  song2: '',
                                  fromhome: true,
                                  frompicker: false,
                                )));
                      },
                      child: IconCard(icon: "assets/icons/start.svg"),
                    ),
                    GestureDetector(
                      onTap: () {
                        print('pro');
                      },
                      child: IconCard(icon: "assets/icons/gopro.svg"),
                    ),
                    GestureDetector(
                      onTap: () {
                        print('more');
                      },
                      child: IconCard(icon: "assets/icons/sheep.svg"),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: widget.size.height * 0.55,
              width: widget.size.width * 0.69,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(63),
                  bottomLeft: Radius.circular(63),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(10, 10),
                    blurRadius: 80,
                    color: kPrimaryColor.withOpacity(0.4),
                  ),
                ],
                image: DecorationImage(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.fill,
                  image: AssetImage("assets/images/mic.jpg"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
