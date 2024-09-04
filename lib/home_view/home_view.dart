import 'package:flutter/material.dart';
import 'package:testai/model/data/user_data.dart';
import 'package:testai/model/user.dart';
import 'package:voice_search/voice_search.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<User> filteredItems = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = users;
  }
  void _filterList(String query) {
    setState(() {
      // Split the query into individual keywords by spaces
      List<String> keywords = query.toLowerCase().split(' ');

      // Filter the users list based on the presence of any relevant keyword in the fullInfo string
      filteredItems = users.where((user) {
        String fullInfoLower = user.fullInfo.toLowerCase();

        // Check if any relevant keyword is contained in the fullInfo string
        return keywords.any((keyword) => fullInfoLower.contains(keyword));
      }).toList();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Searchable List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _filterList(value);
                    },
                  ),
                ),
                SizedBox(width: 10),
                VoiceSearchWidget(
                  onResult: (String result) {
                    _controller.text = result;
                    _filterList(result);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final user = filteredItems[index];
                return Card(
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name),
                        Text(user.phone),
                      ],
                    ),
                    subtitle: Text(user.designation),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
