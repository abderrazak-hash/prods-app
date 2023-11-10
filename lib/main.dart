import 'package:flutter/material.dart';
import 'package:networking_starter_code/widgets/add_item_page.dart';
import 'package:provider/provider.dart';

import 'models/shopping_list_provider.dart';
import 'widgets/shopping_list_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (BuildContext context) => ShoppingListProvider(),
        child: MaterialApp(
          title: 'Shopping List',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const AddItemPage(),
        ));
  }
}
