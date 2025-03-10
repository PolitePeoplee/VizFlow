import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import 'darktheme.dart';
import 'guidence.dart';

class HistogramPage extends StatefulWidget {
  List<dynamic> userData;
  int userColCount;
  HistogramPage({super.key, required this.userData, required this.userColCount});

  @override
  State<HistogramPage> createState() => _HistogramPageState();
}

class _HistogramPageState extends State<HistogramPage> {
  GlobalKey _chartKey = GlobalKey();

  double setInterval(List<dynamic> data, int userColCount) {
    List<int> data1 = [];
    for (int i = 0; i < data.length; i++) {
      data1.add(data[i]);
    }
    double interval;
    interval = (data1.reduce(max) - data1.reduce(min)) / (userColCount - 1);
    return interval;
  }

  Future<void> _saveChartAsPng(BuildContext context) async {
    try {
      RenderRepaintBoundary boundary =
          _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final String path = join(directory.path, 'chart_${DateTime.now().millisecondsSinceEpoch}.png');

      File(path).writeAsBytesSync(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('График сохранен в $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении: $e')),
        );
      }
    }
  }

  @override
 Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  List<dynamic> histogramData = widget.userData;

  return Scaffold(
  appBar: AppBar(
    title: Center(child: Text('VizFlow')),
    actions: [
      IconButton(
        icon: Icon(Icons.save_alt),
        onPressed: () => _saveChartAsPng(context),
      ),
    ],
  ),
  body: Column(
    children: [
      Expanded(
        child: RepaintBoundary(
          key: _chartKey,
          child: Container(
            color: colorScheme.surface, // Цвет фона контейнера в зависимости от темы
            child: SfCartesianChart(
              backgroundColor: colorScheme.surface, // Цвет фона графика
              primaryXAxis: NumericAxis(
                labelStyle: TextStyle(color: colorScheme.onSurface), // Цвет текста оси X
              ),
              primaryYAxis: NumericAxis(
                labelStyle: TextStyle(color: colorScheme.onSurface), // Цвет текста оси Y
              ),
              series: <CartesianSeries>[
                HistogramSeries<dynamic, double>(
                  dataSource: histogramData,
                  binInterval: setInterval(histogramData, widget.userColCount),
                  yValueMapper: (dynamic data, _) => data,
                  color: themeProvider.isDarkMode ? const ui.Color.fromARGB(99, 174, 228, 253) : Colors.lightBlue, // Цвет столбцов гистограммы
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
  bottomNavigationBar: BottomAppBar(
    //color: themeProvider.isDarkMode ? Colors.black : Colors.white, // Цвет BottomAppBar
    shape: CircularNotchedRectangle(),
    notchMargin: 8.0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GuidePage(),
              ),
            );
          },
          child: Image.asset(
            'assets/images/book.png',
            width: 25,
            height: 28,
          ),
        ),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  //backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white, // Цвет фона диалога
                  child: Container(
                    width: 307,
                    height: 185,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Text("Настройки", style: TextStyle(fontSize: 20)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Divider(thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0, left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 35),
                              Text("Тёмная тема", style: TextStyle(fontSize: 20), selectionColor: themeProvider.isDarkMode ? Colors.white : Colors.black,),
                              SizedBox(width: 35),
                              Switch(
                                value: themeProvider.isDarkMode,
                                onChanged: (value) {
                                  themeProvider.toggleTheme();
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30, right: 100),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 115,
                              height: 27,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFF2F2F2), // Цвет фона кнопки
                                  shadowColor: Colors.black.withOpacity(0.2), // Цвет тени
                                  elevation: 5, // Уровень тени
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Ок',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Image.asset(
            'assets/images/settings.png',
            width: 28,
            height: 28,
          ),
        ),
      ], // Закрывающая скобка для Row
    ),
  ),
); // Закрывающая скобка для BottomAppBar

}
}
