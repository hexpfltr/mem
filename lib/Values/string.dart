// ignore_for_file: constant_identifier_names

part of Values;

class StringConst {
  static const String BASE_URL = "http://mec-uae.net:83/facerec";
  static const String TOKEN = "";
  static const String USERID = "id";
  static const String API_VERSION = "/version";
  static const String LOGIN = "/oauth/token";
  static const String LOGOUT = "$BASE_URL/staff/log_out";
  static const String PROFILE = "/api/user";

// >-----
  static const String LIST_OF_EMPLOYEES = "/api/employees";
  static const String EMPLOYEE_DETAILS = "/api/employees/details";
  static const String SET_PERSONID = "/api/employees";
  static const String ADD_FACEID = "/api/employees";
  static const String CLEAR_PERSONID = "/api/employees/clear-person-ids";
  static const String CLEAR_SALESMAN_FACEID = "/api/salesman/clear-person-ids";
  static const String CHECK_IN = "/api/employees/add-check-in";
  static const String ADD_FOOD_INTAKE = "/api/mess/add-food-take";
  static const String SALESMAN_CHECK_IN = "/api/salesman/add-check-in";
  static const String SALESMAN_CHECK_OUT = "/api/salesman/add-check-out";
  static const String MEETING_CHECK_IN = "/api/salesman/add-meeting-check-in";
  static const String MEETING_CHECK_OUT = "/api/salesman/add-meeting-check-out";
  static const String CHECK_OUT = "/api/employees/add-check-out";

  static const String GROUP_ID = "9a4d51c1-8e68-4ger-a23b-6c7f5d92a1d3";
  static const String ACCESS_KEY = "AKIARPAADLHA3MN2P6MA";
  static const String SECRET_KEY = "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";
  static const String REGION = "ap-south-1";
  static const String CLIENT_SECRET =
      "8au2rvuDeYVDIyRGqJfldeGNZHQ6xJc10SoHqKt1";
}
