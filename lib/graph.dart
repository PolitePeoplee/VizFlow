import 'package:flutter/material.dart';
class LRPage extends StatefulWidget{
  const LRPage({super.key});
  @override
  State<LRPage> createState() => _LRPageState();
}
class RegressionLinePainter extends CustomPainter {
  final List<Offset> points;
  final double m;
  final double b;

  RegressionLinePainter(this.points, this.m, this.b);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;

    // Рисуем оси
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint); // Ось X
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint); // Ось Y

    // Рисуем точки
    for (var point in points) {
      canvas.drawCircle(
        Offset(point.dx * 50, size.height - point.dy * 50), // Масштабируем точки
        4,
        paint..color = Colors.red,
      );
    }

    // Рисуем линию регрессии
    final startY = m * 0 + b; // y = mx + b при x = 0
    final endY = m * (size.width / 50) + b; // y = mx + b при x = size.width / 50

    canvas.drawLine(
      Offset(0, size.height - startY * 50),
      Offset(size.width, size.height - endY * 50),
      paint..color = Colors.green,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
class _LRPageState extends State<LRPage>
{
  @override
  Widget build(BuildContext context) {
      final List<Offset> points = [
    Offset(1, 2),
    Offset(2, 3),
    Offset(3, 5),
    Offset(4, 4),
    Offset(5, 6),
      ];
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
    final regressionParams = calculateRegressionLine(points);
    final m = regressionParams['m']!;
    final b = regressionParams['b']!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Линейная регрессия'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: CustomPaint(
                size: Size(double.infinity, 300),
                painter: RegressionLinePainter(points, m, b),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Уравнение линии регрессии: y = ${m.toStringAsFixed(2)}x + ${b.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
