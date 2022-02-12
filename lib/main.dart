/*
import 'package:flutter/material.dart';

import 'home.dart';

void main() {
  runApp(const NewsApiApp());
}

class NewsApiApp extends StatefulWidget {
  const NewsApiApp({Key? key}) : super(key: key);

  @override
  _NewsApiAppState createState() => _NewsApiAppState();
}

class _NewsApiAppState extends State<NewsApiApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primaryColor: Colors.white),
        home: const Scaffold(body: Home()));
  }
}
*/

import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/model/error.dart';
import 'package:news_api_flutter_package/model/source.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:newsapiapp/article_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'create_article.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News API',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String apiKey = '';
  final NewsAPI _newsAPI = NewsAPI('YOUR API KEY GOES HERE');
  //late NewsAPI _newsAPI;

  /*getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      apiKey = prefs.getString('apiKey')!;
    });
  }

  @override
  void initState() {
    super.initState();
    getApiKey();
  }*/

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: _buildAppBar(),
          drawer: Drawer(
              backgroundColor: Colors.white,
              child: apiKey == ''
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: 60, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Api Key'),
                          apiKey == ''
                              ? TextField(
                                  onChanged: (String? apiKey) async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString('apiKey', apiKey!);
                                  },
                                )
                              : Text(apiKey)
                        ],
                      ),
                    )
                  : const Center(
                      child: Text('Set your Api Key in the Drawer'),
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
    );
  }

  TabBar _buildTabBar() {
    return const TabBar(
      tabs: [
        Tab(text: "Top Headlines"),
        Tab(text: "Everything"),
        Tab(text: "Sources"),
      ],
    );
  }

  Widget _buildBody() {
    return TabBarView(
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
        future: _newsAPI.getEverything(query: "bitcoin"),
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