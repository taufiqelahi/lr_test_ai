import 'package:flutter/material.dart';
import 'package:voice_search/voice_search.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String> allItems = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];
  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = allItems;
  }
  void _filterList(String query) {
    setState(() {
      filteredItems = allItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text('Searchable List'),
      actions: [
        VoiceSearchWidget(
          onResult: _filterList,
        ),
      ],
    ),
    body: ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(filteredItems[index]));
      },
    ),
    );;
  }
}
