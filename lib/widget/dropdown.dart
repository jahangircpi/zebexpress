import 'package:democab/dataprovider/appdata.dart';
import 'package:democab/widget/BrandDivider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PayType {
  final String payType;
  const PayType(this.payType);
}

class DropDowner extends StatefulWidget {
  final Function onChanged;

  DropDowner({this.onChanged});
  @override
  _DropDownerState createState() => _DropDownerState();
}

class _DropDownerState extends State<DropDowner> {
  PayType selected;

  List<PayType> userpays = <PayType>[
    const PayType('wallet'),
    const PayType('cash'),
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      hint: Text('Select Payment'),
      value: selected,
      items: userpays.map((PayType userpay) {
        return DropdownMenuItem<PayType>(
            value: userpay,
            child: Row(
              children: [
                Text(userpay.payType),
                BrandDivider(),
              ],
            ));
      }).toList(),
      onChanged: (PayType value) {
        setState(() {
          selected = value;
          Provider.of<AppData>(context, listen: false)
              .updatePayType(value.payType);
          //print(value.payType);
        });
      },
    );
  }
}
