import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
class PiePage extends StatefulWidget{
  const PiePage({super.key});
  @override
  State<PiePage> createState() => _PiePageState();
}
class _PieData {
 _PieData(this.xData, this.yData, [this.text]);
 final String xData;
 final num yData;
 String? text;
}
class _PiePageState extends State<PiePage>
{
  @override
  Widget build(BuildContext context) {
      final List<_PieData> pieData = [
    _PieData("One", 31), _PieData("Two", 31), _PieData("Three", 31)];
    return Center(
      child:SfCircularChart(
        backgroundColor: Colors.white,
      title: ChartTitle(text: 'Sales by sales person'),
      legend: Legend(isVisible: true),
      series: <PieSeries<_PieData, String>>[
        PieSeries<_PieData, String>(
          explode: true,
          explodeIndex: 0,
          dataSource: pieData,
          xValueMapper: (_PieData data, _) => data.xData,
          yValueMapper: (_PieData data, _) => data.yData,
          dataLabelMapper: (_PieData data, _) => data.text,
          dataLabelSettings: DataLabelSettings(isVisible: true)),
        ]
      )
    );
  }
}
