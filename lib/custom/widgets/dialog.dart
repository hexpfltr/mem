import 'package:Mem/Values/values.dart';
import 'package:Mem/custom/widgets/custom_text.dart';
import 'package:Mem/custom/widgets/systempadding.dart';
import 'package:Mem/utils/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class Dialogs {
  static const spinkit =
      SpinKitRotatingPlain(color: AppColors.primaryColor, size: 50.0);

  static showLoading() {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true,
      context: GetIt.I<NavigationService>().getContext(),
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => true,
          child: const Dialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: spinkit,
          ),
        );
      },
    );
  }

  static showLoading2({
    required BuildContext context,
  }) {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => true,
          child: Dialog(
            insetAnimationDuration: const Duration(seconds: 2),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: Lottie.asset('assets/lottie/faceid.json'),
          ),
        );
      },
    );
  }

  static showAlertDialog(
      {required BuildContext context,
      required String title,
      required Widget subTitle,
      required VoidCallback yesClick}) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: SystemPadding(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                customText(
                  id: 1,
                  text: title,
                  color: AppColors.primaryDarkColor,
                  weight: FontWeight.bold,
                  textSize: 19,
                ),
                Divider(),
              ],
            ),
          ),
        ),
        actions: [
          subTitle,
          Divider(),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
                yesClick();
              },
              child: Text("Submit")),
        ],
      ),
    );
  }

  static showError({
    required BuildContext context,
  }) {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => true,
          child: Dialog(
            insetAnimationDuration: const Duration(seconds: 2),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: Lottie.asset('assets/lottie/error.json'),
          ),
        );
      },
    );
  }
}
