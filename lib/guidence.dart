import 'package:flutter/material.dart';

class GuidePage extends StatefulWidget{
  GuidePage({super.key});
  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage>
{
  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: Text('Руководство'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Руководство',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Дашборд визуализирует данные в виде одного из трех графиков на выбор.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Как создать график?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. На главной странице нажмите на +',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '2. Введите название графика',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '3. Выберите тип графика',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '4. Выберите источник данных',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Построение гистограммы:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Ручной ввод (до 10 значений):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '1. Введите название столбца с данными для оси ОХ',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '2. Укажите количество столбцов',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '3. Нажмите Далее',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '4. Введите значения, по которым будет строиться гистограмма',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '5. Нажмите ОК, затем на зелёную кнопку с названием и типом графика',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Файл .disc:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '1. Введите название столбцов с данными для ОХ и ОУ',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '2. Выберите файл формата .xlsx',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '3. Нажмите ОК, затем на зелёную кнопку с названием и типом графика',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Построение круговой диаграммы:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Ручной ввод (до 10 значений):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '1. Введите количество секторов',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '2. Нажмите Далее',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '3. Введите название секторов и их значений',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '4. Нажмите ОК, затем на зелёную кнопку с названием и типом графика',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Файл .xlsx:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '1. Введите название названия столбцов с данными и категориями',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '2. Выберите файл формата .xlsx',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '3. Нажмите ОК, затем на зелёную кнопку с названием и типом графика',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              'Построение графика корреляции:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Ручной ввод (до 10 значений):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '1. Введите название осей ОХ и ОУ',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '2. Укажите количество точек',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '3. Нажмите Далее',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '4. Введите данные каждой точки (значения по осям X и Y)',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '5. Нажмите ОК, затем на зелёную кнопку с названием и типом графика',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Файл .xlsx:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '1. Введите названия осей ОХ и ОУ',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '2. Выберите файл формата .xlsx',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '3. Нажмите ОК, затем на зелёную кнопку с названием и типом графика',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
