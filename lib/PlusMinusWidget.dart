import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlusMinusWidget extends StatelessWidget {
  final void Function()? plus;
  final void Function()? minus;

  PlusMinusWidget(this.plus, this.minus);

  @override
  Widget build(BuildContext context) {

    return
      Container(
        padding: EdgeInsets.all(5),

      child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CupertinoColors.systemBackground.withOpacity(0.7)),

      width: 80,
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(width: 30, height: 40,
            child: CupertinoButton(
              padding: EdgeInsets.zero, child: Icon(CupertinoIcons.minus, size: 18,),
                alignment: Alignment(0, 0),
                onPressed: minus,

            ),
          ),
          Container(width: 30, height: 40,
            child:  CupertinoButton(
              padding: EdgeInsets.zero, child: Icon(CupertinoIcons.plus, size: 18,),
                alignment: Alignment(0, 0),
                onPressed: plus,

            ),
          ),
        ],
      ),
      ),
    );
  }
}
