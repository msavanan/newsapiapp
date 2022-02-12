import 'package:flutter/material.dart';

import 'article_view.dart';

class CreateArticle extends StatelessWidget {
  const CreateArticle({Key? key, required this.child, required this.url})
      : super(key: key);
  final Widget child;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return ArticleView(postUrl: url!);
          }));
        },
        child: child);
  }
}
