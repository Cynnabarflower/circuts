import 'package:circuts2/widgets/plot.dart';
import 'package:fluent_ui/fluent_ui.dart';

class PlotCard extends StatelessWidget {

  PlotController controller;
  GlobalKey? key;


  PlotCard({required this.controller, this.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InfoLabel(
        label: 'График',
        child: AspectRatio(
          key: GlobalKey(),
          aspectRatio: 4/3,
          child: Plot(
              key: key,
              controller: controller
          ),
        ),
      ),
    );
  }
}