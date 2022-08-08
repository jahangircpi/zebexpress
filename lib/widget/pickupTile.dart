import 'package:democab/brand_colors.dart';
import 'package:democab/dataprovider/appdata.dart';
import 'package:democab/model/prediction.dart';
import 'package:democab/requests/widgetmethods.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class PickupTile extends StatelessWidget {
  final Prediction prediction;
  final TextEditingController pick;
  PickupTile({this.prediction, this.pick});
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        pick.text = prediction.mainText;
        Provider.of<AppData>(context, listen: false).checkPickup(true);
        MyMethods.pickAddress(prediction.placeId, context);
      },
      padding: EdgeInsets.all(0),
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 8.0,
            ),
            Row(
              children: [
                Icon(
                  OMIcons.locationOn,
                  color: BrandColors.colorDimText,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prediction.mainText,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        prediction.secondaryText,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, color: BrandColors.colorDimText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8.0,
            ),
          ],
        ),
      ),
    );
  }
}
