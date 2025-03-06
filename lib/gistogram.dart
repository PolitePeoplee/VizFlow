import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
class GistogramPage extends StatefulWidget{
  final List<int> userData;
  final int userColCount;
  GistogramPage({super.key, required this.userData, required this.userColCount});
  @override
  State<GistogramPage> createState() => _GistogramPageState();
}

class _GistogramPageState extends State<GistogramPage>
{
  double setInterval(List<int> data, int userColCount)
  {
    double interval;
    interval = (data.reduce(max) - data.reduce(min)) / (userColCount - 1);
    return interval;
  }
  @override
  Widget build(BuildContext context) {
     late List<int> histogramData = widget.userData;
        return Scaffold(
            body: Center(
                child: Container(
                  child: Stack(
                    children: [
                      SfCartesianChart(series: <CartesianSeries>[
                    HistogramSeries<int, double>(
                    dataSource: histogramData,
                    binInterval: setInterval(histogramData, widget.userColCount),
                    yValueMapper: (int data, _) => data)]),
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
