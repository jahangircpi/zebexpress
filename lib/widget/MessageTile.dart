import 'package:democab/brand_colors.dart';
import 'package:democab/model/message.dart';
import 'package:democab/requests/requestmethods.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final Message messages;
  MessageTile({this.messages});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.message),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          messages.message,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      RequestMethods.formatMyDate(messages.createdAt),
                      style: TextStyle(color: BrandColors.colorTextLight),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
