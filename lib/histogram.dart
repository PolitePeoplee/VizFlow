import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HistogramPage extends StatefulWidget{
  List<dynamic> userData;
  int userColCount;
  HistogramPage({super.key, required this.userData, required this.userColCount});
  @override
  State<HistogramPage> createState() => _HistogramPageState();
}

class _HistogramPageState extends State<HistogramPage>
{
  GlobalKey _chartKey = GlobalKey();
  double setInterval(List<dynamic> data, int userColCount)
  {
    List<int> data1 = [];
    for(int i = 0; i < data.length; i++)
    {
      data1.add(data[i]);
    }
    double interval;
    interval = (data1.reduce(max) - data1.reduce(min)) / (userColCount - 1);
    return interval;
  }
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
     List<dynamic> histogramData = widget.userData;
        return Scaffold(
          appBar: AppBar(
            title: Center(child: Text('VizFlow')),
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
                    child: SfCartesianChart(
                      backgroundColor: Colors.white,
                      series: <CartesianSeries>[
                      HistogramSeries<dynamic, double>(
                      dataSource: histogramData,
                      binInterval: setInterval(histogramData, widget.userColCount),
                      yValueMapper: (dynamic data, _) => data)]),
                          )
                      )
                    ),
                  );
  }
}
