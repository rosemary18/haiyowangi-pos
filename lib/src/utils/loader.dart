import 'package:flutter/material.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void showModalLoader({ Duration? duration }) async {

  rootNavigatorKey.currentState?.push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (BuildContext context, _, __) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
            insetPadding: const EdgeInsets.all(0),
            backgroundColor: const Color.fromARGB(107, 54, 54, 54),
            elevation: 0,
            child: Center(
              child: LoadingAnimationWidget.threeArchedCircle(size: 50, color: Colors.white),
            ),
          ),
        );
      },
    ),
  );

  if (duration != null) {
    await Future.delayed(duration);
    rootNavigatorKey.currentState?.pop();
  }

}

void showModalSyncLoader({ Duration? duration }) async {

  rootNavigatorKey.currentState?.push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (BuildContext context, _, __) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
            insetPadding: const EdgeInsets.all(0),
            backgroundColor: const Color.fromARGB(107, 54, 54, 54),
            elevation: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoadingAnimationWidget.threeArchedCircle(size: 50, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text("Singkronasi...", style: TextStyle(color: Colors.white))
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  if (duration != null) {
    await Future.delayed(duration);
    rootNavigatorKey.currentState?.pop();
  }

}