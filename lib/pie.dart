import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'darktheme.dart';
import 'guidence.dart';
class PiePage extends StatefulWidget{
  PiePage({super.key, required this.userData});
  late List<PieData> userData;
  @override
  State<PiePage> createState() => _PiePageState();
}
class PieData {
 PieData(this.xData, this.yData, [this.text]);
 final String xData;
 final num yData;
 String? text;
}
class _PiePageState extends State<PiePage>
{
  
  GlobalKey _chartKey = GlobalKey();
  Future<void> _saveChartAsPng(BuildContext context) async {
  try {
    // Находим RenderRepaintBoundary по ключу
    RenderRepaintBoundary boundary =
        _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // Преобразуем график в изображение
    ui.Image image = await boundary.toImage();

    // Конвертируем изображение в байты (PNG)
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Получаем путь для сохранения файла
    final directory = await getApplicationDocumentsDirectory();
    final String path = join(directory.path, 'chart_${DateTime.now().millisecondsSinceEpoch}.png');

    // Сохраняем файл
    File(path).writeAsBytesSync(pngBytes);

    // Проверяем, что виджет все еще mounted
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('График сохранен в $path')),
      );
    }
  } catch (e) {
    // Проверяем, что виджет все еще mounted
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
    final List<PieData> pieData = widget.userData;
    return Scaffold(
      appBar: AppBar(
            title: Center( child: Text('VizFlow')),
            actions: [
              // Кнопка для сохранения графика
              IconButton(
                icon: Icon(Icons.save_alt),
                onPressed: () => _saveChartAsPng(context),
                ),
              ],
            ),
      body: Center(
        child: RepaintBoundary(
          key: _chartKey,
          child: Container(
            child: SfCircularChart(
                backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
              legend: Legend(isVisible: true),
              series: <PieSeries<PieData, String>>[
                PieSeries<PieData, String>(
                  explode: false,
                  explodeIndex: 0,
                  dataSource: pieData,
                  xValueMapper: (PieData data, _) => data.xData,
                  yValueMapper: (PieData data, _) => data.yData,
                  dataLabelMapper: (PieData data, _) => data.text,
                  dataLabelSettings: DataLabelSettings(isVisible: true)),
                ]
              ),
          )
        )
      ),
      bottomNavigationBar: BottomAppBar(
    color: themeProvider.isDarkMode ? Colors.black : Colors.white, // Цвет BottomAppBar
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
                  backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white, // Цвет фона диалога
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
                              Text("${themeProvider.isDarkMode ? "Светлая" : "Тёмная"} тема", style: TextStyle(fontSize: 20), selectionColor: themeProvider.isDarkMode ? Colors.white : Colors.black,),
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
    );
  }
}
