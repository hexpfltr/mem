// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:Mem/custom/widgets/custom_text.dart';
import 'package:Mem/custom/widgets/dialog.dart';
import 'package:Mem/models/employees.model.dart';
import 'package:Mem/splash_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Values/values.dart';
import '../dio/api_response.dart';
import '../dio/repo.dart';
import '../utils/navigation_service.dart';
import '../utils/slide_right_route.dart';
import '../views/Profile/profile.model.dart';

class EmployeeProvider with ChangeNotifier {
  final Repo repo;
  final NavigationService ns;
  final SharedPreferences sharedPreferences;

  EmployeeProvider(
      {required this.repo, required this.ns, required this.sharedPreferences});

  RefreshController refreshController = RefreshController();
  List<Employees> employees = [];
  Profile? profile;
  final TextEditingController custnameController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController mnotesController = TextEditingController();
  final TextEditingController employeController = TextEditingController();
  List<Employees> filteredEmployees = [];

  Position? _currentposition;
  Position? get currentposition => _currentposition;
  set currentposition(Position? position) {
    _currentposition = position;
    notifyListeners();
  }

  String? _selectedValue;
  // Getter for selectedValue
  String? get selectedValue => _selectedValue;

  // Method to update selectedValue
  void updateSelectedValue(String? value) {
    _selectedValue = value;
    notifyListeners(); // Notify listeners about the change
  }

  bool _foodIn = false;
  bool get foodIn => _foodIn;

  set foodIn(bool newValue) {
    _foodIn = newValue;
    notifyListeners();
  }
  Future<List<Employees>> getlistofEmployees() async {
    String search = employeController.text;
    employees = [];
    search.isNotEmpty ? search : '';
    ApiResponse? res =
        await repo.getData("${StringConst.LIST_OF_EMPLOYEES}?search=$search");
    if (res.response != null && res.response!.statusCode == 200) {
      employees = List<Employees>.from(
          res.response?.data.map((x) => Employees.fromJson(x)));
      filteredEmployees = employees;
      // print("emp----${filteredEmployees.last.employeeId}");
      notifyListeners();
    } else if (res.error != "401") {
      if (kDebugMode) {
        print(res.error);
      }
    }
    return employees;
  }

  List<Employees> get filteredEmployeesList {
    return filteredEmployees;
  }

  Future<void> setPersonId(
      {required String employeeid, required String personId}) async {
    final Map<String, dynamic> personData = {
      "person_id": personId,
    };
    if (kDebugMode) {
      print(personData);
    }
    ApiResponse? res = await repo.postData(
        '${StringConst.SET_PERSONID}/$employeeid/set-person-id',
        data: jsonEncode(personData));
    if (res.response?.data != null && res.response?.statusCode == 200) {
      if (res.response?.statusCode == 200) {
        Alerts.showSuccess(res.response?.data["message"]);
      } else {
        Alerts.showError(res.response?.data["message"]);
      }
    } else if (res.error != "401") {
      if (kDebugMode) {
        print(res.error);
      }
      Alerts.showError(res.error);
    }
  }

  Future<void> addFaceId(
      {required String employeeid, required String faceId}) async {
    final Map<String, dynamic> faceData = {
      "face_id": faceId,
    };
    if (kDebugMode) {
      print(faceData);
    }
    ApiResponse? res = await repo.postData(
        '${StringConst.ADD_FACEID}/$employeeid/add-face-id',
        data: jsonEncode(faceData));
    if (res.response?.data != null && res.response?.statusCode == 200) {
      if (res.response?.statusCode == 200) {
        Alerts.showSuccess(res.response?.data["message"]);
      } else {
        Alerts.showError(res.response?.data["message"]);
      }
    } else if (res.error != "401") {
      if (kDebugMode) {
        print(res.error);
      }
      Alerts.showError(res.error);
    }
  }

  Future deletePersonId(String personId) async {
    var data = {
      "person_ids": ["$personId"]
    };
    print(jsonEncode(data));
    ApiResponse res =
        await repo.postData(StringConst.CLEAR_PERSONID, data: data);

    if (res.response != null && res.response!.statusCode == 200) {
      Alerts.showError("FaceId deleted permenantly");
    } else {
      Alerts.showError(res.error.toString());
    }
  }

  Future deleteSalesFaceIds(String personId) async {
    var data = {
      "person_ids": ["$personId"]
    };
    print(jsonEncode(data));
    ApiResponse res =
        await repo.postData(StringConst.CLEAR_SALESMAN_FACEID, data: data);

    if (res.response != null && res.response!.statusCode == 200) {
      Alerts.showError("FaceId deleted permenantly");
    } else {
      Alerts.showError(res.error.toString());
    }
  }

  Future<void> checkIn(
      {required String employeeid,
      required String personid,
      required String lat,
      required String lng,
      XFile? file,
      required BuildContext context,
      required bool action,
      required String worktypeId,
      required String worktype}) async {
    var mapData = {
      "entry_type": 0,
      "work_type_id": worktypeId,
      "work_type": worktype,
      "person_id": personid,
      "employee_id": employeeid,
      "lat": lat.toString(),
      "lng": lng.toString(),
      "device": "",
      "address": ""
    };
    if (file != null) {
      mapData["photo"] = await MultipartFile.fromFile(file.path);
    }
    final formData = FormData.fromMap(mapData);
    try {
      ApiResponse res = await repo.postData(StringConst.CHECK_IN,
          data: formData, isMultipart: true);
      if (res.response?.statusCode == 200 &&
          res.response?.data["message"] !=
              "Consecutive check ins not allowed") {
        // Alerts.showSuccess(res.response?.data["message"]);
        getEmployeeDetails(personid, context, action).then((value) async {
          await DefaultCacheManager().emptyCache();
        });
      } else {
        popContext(context).then((value) => QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: action == true
                        ? "Multiple Check-In Attempt"
                        : "Multiple Check-Out Attempt",
                    text: action == true
                        ? "Consecutive check ins not allowed"
                        : "Consecutive check outs not allowed",
                    animType: QuickAlertAnimType.slideInDown)
                .then((value) async {
              await DefaultCacheManager().emptyCache();
            }));
      }
    } catch (e) {
      popContext(context).then((value) => QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  title: "Try Again",
                  text:
                      "Ensure your face is centered within the square, then try again.",
                  animType: QuickAlertAnimType.slideInUp)
              .then((value) async {
            await DefaultCacheManager().emptyCache();
          }));
    }
  }

  Future<void> addFoodIntake(
      {required String employeeid,
      required String personid,
      required Position pos,
      required BuildContext context,
      required String employeeids,
      XFile? file}) async {
    final mapData = {
      "entry_type": 0,
      "taker_person_id": personid,
      "taker_employee_id": employeeid,
      "lat": pos.latitude.toString(),
      "lng": pos.longitude.toString(),
      "device": "",
      "address": "",
      "employee_ids[0]": employeeids
    };
    if (file != null) {
      mapData["photo"] = await MultipartFile.fromFile(file.path);
    }
    print("map-$mapData");
    var formData = FormData.fromMap(mapData);

    ApiResponse res = await repo.postData(StringConst.ADD_FOOD_INTAKE,
        data: formData, isMultipart: true);
    if (res.response != null && res.response?.statusCode == 200) {
      getEmployeeDetails2(personid, context);
    } else {
      popContext(context).then((value) => QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: res.response?.data["message"],
          animType: QuickAlertAnimType.slideInDown));
    }
  }

  Future<void> popContext(BuildContext context) async {
    Navigator.pop(context, true);
    // notifyListeners();
  }

  Future<void> salesmanCheckIn({
    XFile? file,
    required bool action,
    required Position pos,
  }) async {
    final mapData = {
      "entry_type": 1,
      "lat": pos.latitude.toString(),
      "lng": pos.longitude.toString(),
      "device": ""
    };
    if (file != null) {
      mapData["photo"] = await MultipartFile.fromFile(file.path);
    }
    print(mapData);
    var formData = FormData.fromMap(mapData);

    ApiResponse res = await repo.postData(StringConst.SALESMAN_CHECK_IN,
        data: formData, isMultipart: true);
    if (res.response != null && res.response?.statusCode == 200) {
      Alerts.showSuccess(res.response?.data["message"]);
    } else {
      Alerts.showError(res.response!.data["message"]);
    }
  }

  Future<void> meetingcheckIn({
    XFile? file,
    required Position pos,
  }) async {
    final mapData = {
      "entry_type": 1,
      "lat": pos.latitude.toString(),
      "lng": pos.longitude.toString(),
    };
    if (file != null) {
      mapData["photo"] = await MultipartFile.fromFile(file.path);
    }
    print(mapData);
    var formData = FormData.fromMap(mapData);

    ApiResponse res = await repo.postData(StringConst.MEETING_CHECK_IN,
        data: formData, isMultipart: true);
    if (res.response != null && res.response?.statusCode == 200) {
      Alerts.showSuccess(res.response?.data["message"]);
    } else {
      Alerts.showError(res.response!.data["message"]);
    }
  }

  Future<void> meetingCheckout({
    XFile? file,
    required Position pos,
  }) async {
    String custmer = custnameController.text;
    String purpose = purposeController.text;
    String meetingnots = mnotesController.text;
    final mapData = {
      'entry_type': 1,
      'customer_name': custmer,
      'purpose': purpose,
      'meeting_notes': meetingnots,
      'lat': pos.latitude.toString(),
      'lng': pos.longitude.toString(),
    };
    if (file != null) {
      mapData['photo'] = await MultipartFile.fromFile(file.path);
    }
    print(mapData);
    var formData = FormData.fromMap(mapData);

    ApiResponse? res = await repo.postData(StringConst.MEETING_CHECK_OUT,
        data: formData, isMultipart: true);
    print(res.response?.statusCode);
    if (res.response != null && res.response?.statusCode == 200) {
      clearControllers();
      Alerts.showSuccess(res.response?.data["message"]);
    } else {
      Alerts.showError(res.response!.data["message"]);
      clearControllers();
    }
  }

  Future<void> checkout(
      {required String employeeid,
      required String personid,
      required Position pos,
      required BuildContext context,
      XFile? file,
      required bool action}) async {
    final mapData = {
      'entry_type': 0,
      'person_id': personid,
      'employee_id': employeeid,
      'lat': pos.latitude.toString(),
      'lng': pos.longitude.toString(),
      'device': '',
    };
    if (file != null) {
      mapData['photo'] = await MultipartFile.fromFile(file.path);
    }
    print(mapData);
    final formData = FormData.fromMap(mapData);
    try {
      ApiResponse? res = await repo.postData(StringConst.CHECK_OUT,
          data: formData, isMultipart: true);
      // print(res.response?.statusCode);
      if (res.response != null &&
          res.response?.statusCode == 200 &&
          res.response?.data["message"] !=
              "Consecutive check outs not allowed") {
        // Alerts.showSuccess(res.response?.data["message"]);
        getEmployeeDetails(personid, context, action).then((value) async {
          await DefaultCacheManager().emptyCache();
        });
      } else {
        popContext(context).then((value) => QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: action == true
                        ? "Multiple Check-In Attempt"
                        : "Multiple Check-Out Attempt",
                    text: action == true
                        ? "Consecutive check ins not allowed"
                        : "Consecutive check outs not allowed",
                    animType: QuickAlertAnimType.slideInUp)
                .then((value) async {
              await DefaultCacheManager().emptyCache();
            }));
      }
    } catch (e) {
      popContext(context).then((value) => QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  title: "Try Again",
                  text:
                      "Ensure your face is centered within the square, then try again.",
                  animType: QuickAlertAnimType.slideInUp)
              .then((value) async {
            await DefaultCacheManager().emptyCache();
          }));
    }
  }

  Future<void> salesmanCheckout(
      {XFile? file, required Position pos, required bool action}) async {
    final mapData = {
      'entry_type': 1,
      'lat': pos.latitude.toString(),
      'lng': pos.longitude.toString(),
      'device': '',
    };
    if (file != null) {
      mapData['photo'] = await MultipartFile.fromFile(file.path);
    }
    print(mapData);
    var formData = FormData.fromMap(mapData);

    ApiResponse? res = await repo.postData(StringConst.SALESMAN_CHECK_OUT,
        data: formData, isMultipart: true);
    print(res.response?.statusCode);
    if (res.response != null && res.response?.statusCode == 200) {
      Alerts.showSuccess(res.response?.data["message"]);
    } else {
      Alerts.showError(res.response!.data["message"]);
    }
  }

  Future<Profile?> getProfile() async {
    ApiResponse? res = await repo.getData(StringConst.PROFILE);
    if (res.response != null && res.response!.statusCode == 200) {
      print("res->${res.response!.data}");
      profile = Profile.fromJson(res.response!.data);
      notifyListeners();
      return profile;
    } else if (res.error != "401") {
      if (kDebugMode) {
        print(res.error);
      }
    }
    return profile;
  }

  Future getEmployeeDetails(
      String personId, BuildContext context, bool action) async {
    print("in----");
    var data = {"person_id": personId};
    ApiResponse? res =
        await repo.getData(StringConst.EMPLOYEE_DETAILS, data: data);
    if (res.response != null && res.response?.statusCode == 200) {
      popContext(context).then((value) => QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title:
              action == true ? "Check-In Successful" : "Check-Out Successful",
          animType: QuickAlertAnimType.slideInUp,
          widget: action == true
              ? Text.rich(
                  TextSpan(
                    text: 'Great to see you, ',
                    children: [
                      TextSpan(
                        text: '${res.response?.data["name"]}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: '! You are now checked in - '),
                      TextSpan(
                        text: '${res.response?.data["employee_id"]}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : Text.rich(
                  TextSpan(
                    text: 'Thanks for checking out with us, ',
                    children: [
                      TextSpan(
                        text: '${res.response?.data["name"]}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: '. See you next time! '),
                      TextSpan(
                        text: '${res.response?.data["employee_id"]}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
          // ? "Great to see you, ${res.response?.data["name"]}! You are now checked in - ${res.response?.data["employee_id"]}."
          // : "Name: ${res.response?.data["name"]}\nId : ${res.response?.data["employee_id"]}\nThanks for checking out with us, See you next time!",

          ));
      notifyListeners();
    } else {
      if (kDebugMode) {
        print(res.error);
      }
    }
  }

  Future getEmployeeDetails2(String personId, BuildContext context) async {
    var data = {"person_id": personId};
    ApiResponse? res =
        await repo.getData(StringConst.EMPLOYEE_DETAILS, data: data);
    if (res.response?.data != "" && res.response?.statusCode == 200) {
      popContext(context).then((value) => QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Food InTake Successful",
          animType: QuickAlertAnimType.slideInUp,
          widget: Text.rich(
            TextSpan(
              text: 'Hooray ',
              children: [
                TextSpan(
                  text: '${res.response?.data["name"]}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                    text: '! Your food intake has been logged successfully'),
                TextSpan(
                  text: '${res.response?.data["employee_id"]}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )));
      notifyListeners();
    } else {
      if (kDebugMode) {
        print(res.error);
      }
    }
  }

  logout() async {
    await sharedPreferences.clear().then((value) => Future.delayed(
        const Duration(seconds: 3),
        () => Navigator.pushAndRemoveUntil(ns.getContext(),
            SlideRightRoute(page: const SplashScreen()), (route) => false)));
  }

  void clearControllers() {
    custnameController.clear();
    purposeController.clear();
    mnotesController.clear();
  }
}
