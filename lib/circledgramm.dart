import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    final List<PieData> pieData = widget.userData;
    return Center(
      child: Container(
        child: Stack(
          children:[
            SfCircularChart(
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
            Positioned(
              top: 30,
              right: 30,
              child:
                ElevatedButton(onPressed: (){
                      Navigator.pop(context);
                     },
                     child: Text(
                      'Назад', style: TextStyle(color: Colors.black),),
                          ),
                        )
          ],
          
          
        )
      )
    );
  }
}
