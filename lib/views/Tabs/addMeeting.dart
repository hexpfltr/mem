// import 'dart:io';

// import 'package:Mem/Values/values.dart';
// import 'package:Mem/custom/widgets/custom_text.dart';
// import 'package:Mem/custom/widgets/custom_textfield.dart';
// import 'package:Mem/custom/widgets/dialog.dart';
// import 'package:Mem/custom/widgets/systempadding.dart';
// import 'package:Mem/providers/employee_provider.dart';
// import 'package:aws_rekognition_api/rekognition-2016-06-27.dart' as aws;
// import 'package:camera/camera.dart';
// import 'package:face_camera/face_camera.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:provider/provider.dart';

// class AddMeeting extends StatefulWidget {
//   final bool usertype;
//   final bool checkin;
//   final Position position;
//   const AddMeeting(
//       {super.key,
//       required this.usertype,
//       required this.checkin,
//       required this.position});

//   @override
//   State<AddMeeting> createState() => _AddMeetingState();
// }

// class _AddMeetingState extends State<AddMeeting> {
//   bool usertype = true;
//   final rekognition = aws.Rekognition(
//       region: StringConst.REGION,
//       credentials: aws.AwsClientCredentials(
//         accessKey: StringConst.ACCESS_KEY,
//         secretKey: StringConst.SECRET_KEY,
//       ));

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: AppColors.white,
//         body: SmartFaceCamera(
//           imageResolution: ImageResolution.high,
//           autoCapture: false,
//           showFlashControl: false,
//           showCameraLensControl: false,
//           defaultCameraLens: CameraLens.front,
//           message: widget.checkin == true
//               ? 'Check In\nCenter your face in the square'
//               : 'Check Out\nCenter your face in the square',
//           onCapture: (File? image) {
//             print("image captured");
//             verifySalesmanMeeting(context, XFile(image!.path), widget.checkin);
//           },
//         ),
//       ),
//     );
//   }

//   Future<void> verifySalesmanMeeting(
//       BuildContext context, XFile image, bool checkin) async {
//     EmployeeProvider employee =
//         Provider.of<EmployeeProvider>(context, listen: false);
//     if (image == null) {
//       print('Image capture canceled.');
//       return;
//     }
//     final imageBytes = File(image.path).readAsBytesSync();
//     Dialogs.showLoading();
//     try {
//       final searchFacesResponse = await rekognition.searchFacesByImage(
//         collectionId: StringConst.GROUP_ID,
//         image: aws.Image(bytes: Uint8List.fromList(imageBytes)),
//       );
//       //  ------------------------------------------------------------------->-
//       if (searchFacesResponse.faceMatches!.isNotEmpty) {
//         print('Employees face verified successfully');
//         print(searchFacesResponse.faceMatches!.first.face!.externalImageId);

//         String inputString =
//             searchFacesResponse.faceMatches!.first.face!.externalImageId!;
//         int decimalPointIndex = inputString.indexOf(".");
//         String personId = inputString.substring(0, decimalPointIndex);
//         String emplyeId = inputString.substring(decimalPointIndex + 1);
//         if (checkin == true) {
//           employee
//               .meetingcheckIn(file: image, pos: widget.position)
//               .then((value) => Navigator.pop(context, true));
//         } else {
//           showcheckoutform(employee, image, context);
//         }
//       } else {
//         print('Employees face verification failed');
//         Alerts.showError("User not Found ! ");
//         // Dialogs.showError(context: context);
//       }
//     } catch (e) {
//       Navigator.pop(context, true);
//       print('Face Verification error : ${e}');
//       // Dialogs.showError(context: context);
//       Alerts.showError('FaceId not found');
//       // Dialogs.showError(context: context);
//       // Future.delayed(const Duration(seconds: 5), () => Navigator.pop(context));
//     }
//   }

//   Future<void> showcheckoutform(
//       EmployeeProvider employee, XFile image, BuildContext context) async {
//     showGeneralDialog(
//         context: context,
//         barrierLabel: "",
//         barrierDismissible: false,
//         barrierColor: Colors.black.withOpacity(0.5),
//         transitionDuration: Duration(milliseconds: 200),
//         pageBuilder: (filtercontext, __, ___) {
//           return StatefulBuilder(builder: (context, setState) {
//             return SystemPadding(
//                 child: Center(
//                     child: Container(
//               padding: EdgeInsets.all(10),
//               margin: EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(5)),
//               child: Material(
//                 color: AppColors.white,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     customText(
//                       id: 1,
//                       text: "Check Out",
//                       color: AppColors.primaryDarkColor,
//                       weight: FontWeight.bold,
//                       textSize: 22,
//                     ),
//                     Divider(),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: customText(
//                         text: "Customer Name",
//                         id: 1,
//                         textSize: 17,
//                       ),
//                     ),
//                     Row(children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: Material(
//                             color: AppColors.white,
//                             child: CustomTextFormField(
//                               maxlines: 1,
//                               id: 0,
//                               controller: employee.custnameController,
//                               labelColor:
//                                   const Color.fromRGBO(173, 173, 173, 1),
//                               hintText: "Enter customer name",
//                               hintColor: Colors.grey,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ]),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: customText(
//                         text: "Purpose",
//                         id: 1,
//                         textSize: 17,
//                       ),
//                     ),
//                     Row(children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: Material(
//                             color: AppColors.white,
//                             child: CustomTextFormField(
//                               maxlines: 1,
//                               id: 0,
//                               controller: employee.purposeController,
//                               labelColor: AppColors.hint2,
//                               hintText: "Enter purpose",
//                               hintColor: Colors.grey,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ]),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: customText(
//                         text: "meeting Notes",
//                         id: 1,
//                         textSize: 17,
//                       ),
//                     ),
//                     Row(children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: Material(
//                             color: AppColors.white,
//                             child: CustomTextFormField(
//                               maxlines: 3,
//                               id: 0,
//                               controller: employee.mnotesController,
//                               labelColor: AppColors.hint2,
//                               hintText: "Enter Notes",
//                               hintColor: Colors.grey,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ]),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(4)),
//                                 backgroundColor:
//                                     AppColors.primaryColor.withOpacity(.4),
//                                 fixedSize: Size(100, 50),
//                               ),
//                               onPressed: () {
//                                 employee
//                                     .meetingCheckout(
//                                         file: image, pos: widget.position)
//                                     .whenComplete(() => Navigator.pop(context))
//                                     .then((value) =>
//                                         Navigator.pop(context, true));
//                               },
//                               child: const Row(children: [
//                                 Icon(Iconsax.arrow_down_24,
//                                     color: AppColors.white),
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 customText(
//                                   text: 'Add Check Out',
//                                   id: 1,
//                                   color: AppColors.black,
//                                 ),
//                               ])),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                   ],
//                 ),
//               ),
//             )));
//           });
//         });
//   }
// }
