import 'package:democab/brand_colors.dart';
import 'package:democab/model/prediction.dart';
import 'package:democab/requests/widgetmethods.dart';
//import 'package:Taxi/screens/shareridepage.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  PredictionTile({this.prediction});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        MyMethods.getPlaceDetails(prediction.placeId, context);
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
