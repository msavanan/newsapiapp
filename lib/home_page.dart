import 'package:flutter/material.dart';

import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/model/error.dart';
import 'package:news_api_flutter_package/model/source.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';

import 'package:newsapiapp/api_key.dart';
import 'package:newsapiapp/create_article.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  //final NewsAPI _newsAPI = NewsAPI(ApiKey().key);
  final NewsAPI _newsAPI = NewsAPI("");
  String query = ApiKey().query;
  final _formKey = GlobalKey<FormState>();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: _buildAppBar(),
          drawer: Drawer(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const Text('Api Key'), Text(ApiKey().key)],
                ),
              )),
          body: _buildBody(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("News API"),
      centerTitle: true,
      bottom: _buildTabBar(),
      actions: [
        IconButton(
            onPressed: () {
              final double mWidth = MediaQuery.of(context).size.width;
              final double mHeight = MediaQuery.of(context).size.height;
              final double width = mWidth * .9;
              final double height = mHeight * .23;
              const double fixedHeight = 190;
              const double fixedWidth = 370;

              showDialog(
                  context: context,
                  builder: (BuildContext context) {
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
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide())),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton(
                                          child: const Text('OK'),
                                          onPressed: () async {
                                            if ((_formKey.currentState
                                                ?.validate())!) {
                                              setState(() {
                                                query = query;
                                              });
                                              _tabController?.animateTo(1);
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
                  });
            },
            icon: const Icon(Icons.search))
      ],
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: [
        const Tab(text: "Top Headlines"),
        Tab(text: query.isEmpty ? "Everything" : query),
        const Tab(text: "Sources"),
      ],
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTopHeadlinesTabView(),
        _buildEverythingTabView(),
        _buildSourcesTabView(),
      ],
    );
  }

  Widget _buildTopHeadlinesTabView() {
    return FutureBuilder<List<Article>>(
        future: _newsAPI.getTopHeadlines(country: "us"),
        builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? snapshot.hasData
                  ? _buildArticleListView(snapshot.data!)
                  : _buildError(snapshot.error as ApiError)
              : _buildProgress();
        });
  }

  Widget _buildEverythingTabView() {
    return FutureBuilder<List<Article>>(
        future:
            _newsAPI.getEverything(query: query.isNotEmpty ? query : "bitcoin"),
        builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? snapshot.hasData
                  ? _buildArticleListView(snapshot.data!)
                  : _buildError(snapshot.error as ApiError)
              : _buildProgress();
        });
  }

  Widget _buildArticleListView(List<Article> articles) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        Article article = articles[index];
        final String? url = article.url;
        return Card(
          child: CreateArticle(
            url: url,
            child: ListTile(
              title: Text(article.title!, maxLines: 2),
              subtitle: Text(article.description ?? "", maxLines: 3),
              trailing: article.urlToImage == null
                  ? null
                  : Image.network(article.urlToImage!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourcesTabView() {
    return FutureBuilder<List<Source>>(
      future: _newsAPI.getSources(),
      builder: (BuildContext context, AsyncSnapshot<List<Source>> snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? snapshot.hasData
                ? _buildSourceListView(snapshot.data!)
                : _buildError(snapshot.error as ApiError)
            : _buildProgress();
      },
    );
  }

  Widget _buildSourceListView(List<Source> sources) {
    return ListView.builder(
      itemCount: sources.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text(sources[index].name!),
            subtitle: Text(sources[index].description!),
          ),
        );
      },
    );
  }

  Widget _buildProgress() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(ApiError error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error.code ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(error.message!, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
