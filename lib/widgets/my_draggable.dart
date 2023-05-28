import 'package:fluent_ui/fluent_ui.dart';

class MyDraggable extends StatelessWidget {

  Widget child;


  MyDraggable({required this.child});

  @override
  Widget build(BuildContext context) {
    return Draggable(
        child: child,
        feedback: child,
      childWhenDragging: ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.grey.withOpacity(0.05), BlendMode.srcIn),
        child: child,
      ),
    );
  }
}