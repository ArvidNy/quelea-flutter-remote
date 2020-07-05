import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../dialogs/search-item-dialog.dart';
import '../handlers/download-handler.dart';
import '../handlers/language-delegate.dart';
import '../objects/search-item.dart';
import '../utils/global-utils.dart' as global;

/// A delegate that handles song search on server.
/// Data is retrieved from the server and displayed
/// in a `ListView`. An item that is clicked is previewed
/// in the `showAddSearchItemDialog`.
class SongSearchDelegate extends SearchDelegate<String> {

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        tooltip: AppLocalizations.of(Get.context).getText("clear.search.box"),
        icon: const Icon((Icons.clear)),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
      // Might be self-explanatory and not needed
      // IconButton(
      //   tooltip: AppLocalizations.of(global.context).getText("help.menu"),
      //   icon: const Icon((Icons.help)),
      //   onPressed: () {
      //     
      //   },
      // ),
    ];
  }

@override
ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark();
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<SearchItem>>(
      future: DownloadHandler().searchResults(query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<SearchItem> data = snapshot.data;
          return _resultsListView(data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<SearchItem>>(
      future: DownloadHandler().searchResults(query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<SearchItem> data = snapshot.data;
          return _resultsListView(data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }

  ListView _resultsListView(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return new ListTile(
            title: Text(data[index].title),
            onTap: () {
              var id = data[index].id;
              DownloadHandler().download(global.url + "/song/$id", (lyrics) {
                showAddSearchItemDialog(data[index].title, lyrics, id,
                    () => close(context, data[index].title));
              });
            },
          );
        });
  }
}
