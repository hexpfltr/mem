import 'package:dio/dio.dart';

import 'error_response.dart';

class ApiErrorHandler {
  static dynamic getMessage(error) {
    dynamic errorDescription = "";

    if (error is Exception) {
      try {
        if (error is DioException) {
          switch (error.type) {
            case DioExceptionType.badCertificate:
              errorDescription =
                  "Sorry, there's an issue with the server's security certificate. Please try again later.";
              break;
            case DioExceptionType.connectionError:
              errorDescription =
                  "Sorry, we couldn't connect to the server. Please check your internet connection or try again later.";
              break;
            case DioExceptionType.cancel:
              errorDescription = "The request to the server was cancelled.";
              break;
            case DioExceptionType.connectionTimeout:
              errorDescription =
                  "The connection to the server timed out. Please try again later.";
              break;
            case DioExceptionType.unknown:
              errorDescription =
                  "Sorry, there was a problem connecting to the server due to an internet connection issue. Please check your network and try again.";
              break;
            case DioExceptionType.receiveTimeout:
              errorDescription =
                  "Sorry, we didn't receive a response from the server in time. Please try again later.";
              break;
            case DioExceptionType.badResponse:
              switch (error.response!.statusCode) {
                case 302:
                  errorDescription = "Redirecting... Please wait.";
                  break;
                case 400:
                case 409:
                  try {
                    // Assuming the response contains a 'message' field, otherwise, use a generic error message.
                    errorDescription = error.response!.data['message'] ??
                        "An error occurred while processing your request. Please try again.";
                  } catch (e) {
                    print("400 -> ${error.response!.statusMessage}");
                  }
                  break;
                case 401:
                  errorDescription =
                      "Sorry, you are not authorized to perform this action.";
                  break;
                case 404:
                  errorDescription =
                      "Sorry, the requested resource was not found.";
                  break;
                case 500:
                case 503:
                  errorDescription =
                      "Sorry, there was an internal server error. Please try again later.";
                  break;
                default:
                  ErrorResponse errorResponse =
                      ErrorResponse.fromJson(error.response?.data);
                  if (errorResponse.errors.isNotEmpty) {
                    // Customize further based on the specific error structure of your API.
                    errorDescription =
                        "An error occurred: ${errorResponse.errors.join(', ')}";
                  } else {
                    errorDescription =
                        "Sorry, an error occurred while processing your request. Please try again later.";
                  }
              }
              break;
            case DioErrorType.sendTimeout:
              errorDescription =
                  "Sending your request to the server took too long. Please try again later.";
              break;
          }
        } else {
          errorDescription =
              "An unexpected error occurred. Please try again later.";
        }
      } on FormatException catch (e) {
        errorDescription =
            "An unexpected error occurred. Please try again later.";
      }
    } else {
      errorDescription =
          "An unexpected error occurred. Please try again later.";
    }

    return errorDescription;
  }
}
