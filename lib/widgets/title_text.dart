import 'package:fluent_ui/fluent_ui.dart';

class TitleText extends StatelessWidget {

  String text;


  TitleText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold),);
  }
}