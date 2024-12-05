import 'package:flutter/material.dart';
import '../utils/color_constraints.dart';

class SelectionPopup extends StatefulWidget {
  const SelectionPopup({
    super.key,
    this.initValue,
    this.errorText,
    this.redErrorText = false,
    required this.isDark,
    required this.label,
    required this.data,
    required this.textValueSetter,
    required this.focus,
  });

  final void Function(String value) textValueSetter;

  final bool isDark;
  final String? initValue;
  final String label;
  final List<String> data;
  final String? errorText;
  final bool redErrorText;
  final FocusNode focus;

  @override
  State<SelectionPopup> createState() => _SelectionPopupState();
}

class _SelectionPopupState extends State<SelectionPopup> {
  @override
  Widget build(BuildContext context) {
    // final themeState = Provider.of<CustomThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DropdownButtonFormField<String>(
        value: widget.initValue,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
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
          contentPadding: const EdgeInsets.only(top: 7, left: 10, bottom: 7, right: 10),
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(9.0))),
          errorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(9.0)),
            borderSide: BorderSide(
              width: 1.5, color: (widget.errorText != '') ? Colors.red : Colors.black38,
              // color: Colors.red,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(9.0)),
            borderSide: BorderSide(
              width: 1.5,
              color: widget.isDark ? Colors.grey.shade400 : Colors.black.withOpacity(0.8),
            ),
          ),
          labelText: widget.label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          floatingLabelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
            if (states.contains(MaterialState.error)) {
              return const TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
            } else if (states.contains(MaterialState.focused)) {
              return const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold);
            } else {
              return TextStyle(color: widget.isDark ? Colors.grey.shade500 : Colors.black, fontWeight: FontWeight.bold);
            }
          }),
          isDense: true,
          hintText: widget.label,
          hintStyle: TextStyle(
            color: widget.isDark ? ColorConfig.darkHintColor : ColorConfig.lightHintColor,
            letterSpacing: 0.7,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
          errorStyle: const TextStyle(color: Colors.red),
          labelStyle: MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
            final Color color = states.contains(MaterialState.error)
                ? (widget.isDark ? ColorConfig.darkLabelColor : ColorConfig.lightLabelColor) //Theme.of(context).colorScheme.error
                : widget.redErrorText == true
                    ? Colors.red
                    : (widget.isDark ? ColorConfig.darkLabelColor : ColorConfig.lightLabelColor);

            return TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16);
          }),
        ),
        selectedItemBuilder: (BuildContext ctxt) {
          return widget.data.map<Widget>((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: TextStyle(color: widget.isDark ? ColorConfig.lightFontEnabled : Colors.black)),
            );
          }).toList();
        },
        items: widget.data
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ))
            .toList(),
        onChanged: (item) {
          widget.textValueSetter(item as String);
        },
        focusNode: widget.focus,
        dropdownColor: widget.isDark ? ColorConfig.light : Colors.white,
        elevation: 16,
        validator: (String? value) {
          if ((value == null || value.trim() == '' || value.isEmpty) && widget.errorText != null) {
            return widget.errorText;
          }
          return null;
        },
      ),
    );
  }
}
