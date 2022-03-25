import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/payment_model.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

class OrderRepo {
  final DioClient dioClient;

  OrderRepo({@required this.dioClient});

  Future<ApiResponse> getOrderList() async {
    try {
      final response = await dioClient.get(AppConstants.ORDER_URI);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getOrderDetails(
      String orderID, String languageCode) async {
    try {
      final response = await dioClient.get(
        AppConstants.ORDER_DETAILS_URI + orderID,
        options: Options(headers: {AppConstants.LANG_KEY: languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getShippingList() async {
    try {
      final response = await dioClient.get(AppConstants.SHIPPING_URI);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  getFileSize(String filepath, int decimals) async {
    var file = File(filepath);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  Future<ApiResponse> placeOrder(
      String addressID, String couponCode, PaymentModel payment) async {
    try {
      // var formData =
      //     jsonEncode({"payment_image": image, "bank_name": bankName});
      // Map<String, dynamic> formData = {
      //   "payment_image": "$image",
      //   "bank_name": "$bankName"
      // };
      print("CheckImage ${payment.toJson()}");

      final response = await dioClient.post(
          AppConstants.ORDER_PLACE_URI +
              '?address_id=$addressID&coupon_code=$couponCode',
          data: payment);
      print("CheckImage $response");

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> uploadImageAPI(File image) async {
    print("CheckImageLength ${await getFileSize(image.path, 1)}");
    String path = image.path;
    String fileName = path.split('/').last;
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(path, filename: fileName),
    });
    try {
      final response =
          await dioClient.post(AppConstants.UPLOAD_IMAGE_URI, data: formData);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getTrackingInfo(String orderID) async {
    try {
      final response = await dioClient.get(AppConstants.TRACKING_URI + orderID);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getShippingMethod(int sellerId) async {
    try {
      final response = sellerId == 1
          ? await dioClient
              .get('${AppConstants.GET_SHIPPING_METHOD}/$sellerId/admin')
          : await dioClient
              .get('${AppConstants.GET_SHIPPING_METHOD}/$sellerId/seller');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
