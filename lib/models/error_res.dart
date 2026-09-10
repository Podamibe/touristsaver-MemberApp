// To parse this JSON data, do
//
//     final errorResModel = errorResModelFromJson(jsonString);

import 'dart:convert';

ErrorResModel errorResModelFromJson(String str, {int? httpStatusCode}) =>
    ErrorResModel.fromJson(json.decode(str), httpStatusCode: httpStatusCode);

String errorResModelToJson(ErrorResModel data) => json.encode(data.toJson());

class ErrorResModel {
  ErrorResModel({
    this.status,
    this.code,
    this.error,
    this.message,
    this.stack,
    this.data,
    this.httpStatusCode,
  });

  final dynamic status;
  final String? code;
  final Error? error;
  final String? message;
  final String? stack;
  final dynamic data;
  final int? httpStatusCode;

  factory ErrorResModel.fromJson(
    Map<String, dynamic> json, {
    int? httpStatusCode,
  }) =>
      ErrorResModel(
        status: json["status"],
        code: json["code"]?.toString(),
        error: json["error"] == null ? null : Error.fromJson(json["error"]),
        message: json["message"],
        stack: json["stack"],
        data: json["data"],
        httpStatusCode: httpStatusCode,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "code": code,
        "error": error?.toJson(),
        "message": message,
        "stack": stack,
        "data": data,
      };
}

class Error {
  Error({
    this.statusCode,
    this.status,
    this.isOperational,
  });

  final int? statusCode;
  final dynamic status;
  final bool? isOperational;

  factory Error.fromJson(Map<String, dynamic> json) => Error(
        statusCode: json["statusCode"],
        status: json["status"],
        isOperational: json["isOperational"],
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "status": status,
        "isOperational": isOperational,
      };
}
