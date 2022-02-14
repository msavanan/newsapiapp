import 'package:flutter/material.dart';

import 'package:newsapiapp/api_key.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, this.onPressed}) : super(key: key);
  final Function(String)? onPressed;

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();
  String query = ApiKey().query;

  @override
  Widget build(BuildContext context) {
    final double mWidth = MediaQuery.of(context).size.width;
    final double mHeight = MediaQuery.of(context).size.height;
    final double width = mWidth * .9;
    final double height = mHeight * .23;
    const double fixedHeight = 190;
    const double fixedWidth = 370;

    return Dialog(
      child: SizedBox(
        width: width >= fixedWidth
            ? width
            : mWidth >= fixedWidth
                ? fixedWidth
                : mWidth,
        height: height >= fixedHeight
            ? height
            : mHeight >= fixedHeight
                ? fixedHeight
                : mHeight,
        child: Material(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    onChanged: (value) {
                      query = value;
                    },
                    validator: (String? val) {
                      if ((val?.isEmpty)!) {
                        return "Search can't be Empty";
                      }
                    },
                    decoration: const InputDecoration(
                        hintText: 'Search',
                        border: OutlineInputBorder(borderSide: BorderSide())),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          child: const Text('OK'),
                          onPressed: () async {
                            if ((_formKey.currentState?.validate())!) {
                              setState(() {
                                query = query;
                              });
                              if (widget.onPressed != null) {
                                widget.onPressed!(query);
                              }
                              await ApiKey().setQuery(query);
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
