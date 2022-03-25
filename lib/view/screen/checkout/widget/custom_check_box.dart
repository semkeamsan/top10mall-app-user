import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/bank_info_model.dart';
import 'package:flutter_sixvalley_ecommerce/provider/cart_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/order_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:provider/provider.dart';

class CustomCheckBox extends StatelessWidget {
  final DataBank bank;
  final int index;
  CustomCheckBox({@required this.bank, @required this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, order, child) {
        if (order.bankpaymentMethodIndex == 0) {
          order.setPaymentMethod(index, bank.bankName);
        }
        return InkWell(
          onTap: () => order.setPaymentMethod(index, bank.bankName),
          child: Row(children: [
            Checkbox(
              value: order.bankpaymentMethodIndex == index,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (bool isChecked) =>
                  order.setPaymentMethod(index, bank.bankName),
            ),
            Expanded(
              child: Text(
                  "${bank.bankName} (${bank.accountNo} ${bank.holderName})",
                  style: titilliumRegular.copyWith(
                    color: order.bankpaymentMethodIndex == index
                        ? Theme.of(context).textTheme.bodyText1.color
                        : ColorResources.getGainsBoro(context),
                  )),
            ),
          ]),
        );
      },
    );
  }
}
