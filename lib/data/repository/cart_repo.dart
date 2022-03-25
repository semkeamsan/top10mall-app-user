
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/base/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepo{
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  CartRepo({@required this.dioClient, @required this.sharedPreferences});


  List<CartModel> getCartList() {
    List<String> carts = sharedPreferences.getStringList(AppConstants.CART_LIST);
    List<CartModel> cartList = [];
    carts.forEach((cart) => cartList.add(CartModel.fromJson(jsonDecode(cart))) );
    return cartList;
  }

  void addToCartList(List<CartModel> cartProductList) {
    List<String> carts = [];
    cartProductList.forEach((cartModel) => carts.add(jsonEncode(cartModel)) );
    sharedPreferences.setStringList(AppConstants.CART_LIST, carts);
  }



  Future<ApiResponse> getCartListData() async {
    try {
      final response = await dioClient.get(AppConstants.GET_CART_DATA_URI);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
  Future<ApiResponse> addToCartListData(CartModel cart, List<ChoiceOptions> choiceOptions, List<int> variationIndexes) async {
    Map<String, dynamic> _choice = Map();
    int _i = 0;
    if(cart.variant.isNotEmpty) {
      _choice.addAll({'choice_0': cart.variant});
      _i = 1;
    }
    for(int index=0; index<choiceOptions.length; index++){
      _choice.addAll({'choice_${index+_i}': choiceOptions[index].options[variationIndexes[index]]});
    }
    Map<String, dynamic> _data = {'id': cart.id,
      'variant': cart.variation != null ? cart.variation.type : null,
      'quantity': cart.quantity};
    _data.addAll(_choice);
    if(cart.variant.isNotEmpty) {
      _data.addAll({'color': cart.color});
    }
    print(_data);
    try {
      final response = await dioClient.post(
        AppConstants.ADD_TO_CART_URI,
        data: _data,
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
  Future<ApiResponse> updateQuantity( int key,int quantity) async {
    print('Body: ${{'_method': 'put', 'key': key, 'quantity': quantity}}');
    try {
      final response = await dioClient.post(AppConstants.UPDATE_CART_QUANTITY_URI,
        data: {'_method': 'put', 'key': key, 'quantity': quantity});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
  Future<ApiResponse> removeFromCart(int key) async {
    try {
      final response = await dioClient.post(AppConstants.REMOVE_FROM_CART_URI,
          data: {'_method': 'delete', 'key': key});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
  Future<ApiResponse> getShippingMethod(int sellerId) async {
    try {
      final response = sellerId==1?await dioClient.get('${AppConstants.GET_SHIPPING_METHOD}/$sellerId/admin'):
      await dioClient.get('${AppConstants.GET_SHIPPING_METHOD}/$sellerId/seller');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> addShippingMethod(int id, String cartGroupId) async {
    print('===>${{"id":id, "cart_group_id": cartGroupId}}');
    try {
      final response = await dioClient.post(AppConstants.CHOOSE_SHIPPING_METHOD, data: {"id":id, "cart_group_id": cartGroupId});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
  Future<ApiResponse> getChosenShippingMethod() async {
    try {
      final response =await dioClient.get(AppConstants.CHOSEN_SHIPPING_METHOD_URI);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // for payment method
  Future<ApiResponse> getPaymentMethod() async {
    // print("CheckResponse1 $identity");
    try {
      final response = await dioClient.get(AppConstants.GET_PAYMENT_METHOD);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }



}