import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/model/error.dart';
import 'package:news_api_flutter_package/model/source.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:newsapiapp/search_page.dart';
import 'package:newsapiapp/verify_apikey.dart';
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
        home: SetApiKey() //HomePage(),
        );
  }
}

class SetApiKey extends StatefulWidget {
  const SetApiKey({Key? key}) : super(key: key);

  @override
  State<SetApiKey> createState() => _SetApiKeyState();
}

class _SetApiKeyState extends State<SetApiKey> {
  final _formKey = GlobalKey<FormState>();
  bool isValidating = false;
  final VerifyApiKey verifyApiKey = VerifyApiKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: isValidating,
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height * .3),
              child: Form(
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Text('API Key'))),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, right: 30, top: 5),
                        child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter(RegExp('[a-zA-Z0-9]'),
                                  allow: true)
                            ],
                            onChanged: (apiKey) {
                              verifyApiKey.apiKey = apiKey.trim();
                            },
                            validator: (apiKey) {
                              if ((apiKey?.isEmpty)!) {
                                return "API key can't be empty";
                              } else if (verifyApiKey.status == 'error' ||
                                  verifyApiKey.code == 'apiKeyInvalid') {
                                return 'Invalid API Key';
                              } else if (verifyApiKey.code == 'apiKeyMissing') {
                                return 'API Key is missing';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                hintText: 'API Key goes here',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide()))),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: ElevatedButton(
                            child: const Text('Ok'),
                            onPressed: () async {
                              setState(() {
                                isValidating = true;
                              });
                              await verifyApiKey.getResponse();
                              setState(() {
                                isValidating = false;
                              });
                              if ((_formKey.currentState?.validate())!) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return const HomePage();
                                }));
                              }
                            },
                          ),
                        ),
                      )
                    ]),
              ),
            ),
          ),
        ),
      ),
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
      actions: [
        IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return const SearchPage();
              }));
            },
            icon: const Icon(Icons.search))
      ],
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
