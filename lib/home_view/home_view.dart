import 'package:flutter/material.dart';
import 'package:testai/home_view/view/voice_view.dart';
import 'package:testai/model/data/user_data.dart';
import 'package:testai/model/user.dart';
import 'package:url_launcher/url_launcher.dart';
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
  void _filterList(String query) async {
    setState(() {
      List<String> keywords = query.toLowerCase().split(' ');

      filteredItems = users.where((user) {
        String fullInfoLower = user.fullInfo.toLowerCase();
        return keywords.any((keyword) => fullInfoLower.contains(keyword));
      }).toList();

      // If the query contains the word "call", initiate the call
      if (keywords.contains('call') && filteredItems.isNotEmpty) {
        _makePhoneCall(filteredItems.first.phone);
      }
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Searchable List'),
        actions: [
          IconButton(onPressed: (){
            // Navigator.push(context, MaterialPageRoute(builder: (_)=>MyHomePage()));
          }, icon: Icon(Icons.arrow_forward_ios))
        ],
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
