import 'package:flutter/material.dart';

class DropDownHelper extends StatefulWidget {
  final List<String> services;
  final Function(String) onServiceSelected;

  const DropDownHelper({super.key, required this.services, required this.onServiceSelected});

  @override
  State<DropDownHelper> createState() => _DropDownHelperState();
}

class _DropDownHelperState extends State<DropDownHelper> {
  String selectedCourseValue = "";

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white54,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        contentPadding: const EdgeInsets.all(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCourseValue,
          isDense: true,
          isExpanded: true,
          menuMaxHeight: 350,
          items: [
            const DropdownMenuItem(
              value: "",
              child: Text("Select Service"),
            ),
            ...widget.services.map<DropdownMenuItem<String>>((service) {
              return DropdownMenuItem(
                value: service,
                child: Text(service),
              );
            }).toList(),
          ],
          onChanged: (newValue) {
            setState(() {
              selectedCourseValue = newValue!;
              widget.onServiceSelected(selectedCourseValue); // Call the callback here
            });
          },
        ),
      ),
    );
  }
}

class DropDownHelper1 extends StatefulWidget {
  final List<String> services;
  final Function(String) onServiceSelected;

  const DropDownHelper1({super.key, required this.services, required this.onServiceSelected});

  @override
  State<DropDownHelper1> createState() => _DropDownHelperState1();
}

class _DropDownHelperState1 extends State<DropDownHelper1> {
  late String selectedCourseValue;

  @override
  void initState() {
    super.initState();
    print('these are dropdown services : ${widget.services}');
    // Set the initial value to the first item in the services list
    selectedCourseValue = widget.services.isNotEmpty ? widget.services.first : "";
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white54,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        contentPadding: const EdgeInsets.all(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCourseValue,
          isDense: true,
          isExpanded: true,
          menuMaxHeight: 350,
          items: [
            ...widget.services.map<DropdownMenuItem<String>>((service) {
              return DropdownMenuItem(
                value: service,
                child: Text(service),
              );
            }).toList(),
          ],
          onChanged: (newValue) {
            setState(() {
              selectedCourseValue = newValue!;
              widget.onServiceSelected(selectedCourseValue); // Call the callback here
            });
          },
        ),
      ),
    );
  }
}

class productDropDownHelper extends StatefulWidget {
  final List<String> services;
  final Function(String) onServiceSelected;

  const productDropDownHelper({super.key, required this.services, required this.onServiceSelected});

  @override
  State<productDropDownHelper> createState() => _productDropDownHelperState();
}

class _productDropDownHelperState extends State<productDropDownHelper> {
  String selectedCourseValue = "";

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white54,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        contentPadding: const EdgeInsets.all(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCourseValue,
          isDense: true,
          isExpanded: true,
          menuMaxHeight: 350,
          items: [
            const DropdownMenuItem(
              value: "",
              child: Text("Select Product"),
            ),
            ...widget.services.map<DropdownMenuItem<String>>((service) {
              return DropdownMenuItem(
                value: service,
                child: Text(service),
              );
            }).toList(),
          ],
          onChanged: (newValue) {
            setState(() {
              selectedCourseValue = newValue!;
              widget.onServiceSelected(selectedCourseValue); // Call the callback here
            });
          },
        ),
      ),
    );
  }
}