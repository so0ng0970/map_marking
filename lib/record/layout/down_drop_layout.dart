import 'package:flutter/material.dart';
import 'package:map_marking/common/const/color.dart';

DropdownButtonFormField<String> dropdownButtonFormField({
  required String? selectedPicGroup,
  required bool edit,
  required Function(String?) onChanged,
  required List<String> picGroup,
}) {
  return DropdownButtonFormField(
    autovalidateMode: AutovalidateMode.onUserInteraction,
    borderRadius: BorderRadius.circular(10),
    dropdownColor: selectedPicGroup == null
        ? UNSELECTED
        : SELECTEDCOLOR[picGroup.indexOf(
            selectedPicGroup.toString(),
          )],
    decoration: InputDecoration(
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: FOCUS_BORDERSIDE,
          width: 2,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: DRAWER_BG,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: selectedPicGroup == null
          ? UNSELECTED
          : SELECTEDCOLOR[picGroup.indexOf(
              selectedPicGroup.toString(),
            )],
    ),
    hint: const Text('선택하세요'),
    isDense: true,
    isExpanded: true,
    value: selectedPicGroup,
    selectedItemBuilder: (BuildContext context) {
      return picGroup.map<Widget>((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
          ),
        );
      }).toList();
    },
    items: picGroup.map((item) {
      int index = picGroup.indexOf(item);
      return DropdownMenuItem(
        value: item,
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item,
                style: const TextStyle(color: RECORD_TEXT),
              ),
              Icon(
                Icons.circle,
                color: DROPBACKCOLOR[index],
                size: 20,
              )
            ],
          ),
        ),
      );
    }).toList(),
    validator: (value) => value?.isEmpty ?? true ? '선택해주세요' : null,
    onChanged:edit? null : onChanged,
  );
}
