import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
                backgroundColor: Colors.white,
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
      )
    );
  }
}
