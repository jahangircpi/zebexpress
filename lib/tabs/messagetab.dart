import 'package:democab/brand_colors.dart';
import 'package:democab/dataprovider/appdata.dart';
import 'package:democab/globalvariable.dart';
import 'package:democab/model/message.dart';
import 'package:democab/widget/BrandDivider.dart';
import 'package:democab/widget/MessageTile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageTab extends StatefulWidget {
  @override
  _MessageTabState createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(fontFamily: 'Brand-Bold'),
        ),
        backgroundColor: BrandColors.colorPrimary,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          return Dismissible(
            direction: DismissDirection.startToEnd,
            resizeDuration: Duration(milliseconds: 200),
            onDismissed: (direction) {
              deleteMessage(
                  Provider.of<AppData>(context, listen: false).messages[index],
                  context);
              setState(() {
                Provider.of<AppData>(context, listen: false)
                    .messages
                    .removeAt(index);
              });
            },
            key: ObjectKey(Provider.of<AppData>(context).messages[index]),
            child: MessageTile(
              messages: Provider.of<AppData>(context).messages[index],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => BrandDivider(),
        itemCount: Provider.of<AppData>(context).messages.length,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }

  void deleteMessage(Message msRef, context) {
    FirebaseDatabase.instance
        .reference()
        .child('messages/${msRef.key}')
        .remove();

    FirebaseDatabase.instance
        .reference()
        .child('users/${currentFirebaseUser.uid}/message/${msRef.key}')
        .remove();
    print(msRef.key);
  }
}
