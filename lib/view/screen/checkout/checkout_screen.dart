import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/body/order_place_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/bank_info_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/cart_model.dart';

import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/provider/cart_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/coupon_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/order_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/product_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/profile_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/splash_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/utill/unity.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/amount_widget.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/animated_custom_dialog.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/custom_app_bar.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/custom_loader.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/my_dialog.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/title_row.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/cart/cart_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/checkout/widget/address_bottom_sheet.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/checkout/widget/custom_check_box.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/dashboard/dashboard_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/payment/payment_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/product/review_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel> cartList;
  final bool fromProductDetails;
  final double totalOrderAmount;
  final double shippingFee;
  final double discount;
  final double tax;
  final int sellerId;
  CheckoutScreen(
      {@required this.cartList,
      this.fromProductDetails = false,
      @required this.discount,
      @required this.tax,
      @required this.totalOrderAmount,
      @required this.shippingFee,
      this.sellerId});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _controller = TextEditingController();
  double _order = 0;
  bool _digitalPayment;
  File _files = File('');
  String image = "";
  ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Provider.of<ProfileProvider>(context, listen: false)
        .initAddressList(context);
    Provider.of<ProfileProvider>(context, listen: false)
        .initAddressTypeList(context);
    Provider.of<CouponProvider>(context, listen: false).removePrevCouponData();
    Provider.of<CartProvider>(context, listen: false).getCartDataAPI(context);
    Provider.of<CartProvider>(context, listen: false)
        .getChosenShippingMethod(context);

    _digitalPayment = Provider.of<SplashProvider>(context, listen: false)
        .configModel
        .digitalPayment;
    if (_digitalPayment) {
      Provider.of<CartProvider>(context, listen: false)
          .getPaymentInfor(context);
    }
  }

  void onCallbackUploadImage(String imageResponse) {
    print("CheckImageName $imageResponse");
    image = imageResponse;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _order = widget.totalOrderAmount + widget.discount;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      bottomNavigationBar: Container(
        height: App.height(context) * 9,
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_LARGE,
            vertical: Dimensions.PADDING_SIZE_DEFAULT),
        decoration: BoxDecoration(
            color: ColorResources.getPrimaryLight(context),
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10))),
        child: Consumer<OrderProvider>(
          builder: (context, order, child) {
            // double _shippingCost = Provider.of<CartProvider>(context, listen: false).shippingMethodIndex != null ? Provider.of<CartProvider>(context, listen: false).shippingMethodList[Provider.of<CartProvider>(context, listen: false).shippingMethodIndex[0]].cost : 0;
            // double _couponDiscount = Provider.of<CouponProvider>(context).discount != null ? Provider.of<CouponProvider>(context).discount : 0;
            return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<CouponProvider>(builder: (context, coupon, child) {
                    double _couponDiscount =
                        coupon.discount != null ? coupon.discount : 0;
                    return Text(
                      PriceConverter.convertPrice(
                          context,
                          (widget.totalOrderAmount +
                              widget.shippingFee +
                              widget.tax -
                              _couponDiscount)),
                      style: titilliumSemiBold.copyWith(
                          color: ColorResources.getTextTitle(context)),
                    );
                  }),
                  !Provider.of<OrderProvider>(context).isLoading
                      ? Builder(
                          builder: (context) => SizedBox(
                            height: App.height(context) * 9,
                            width: App.width(context) * 30,
                            child: TextButton(
                              onPressed: () async {
                                if (Provider.of<OrderProvider>(context,
                                                listen: false)
                                            .addressIndex ==
                                        null ||
                                    _files.path.isEmpty) {
                                  print("Checkhere1");

                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: (Provider.of<OrderProvider>(
                                                          context,
                                                          listen: false)
                                                      .addressIndex ==
                                                  null)
                                              ? Text(getTranslated(
                                                  'select_a_shipping_address',
                                                  context))
                                              : Text(getTranslated(
                                                  'select_a_image_payment',
                                                  context)),
                                          backgroundColor: Colors.red));
                                } else {
                                  List<CartModel> _cartList = [];
                                  _cartList.addAll(widget.cartList);
                                  for (int index = 0;
                                      index < widget.cartList.length;
                                      index++) {
                                    for (int i = 0;
                                        i <
                                            Provider.of<CartProvider>(context,
                                                    listen: false)
                                                .chosenShippingList
                                                .length;
                                        i++) {
                                      if (Provider.of<CartProvider>(context,
                                                  listen: false)
                                              .chosenShippingList[i]
                                              .cartGroupId ==
                                          widget.cartList[index].cartGroupId) {
                                        _cartList[index].shippingMethodId =
                                            Provider.of<CartProvider>(context,
                                                    listen: false)
                                                .chosenShippingList[i]
                                                .id;
                                        print(
                                            "Checkhere2 ${_cartList[index].shippingMethodId}");

                                        break;
                                      }
                                    }
                                  }

                                  double couponDiscount =
                                      Provider.of<CouponProvider>(context,
                                                      listen: false)
                                                  .discount !=
                                              null
                                          ? Provider.of<CouponProvider>(context,
                                                  listen: false)
                                              .discount
                                          : 0;
                                  String couponCode =
                                      Provider.of<CouponProvider>(context,
                                                      listen: false)
                                                  .discount !=
                                              null
                                          ? Provider.of<CouponProvider>(context,
                                                  listen: false)
                                              .coupon
                                              .code
                                          : '';
                                  if (Provider.of<CartProvider>(context,
                                              listen: false)
                                          .bankpaymentMethodIndex ==
                                      0) {
                                    Provider.of<OrderProvider>(context,
                                            listen: false)
                                        .placeOrder(
                                            OrderPlaceModel(
                                              CustomerInfo(
                                                Provider.of<ProfileProvider>(
                                                        context,
                                                        listen: false)
                                                    .addressList[Provider.of<
                                                                OrderProvider>(
                                                            context,
                                                            listen: false)
                                                        .addressIndex]
                                                    .id
                                                    .toString(),
                                                Provider.of<ProfileProvider>(
                                                        context,
                                                        listen: false)
                                                    .addressList[Provider.of<
                                                                OrderProvider>(
                                                            context,
                                                            listen: false)
                                                        .addressIndex]
                                                    .address,
                                              ),
                                              _cartList,
                                              order.paymentMethodIndex == 1
                                                  ? 'digital_payment'
                                                  : '',
                                              couponDiscount,
                                            ),
                                            _callback,
                                            _cartList,
                                            Provider.of<ProfileProvider>(
                                                    context,
                                                    listen: false)
                                                .addressList[
                                                    Provider.of<OrderProvider>(
                                                            context,
                                                            listen: false)
                                                        .addressIndex]
                                                .id
                                                .toString(),
                                            couponCode,
                                            bankName: Provider.of<CartProvider>(
                                                    context,
                                                    listen: false)
                                                .bankpaymentName
                                                .toString(),
                                            image: image);
                                  }
                                  // else {
                                  //   print("Checkhere4");

                                  //   String userID =
                                  //       await Provider.of<ProfileProvider>(
                                  //               context,
                                  //               listen: false)
                                  //           .getUserInfo(context);
                                  //   Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //           builder: (_) => PaymentScreen(
                                  //                 customerID: userID,
                                  //                 addressID: Provider.of<
                                  //                             ProfileProvider>(
                                  //                         context,
                                  //                         listen: false)
                                  //                     .addressList[Provider.of<
                                  //                                 OrderProvider>(
                                  //                             context,
                                  //                             listen: false)
                                  //                         .addressIndex]
                                  //                     .id
                                  //                     .toString(),
                                  //                 couponCode:
                                  //                     Provider.of<CouponProvider>(
                                  //                                     context,
                                  //                                     listen:
                                  //                                         false)
                                  //                                 .discount !=
                                  //                             null
                                  //                         ? Provider.of<
                                  //                                     CouponProvider>(
                                  //                                 context,
                                  //                                 listen: false)
                                  //                             .coupon
                                  //                             .code
                                  //                         : '',
                                  //                 tax: widget.tax,
                                  //                 totalOrderAmount:
                                  //                     widget.totalOrderAmount,
                                  //                 shippingFee:
                                  //                     widget.shippingFee,
                                  //                 discount: widget.discount,
                                  //               )));
                                  // }
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).highlightColor,
                                alignment: Alignment.center,
                                // padding: EdgeInsets.only(bottom: 4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(getTranslated('proceed', context),
                                  style: titilliumSemiBold.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                    color: ColorResources.getPrimary(context),
                                  )),
                            ),
                          ),
                        )
                      : Container(
                          height: 30,
                          width: 100,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).highlightColor)),
                        ),
                ]);
          },
        ),
      ),
      body: Column(
        children: [
          CustomAppBar(title: getTranslated('checkout', context)),
          Expanded(
            child: ListView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(0),
                children: [
                  // Order Details
                  Container(
                    margin: EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    color: Theme.of(context).highlightColor,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitleRow(
                              title:
                                  ('${getTranslated('ORDER_DETAILS', context)}'),
                              onTap: widget.fromProductDetails
                                  ? null
                                  : () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => CartScreen(
                                                    fromCheckout: true,
                                                  )));
                                    }),
                          Padding(
                            padding:
                                EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                            child: Row(children: [
                              FadeInImage.assetNetwork(
                                placeholder: Images.placeholder,
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                                image:
                                    '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productThumbnailUrl}/${Provider.of<CartProvider>(context, listen: false).cartList[0].thumbnail}',
                                imageErrorBuilder: (c, o, s) => Image.asset(
                                    Images.placeholder,
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50),
                              ),
                              SizedBox(width: Dimensions.MARGIN_SIZE_DEFAULT),
                              Expanded(
                                flex: 3,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Provider.of<CartProvider>(context,
                                                listen: false)
                                            .cartList[0]
                                            .name,
                                        style: titilliumRegular.copyWith(
                                            fontSize: Dimensions
                                                .FONT_SIZE_EXTRA_SMALL,
                                            color: ColorResources.getPrimary(
                                                context)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                          height: Dimensions
                                              .MARGIN_SIZE_EXTRA_SMALL),
                                      Row(children: [
                                        Text(
                                          PriceConverter.convertPrice(
                                              context,
                                              Provider.of<CartProvider>(context,
                                                      listen: false)
                                                  .cartList[0]
                                                  .price),
                                          style: titilliumSemiBold.copyWith(
                                              color: ColorResources.getPrimary(
                                                  context)),
                                        ),
                                        SizedBox(
                                            width:
                                                Dimensions.PADDING_SIZE_SMALL),
                                        Text(
                                            Provider.of<CartProvider>(context,
                                                    listen: false)
                                                .cartList[0]
                                                .quantity
                                                .toString(),
                                            style: titilliumSemiBold.copyWith(
                                                color:
                                                    ColorResources.getPrimary(
                                                        context))),
                                        Container(
                                          height: 20,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: Dimensions
                                                  .PADDING_SIZE_EXTRA_SMALL),
                                          margin: EdgeInsets.only(
                                              left: Dimensions
                                                  .MARGIN_SIZE_EXTRA_LARGE),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                  color:
                                                      ColorResources.getPrimary(
                                                          context))),
                                          child: Text(
                                            PriceConverter
                                                .percentageCalculation(
                                                    context,
                                                    Provider.of<CartProvider>(
                                                            context,
                                                            listen: false)
                                                        .cartList[0]
                                                        .price,
                                                    Provider.of<CartProvider>(
                                                            context,
                                                            listen: false)
                                                        .cartList[0]
                                                        .discount,
                                                    Provider.of<CartProvider>(
                                                            context,
                                                            listen: false)
                                                        .cartList[0]
                                                        .discountType),
                                            style: titilliumRegular.copyWith(
                                                fontSize: Dimensions
                                                    .FONT_SIZE_EXTRA_SMALL,
                                                color:
                                                    ColorResources.getPrimary(
                                                        context)),
                                          ),
                                        ),
                                      ]),
                                    ]),
                              ),
                            ]),
                          ),

                          // Coupon
                          Row(children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      hintText: 'Have a coupon?',
                                      hintStyle: titilliumRegular.copyWith(
                                          color:
                                              ColorResources.HINT_TEXT_COLOR),
                                      filled: true,
                                      fillColor:
                                          ColorResources.getIconBg(context),
                                      border: InputBorder.none,
                                    )),
                              ),
                            ),
                            SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                            !Provider.of<CouponProvider>(context).isLoading
                                ? ElevatedButton(
                                    onPressed: () {
                                      if (_controller.text.isNotEmpty) {
                                        Provider.of<CouponProvider>(context,
                                                listen: false)
                                            .initCoupon(
                                                _controller.text, _order)
                                            .then((value) {
                                          if (value > 0) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'You got ${PriceConverter.convertPrice(context, value)} discount'),
                                                    backgroundColor:
                                                        Colors.green));
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(getTranslated(
                                                  'invalid_coupon_or',
                                                  context)),
                                              backgroundColor: Colors.red,
                                            ));
                                          }
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: ColorResources.getGreen(context),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child:
                                        Text(getTranslated('APPLY', context)),
                                  )
                                : CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).primaryColor)),
                          ]),
                        ]),
                  ),

                  // Total bill
                  Container(
                    margin: EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    color: Theme.of(context).highlightColor,
                    child: Consumer<OrderProvider>(
                      builder: (context, order, child) {
                        //_shippingCost = order.shippingIndex != null ? order.shippingList[order.shippingIndex].cost : 0;
                        double _couponDiscount =
                            Provider.of<CouponProvider>(context).discount !=
                                    null
                                ? Provider.of<CouponProvider>(context).discount
                                : 0;

                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleRow(title: getTranslated('TOTAL', context)),
                              AmountWidget(
                                  title: getTranslated('ORDER', context),
                                  amount: PriceConverter.convertPrice(
                                      context, _order)),
                              AmountWidget(
                                  title: getTranslated('SHIPPING_FEE', context),
                                  amount: PriceConverter.convertPrice(
                                      context, widget.shippingFee)),
                              AmountWidget(
                                  title: getTranslated('DISCOUNT', context),
                                  amount: PriceConverter.convertPrice(
                                      context, widget.discount)),
                              AmountWidget(
                                  title:
                                      getTranslated('coupon_voucher', context),
                                  amount: PriceConverter.convertPrice(
                                      context, _couponDiscount)),
                              AmountWidget(
                                  title: getTranslated('TAX', context),
                                  amount: PriceConverter.convertPrice(
                                      context, widget.tax)),
                              Divider(
                                  height: 5,
                                  color: Theme.of(context).hintColor),
                              AmountWidget(
                                  title:
                                      getTranslated('TOTAL_PAYABLE', context),
                                  amount: PriceConverter.convertPrice(
                                      context,
                                      (_order +
                                          widget.shippingFee -
                                          widget.discount -
                                          _couponDiscount +
                                          widget.tax))),
                            ]);
                      },
                    ),
                  ),

                  // Shipping Details
                  Container(
                    margin: EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                    decoration:
                        BoxDecoration(color: Theme.of(context).highlightColor),
                    child: Column(children: [
                      InkWell(
                        onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AddressBottomSheet()),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(getTranslated('SHIPPING_TO', context),
                                  style: titilliumRegular),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      Provider.of<OrderProvider>(context)
                                                  .addressIndex ==
                                              null
                                          ? getTranslated(
                                              'add_your_address', context)
                                          : "${Provider.of<ProfileProvider>(context, listen: false).addressList[Provider.of<OrderProvider>(context, listen: false).addressIndex].address},${Provider.of<ProfileProvider>(context, listen: false).addressList[Provider.of<OrderProvider>(context, listen: false).addressIndex].city}, ${Provider.of<ProfileProvider>(context, listen: false).addressList[Provider.of<OrderProvider>(context, listen: false).addressIndex].zip}",
                                      style: titilliumRegular.copyWith(
                                          fontSize: Dimensions.FONT_SIZE_LARGE),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                        width: Dimensions
                                            .PADDING_SIZE_EXTRA_SMALL),
                                    Image.asset(Images.EDIT_TWO,
                                        width: 15,
                                        height: 15,
                                        color:
                                            ColorResources.getPrimary(context)),
                                  ]),
                            ]),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        child: Divider(
                            height: 2, color: ColorResources.getHint(context)),
                      ),
                      // InkWell(
                      //   onTap: () => showModalBottomSheet(
                      //     context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                      //     builder: (context) => ShippingMethodBottomSheet(),
                      //   ),
                      //   child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      //     Text(getTranslated('SHIPPING_PARTNER', context), style: titilliumRegular),
                      //     Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      //       Text(
                      //         Provider.of<OrderProvider>(context).shippingIndex == null ? getTranslated('select_shipping_method', context)
                      //             : Provider.of<OrderProvider>(context, listen: false).shippingList[Provider.of<OrderProvider>(context, listen: false).shippingIndex].title,
                      //         style: titilliumSemiBold.copyWith(color: ColorResources.getPrimary(context)),
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //       ),
                      //       SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      //       Image.asset(Images.EDIT_TWO, width: 15, height: 15, color: ColorResources.getPrimary(context)),
                      //     ]),
                      //   ]),
                      // ),
                    ]),
                  ),

                  // Payment Method
                  Container(
                    margin: EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    color: Theme.of(context).highlightColor,
                    child: Column(children: [
                      TitleRow(title: getTranslated('payment_method', context)),
                      SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      // CustomCheckBox(
                      //     title: getTranslated('cash_on_delivery', context),
                      //     index: 0),
                      _digitalPayment
                          ? Consumer<CartProvider>(
                              builder: (context, bank, child) {
                              List<DataBank> _bankInfor = [];
                              if (bank.bankInfoModel != null &&
                                  !bank.isLoading) {
                                _bankInfor.addAll(bank.bankInfoModel.data);
                                return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _bankInfor.length,
                                    padding: EdgeInsets.all(0),
                                    itemBuilder: (BuildContext context, index) {
                                      return CustomCheckBox(
                                          bank: _bankInfor[index],
                                          index: index);
                                    });
                              } else {
                                return Center(
                                  child: CustomLoader(
                                      size: App.height(context) * 3,
                                      color: Theme.of(context).primaryColor),
                                );
                              }
                            })
                          : SizedBox(),
                    ]),
                  ),

                  //Upload Invoice bank
                  Container(
                    // height: App.height(context) * 20,
                    margin: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                    decoration: BoxDecoration(
                        color: Theme.of(context).highlightColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(getTranslated('upload_bank_invoice', context),
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_DEFAULT)),
                            Text(
                                getTranslated(
                                    'warning_payment_before', context),
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_SMALL)),
                          ],
                        )),
                        SizedBox(
                          height: App.height(context) * 10,
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: Dimensions.PADDING_SIZE_SMALL),
                            child: InkWell(
                              onTap: () async {
                                PickedFile pickedFile =
                                    await imagePicker.getImage(
                                        source: ImageSource.gallery,
                                        maxWidth: 500,
                                        maxHeight: 500,
                                        imageQuality: 100);
                                if (pickedFile != null) {
                                  _files = File(pickedFile.path);
                                  await Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .uploadImage(
                                          _files, onCallbackUploadImage);
                                  setState(() {});
                                }
                              },
                              child: _files.path.isEmpty
                                  ? Container(
                                      height: 40,
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          Icon(Icons.cloud_upload_outlined,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          CustomPaint(
                                            size: Size(100, 40),
                                            foregroundPainter: new MyPainter(
                                                completeColor: ColorResources
                                                    .getColombiaBlue(context),
                                                width: 2),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.file(_files,
                                          height: App.height(context) * 10,
                                          width: App.width(context) * 20,
                                          fit: BoxFit.cover),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  void _callback(bool isSuccess, String message, String orderID,
      List<CartModel> carts) async {
    if (isSuccess) {
      //jaman baba
      // Provider.of<CartProvider>(context, listen: false).removeCheckoutProduct(carts);
      Provider.of<ProductProvider>(context, listen: false).getLatestProductList(
        1,
        context,
        reload: true,
      );
      // if (Provider.of<OrderProvider>(context, listen: false)
      //         .paymentMethodIndex ==
      //     0) {

      // } else {}
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => DashBoardScreen()),
          (route) => false);
      showAnimatedDialog(
          context,
          MyDialog(
            icon: Icons.check,
            title: getTranslated('order_placed', context),
            description: getTranslated('your_order_placed', context),
            isFailed: false,
          ),
          dismissible: false,
          isFlip: true);
      Provider.of<OrderProvider>(context, listen: false).stopLoader();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message), backgroundColor: ColorResources.RED));
    }
  }
}

class PaymentButton extends StatelessWidget {
  final String image;
  final Function onTap;
  PaymentButton({@required this.image, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 45,
        margin: EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: ColorResources.getGrey(context)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset(image),
      ),
    );
  }
}
