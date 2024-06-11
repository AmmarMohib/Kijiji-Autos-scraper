import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:swoopa_clone/model/car.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Car> _data = [];
  String? _nextPageToken;
  int? count;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData({String? pageToken}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    final url = pageToken != null
        ? 'https://www.kijijiautos.ca/consumer/srp/by-params?listingsOnly=true&sb=rel&od=down&ms=24100%3B3&ms=24100%3B28%3BTrail&vc=Car&psz=20&pageToken=$pageToken'
        : 'https://www.kijijiautos.ca/consumer/srp/by-params?listingsOnly=true&sb=rel&od=down&ms=24100%3B3&ms=24100%3B28%3BTrail&vc=Car&psz=20';

    final response = await http.get(Uri.parse(url), headers: {
      "accept": "application/json;version=2",
      "accept-language": "en-CA",
      "cache-control": "no-cache",
      "content-type": "application/json",
      "pragma": "no-cache",
      "priority": "u=1, i",
      "sec-ch-ua":
          "\"Google Chrome\";v=\"125\", \"Chromium\";v=\"125\", \"Not.A/Brand\";v=\"24\"",
      "sec-ch-ua-mobile": "?0",
      "sec-ch-ua-platform": "\"Windows\"",
      "sec-fetch-dest": "empty",
      "sec-fetch-mode": "cors",
      "sec-fetch-site": "same-origin",
      "x-client": "ca.move.web.app",
      "x-client-id": "97c89fb3-a6f4-49d2-a4a4-af85ef73bab4",
      "Referer": "https://www.kijijiautos.ca/cars/",
      "Referrer-Policy": "strict-origin-when-cross-origin"
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> items = data['listings']['items'];
      count = data['listings']['numResultsTotal'];
      final List<Car> cars = items.map((item) {
        return Car(
          title: item['structuredTitle'].toString(),
          imageUrl:
              'https://${item['images'][0]['uri'].toString()}?rule=move-500-jpg',
          price: item['prices']['consumerPrice']['localized'].toString(),
          location: item['attr']['loc'].toString(),
          travel: item['attr']['ml'].toString(),
        );
      }).toList();

      setState(() {
        _data.addAll(cars);
        _nextPageToken = data['listings']['nextPageToken'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Kijiji Cars (Scraped)"),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("${count.toString()} total results found"),
            )),
      ),
      body:

          Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Number of columns
                childAspectRatio: 1.25, // Adjust the ratio as needed
                crossAxisSpacing: 10,
              ),
              itemCount: _data.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Card(
                      margin:
                          const EdgeInsets.only(top: 5, left: 30, right: 30),
                      elevation: 0.2,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            color: Colors.black, strokeAlign: 5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SizedBox(
                        height: 275,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                    bottom: Radius.circular(5)),
                                child: Image.network(
                                  _data[index].imageUrl,
                                  width: double.maxFinite,
                                  height: double.maxFinite,
                                  // height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      _data[index].title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Text(
                                        'Price: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(_data[index].price),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Mileage: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(_data[index].travel),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Location: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(_data[index].location),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _fetchData(pageToken: _nextPageToken);
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(seconds: 2),
            curve: Curves.bounceInOut,
          );
        },
        child: const Icon(Icons.move_down_sharp),
      ),
    );
  }
}
