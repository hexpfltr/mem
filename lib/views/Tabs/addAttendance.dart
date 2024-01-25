// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:Mem/Values/values.dart';
import 'package:Mem/custom/widgets/custom_text.dart';
import 'package:Mem/custom/widgets/dialog.dart';
import 'package:Mem/providers/auth_provider.dart';
import 'package:Mem/providers/employee_provider.dart';
import 'package:Mem/utils/face_camera.dart';
import 'package:Mem/utils/search_facecamera.dart';
import 'package:Mem/utils/smartfacecam2.dart';
import 'package:Mem/views/Employees/employees.dart';
import 'package:Mem/views/Home/addFood.dart';
import 'package:Mem/views/Profile/profile.dart';
import 'package:aws_rekognition_api/rekognition-2016-06-27.dart' as aws;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AddAttendance extends StatefulWidget {
  final bool usertype;

  const AddAttendance({
    super.key,
    required this.usertype,
  });

  @override
  State<AddAttendance> createState() => _AddAttendanceState();
}

class _AddAttendanceState extends State<AddAttendance> {
  String selectedTitle = "Choose WorkType";
  final rekognition = aws.Rekognition(
      region: StringConst.REGION,
      credentials: aws.AwsClientCredentials(
        accessKey: StringConst.ACCESS_KEY,
        secretKey: StringConst.SECRET_KEY,
      ));
  @override
  void initState() {
    super.initState();
    fetchPosition(context);
  }

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
    } else if (!serviceEnabled) {
      bool locationSettingsOpened = await Geolocator.openLocationSettings();
      if (!locationSettingsOpened) {
        Fluttertoast.showToast(msg: 'Failed to open location settings.');
      }
    } else {
      // Get the current position.
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Update the position provider.
      final positionProvider =
          Provider.of<EmployeeProvider>(context, listen: false);
      positionProvider.currentposition = currentPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<EmployeeProvider>(builder: (context, provider, child) {
      return SafeArea(
          child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                    backgroundColor: AppColors.primaryDarkColor,
                    leadingWidth: 150,
                    toolbarHeight: 80,
                    actions: [
                      InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const EmployeeListView()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      AppColors.white10.withOpacity(.3),
                                  child: CircleAvatar(
                                      backgroundColor:
                                          AppColors.white.withOpacity(.4),
                                      child: const Icon(
                                        Iconsax.people,
                                        color: AppColors.white,
                                      )),
                                ),
                              ],
                            ),
                          )),
                      InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileWidget()));
                          },
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                    AppColors.white10.withOpacity(.3),
                                child: CircleAvatar(
                                    backgroundColor:
                                        AppColors.white.withOpacity(.4),
                                    child: const Icon(
                                      Iconsax.setting_2,
                                      color: AppColors.white,
                                    )),
                              ),
                            ],
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                    leading: const Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        customText(
                          text: "MEM ",
                          id: 0,
                          textSize: 23,
                        ),
                      ],
                    ),
                    bottom: widget.usertype == true
                        ? PreferredSize(
                            preferredSize: Size(size.width, 50),
                            child: AppBar(
                              centerTitle: true,
                              toolbarHeight: 45,
                              backgroundColor: AppColors.blue,
                              elevation: 0,
                              title: ToggleSwitch(
                                minWidth: size.width,
                                customTextStyles: [
                                  TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600),
                                  TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600)
                                ],
                                cornerRadius: 8.0,
                                inactiveFgColor: Colors.white,
                                initialLabelIndex:
                                    provider.foodIn == false ? 0 : 1,
                                changeOnTap: true,
                                totalSwitches: 2,
                                activeBgColor: const [
                                  AppColors.primaryDarkColor,
                                  AppColors.primaryColor
                                ],
                                labels: const ['Attendance', 'Food Intake'],
                                onToggle: (index) {
                                  print('switched to: $index');
                                  if (index == 0) {
                                    provider.foodIn = false;
                                  } else {
                                    provider.foodIn = true;
                                  }
                                },
                              ),
                            ))
                        : PreferredSize(
                            preferredSize: Size(size.width, 50),
                            child: AppBar(
                              centerTitle: true,
                              toolbarHeight: 45,
                              backgroundColor: AppColors.blue,
                              elevation: 0,
                              title: ToggleSwitch(
                                minWidth: size.width,
                                customTextStyles: [
                                  TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600),
                                  TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600)
                                ],
                                cornerRadius: 8.0,
                                inactiveFgColor: Colors.white,
                                initialLabelIndex:
                                    provider.foodIn == false ? 0 : 1,
                                changeOnTap: true,
                                totalSwitches: 2,
                                activeBgColor: const [
                                  AppColors.primaryDarkColor,
                                  AppColors.primaryColor
                                ],
                                labels: const ['Attendance', 'Meeting'],
                                onToggle: (index) {
                                  print('switched to: $index');
                                  if (index == 0) {
                                    provider.foodIn = false;
                                  } else {
                                    provider.foodIn = true;
                                  }
                                },
                              ),
                            ))),
                body: widget.usertype == true
                    ? SmartFaceCamera(
                        imageResolution: ImageResolution.medium,
                        autoCapture: false,
                        showFlashControl: false,
                        showCameraLensControl: false,
                        defaultCameraLens: CameraLens.front,
                        message: '',
                        onCheckin: (File? image) async {
                          await Haptics.vibrate(HapticsType.success).then(
                              (value) => provider.foodIn == false
                                  ? verifyEmployeecheckin(
                                      context, XFile(image!.path), true)
                                  : verifyEmployeeFoodIntake(
                                      context, XFile(image!.path)));
                        },
                        onCheckout: (File? image) async {
                          await Haptics.vibrate(HapticsType.success).then(
                              (value) => verifyEmployeecheckin(
                                  context, XFile(image!.path), false));
                        },
                        foodIn: provider.foodIn,
                      )
                    
                    : TabBarView(children: [
                        SmartFaceCamera(
                          imageResolution: ImageResolution.medium,
                          autoCapture: false,
                          showFlashControl: false,
                          showCameraLensControl: false,
                          defaultCameraLens: CameraLens.front,
                          message: '',
                          onCheckin: (File? image) async {
                            await Haptics.vibrate(HapticsType.success).then(
                                (value) => verifyEmployeecheckin(
                                    context, XFile(image!.path), true));
                          },
                          onCheckout: (File? image) async {
                            await Haptics.vibrate(HapticsType.success).then(
                                (value) => verifyEmployeecheckin(
                                    context, XFile(image!.path), false));
                          },
                          foodIn: provider.foodIn,
                        ),
                        SmartFaceCamera(
                          imageResolution: ImageResolution.medium,
                          autoCapture: false,
                          showFlashControl: false,
                          showCameraLensControl: false,
                          defaultCameraLens: CameraLens.front,
                          message: '',
                          onCheckin: (File? image) async {
                            await Haptics.vibrate(HapticsType.success).then(
                                (value) => verifyEmployeecheckin(
                                    context, XFile(image!.path), true));
                          },
                          onCheckout: (File? image) async {
                            await Haptics.vibrate(HapticsType.success).then(
                                (value) => verifyEmployeecheckin(
                                    context, XFile(image!.path), false));
                          },
                          foodIn: provider.foodIn,
                        ),
                      ]),
              )));
    });
  }

  Future<void> verifyEmployeecheckin(
      BuildContext context, XFile image, bool checkin) async {
    EmployeeProvider employee =
        Provider.of<EmployeeProvider>(context, listen: false);
    String? selectedValue;
    if (image == null) {
      print('Image capture canceled.');
      return;
    }
    final compressedImage = await FlutterImageCompress.compressWithFile(
      image.path,
      quality: 50,
    );
    // final imageBytes = await File(image.path).readAsBytes();
    Dialogs.showLoading();
    try {
      final searchFacesResponse = await rekognition.searchFacesByImage(
        collectionId: StringConst.GROUP_ID,
        image: aws.Image(bytes: compressedImage),
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
        if (checkin == true) {
          if (employee.currentposition?.latitude != null) {
            if (widget.usertype == true) {
              employee.getProfile().then((value) {
                if (employee.profile?.workTypeDefault != null) {
                  employee.checkIn(
                      employeeid: emplyeId,
                      context: context,
                      personid: personId,
                      file: image,
                      worktype: employee.profile!.workTypeDefault!,
                      worktypeId: employee.profile!.workTypeIdDefault,
                      lat: employee.currentposition!.latitude.toString(),
                      lng: employee.currentposition!.longitude.toString(),
                      action: checkin);
                } else {
                  selectedValue = employee.profile!.workTypeAutoselect;
                  employee.updateSelectedValue(selectedValue);
                  Dialogs.showAlertDialog(
                      context: context,
                      title: "Choose WorkType",
                      subTitle: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        hint: Text(
                          employee.profile!.workTypeAutoselect != null
                              ? employee.profile!.workTypeAutoselect!
                              : 'Choose WorkType',
                          style: const TextStyle(fontSize: 14),
                        ),
                        items: employee.profile?.workTypes != null
                            ? employee.profile!.workTypes!
                                .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ))
                                .toList()
                            : List.empty(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a WorkType.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          selectedValue = value.toString();
                          employee.updateSelectedValue(selectedValue);
                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.only(right: 8),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                          iconSize: 24,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                      yesClick: () {
                        employee
                            .checkIn(
                                employeeid: emplyeId,
                                context: context,
                                personid: personId,
                                file: image,
                                worktype: selectedValue != null
                                    ? selectedValue!
                                    : employee.profile!.workTypeAutoselect!,
                                worktypeId: selectedValue != null
                                    ? employee.profile!.workTypeIds!.elementAt(
                                        employee.profile!.workTypes!
                                            .indexOf(selectedValue!))
                                    : employee.profile!.workTypeIdAutoselect!,
                                lat: employee.currentposition!.latitude
                                    .toString(),
                                lng: employee.currentposition!.longitude
                                    .toString(),
                                action: checkin)
                            .then((value) {
                          selectedValue = employee.profile!.workTypeAutoselect;
                          employee.updateSelectedValue(selectedValue);
                        });
                      });
                }
              });
            } else {
              employee.salesmanCheckIn(
                  file: image, pos: employee.currentposition!, action: checkin);
            }
          } else {
            fetchPosition(context);
          }
        } else {
          if (employee.currentposition?.latitude != null) {
            if (widget.usertype == true) {
              employee.checkout(
                  employeeid: emplyeId,
                  context: context,
                  personid: personId,
                  file: image,
                  pos: employee.currentposition!,
                  action: checkin);
            } else {
              employee.salesmanCheckout(
                  file: image, pos: employee.currentposition!, action: checkin);
            }
          } else {
            fetchPosition(context);
          }
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
