// To parse this JSON data, do
//
//     final errorResModel = errorResModelFromJson(jsonString);

import 'dart:convert';
import 'package:touristsaver/common/models/member_error_presentation.dart';

ErrorResModel errorResModelFromJson(String str, {int? httpStatusCode}) =>
    ErrorResModel.fromJson(json.decode(str), httpStatusCode: httpStatusCode);

String errorResModelToJson(ErrorResModel data) => json.encode(data.toJson());

class ErrorResModel {
  ErrorResModel({
    this.status,
    this.code,
    this.reason,
    this.error,
    this.message,
    this.stack,
    this.data,
    this.httpStatusCode,
    this.memberFacingTitle,
    this.memberFacingMessage,
  });

  final dynamic status;
  final String? code;
  final String? reason;
  final Error? error;
  final String? message;
  final String? stack;
  final dynamic data;
  final int? httpStatusCode;
  final String? memberFacingTitle;
  final String? memberFacingMessage;

  String? get technicalCode => MemberErrorPresenter.technicalCodeFromResponse(
        code: code,
        reason: reason,
        message: message,
      );

  factory ErrorResModel.fromJson(
    Map<String, dynamic> json, {
    int? httpStatusCode,
  }) =>
      ErrorResModel(
        status: json["status"],
        code: json["code"]?.toString(),
        reason: json["reason"]?.toString(),
        error: json["error"] == null ? null : Error.fromJson(json["error"]),
        message: json["message"],
        stack: json["stack"],
        data: json["data"],
        httpStatusCode: httpStatusCode,
        memberFacingTitle: json['memberFacingTitle']?.toString() ??
            (json['memberFacing'] is Map
                ? json['memberFacing']['title']?.toString()
                : null),
        memberFacingMessage: json['memberFacingMessage']?.toString() ??
            (json['memberFacing'] is Map
                ? json['memberFacing']['message']?.toString()
                : null),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "code": code,
        "reason": reason,
        "error": error?.toJson(),
        "message": message,
        "stack": stack,
        "data": data,
        "memberFacingTitle": memberFacingTitle,
        "memberFacingMessage": memberFacingMessage,
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
