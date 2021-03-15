import 'package:ello/screens/otpConfermationScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _mobileNoEditingController = TextEditingController();

  InputDecoration _inputDecoration(String labelText, Widget icon) {
    return InputDecoration(
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(252, 252, 252, 1))),
        labelText: labelText,
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        hintStyle: TextStyle(color: Color.fromRGBO(252, 252, 252, 1)),
        icon: icon,
        errorStyle: TextStyle(color: Color.fromRGBO(248, 218, 87, 1)),
        errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(248, 218, 87, 1))),
        focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)));
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _mobileNoEditingController,
                      decoration: _inputDecoration(
                          "Mobile No", Icon(Icons.phone_android)),
                      validator: (val) {
                        return val.length < 10
                            ? "Please Enter valid Mobile No"
                            : null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                if (formKey.currentState.validate()) {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (BuildContext context) =>
                          OtpConfirmationScreen(mobileNo: '+91${_mobileNoEditingController.text}',)));
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                      color: Colors.pink),
                child: Text(
                  "Sign Up With The OTP",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
