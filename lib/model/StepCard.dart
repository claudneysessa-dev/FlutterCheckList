import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/html_parser.dart';
import 'package:flutter_app/model/StepClass.dart';

class StepCard extends StatelessWidget {
  const StepCard({Key key, this.step}) : super(key: key);

  final StepClass step;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.body1;
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new HtmlTextView(data: step.content)
//            Text(step.content, style: textStyle, overflow: TextOverflow.clip,),
//            Icon(Icons.check_box, size: 128.0, color: textStyle.color),
          ],
        ),
      ),
    );
  }
}