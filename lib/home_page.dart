import 'package:flutter/material.dart';

import 'package:newsapiapp/news_api_flutter_package/model/article.dart';
import 'package:newsapiapp/news_api_flutter_package/model/error.dart';
import 'package:newsapiapp/news_api_flutter_package/model/source.dart';
import 'package:newsapiapp/news_api_flutter_package/news_api_flutter_package.dart';

import 'package:newsapiapp/api_key.dart';
import 'package:newsapiapp/create_article.dart';
import 'package:newsapiapp/search_page.dart';
import 'package:newsapiapp/set_apikey.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final NewsAPI _newsAPI = NewsAPI(ApiKey().key);
  //final NewsAPI _newsAPI = NewsAPI("");
  String query = ApiKey().query;
  TabController? _tabController;
  String? updateSource;

  onPressed(String strQuery) {
    setState(() {
      query = strQuery;
    });
    print('++++++++++++++++++++++++');
    print(query);
    _tabController?.animateTo(1);
  }

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
          drawer: SizedBox(
            width: MediaQuery.of(context).size.width * .8,
            child: Drawer(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Api Key'),
                    Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.35,
                                        child: const Center(
                                            child: SetApiKey(
                                          topPadding: 0.07,
                                        )),
                                      ),
                                    );
                                  });
                            },
                            child: Text(ApiKey().key)))
                  ],
                ),
              ),
            ),
          ),
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
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SearchPage(
                      onPressed: (strQuery) {
                        onPressed(strQuery);
                      },
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
        future: updateSource == null
            ? _newsAPI.getTopHeadlines(country: "in")
            : _newsAPI.getTopHeadlines(sources: ApiKey.source),
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
        future: _newsAPI.getEverything(
            query: query.isNotEmpty ? query : "bitcoin",
            sortBy: ApiKey.sortBy,
            sources: ApiKey.source),
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
                        : Image.network(article.urlToImage!))));
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
        });
  }

  Widget _buildSourceListView(List<Source> sources) {
    ValueNotifier<List<bool>> selectSource =
        ValueNotifier<List<bool>>(sources.map((e) => false).toList());
    reset() {
      selectSource.value = sources.map((e) => false).toList();
    }

    onChanged(int index) {
      selectSource.value[index] = true;
      setState(() {
        updateSource = sources[index].name;
      });
    }

    return ValueListenableBuilder(
      valueListenable: selectSource,
      builder: (context, List<bool> select, child) {
        return ListView.builder(
          itemCount: sources.length,
          itemBuilder: (context, index) {
            return Card(
                child: ListTile(
                    title: Row(
                      children: [
                        Checkbox(
                            value: select[index],
                            onChanged: (value) {
                              print('+++++++++++++++++++++++++++++++');
                              print(value);
                              reset();
                              if (value!) {
                                onChanged(index);
                                ApiKey.source = sources[index].name;
                              } else {
                                reset();
                              }
                            }),
                        Text(sources[index].name!),
                      ],
                    ),
                    subtitle: Text(sources[index].description!)));
          },
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
            Text(error.code ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(error.message!, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
