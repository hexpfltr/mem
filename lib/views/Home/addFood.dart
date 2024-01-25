// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:Mem/Values/values.dart';
import 'package:Mem/custom/widgets/dialog.dart';
import 'package:Mem/providers/employee_provider.dart';
import 'package:Mem/utils/face_camera.dart';
import 'package:Mem/utils/smartfacecam2.dart';
import 'package:aws_rekognition_api/rekognition-2016-06-27.dart' as aws;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class AddFood extends StatefulWidget {
  final bool usertype;

  const AddFood({super.key, required this.usertype});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final rekognition = aws.Rekognition(
      region: StringConst.REGION,
      credentials: aws.AwsClientCredentials(
        accessKey: StringConst.ACCESS_KEY,
        secretKey: StringConst.SECRET_KEY,
      ));
  Future<void> fetchPosition(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: 'Location permission is required.');
      }
    }

    if (!serviceEnabled) {
      bool locationSettingsOpened = await Geolocator.openLocationSettings();
      if (!locationSettingsOpened) {
        Fluttertoast.showToast(msg: 'Failed to open location settings.');
      }
    }
    // Get the current position.
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Update the position provider.
    final positionProvider =
        Provider.of<EmployeeProvider>(context, listen: false);
    print(currentPosition.latitude);
    positionProvider.currentposition = currentPosition;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryDarkColor,
          elevation: 0,
          title: Text("Food Intake"),
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Iconsax.arrow_left_1),
          ),
        ),
        backgroundColor: AppColors.white,
        body: SmartFaceCamera2(
          imageResolution: ImageResolution.low,
          autoCapture: false,
          showFlashControl: false,
          showCameraLensControl: false,
          defaultCameraLens: CameraLens.front,
          message: 'Center your face in the square',
          onFoodIntake: (File? image) async {
            await Haptics.vibrate(HapticsType.success).then((value) =>
                verifyEmployeeFoodIntake(context, XFile(image!.path)));
          },
        ),
      ),
    );
  }

  Future<void> verifyEmployeeFoodIntake(
      BuildContext context, XFile image) async {
    EmployeeProvider employee =
        Provider.of<EmployeeProvider>(context, listen: false);

    if (image == null) {
      print('Image capture canceled.');
      return;
    }
    final imageBytes = File(image.path).readAsBytesSync();
    Dialogs.showLoading();
    try {
      final searchFacesResponse = await rekognition.searchFacesByImage(
        collectionId: StringConst.GROUP_ID,
        image: aws.Image(bytes: Uint8List.fromList(imageBytes)),
      );
      //  ------------------------------------------------------------------->-
      if (searchFacesResponse.faceMatches != null) {
        print('Employees face verified successfully');
        String inputString =
            searchFacesResponse.faceMatches!.first.face!.externalImageId!;
        int decimalPointIndex = inputString.indexOf(".");
        String personId = inputString.substring(0, decimalPointIndex);
        String emplyeId =
            inputString.substring(decimalPointIndex + 1).replaceAll('_', ' ');
        // print("object2222${employee.currentposition?.latitude}");
        int index = StringConst.GROUP_ID.length;
        String employeeIds = personId.substring(index);

        if (employee.currentposition?.latitude != null) {
          employee.addFoodIntake(
              context: context,
              employeeid: emplyeId,
              personid: personId,
              file: image,
              pos: employee.currentposition!,
              employeeids: employeeIds);
        } else {
          fetchPosition(context);
        }
      } else {
        print('Employees face verification failed');
        employee.popContext(context).then((value) => QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: "User not Found !",
            text: "User is not registered",
            animType: QuickAlertAnimType.slideInDown));
        // Dialogs.showError(context: context);
      }
    } catch (e) {
      employee.popContext(context).then((value) => QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "User not Found !",
          text: "User is not registered",
          animType: QuickAlertAnimType.slideInDown));
    }
  }
}
