import 'dart:io';
import 'dart:typed_data';

import 'package:Mem/Values/values.dart';
import 'package:Mem/custom/widgets/custom_text.dart';
import 'package:Mem/utils/slide_right_route.dart';
// import 'package:Mem/views/Tabs/addMeeting.dart';
import 'package:aws_rekognition_api/rekognition-2016-06-27.dart' as aws;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class Tab2 extends StatefulWidget {
  const Tab2({super.key});

  @override
  State<Tab2> createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  File? newimage2;
  Uint8List? imageBytes;
  final uuid = const Uuid();
  File? _img2;
  String? _path2;
  ImagePicker? _imagePicker2;
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
    _imagePicker2 = ImagePicker();
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
            const SizedBox(
              height: 10,
            ),
            Center(
              child: customText(
                text: 'Coremetal Meeting',
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
                      backgroundColor: AppColors.primaryColor.withOpacity(.4),
                      fixedSize: Size(size.width * 0.40, 50),
                    ),
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     SlideRightRoute(
                      //         page: AddMeeting(
                      //             usertype: false,
                      //             checkin: true,
                      //             position: position!)));
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
                      backgroundColor: AppColors.primaryColor.withOpacity(.4),
                      fixedSize: Size(size.width * 0.40, 50),
                    ),
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     SlideRightRoute(
                      //         page: AddMeeting(
                      //       usertype: false,
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
              ],
            )));
  }

// Future _getImage(
//     BuildContext context, ImageSource source, bool checkin) async {
//   setState(() {
//     _img2 = null;
//     _path2 = null;
//   });
//   final pickedFile = await _imagePicker2?.pickImage(
//       source: source,
//       imageQuality: 70,
//       preferredCameraDevice: CameraDevice.front);
//   if (pickedFile != null) {
//     _processFile(pickedFile.path).then((value) {});
//     verifySalesmanMeeting(context, pickedFile, checkin);
//   }
// }

// Future<void> verifySalesmanMeeting(
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
//         employee
//             .meetingcheckIn(file: image)
//             .then((value) => Navigator.pop(context, true));
//       } else {
//         showcheckoutform(employee, image, context);
//       }
//     } else {
//       print('Employees face verification failed');
//       Alerts.showError("User not Found ! ");
//       // Dialogs.showError(context: context);
//     }
//   } catch (e) {
//     Navigator.pop(context, true);
//     print('Face Verification error : ${e}');
//     // Dialogs.showError(context: context);
//     Alerts.showError('FaceId not found');
//     // Dialogs.showError(context: context);
//     // Future.delayed(const Duration(seconds: 5), () => Navigator.pop(context));
//   }
// }

// Future<void> showcheckoutform(
//     EmployeeProvider employee, XFile image, BuildContext context) async {
//   showGeneralDialog(
//       context: context,
//       barrierLabel: "",
//       barrierDismissible: false,
//       barrierColor: Colors.black.withOpacity(0.5),
//       transitionDuration: Duration(milliseconds: 200),
//       pageBuilder: (filtercontext, __, ___) {
//         return StatefulBuilder(builder: (context, setState) {
//           return SystemPadding(
//               child: Center(
//                   child: Container(
//             padding: EdgeInsets.all(10),
//             margin: EdgeInsets.symmetric(horizontal: 16),
//             decoration: BoxDecoration(
//                 color: AppColors.white,
//                 borderRadius: BorderRadius.circular(5)),
//             child: Material(
//               color: AppColors.white,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   customText(
//                     id: 1,
//                     text: "Check Out",
//                     color: AppColors.primaryDarkColor,
//                     weight: FontWeight.bold,
//                     textSize: 22,
//                   ),
//                   Divider(),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: customText(
//                       text: "Customer Name",
//                       id: 1,
//                       textSize: 17,
//                     ),
//                   ),
//                   Row(children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Material(
//                           color: AppColors.white,
//                           child: CustomTextFormField(
//                             maxlines: 1,
//                             id: 0,
//                             controller: employee.custnameController,
//                             labelColor:
//                                 const Color.fromRGBO(173, 173, 173, 1),
//                             hintText: "Enter customer name",
//                             hintColor: Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ]),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: customText(
//                       text: "Purpose",
//                       id: 1,
//                       textSize: 17,
//                     ),
//                   ),
//                   Row(children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Material(
//                           color: AppColors.white,
//                           child: CustomTextFormField(
//                             maxlines: 1,
//                             id: 0,
//                             controller: employee.purposeController,
//                             labelColor: AppColors.hint2,
//                             hintText: "Enter purpose",
//                             hintColor: Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ]),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: customText(
//                       text: "meeting Notes",
//                       id: 1,
//                       textSize: 17,
//                     ),
//                   ),
//                   Row(children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Material(
//                           color: AppColors.white,
//                           child: CustomTextFormField(
//                             maxlines: 3,
//                             id: 0,
//                             controller: employee.mnotesController,
//                             labelColor: AppColors.hint2,
//                             hintText: "Enter Notes",
//                             hintColor: Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ]),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(4)),
//                               backgroundColor:
//                                   AppColors.primaryColor.withOpacity(.4),
//                               fixedSize: Size(100, 50),
//                             ),
//                             onPressed: () {
//                               employee
//                                   .meetingCheckout(file: image)
//                                   .whenComplete(() => Navigator.pop(context))
//                                   .then((value) =>
//                                       Navigator.pop(context, true));
//                             },
//                             child: const Row(children: [
//                               Icon(Iconsax.arrow_down_24,
//                                   color: AppColors.white),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               customText(
//                                 text: 'Add Check Out',
//                                 id: 1,
//                                 color: AppColors.black,
//                               ),
//                             ])),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                 ],
//               ),
//             ),
//           )));
//         });
//       });
// }

// Future _processFile(String path) async {
//   setState(() {
//     _img2 = File(path);
//   });
//   _path2 = path;
//   final inputImage = InputImage.fromFilePath(path);
//   // widget.onImage(inputImage);
// }
}
