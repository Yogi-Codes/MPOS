import 'package:flutter/material.dart';
import 'package:six_pos/util/dimensions.dart';
import 'package:six_pos/util/styles.dart';

class CustomHeader extends StatelessWidget {
  final String headerImage;
  final String title;
  const CustomHeader(
      {Key key, @required this.title, @required this.headerImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xff0140DB),
            Color(0xff0090DB),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(headerImage, height: 30),
            SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
            Text(
              title,
              style: fontSizeMedium.copyWith(
                fontSize: Dimensions.fontSizeOverLarge,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
