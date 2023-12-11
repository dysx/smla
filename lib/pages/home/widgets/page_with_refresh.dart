import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class PageWithRefresh extends StatefulWidget {
  const PageWithRefresh({
    Key? key,
    required this.child,
    required this.onRefresh
  }) : super(key: key);

  final Widget child;
  final Function? onRefresh;

  @override
  State<PageWithRefresh> createState() => _PageWithRefreshState();
}

class _PageWithRefreshState extends State<PageWithRefresh> {

  double floatButtonWidth = Get.width / 11;
  Offset offset = Offset(0, Get.statusBarHeight + 10);
  bool dragging = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: widget.child
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: refreshDrag()
          )
        ],
      ),
    );
  }

  Widget refreshDrag() {
    return SafeArea(
        child: Draggable(
          child: dragging ? SizedBox() : floatButton(),
          feedback: floatButton(),
          onDragStarted: (){
            setState(() {
              dragging = true;
            });
          },
          onDragEnd: (DraggableDetails details) {
            setState(() {
              dragging = false;
            });
          },
          onDraggableCanceled:
              (Velocity velocity, Offset offset) {

            // 计算组件可移动范围  更新位置信息
            setState(() {
              var x = offset.dx;
              var y = offset.dy;

              if (x < Get.width / 2) {
                x = 0;
              } else {
                x = Get.width - floatButtonWidth;
              }

              if (y < 20) {
                y = 20;
              }
              if (y > Get.height - Get.statusBarHeight - floatButtonWidth) {
                y = Get.height - Get.statusBarHeight - floatButtonWidth;
              }

              offset = Offset(x, y);

            });
          },
        )
    );
  }

  Widget floatButton() {
    return SizedBox(
      width: floatButtonWidth,
      height: floatButtonWidth,
      child: FloatingActionButton(
        backgroundColor: Colors.black.withOpacity(0.2),
        onPressed: () async {
          widget.onRefresh?.call();
        },
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }
}
