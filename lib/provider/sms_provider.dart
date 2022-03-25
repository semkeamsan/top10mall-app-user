import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/show_custom_snakbar.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/auth/widget/otp_verification_screen.dart';

enum SMSModelState { loading, loaded }

class SMSModel extends ChangeNotifier {
  var _state = SMSModelState.loaded;
  SMSModelState get state => _state;
  String _verificationId = '';
  String _smsCode = '';
  String get smsCode => _smsCode;
  FirebaseAuth _auth = FirebaseAuth.instance;
  // String _phoneNumber = '';
  // String get phoneNumber => _phoneNumber;

  /// Update state
  void _updateState(state) {
    _state = state;
    notifyListeners();
  }

  Future<void> sendOTP(
    BuildContext context,
    // Function onPageChanged,
    Function onMessage,
    // Function onVerify,
    String checkP,
    String tempToken,
    String _phoneNumber,
  ) async {
    // _phoneNumber = "+855$_phoneNumber";
    print("CheckUserPhoneNumber1 $_phoneNumber");

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted: (auth.PhoneAuthCredential credential) async {
          _smsCode = credential.smsCode;
          _updateState(SMSModelState.loaded);
          // onVerify();
          // await smsVerify(_phoneNumber);
        },
        verificationFailed: (auth.FirebaseAuthException e) {
          print("CheckUserPhoneNumber2 ${e.phoneNumber} ${e.message}");
          onMessage(e.message);
        },
        codeSent: (String verificationId, int resendToken) {
          print("CheckUserPhoneNumber3 $verificationId");
          
          _verificationId = verificationId;
          _updateState(SMSModelState.loaded);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => VerificationScreen(
                    tempToken, _phoneNumber, '', verificationId, checkP),
                settings: RouteSettings(
                  arguments: _phoneNumber,
                ),
              ),
              (route) => false);
        },
        // timeout: Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (err) {
      print("CHeckPhoneVerify3");
      print(err);
    }
  }

  Future<bool> smsVerify(
      String _phoneNumber, String _smsCode, String verificationId) async {
    // _updateState(SMSModelState.loading);
    try {
      print("CheckUserPhoneNumber $verificationId");
      final credential = auth.PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: _smsCode);
      final user = await loginFirebaseCredential(credential: credential);
      if (user != null) {
        _phoneNumber = _phoneNumber.replaceAll('+', '').replaceAll(' ', '');
        return true;
      }
    } on auth.FirebaseAuthException catch (err) {
      print("Error Firebase ${err.message}");
      // showMessage(err.code);
    }
    _updateState(SMSModelState.loaded);
    return false;
  }

  Future<User> loginFirebaseCredential({credential}) async {
    return (await _auth.signInWithCredential(credential)).user;
  }

  // void updatePhoneNumber(val) {
  //   _phoneNumber = val;
  //   notifyListeners();
  // }

  void updateSMSCode(val) {
    _smsCode = val;
    notifyListeners();
  }
}
