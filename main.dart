import 'dart:convert';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project_1/app/services/api_keys.dart';
import 'package:project_1/filmtile.dart';

import 'package:http/http.dart' as http;

List<FilmTile> filmQ = List<FilmTile>();
List<FilmTile> currentList = List<FilmTile>();
List<FilmTile> searchList = List<FilmTile>();
List<FilmTile> seenList = List<FilmTile>();
TextEditingController searchText = new TextEditingController();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //this runs whenever the widget needs to be rendered on the screen

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Queue',
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  bool showNav = true;
  bool showCancel = false;
  String lastSearch;
  FocusScopeNode prevFocus;
  String searchBarHint = "Search movie titles";

  //static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        currentList = List.from(filmQ);
        searchBarHint = "Search movie titles";
        break;
      case 2:
        currentList = List.from(seenList);
        searchBarHint = "Search seen titles";
        break;
      default:
        //MAKE THIS BETTER
        currentList = List<FilmTile>();
    }
  }

  void _updateFromSearch() {
    setState(() {
      _selectedIndex = _selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //TODO: add action buttions for the dot menu
        toolbarHeight: 108,
        title: SizedBox(
          height: kToolbarHeight,
          child: Align(
            alignment: Alignment.center,
            child: Image(
              image: NetworkImage(
                  "https://img.icons8.com/ios/100/000000/nest.png"),
              width: 120,
              height: 120,
            ),
          ),
        ),
        backgroundColor: Colors.blue[300],
        bottom: PreferredSize(
          preferredSize: null,
          child: Container(
            width: 350,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                //this is for the enter key to run
                textInputAction: TextInputAction.go,
                onSubmitted: (value) {
                  runSearch();
                },
                autofocus: false,
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  showCancel = true;
                  if (currentFocus == prevFocus) {
                    currentFocus.unfocus();
                    prevFocus = null;
                    showCancel = false;
                    return;
                  }
                  currentList = List.from(searchList);
                  prevFocus = FocusScope.of(context);

                  hindNavFunc();
                },
                controller: searchText,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: searchBarHint,
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  suffixIcon: Visibility(
                      visible: showCancel,
                      child: IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: cancelPressed,
                      )),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: currentList.length,
        itemBuilder: (context, index) {
          return Card(
            child: currentList[index],
            shadowColor: Colors.black,
          );
        },
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Visibility(
        visible: showNav,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Queue',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Discovery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lock_clock),
              label: 'Seen',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue[300],
          unselectedItemColor: Colors.white70,
          onTap: _onItemTapped,
          backgroundColor: Colors.black87,
        ),
      ),
    );
  }

  void orderAction(String choice) {
    print("you want to order it by " + choice);
  }

  void showNavFunc() {
    showNav = true;
    _updateFromSearch();
  }

  void hindNavFunc() {
    showNav = false;
    _updateFromSearch();
  }

  void cancelPressed() {
    searchList.clear();
    searchText.clear();
    currentList.clear();
    currentList = List.from(filmQ);
    showNavFunc();
  }

  Future<void> runSearch() async {
    searchList.clear();
    currentList.clear();
    lastSearch = searchText.text;
    var got = await http.get(
        "https://api.themoviedb.org/3/search/movie?api_key=" +
            APIKeys.movieLookupKey +
            "&language=en-US&query=" +
            searchText.text +
            "&page=1&include_adult=true");
    //print(got.body.toString());
    var jgot = jsonDecode(got.body);
    //TODO: figure out how to get spesifics from the JSON file
    for (var i = 0; i < double.maxFinite; i++) {
      try {
        var title = jgot['results'][i]['original_title'];
        var year = DateTime.parse(jgot['results'][i]['release_date']).year;
        var url = "https://image.tmdb.org/t/p/w500/" +
            jgot['results'][i]['poster_path'];

        int id = jgot['results'][i]['id'];
        searchList.add(FilmTile(title, year, url, id));
      } catch (_) {
        if (searchList.isEmpty) {
          print("no results found");
        } else {
          currentList = List.from(searchList);
          print("all titles added!");
        }
        break;
      }
    }
    showCancel = true;
    _updateFromSearch();
  }
}
