import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Material(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          decoration: InputDecoration(
              suffixIcon:
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              hintText: 'Search',
              //enabledBorder: OutlineInputBorder(),
              border: const OutlineInputBorder(borderSide: BorderSide())),
        ),
      ),
    ));
  }
}
