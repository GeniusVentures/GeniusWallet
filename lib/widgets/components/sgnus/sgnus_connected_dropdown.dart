import 'package:flutter/material.dart';

class SGNUSConnectedDropdown extends StatefulWidget {
  const SGNUSConnectedDropdown({Key? key}) : super(key: key);

  @override
  SGNUSConnectedDropdownState createState() => SGNUSConnectedDropdownState();
}

class SGNUSConnectedDropdownState extends State<SGNUSConnectedDropdown> {
  // List of items for the dropdown
  final List<String> items = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry'
  ];

  // Variable to hold the selected value
  String? selectedItem = 'Apple';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: const Text('Select an item'),
      value: selectedItem,
      onChanged: (String? newValue) {
        setState(() {
          selectedItem = newValue;
        });
      },
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}
