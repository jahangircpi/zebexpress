import 'package:democab/dataprovider/appdata.dart';
import 'package:democab/widget/BrandDivider.dart';
import 'package:democab/widget/HistoryTile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryTab extends StatefulWidget {
  @override
  _HistoryTabState createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delivery History',
          style: TextStyle(fontFamily: 'Brand-Bold'),
        ),
        backgroundColor: Colors.black,
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   icon: Icon(Icons.keyboard_arrow_left),
        // ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          return HistoryTile(
            history: Provider.of<AppData>(context).tripHistory[index],
          );
        },
        separatorBuilder: (BuildContext context, int index) => BrandDivider(),
        itemCount: Provider.of<AppData>(context).tripHistory.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
