import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/custom_theme_provider.dart';
import '../utils/color_constraints.dart';

class InputDateWidgetV1 extends StatefulWidget {
  const InputDateWidgetV1({
    super.key,
    required TextEditingController dtController,
    this.clearbutton = false,
    required this.textValueSetter,
    required this.initialDate,
    this.enabled = true,
    this.errorText,
    this.redErrorText = false,
  }) : dateController = dtController;

  final TextEditingController dateController;
  final void Function(DateTime? value) textValueSetter;
  final bool clearbutton;
  final DateTime? initialDate;
  final bool enabled;
  final String? errorText;
  final bool redErrorText;

  @override
  State<InputDateWidgetV1> createState() => _InputDateWidgetV1State();
}

class _InputDateWidgetV1State extends State<InputDateWidgetV1> {
  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<CustomThemeProvider>(context);

    // https://medium.com/flutter-community/a-deep-dive-into-datepicker-in-flutter-37e84f7d8d6c

    // Which holds the selected date
    // Defaults to today's date.
    DateTime selectedDate = widget.dateController.text == '' ? DateTime.now() : DateFormat('dd-MM-yyyy').parse(widget.dateController.text);

    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.dateController,
      keyboardType: TextInputType.none,
      readOnly: true,
      // initialValue: (initialDate != null)
      //     ? DateFormat('dd-MM-yyyy').format(initialDate!)
      //     : '',
      decoration: InputDecoration(
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(9.0))),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(9.0)),
          borderSide: BorderSide(
            width: 1.5,
            color: themeState.getDarkTheme ? Colors.grey.shade400 : Colors.black.withOpacity(0.8),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: -5.0),
        labelText: 'DOB (Optional)',
        labelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
          final Color color = states.contains(MaterialState.error)
              ? (themeState.getDarkTheme ? ColorConfig.darkLabelColor : ColorConfig.lightLabelColor) //Theme.of(context).colorScheme.error
              : widget.redErrorText == true
                  ? Colors.red
                  : (themeState.getDarkTheme ? ColorConfig.darkLabelColor : ColorConfig.lightLabelColor);

          return TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1.3);
        }),
        isDense: true,
        hintText: 'DOB (Optional)',
        hintStyle: TextStyle(
          color: themeState.getDarkTheme ? ColorConfig.darkHintColor : ColorConfig.lightHintColor,
          letterSpacing: 0.7,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
        prefixIcon: const Icon(
          Icons.calendar_month,
          size: 22,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        prefixIconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          // if (states.contains(MaterialState.error)) {
          //   return Colors.red;
          // }
          if (states.contains(MaterialState.focused)) {
            return Colors.blue;
          } else {
            return Colors.grey.shade700;
          }
        }),
        suffixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(end: 2.0),
          child: GestureDetector(
            child: Icon(widget.clearbutton == true && widget.enabled && widget.dateController.text != '' ? Icons.clear : null),
            onTap: () {
              setState(() {
                widget.dateController.text = '';
                widget.textValueSetter(null);
              });
            },
          ),
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        suffixIconColor: Colors.grey.shade700,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.error)) {
            return const TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
          } else if (states.contains(MaterialState.focused)) {
            return const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold);
          } else {
            return TextStyle(color: themeState.getDarkTheme ? Colors.grey.shade500 : Colors.black, fontWeight: FontWeight.bold);
          }
        }),
      ),
      onTap: () async {
        if (widget.enabled == true) {
          DateTime? pickeddate = await showDatePicker(
            context: context,
            initialDate: selectedDate, // Refer step 1
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            currentDate: DateTime.now(),
            // initialEntryMode: DatePickerEntryMode.input,
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.fromSwatch(
                    primarySwatch: Colors.teal,
                    // primaryColorDark: Colors.teal,
                    accentColor: Colors.teal,
                  ),
                  dialogBackgroundColor: themeState.getDarkTheme ? ColorConfig.light : Colors.white,
                ),
                child: child!,
              );
            },
          );

          if (pickeddate != null) {
            widget.dateController.text = DateFormat('dd-MM-yyyy').format(pickeddate);
            widget.textValueSetter(pickeddate);

            if (pickeddate != selectedDate) {
              setState(() {
                selectedDate = pickeddate;
              });
            }
          } else {
            // widget.dateController.text = '';
          }
        } else {}
      },
      validator: (String? value) {
        if ((value == null || value.trim() == '') && widget.errorText != null) {
          return widget.errorText;
        }
        return null;
      },
      style: TextStyle(color: themeState.getDarkTheme ? ColorConfig.lightFontEnabled : Colors.black, fontWeight: FontWeight.bold),
    );
  }
}
