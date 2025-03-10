import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'darktheme.dart';
import 'guidence.dart';
class LRPage extends StatefulWidget {
  final List<Offset> userPoints;
  LRPage({super.key, required this.userPoints});

  @override
  State<LRPage> createState() => _LRPageState();
}

class RegressionLinePainter extends CustomPainter {
  final List<Offset> points;
  final double m;
  final double b;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  RegressionLinePainter(this.points, this.m, this.b, this.minX, this.maxX, this.minY, this.maxY);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;

    // Рисуем оси
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint); // Ось X
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint); // Ось Y

    // Нормализация и масштабирование точек
    for (var point in points) {
      double normalizedX = (point.dx - minX) / (maxX - minX);
      double normalizedY = (point.dy - minY) / (maxY - minY);

      double scaledX = normalizedX * size.width;
      double scaledY = size.height - normalizedY * size.height; // Инвертируем Y для корректного отображения

      canvas.drawCircle(
        Offset(scaledX, scaledY),
        4,
        paint..color = Colors.red,
      );
    }

    // Рисуем линию регрессии
    double startX = minX;
    double endX = maxX;

    double startY = m * startX + b; // y = mx + b
    double endY = m * endX + b;

    double normalizedStartX = (startX - minX) / (maxX - minX);
    double normalizedEndX = (endX - minX) / (maxX - minX);
    double normalizedStartY = (startY - minY) / (maxY - minY);
    double normalizedEndY = (endY - minY) / (maxY - minY);

    double scaledStartX = normalizedStartX * size.width;
    double scaledStartY = size.height - normalizedStartY * size.height;
    double scaledEndX = normalizedEndX * size.width;
    double scaledEndY = size.height - normalizedEndY * size.height;

    canvas.drawLine(
      Offset(scaledStartX, scaledStartY),
      Offset(scaledEndX, scaledEndY),
      paint..color = Colors.green,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _LRPageState extends State<LRPage> {
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
      Map<String, double> calculateRegressionLine(List<Offset> points) {
      int n = points.length;
      double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

      for (var point in points) {
        sumX += point.dx;
        sumY += point.dy;
        sumXY += point.dx * point.dy;
        sumX2 += point.dx * point.dx;
      }

      double m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
      double b = (sumY - m * sumX) / n;

      return {'m': m, 'b': b};
    }
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<Offset> points = widget.userPoints;
    // Находим минимальные и максимальные значения по осям X и Y
    double minX = points.map((point) => point.dx).reduce((a, b) => a < b ? a : b);
    double maxX = points.map((point) => point.dx).reduce((a, b) => a > b ? a : b);
    double minY = points.map((point) => point.dy).reduce((a, b) => a < b ? a : b);
    double maxY = points.map((point) => point.dy).reduce((a, b) => a > b ? a : b);
    final regressionParams = calculateRegressionLine(points);
    final m = regressionParams['m']!;
    final b = regressionParams['b']!;
    return Scaffold(
      //backgroundColor: Colors.white,
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
          //color: themeProvider.isDarkMode ? Colors.black : Colors.white,
          child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: CustomPaint(
                        size: Size(double.infinity, 300),
                        painter: RegressionLinePainter(points, m, b, minX, maxX, minY, maxY),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Уравнение линии корреляции: y = ${m.toStringAsFixed(2)}x + ${b.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18),
                    ),
                        ],
                      ),
                    ),
            )
          )
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
