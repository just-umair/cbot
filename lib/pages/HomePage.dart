import 'dart:io';

import 'package:cbot/pages/LoginPage.dart';
import 'package:cbot/pages/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Interval;

import 'dart:async';
import 'package:candlesticks/candlesticks.dart' as graph;
import 'package:intl/intl.dart';
import 'package:coinbase_exchange/coinbase_exchange.dart' as cb;
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

class CandleChart extends StatefulWidget {
  const CandleChart({Key? key}) : super(key: key);

  @override
  State<CandleChart> createState() => _CandleChartState();
}

class _CandleChartState extends State<CandleChart> {
  final _advancedDrawerController = AdvancedDrawerController();
  String dropdownvalue = 'BTC-USD';

  // List of items in our dropdown menu
  var items = [
    'ETH-USD',
    'BTC-USD',
    'ADA-USD',
    'WBTC-USD',
    'ATOM-USD',
    'DAI-USD',
    'LTC-USD',
  ];

  final _client = cb.WebsocketClient();
  final _streamController = StreamController.broadcast();
  final oCcy = NumberFormat("#,##0.00", "en_US");
  final _textStyle = const TextStyle(
    fontSize: 28.0,
    color: Colors.white70,
  );
  var btcPrice = '';
  var coinPrice = '';
  var ltePrice = '';
  final cb.ProductsClient productsClient = cb.ProductsClient(
    apiKey: '',
    secretKey: '',
    passphrase: '',
  );

  @override
  void initState() {
    _client.connect();
    _streamController.addStream(
      _client.subscribe(
        productIds: [
          'ETH-USD',
          'BTC-USD',
          'LTC-USD',
          'ADA-USD',
          'WBTC-USD',
          'ATOM-USD',
          'DAI-USD',
          'LTC-USD',
        ],
        channels: [cb.ChannelEnum.ticker],
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _client.close();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _user = fire.FirebaseAuth.instance.currentUser!;
    return AdvancedDrawer(
      backdropColor: Colors.blueGrey,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 0.0,
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: const Text(
            'CBOT',
          ),
          leading: IconButton(
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    value.visible ? Icons.clear : Icons.menu,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
            ),
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<fire.User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('SOMETHING WENT WRONG!'));
            } else if (snapshot.hasData) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff1d3f64),
                      Colors.blueGrey,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      FutureBuilder(
                        future: productsClient.getProductCandles(
                          productId: dropdownvalue,
                        ),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<cb.Candle>> snapshot) {
                          if (snapshot.hasData) {
                            List<graph.Candle> candles = snapshot.data!
                                .map((e) => graph.Candle(
                                      date: e.time!,
                                      high: e.high!,
                                      low: e.low!,
                                      open: e.open!,
                                      close: e.close!,
                                      volume: e.volume!,
                                    ))
                                .toList();
                            return AspectRatio(
                              aspectRatio: 1.2,
                              child: graph.Candlesticks(
                                candles: candles,
                                onIntervalChange: (_) async {},
                                interval: '1m',
                              ),
                            );
                          }

                          return Container();
                        },
                      ),
                      const SizedBox(height: 28.0),
                      StreamBuilder<dynamic>(
                        stream: _streamController.stream,
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.none) {
                            return const Text('None');
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Waiting...');
                          } else if (snapshot.connectionState ==
                              ConnectionState.active) {
                            var data = snapshot.data;
                            if (data is cb.StreamTicker) {
                              if (data.productId == dropdownvalue) {
                                coinPrice = '\$' + oCcy.format(data.price);
                              }

                              return Text(
                                '$dropdownvalue: $coinPrice',
                                style: _textStyle,
                              );
                            } else {
                              return const Text('Something Else');
                            }
                          } else if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return const Text('Done');
                          }
                          return Container();
                        },
                      ),
                      DropdownButton(
                        // Initial Value
                        value: dropdownvalue,
                        dropdownColor: Colors.white,
                        focusColor: Colors.white,

                        // Down Arrow Icon
                        icon: const Icon(Icons.keyboard_arrow_down),

                        // Array list of items
                        items: items.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownvalue = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            if (snapshot.data == null) {
              return const ErrorClass();
            } else {
              return const ErrorClass();
            }
          },
        ),
      ),
      drawer: SafeArea(
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 75.0,
                height: 75.0,
                margin: const EdgeInsets.only(
                  top: 24.0,
                  bottom: 64.0,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Image(
                  image: NetworkImage(_user.photoURL!),
                ),
              ),
              ListTile(
                onTap: () {},
                leading: const Icon(Icons.home),
                title: const Text('Home'),
              ),
              ListTile(
                onTap: () {},
                leading: const Icon(Icons.account_circle_rounded),
                title: const Text('Profile'),
              ),
              ListTile(
                onTap: () {},
                leading: const Icon(Icons.favorite),
                title: const Text('Favourites'),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
              ),
              ListTile(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                },
                leading: const Icon(Icons.login_outlined),
                title: const Text('Logout'),
              ),
              const Spacer(),
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 16.0,
                  ),
                  child: const Text('Terms of Service | Privacy Policy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
}

class ErrorClass extends StatefulWidget {
  const ErrorClass({Key? key}) : super(key: key);

  @override
  _ErrorClassState createState() => _ErrorClassState();
}

class _ErrorClassState extends State<ErrorClass> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Image(
        image: AssetImage('assets/images/home.png'),
      ),
    );
  }
}
