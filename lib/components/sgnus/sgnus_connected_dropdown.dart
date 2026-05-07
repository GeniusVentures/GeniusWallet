import 'package:flutter/material.dart';
import 'package:genius_wallet/components/inputs/gw_select.dart';

class SGNUSConnectedDropdown extends StatefulWidget {
  const SGNUSConnectedDropdown({super.key});

  @override
  SGNUSConnectedDropdownState createState() => SGNUSConnectedDropdownState();
}

class SGNUSConnectedDropdownState extends State<SGNUSConnectedDropdown> {
  static const List<String> _items = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
  ];

  String? selectedItem = 'Apple';

  @override
  Widget build(BuildContext context) {
    return GWSelect<String>(
      value: selectedItem,
      hint: 'Select an item',
      items: _items
          .map((item) => GWSelectItem<String>(value: item, label: item))
          .toList(),
      onChanged: (value) => setState(() => selectedItem = value),
    );
  }
}
