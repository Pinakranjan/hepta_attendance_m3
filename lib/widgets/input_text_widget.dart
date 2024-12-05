import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';

import '../utils/color_constraints.dart';

class InputTextFieldV1 extends StatelessWidget {
  const InputTextFieldV1({
    super.key,
    TextEditingController? controller,
    required this.isDark,
    required this.labelText,
    this.hintText,
    this.initialText,
    this.errorText,
    this.prefixIcon,
    this.sufixIcon = false,
    required this.textValueSetter,
    this.redErrorText = false,
    this.maxLength = 50,
    this.displaylines = 1,
    this.counterText = false,
    this.hidePassword = false,
    this.enabled = true,
    this.readonly = false,
    this.suffixicontick = false,
    this.rememberme = false,
    this.showHide,
    this.inputType = TextInputType.text,
    this.textType = TextCapitalization.none,
    this.autovalidateMode = AutovalidateMode.always,
    this.textFocus,
    this.autofocus = false,
  }) : _controller = controller;

  final bool isDark;
  final String labelText;
  final String? hintText;
  final String? initialText;
  final String? errorText;
  final Widget? prefixIcon;
  final bool? sufixIcon;
  final bool redErrorText;
  final int maxLength;
  final int displaylines;
  final bool counterText;
  final bool hidePassword;
  final bool enabled;
  final bool readonly;
  final bool autofocus;
  final bool suffixicontick;
  final bool rememberme;
  final AutovalidateMode autovalidateMode;
  final TextInputType inputType;
  final TextCapitalization textType;
  final FocusNode? textFocus;
  final TextEditingController? _controller;

  final void Function(String value) textValueSetter;
  final void Function(bool value)? showHide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          errorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(9.0)),
            borderSide: BorderSide(
              color: (errorText != '') ? ColorConfig.focusedBorderInValid : (isDark == true ? ColorConfig.darkBorderValid : ColorConfig.lightBorderValid),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(9.0)),
            borderSide: BorderSide(width: 1.5, color: ColorConfig.lightBorderEnabled),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(9.0)),
            borderSide: BorderSide(
              width: 2,
              color: ColorConfig.focusedBorderValid,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(9.0)),
            borderSide: BorderSide(
              width: 2,
              color: ColorConfig.focusedBorderInValid,
            ),
          ),
          // focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.7, color: Colors.red)),
          disabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(9.0)),
            borderSide: BorderSide(width: 1.0, color: ColorConfig.lightBorderDisabled),
          ),
          // contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
          contentPadding: EdgeInsets.only(top: 10, left: 10, bottom: 10, right: (inputType == TextInputType.multiline) ? 0 : 10),
          // contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          // labelText: labelText,
          floatingLabelAlignment: FloatingLabelAlignment.start,
          label: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: rememberme,
                child: Icon(
                  Icons.check_box_outlined,
                  color: isDark == true ? ColorConfig.darkFloatingLabelDisabled : ColorConfig.lightFloatingLabelDisabled,
                ),
              ),
              Visibility(
                visible: !enabled,
                child: Text(labelText),
              ),
              Visibility(
                visible: enabled,
                child: Text(
                  labelText,
                ),
              ),
            ],
          ),
          isDense: true,
          errorStyle: const TextStyle(color: Colors.red),
          hintText: hintText,
          hintStyle: TextStyle(
            color: ColorConfig.lightHintColor,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.clip,
          ),
          prefixIconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
            // if (states.contains(MaterialState.error)) {
            //   return Colors.red;
            // }
            if (states.contains(MaterialState.focused)) {
              if (states.contains(MaterialState.error)) {
                return Colors.red;
              } else {
                return Colors.blue;
              }
            } else {
              return Colors.grey.shade700;
            }
          }),
          prefixIcon: prefixIcon,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 35,
            minHeight: 35,
          ),
          counterText: counterText == true ? null : "",
          labelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
            // final Color color = states.contains(MaterialState.error)
            //     ? (Theme.of(context).colorScheme.secondary) //Theme.of(context).colorScheme.error
            //     : redErrorText == true
            //         ? Colors.red
            //         : (Theme.of(context).colorScheme.secondary);
            return TextStyle(color: ColorConfig.lightLabelColor, fontWeight: FontWeight.bold, letterSpacing: 1.1, overflow: TextOverflow.clip);
          }),
          floatingLabelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.error)) {
              return TextStyle(color: ColorConfig.focusedFloatingLabelInValid);
            } else if (states.contains(MaterialState.focused)) {
              return TextStyle(color: ColorConfig.focusedFloatingLabelValid);
            } else {
              if (states.contains(MaterialState.disabled)) {
                return TextStyle(color: ColorConfig.lightFloatingLabelDisabled);
              } else {
                return TextStyle(color: ColorConfig.lightFloatingLabelEnabled);
              }
            }
          }),
          // counterStyle: TextStyle(color: themeState.getDarkTheme ? Colors.yellow : Colors.black),
          // helperText: "Password must contain special character",
          // helperStyle: const TextStyle(color: Colors.green),
          suffixIcon: sufixIcon == false
              ? null
              : (suffixicontick == true
                  ? const Icon(Icons.check_circle_rounded)
                  : IconButton(
                      onPressed: () {
                        showHide!(!hidePassword);
                      },
                      icon: Icon(hidePassword == true ? Icons.visibility_off : Icons.visibility))),
          suffixIconColor: suffixicontick == true ? const Color.fromARGB(255, 24, 120, 27) : Colors.grey.shade600,
        ),
        validator: (String? value) {
          if (inputType == TextInputType.emailAddress && value != '' && !isEmail(value!)) {
            return "Please enter a valid email address.";
          } else if (inputType == TextInputType.phone && value != '' && !isPhone(value!)) {
            return "Please enter a valid phone number.";
          } else if ((value == null || value.trim() == '') && errorText != null) {
            return errorText;
          }
          return null;
        },
        onSaved: (String? val) => {
          //intValueSetter(int.parse(val ?? ''))
          textValueSetter(val!),
        },
        autovalidateMode: autovalidateMode,
        initialValue: initialText,
        obscureText: hidePassword,
        // inputFormatters: [UpperCaseTextFormatter()], Handled in Service
        textCapitalization: textType,
        enabled: enabled,
        readOnly: readonly,
        maxLength: maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        keyboardType: inputType,
        textInputAction: (inputType == TextInputType.multiline) ? TextInputAction.newline : TextInputAction.done,
        textAlignVertical: TextAlignVertical.center,
        focusNode: textFocus,
        autofocus: autofocus,
        autocorrect: false,
        minLines: (inputType == TextInputType.multiline) ? displaylines : 1,
        maxLines: (inputType == TextInputType.multiline) ? 3 : 1,
        expands: false,
        style: enabled == true
            ? TextStyle(color: isDark ? ColorConfig.lightFontEnabled : ColorConfig.darkFontEnabled, fontSize: 16, fontWeight: FontWeight.w600)
            : TextStyle(color: isDark ? ColorConfig.darkFontDisabled : ColorConfig.lightFontDisabled, fontWeight: FontWeight.bold),
      ),
    );
  }
}

bool isPhone(String input) => RegExp(r'^([0|\+[0-9]{1,5})?([5-9][0-9]{9})$').hasMatch(input);
bool isEmail(String input) => EmailValidator.validate(input);

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }

  // to allow digits with asterik and hash
  //  final regex = RegExp(r'\**\d+\**\d+\#?');

  //  inputFormatters = [FilteringTextInputFormatter.allow(regex)];

  // inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^ ?\d*')),]
  //   inputFormatters: [FilteringTextInputFormatter.deny(' ')]
  //   inputFormatters: [FilteringTextInputFormatter.digitsOnly]
  // FilteringTextInputFormatter(RegExp("[a-zA-Z]"), allow: true),
}
