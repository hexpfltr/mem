import 'dart:io';
import 'dart:typed_data';

import 'package:Mem/Values/values.dart';
import 'package:Mem/custom/widgets/custom_text.dart';
import 'package:Mem/utils/slide_right_route.dart';
import 'package:aws_rekognition_api/rekognition-2016-06-27.dart' as aws;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class Tab1 extends StatefulWidget {
  final bool usertype;

  const Tab1({super.key, required this.usertype});

  @override
  State<Tab1> createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  File? newimage;
  Uint8List? imageBytes;
  final uuid = const Uuid();
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;
  final rekognition = aws.Rekognition(
      region: StringConst.REGION,
      credentials: aws.AwsClientCredentials(
        accessKey: StringConst.ACCESS_KEY,
        secretKey: StringConst.SECRET_KEY,
      ));

  @override
  void initState() {
    super.initState();
    fetchPosition();
    _imagePicker = ImagePicker();
  }

  Position? position;

  fetchPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable your Location Service');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location Permissions are Denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location Permission are permanently denied,we cannot request permissions.');
    }
    Position currentposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      position = currentposition;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.activity5,
              color: AppColors.hint.withOpacity(.1),
              size: 80,
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: customText(
                text: 'Coremetal Attendance',
                id: 1,
                color: AppColors.hint.withOpacity(.9),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      backgroundColor: AppColors.blue,
                      fixedSize: Size(size.width * 0.40, 50),
                    ),
                    onPressed: () {
                      // _getImage(context, ImageSource.camera, true);
                      // Navigator.push(
                      //     context,
                      //     SlideRightRoute(
                      //         page: AddAttendance(
                      //       usertype: widget.usertype,
                      //       checkin: true,
                      //       position: position!,
                      //     )));
                    },
                    child: Row(children: [
                      Icon(Iconsax.arrow_up_14, color: AppColors.white10),
                      const SizedBox(
                        width: 10,
                      ),
                      const customText(
                        text: 'Check In',
                        id: 1,
                        color: AppColors.black,
                      ),
                    ])),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      backgroundColor: AppColors.blue,
                      fixedSize: Size(size.width * 0.40, 50),
                    ),
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     SlideRightRoute(
                      //         page: AddAttendance(
                      //       usertype: widget.usertype,
                      //       checkin: false,
                      //       position: position!,
                      //     )));
                    },
                    child: const Row(children: [
                      Icon(Iconsax.arrow_down_24, color: AppColors.white),
                      SizedBox(
                        width: 10,
                      ),
                      customText(
                        text: 'Check Out',
                        id: 1,
                        color: AppColors.black,
                      ),
                    ])),
                // Expanded(
                //   child: Padding(
                //     padding: const EdgeInsets.all(10.0),
                //     child: ElevatedButton(
                //         style: ElevatedButton.styleFrom(
                //           shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(4)),
                //           backgroundColor: AppColors.blue,
                //           fixedSize: Size(size.width * 0.40, 60),
                //         ),
                //         onPressed: () {
                //           Navigator.push(
                //               context,
                //               SlideRightRoute(
                //                   page: AddAttendance(
                //                       usertype: widget.usertype)));
                //         },
                //         child: Row(children: [
                //           Icon(Iconsax.arrow_up_14, color: AppColors.white10),
                //           const SizedBox(
                //             width: 10,
                //           ),
                //           const customText(
                //             text: 'Add Attendance',
                //             id: 1,
                //             textSize: 19,
                //             color: AppColors.primaryDarkColor,
                //           ),
                //         ])),
                //   ),
                // ),
              ],
            )));
  }

// Future _getImage(
//     BuildContext context, ImageSource source, bool checkin) async {
//   setState(() {
//     _image = null;
//     _path = null;
//   });
//   final pickedFile = await _imagePicker?.pickImage(
//       source: source,
//       imageQuality: 70,
//       preferredCameraDevice: CameraDevice.front);
//   if (pickedFile != null) {
//     _processFile(pickedFile.path).then((value) {});
//     verifyEmployeecheckin(context, pickedFile, checkin);
//   }
// }

// Future<void> verifyEmployeecheckin(
//     BuildContext context, XFile image, bool checkin) async {
//   EmployeeProvider employee =
//       Provider.of<EmployeeProvider>(context, listen: false);
//   if (image == null) {
//     print('Image capture canceled.');
//     return;
//   }
//   final imageBytes = File(image.path).readAsBytesSync();
//   Dialogs.showLoading();
//   try {
//     final searchFacesResponse = await rekognition.searchFacesByImage(
//       collectionId: StringConst.GROUP_ID,
//       image: aws.Image(bytes: Uint8List.fromList(imageBytes)),
//     );
//     //  ------------------------------------------------------------------->-
//     if (searchFacesResponse.faceMatches!.isNotEmpty) {
//       print('Employees face verified successfully');
//       print(searchFacesResponse.faceMatches!.first.face!.externalImageId);
//       String inputString =
//           searchFacesResponse.faceMatches!.first.face!.externalImageId!;
//       int decimalPointIndex = inputString.indexOf(".");
//       String personId = inputString.substring(0, decimalPointIndex);
//       String emplyeId = inputString.substring(decimalPointIndex + 1);
//       if (checkin == true) {
//         if (widget.usertype == true) {
//           employee.checkIn(
//               employeeid: emplyeId, personid: personId, file: image);
//         } else {
//           employee.salesmanCheckIn(file: image);
//         }
//       } else {
//         if (widget.usertype == true) {
//           employee.checkout(
//               employeeid: emplyeId, personid: personId, file: image);
//         } else {
//           employee.salesmanCheckout(file: image);
//         }
//       }
//     } else {
//       print('Employees face verification failed');
//       Alerts.showError("User not Found ! ");
//       // Dialogs.showError(context: context);
//     }
//   } catch (e) {
//     print('Face Verification error : ${e}');
//     // Dialogs.showError(context: context);
//     Alerts.showError('FaceId not found');
//     // Dialogs.showError(context: context);
//     // Future.delayed(const Duration(seconds: 5), () => Navigator.pop(context));
//   }
//   Navigator.pop(context);
// }

// Future _processFile(String path) async {
//   setState(() {
//     _image = File(path);
//   });
//   _path = path;
//   final inputImage = InputImage.fromFilePath(path);
//   // widget.onImage(inputImage);
// }
}
