import 'package:flutter/material.dart';

import 'features/dynamic_sticker_screen.dart';
import 'features/photo_sticker_screen.dart';
import 'features/screenshot_sticker_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: '表情包工厂',
        theme: ThemeData(primarySwatch: Colors.pink),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _idx = 0;
  static const _pages = [
    ScreenshotStickerScreen(),
    DynamicStickerScreen(),
    PhotoStickerScreen(),
  ];
  static const _titles = ['截图表情', '动态表情', '我的照片'];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('表情包工厂 · ${_titles[_idx]}')),
        body: _pages[_idx],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.image), label: '截图'),
            BottomNavigationBarItem(icon: Icon(Icons.gif_box), label: '动态'),
            BottomNavigationBarItem(icon: Icon(Icons.face), label: '照片'),
          ],
        ),
      );
}
