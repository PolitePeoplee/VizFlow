import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    final List<Offset> points = widget.userPoints;

    // Находим минимальные и максимальные значения по осям X и Y
    double minX = points.map((point) => point.dx).reduce((a, b) => a < b ? a : b);
    double maxX = points.map((point) => point.dx).reduce((a, b) => a > b ? a : b);
    double minY = points.map((point) => point.dy).reduce((a, b) => a < b ? a : b);
    double maxY = points.map((point) => point.dy).reduce((a, b) => a > b ? a : b);

    // Рассчитываем параметры линии регрессии
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
        title: Text('График корреляции'),
      ),
      body: Padding(
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
    );
  }
}
