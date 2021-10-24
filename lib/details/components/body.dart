import 'package:flutter/material.dart';
import 'package:noisereduction/constants.dart';

import 'image_and_icons.dart';
import 'title_and_price.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: size.height * 0.08,
          ),
          ImageAndIcons(size: size),
          TitleAndPrice(
            title: "No More Noise",
            country:
                "Change your noise \n voice into Clean voice \n with Only one click \n :)",
            statement: "ICON",
            size: size,
          ),
          SizedBox(height: kDefaultPadding),
        ],
      ),
    );
  }
}

// class Body extends StatelessWidget {
//   @override
//   MusicPlayerState state = MusicPlayerState();
//   @protected
//   @mustCallSuper
//   void initState() {
//     //super.initState();
//     state.player.stop();
//     state.player2.stop();
//   }

//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return SingleChildScrollView(
//       child: Column(
//         children: <Widget>[
//           SizedBox(
//             height: size.height * 0.08,
//           ),
//           ImageAndIcons(size: size),
//           TitleAndPrice(
//             title: "No More Noise",
//             country:
//                 "Change your noise \n voice into Clean voice \n with Only one click \n :)",
//             statement: "ICON",
//             size: size,
//           ),
//           SizedBox(height: kDefaultPadding),
//         ],
//       ),
//     );
//   }
// }

//bottm buttons
