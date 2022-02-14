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

  List<bool> selectSort = [true, false, false];

  resetSort(int index) {
    selectSort = [false, false, false];
    setState(() {
      selectSort[index] = true;
    });
    ApiKey.sortBy = ApiKey.sortByList[index];
  }

  @override
  Widget build(BuildContext context) {
    final double mWidth = MediaQuery.of(context).size.width;
    final double mHeight = MediaQuery.of(context).size.height;
    final double width = mWidth * .9;
    final double height = mHeight * .23;
    const double fixedHeight = 350; //190;
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
                      query = value.trim();
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
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SortWidget(
                        resetSort: (int index) {
                          resetSort(index);
                        },
                        selectSort: selectSort),
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

class SortWidget extends StatelessWidget {
  const SortWidget(
      {Key? key, required this.selectSort, required this.resetSort})
      : super(key: key);
  final Function(int) resetSort;
  final List<bool> selectSort;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        SortTile(
            title: 'relevancy',
            value: selectSort[0],
            onChanged: () {
              resetSort(0);
            }),
        SortTile(
            title: 'popularity',
            value: selectSort[1],
            onChanged: () {
              resetSort(1);
            }),
        SortTile(
            title: 'latest',
            value: selectSort[2],
            onChanged: () {
              resetSort(2);
            }),
      ],
    );
  }
}

class SortTile extends StatelessWidget {
  const SortTile(
      {Key? key,
      required this.onChanged,
      required this.value,
      required this.title})
      : super(key: key);
  final bool value;
  final Function onChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Checkbox(
          value: value,
          onChanged: (bool? value) {
            onChanged();
          }),
      Text(title)
    ]);
  }
}
