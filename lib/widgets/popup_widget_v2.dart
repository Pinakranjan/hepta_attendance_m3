import 'package:flutter/material.dart';
import '../utils/color_constraints.dart';

class SelectionPopupV2 extends StatefulWidget {
  const SelectionPopupV2({
    super.key,
    this.initValue,
    required this.isDark,
    required this.data,
    required this.icon,
    required this.initial,
    required this.textValueSetter,
  });

  final void Function(String value) textValueSetter;

  final bool isDark;
  final String? initValue;
  final List<String> data;
  final IconData icon;
  final bool initial;

  @override
  State<SelectionPopupV2> createState() => _SelectionPopupV2State();
}

class _SelectionPopupV2State extends State<SelectionPopupV2> {
  @override
  Widget build(BuildContext context) {
    // final themeState = Provider.of<CustomThemeProvider>(context);

    return DropdownButtonFormField<String>(
      value: widget.initValue,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        prefixIconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused)) {
            return Colors.blue;
          } else {
            return Colors.grey.shade700;
          }
        }),
        contentPadding: const EdgeInsets.only(top: 7, left: 10, bottom: 7, right: 10),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          gapPadding: 0,
          borderSide: BorderSide(width: 1, color: Colors.transparent, style: BorderStyle.none),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(width: 1, color: Colors.transparent, style: BorderStyle.none),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(width: 1, color: Colors.transparent, style: BorderStyle.none),
        ),
        isDense: true,
        prefixIcon: Icon(
          widget.icon,
          size: 22,
          color: widget.initial == false
              ? Colors.blue
              : widget.isDark
                  ? ColorConfig.lightMain
                  : ColorConfig.darkMain,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 20,
          minHeight: 20,
        ),
      ),
      selectedItemBuilder: (BuildContext ctxt) {
        return widget.data.map<Widget>((item) {
          return DropdownMenuItem(
            value: item,
            child: SizedBox(
              width: 65,
              child: Text(
                item,
                style: TextStyle(
                    color: widget.initial == false
                        ? Colors.blue
                        : widget.isDark
                            ? Colors.white
                            : Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList();
      },
      items: widget.data
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
                ),
              ))
          .toList(),
      onChanged: (item) {
        widget.textValueSetter(item as String);
      },
      dropdownColor: widget.isDark ? ColorConfig.light : Colors.white,
      icon: const SizedBox.shrink(),
    );
  }
}
