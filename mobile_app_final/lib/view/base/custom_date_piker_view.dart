import 'package:flutter/material.dart';
import 'package:six_pos/util/dimensions.dart';
import 'package:six_pos/util/styles.dart';

class CustomDatePikerView extends StatelessWidget {
  final String date;
  const CustomDatePikerView({Key key, this.date}) : super(key: key);

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Text(date != null ? date : '2/33/2022', style: fontSizeRegular.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL),),
        trailing: Icon(Icons.work),
        visualDensity: VisualDensity(vertical: -4),
      ),
    );
  }
}
