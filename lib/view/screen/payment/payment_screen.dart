import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/bank_info_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/provider/auth_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/cart_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/coupon_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/unity.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/amount_widget.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/animated_custom_dialog.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/custom_app_bar.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/custom_loader.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/my_dialog.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/title_row.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/dashboard/dashboard_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/product/review_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String addressID;
  final String customerID;
  final String couponCode;
  final double totalOrderAmount;
  final double shippingFee;
  final double discount;
  final double tax;
  PaymentScreen(
      {@required this.addressID,
      @required this.customerID,
      @required this.couponCode,
      this.shippingFee,
      this.tax,
      this.discount,
      this.totalOrderAmount});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedUrl;
  double value = 0.0;
  bool _isLoading = true;
  List<bool> _isChecked;
  List<File> _files = [File(''), File(''), File('')];
  ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Provider.of<CartProvider>(context, listen: false).getPaymentInfor(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, bank, child) {
      List<DataBank> _bankInfor = [];
      if (!bank.isLoading) {
        _bankInfor.addAll(bank.bankInfoModel.data);
        _isChecked = List<bool>.filled(_bankInfor.length, false);
      }
      return Scaffold(
        appBar: AppBar(
          title: Text(getTranslated('PAYMENT', context)),
          // onBackPressed: () => _exitApp(context)
        ),
        bottomSheet: Container(
            height: App.height(context) * 9,
            padding: EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_LARGE,
                vertical: Dimensions.PADDING_SIZE_DEFAULT),
            decoration: BoxDecoration(
                color: ColorResources.getPrimaryLight(context),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10))),
            child: Row(
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
                        color: Theme.of(context).highlightColor),
                  );
                }),
                Builder(
                  builder: (context) => SizedBox(
                    height: App.height(context) * 9,
                    width: App.width(context) * 30,
                    child: TextButton(
                      onPressed: () async {},
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).highlightColor,
                        alignment: Alignment.center,
                        // padding: EdgeInsets.only(bottom: 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(getTranslated('pay_now', context),
                          style: titilliumSemiBold.copyWith(
                            fontSize: Dimensions.FONT_SIZE_DEFAULT,
                            color: ColorResources.getPrimary(context),
                          )),
                    ),
                  ),
                ),
              ],
            )),
        body: bank.isLoading
            ? Center(
                child: CustomLoader(color: Theme.of(context).primaryColor),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        // height: App.height(context) * 20,
                        margin: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                        padding:
                            EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                        decoration: BoxDecoration(
                            color: Colors.lightBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TitleRow(
                                        title: getTranslated('TOTAL', context)),
                                    AmountWidget(
                                        title: getTranslated('ORDER', context),
                                        amount: PriceConverter.convertPrice(
                                            context, widget.totalOrderAmount)),
                                    AmountWidget(
                                        title: getTranslated(
                                            'SHIPPING_FEE', context),
                                        amount: PriceConverter.convertPrice(
                                            context, widget.shippingFee)),
                                    AmountWidget(
                                        title:
                                            getTranslated('DISCOUNT', context),
                                        amount: PriceConverter.convertPrice(
                                            context, widget.discount)),
                                    AmountWidget(
                                        title: getTranslated('TAX', context),
                                        amount: PriceConverter.convertPrice(
                                            context, widget.tax)),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: Dimensions
                                              .PADDING_SIZE_EXTRA_SMALL),
                                      child: Divider(
                                          height: 2,
                                          color:
                                              ColorResources.HINT_TEXT_COLOR),
                                    ),
                                    AmountWidget(
                                      title: getTranslated(
                                          'TOTAL_PAYABLE', context),
                                      amount: PriceConverter.convertPrice(
                                          context,
                                          (widget.totalOrderAmount +
                                              widget.shippingFee -
                                              widget.discount -
                                              widget.tax)),
                                    ),
                                  ]),
                            )
                          ],
                        )),
                    Container(
                      // height: App.height(context) * 50,
                      margin: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                      decoration: BoxDecoration(
                          color: Colors.lightBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated('SELECT_PAYMENT_METHOD', context),
                            style: TextStyle(
                                color: Theme.of(context).primaryColorLight,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          ListView.builder(
                            itemCount: _bankInfor.length,
                            shrinkWrap: true,
                            primary: true,
                            itemBuilder: (context, index) {
                              return CheckboxListTile(
                                title: Row(
                                  children: [
                                    Text(_bankInfor[index].bankName),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(_bankInfor[index].holderName),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(_bankInfor[index].accountNo),
                                  ],
                                ),
                                value: _isChecked[index],
                                onChanged: (val) {
                                  setState(
                                    () {
                                      _isChecked[index] = val;
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                        // height: App.height(context) * 20,
                        margin: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                        padding:
                            EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                        decoration: BoxDecoration(
                            color: Colors.lightBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                                    getTranslated('upload_images', context),
                                    style: robotoBold.copyWith(
                                        fontSize: Dimensions.FONT_SIZE_SMALL))),
                            SizedBox(
                              height: App.height(context) * 7,
                              child: ListView.builder(
                                itemCount: 3,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        right: Dimensions.PADDING_SIZE_SMALL),
                                    child: InkWell(
                                      onTap: () async {
                                        if (index == 0 ||
                                            _files[index - 1].path.isNotEmpty) {
                                          PickedFile pickedFile =
                                              await imagePicker.getImage(
                                                  source: ImageSource.gallery,
                                                  maxWidth: 500,
                                                  maxHeight: 500,
                                                  imageQuality: 50);
                                          if (pickedFile != null) {
                                            _files[index] =
                                                File(pickedFile.path);
                                            setState(() {});
                                          }
                                        } else {
                                          print(
                                              "CheckUploadClick ${index == 0 || _files[index - 1].path.isNotEmpty}");
                                        }
                                      },
                                      child: _files[index].path.isEmpty
                                          ? Container(
                                              height: 40,
                                              width: 50,
                                              alignment: Alignment.center,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                      Icons
                                                          .cloud_upload_outlined,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                  CustomPaint(
                                                    size: Size(100, 40),
                                                    foregroundPainter: new MyPainter(
                                                        completeColor:
                                                            ColorResources
                                                                .getColombiaBlue(
                                                                    context),
                                                        width: 2),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: Image.file(_files[index],
                                                  height: 50,
                                                  width: 50,
                                                  fit: BoxFit.cover)),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ))
                  ],
                ),
              ),
      );
    });
  }

  // Future<bool> _exitApp(BuildContext context) async {
  //   if (await controllerGlobal.canGoBack()) {
  //     controllerGlobal.goBack();
  //     return Future.value(false);
  //   } else {
  //     Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (_) => DashBoardScreen()),
  //         (route) => false);
  //     showAnimatedDialog(
  //         context,
  //         MyDialog(
  //           icon: Icons.clear,
  //           title: getTranslated('payment_cancelled', context),
  //           description: getTranslated('your_payment_cancelled', context),
  //           isFailed: true,
  //         ),
  //         dismissible: false,
  //         isFlip: true);
  //     return Future.value(true);
  //   }
  // }
}
