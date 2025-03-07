import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
class GistogramPage extends StatefulWidget{
  final List<dynamic> userData;
  final int userColCount;
  GistogramPage({super.key, required this.userData, required this.userColCount});
  @override
  State<GistogramPage> createState() => _GistogramPageState();
}

class _GistogramPageState extends State<GistogramPage>
{
  double setInterval(List<dynamic> data, int userColCount)
  { 
    List<int> data1 = [];
    for(int i = 0; i < data.length; i++)
    {
      data1.add(int.parse(data[i]));
    }
    double interval;
    interval = (data1.reduce(max) - data1.reduce(min)) / (userColCount - 1);
    return interval;
  }
  @override
  Widget build(BuildContext context) {
     late List<dynamic> histogramData = widget.userData;
        return Scaffold(
            body: Center(
                child: Container(
                  child: Stack(
                    children: [
                      SfCartesianChart(series: <CartesianSeries>[
                    HistogramSeries<dynamic, double>(
                    dataSource: histogramData,
                    binInterval: setInterval(histogramData, widget.userColCount),
                    yValueMapper: (dynamic data, _) => data)]),
                    Positioned(
                      top: 30,
                      right: 15,
                      child:
                    ElevatedButton(onPressed: (){
                        Navigator.pop(context);
                     },
                    child: Text(
                      'Назад', style: TextStyle(color: Colors.black),),
                          ),
                        )
                      ]
                    )
                  ),
                )
              );
  }
}
