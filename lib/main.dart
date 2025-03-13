import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_selector_aurora/file_selector_aurora.dart';
import 'package:VizFlow/guidence.dart';
import 'package:VizFlow/pie.dart';
import 'package:VizFlow/histogram.dart';
import 'package:VizFlow/lrgraph.dart';
import 'package:provider/provider.dart';
import 'darktheme.dart';
import 'package:excel/excel.dart' as ex;
import 'package:file_selector/file_selector.dart' as fs;
final navigatorKey = GlobalKey<NavigatorState>();
class OpenFile extends FileSelectorAurora{
  Future <List<dynamic>> readExcelFile(fs.XFile file, String? formHist) async {
  try {
    // Чтение байтов из файла
    final bytes = await file.readAsBytes();

    // Декодирование Excel файла
    var excel = ex.Excel.decodeBytes(bytes);
    var result = [];
    // Перебор всех листов в файле
    for (var table in excel.tables.keys) {

      // Перебор всех строк в листе
      for (var row in excel.tables[table]!.rows) {
        if(formHist == "Гистограмма")// Преобразование строки в список значений
        {
        var rowData = row.map((cell) => cell?.value.toString()).toString();
        rowData = rowData.replaceAll('(', '').replaceAll(')', '');
        var rowDataDouble = int.tryParse(rowData) ?? -1;
        result.add(rowDataDouble);
        }
        else if(formHist == "Круговая диаграмма")
        {
          var rowData = row.map((cell) => cell?.value.toString()).toString();
          rowData = rowData.replaceAll('(', '').replaceAll(')', '').replaceAll(' ', '');
          List<String> parts = rowData.split(',');
          result.add(parts);
        }
        else if(formHist == "График корреляции")
        {
          var rowData = row.map((cell) => cell?.value.toString()).toString();
          rowData = rowData.replaceAll('(', '').replaceAll(')', '').replaceAll(' ', '');
          List<String> parts = rowData.split(',');
          result.add(parts);
        }
      }
    }
    return result;
  } catch (e) {
    print("Ошибка при чтении файла: $e");
    List<dynamic> a = [];
    return a;
  }
}
  List<dynamic> data = [];
  Future<void> openImageFile(String? formHist) async {
  const fs.XTypeGroup typeGroup = fs.XTypeGroup(
    extensions: <String>['xlsx'],
  );

  // Выбираем файл
  var home = Platform.environment['HOME'];
  fs.XFile? file = await openFile(acceptedTypeGroups: <fs.XTypeGroup>[typeGroup], initialDirectory: home);
  if (file != null) {
    // Откладываем выполнение до завершения текущего кадра
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Читаем данные из файла
      var newData = await readExcelFile(file, formHist);

      // Обновляем состояние, если виджет всё ещё "жив
          data = newData;  // Обновляем данныеx`
    });
  }
}
}
void main() {
  FileSelectorAuroraKeyContainer.navigatorKey = navigatorKey;
  runApp(ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: VizFlowApp()));
}

class VizFlowApp extends StatelessWidget {
  const VizFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        theme: themeProvider.currentTheme,
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      );
      }
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String? formHist; // переменная для выбранного элемента
  String? wayEnter; // переменная для выбранного источника данных
  String? rowName;
  String? colName;
  late int colCount = 0;
  String named = ""; // Хранит имя
  String? positiond; // Хранит тип графика (может быть null)
  bool _isDataSourceExpanded = false; // состояние для управления видимостью выпадающего меню
  bool _isFileSourceExpanded = false; // состояние для управления видимостью второго меню (Файл формата или Ручной ввод)
  bool widgetFinished = false;
  late AnimationController _controller;
  int secondWidgetCount = 0;
  int widgetCount = 0; // Счетчик виджетов
  int alignInt = 0;
  double dialogWidth = 300;
  double dialogHeight = 480;
  late List<PieData> pieData = [];
  bool showFields = false;
  bool showNewWidgets = false;
  List<TextEditingController> _textControllers = [];
  List<dynamic> gistData = [];
  List<Offset> LRData = [];
  List<List<dynamic>> chartsData = [];
  List<dynamic> filesData = [];
  List<List<dynamic>> handData = [];
  bool darkTheme = false;
// Позиции виджетов
  bool _isPlusWidgetMoved = false; // Флаг для отслеживания смещения
  List<Widget> greenWidgets = []; // Список зеленых виджетов
  var a = OpenFile();
  void _updateWidgetPosition() {
    setState(() {
      if (_isPlusWidgetMoved) {
        // Если виджет уже сместился, смещаем его наискосок влево вниз
        _isPlusWidgetMoved = false; // Сбрасываем флаг
      } else {
        // Если виджет не смещен, смещаем его вправо
        _isPlusWidgetMoved = true; // Устанавливаем флаг
      }
    });
  }
  void _showFAQDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 250, height: 200, padding: EdgeInsets.all(8),
          child: Column(children: [Text('FAQ'),
          Column(children: [
            Row(children: [
              Image.asset(
            'assets/images/book.png',
            width: 48,
            height: 48,
            ),
          Text("Руководство")
            ],
          ),
          Divider(),
          Row(children: [
            Image.asset(
            'assets/images/settings.png',
            width: 48,
            height: 48,
            ),
          Text("Настройки")
          ],)
          ],
          ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Закрыть'),
              ),
            ],
            )
          )
        );
      },
    );

  }
  Widget showOkButton(bool hand) {
    return SizedBox(
      width: 120,
      height: 30,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8FFF9A),
        ),
        onPressed: () {
          print(hand);
          bool Empty = false;
          if (hand) {
            for (int i = 0; i < _textControllers.length; i++) {
              if(!_textControllers[i].text.isNotEmpty) {
                Empty = !Empty;
                break;
              }
            }
            if (!Empty) {
                _addGreenWidget(); // Добавление нового зеленого виджета
              _updateWidgetPosition();
              if (alignInt == 5) {
              widgetFinished = true;
              } 
              Navigator.pop(context);
              alignInt++;
            }
            else {
              showErrorWindow();
            }
          }
          else if (colCount != 0 && a.data.isNotEmpty) {
            _addGreenWidget(); // Добавление нового зеленого виджета
            _updateWidgetPosition();
            if (alignInt == 5) {
            widgetFinished = true;
            } 
            Navigator.pop(context);
            alignInt++;
          }
          else {
            showErrorWindow();
          }
        },
        child: Text(
          'Ок',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
  void showErrorWindow() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 218,
            height: 37,
            child: Center(
              child: Text(
                'Все поля должны быть заполнены',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showErrorCount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 218,
            height: 37,
            child: Center(
              child: Text(
                'Количество не должно превышать 10',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _addGreenWidget() {
    setState(() {
      chartsData.add([formHist, wayEnter, greenWidgets.length, colCount]);
      greenWidgets.add(_buildGreenWidget(greenWidgets.length)); // Добавляем новый зеленый виджет
    });
  }
  Alignment setAlignment(int index)
    {
      int num = index;
      switch (num)
      {
        case 0:
          return Alignment.topLeft;
        case 1:
          return Alignment.topRight;
        case 2:
          return Alignment.centerLeft;
        case 3:
          return Alignment.centerRight;
        case 4:
          return Alignment.bottomLeft;
        case 5:
          return Alignment.bottomRight;
        default:
          return Alignment.topCenter;
      }
    }

  @override
  void initState() {
    super.initState();
    // Инициализация AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Освобождаем контроллер
    super.dispose();
  }
  void fillPieData(index)
  {
    for(int i = 0; i < handData[index].length - 1; i++)
      {
        if(i%2 == 0) {
          pieData.add(PieData(handData[index][i], int.parse(handData[index][i+1])));
        } else {
          continue;
        }
      }
  }
  void fillPieDataFile(index){
    for(int i =0; i < filesData[index].length; i++)
    {
      pieData.add(PieData(filesData[index][i][0], int.parse(filesData[index][i][1])));
    }
  }
  void fillGistDataFile(index)
  {
    for(int i = 0; i < filesData[index].length; i++)
    {
      gistData.add(filesData[index][i]);
    }
  }
  void fillGistData(index){
    for(int i = 0; i < handData[index].length; i++)
    {
      gistData.add(int.parse(handData[index][i]));
    }
  }
  void fillHandData(index)
  {
    handData.add([]);
    for(int i = 0; i < _textControllers.length; i++)
    {
      handData[index].add(_textControllers[i].text);
    }
    }
  void fillLRDataFile(index)
  {
    for(int i = 0; i < filesData[index].length; i++)
    {
      LRData.add(Offset(double.parse(filesData[index][i][0]), double.parse(filesData[index][i][1])));
    }
  }
  void fillLRData(index)
  {
    for(int i = 0; i < handData[index].length; i++)
    {
      if(i%2 == 0) {
        LRData.add(Offset(double.parse(handData[index][i]), double.parse(handData[index][i+1])));
      } else {
        continue;
      }
    }
  }
  void debugData(String name, String? position, String? source) {
    // Создаем объект с данными
    Map<String, dynamic> data = {
      'name': name,
      'position': position,
      'dataSource': source,
    };
    setState(() {
      named = name;
      positiond = position;
    });
    // Преобразуем объект в JSON
    String jsonData = jsonEncode(data);
    // Здесь вы можете сохранить jsonData в файл или отправить на сервер
    // Например, вы можете использовать метод для сохранения в файл
    print(jsonData); // Для проверки выведем в консоль
  }
Widget _buildGreenWidget(int index) {
    if(chartsData[index][1] == "Файл формата")
      {
        handData.add([]);
        filesData.add(a.data);
      }
    else
      {
        filesData.add([]);
        fillHandData(index);
      }
    return Align(
      alignment: setAlignment(index),
      child: GestureDetector(
        onTap: () {
                  if(chartsData[index][0] == "Гистограмма")
                  {
                    if(chartsData[index][1] == "Файл формата")
                    {
                      gistData = [];
                      fillGistDataFile(index);
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistogramPage(userData: gistData, userColCount: chartsData[index][3],),
                        )
                      );
                    }
                    else{
                      gistData = [];
                      fillGistData(index);
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistogramPage(userData: gistData, userColCount: chartsData[index][3]),
                        )
                      );
                    }
                  }
                  else if(chartsData[index][0] == "Круговая диаграмма")
                  {
                    if(chartsData[index][1] == "Файл формата")
                    {
                      pieData = [];
                      fillPieDataFile(index);
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PiePage(userData: pieData),
                        )
                      );
                    }
                    else{
                      pieData = [];
                      fillPieData(index);
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PiePage(userData: pieData),
                        )
                      );
                    }
                  }
                  else if(chartsData[index][0] == "График корреляции")
                  {
                    if(chartsData[index][1] == "Файл формата")
                    {
                      LRData = [];
                      fillLRDataFile(index);
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LRPage(userPoints: LRData),
                        )
                      );
                    }
                    else{
                      LRData = [];
                      fillLRData(index);
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LRPage(userPoints: LRData),
                        )
                      );
                    }
                  }
},
        child: Container(
          margin: EdgeInsets.all(11),
          // width: 170,
          // height: 170,
          decoration: BoxDecoration(
            color: Color.fromRGBO(42, 216, 94, 0.41), // Цвет фона
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Название: $named', // Подставьте переменную с названием
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Divider(
                color: Colors.black, // Разделитель
                thickness: 1,
              ),
              Text(
                'Тип: $positiond', // Подставьте переменную с типом
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      //backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          actions: [
            IconButton(
            onPressed: (){
              _showFAQDialog(context);
            },
            icon: themeProvider.isDarkMode ? Image.asset('assets/images/question_white.png',width: 32,height: 32) : Image.asset('assets/images/question_black.png',width: 32,height: 32)),
          ],
          title: GradientText(
            'VizFlow',
            gradient: LinearGradient(
              colors: [Color(0xFF2AD85E), Color(0xFF34EDEF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w400,
              fontFamily: 'Roboto', // Дефолтный шрифт
            ),
          ),
          centerTitle: true,
          //backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
          elevation: 0,
        ),
      ),
      body: Column(
      children: [
        Divider(),
        Flexible(
          child: AnimatedAlign(
            alignment: setAlignment(alignInt),
            duration: Duration(milliseconds: 300),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (screenWidth/170).floor(), // 2 виджета по горизонтали
              childAspectRatio: 1, // Соотношение ширины и высоты
            ),
            itemCount: greenWidgets.length + (widgetFinished ? 0 : 1), // +1 для виджета с плюсом
            itemBuilder: (context, index) {
              if (index < greenWidgets.length) {
                return greenWidgets[index]; // Зеленые виджеты
              } else {
                return Visibility(
                  visible: !widgetFinished,
                  child: GestureDetector(
                    onTap: () {
                      _showParameterDialog(context);
                    },
                    child: Container(
                      margin: EdgeInsets.all(10), // Уменьшите отступ, если необходимо
                      width: 170,
                      height: 170,
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(Icons.add, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        ),
      ],
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
                  //backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white, // Цвет фона диалога
                  child: SizedBox(
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
                              Text("Тёмная тема", style: TextStyle(fontSize: 20), selectionColor: themeProvider.isDarkMode ? Colors.white : Colors.black,),
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
                                  //backgroundColor: Color(0xFFF2F2F2), // Цвет фона кнопки
                                  shadowColor: Colors.black.withOpacity(0.2), // Цвет тени
                                  elevation: 5, // Уровень тени
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Ок',
                                  //style: TextStyle(color: Colors.black),
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

  void _showParameterDialog(BuildContext context) {
    _textControllers = [];
    TextEditingController textController = TextEditingController();
    TextEditingController firstController = TextEditingController(); // Контроллер для первого TextField
    TextEditingController secondController = TextEditingController(); // Контроллер для второго TextField
    bool handCorel = false;
    bool handHist = false;
    bool handCircle = false;
    bool handCircle2 = false;
    bool handEnter = false;
    bool isWidgetsVisible = true;
    bool isLastWidget = false;
    formHist = null;
    wayEnter = null;
    colCount = 0;
    String inputValue = '';
    _isDataSourceExpanded = false; // состояние для управления видимостью выпадающего меню
    _isFileSourceExpanded = false; // состояние для управления видимостью второго меню (Файл формата или Ручной ввод)
    widgetFinished = false;
    dialogWidth = 300;
    dialogHeight = 480;
    showDialog(
      context: context,
      builder: (BuildContext context) {
          Provider.of<ThemeProvider>(context);
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: dialogWidth,
                height: dialogHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  //color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                  gradient: LinearGradient(
                    colors: [Color(0xFF75EC8E), Color(0xFF91E5E6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      //color: Color(0x40000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (isWidgetsVisible) ... [
                    Positioned(
                      bottom: 15,
                      right: 25,
                      child: SizedBox(
                        width: 120,
                        height: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8FFF9A),
                          ),
                          onPressed: () {
                            setState(() {
                            if (textController.text != "" && formHist != null && wayEnter != null) {
                              debugData(textController.text, formHist, wayEnter);
                                dialogHeight = 335;
                                dialogWidth = 307;
                                isWidgetsVisible = false;
                                if (formHist == 'Круговая диаграмма') {
                                if (wayEnter == 'Файл формата') {
                                  isLastWidget = true;
                                }
                                else {
                                  handCircle2 = true;
                                  dialogHeight = 122;
                                  dialogWidth = 307;
                                }
                                }
                                if (formHist == 'Гистограмма') {
                                  dialogHeight = 240;
                                  dialogWidth = 307;
                                  if(wayEnter == 'Ручной ввод') { 
                                  handHist = true;
                                } else {
                                  dialogHeight = 305;
                                  dialogWidth = 307;
                                  isLastWidget = true;
                                }
                                }
                                if (formHist == 'График корреляции') {
                                  dialogHeight = 335;
                                  dialogWidth = 307;
                                  if (wayEnter == 'Ручной ввод') { 
                                  handCorel = true;
                                }
                                else {
                                  isLastWidget = true;
                                }
                                }
                            }
                            else {
                              showErrorWindow();
                            }
                            if (handCircle2 || handHist || handCorel) {
                                handEnter = true;
                            }
                            });
                            },
                          child: Text(
                            'Далее!',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 25,
                      left: 25,
                      child: Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFFDDFFE4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Color(0x65656587),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          cursorColor: Colors.black,
                          controller: textController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Введите название',
                            hintStyle: TextStyle(color: Colors.black), // Цвет текста подсказки
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 13), // Отступы по вертикали
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        top: 85,
                        left: 25,
                        child: Container(
                          width: 250,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFFDDFFE4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Color(0x65656587), width: 1),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isDataSourceExpanded = !_isDataSourceExpanded;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center, // Центрируем по горизонтали
                              crossAxisAlignment: CrossAxisAlignment.center, // Центрируем по вертикали
                              children: [
                                  Text(
                                    formHist ?? 'Тип графика',
                                    textAlign: TextAlign.center, // Центрируем текст
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Roboto', // Дефолтный шрифт
                                    ),
                                  ),
                                Icon(
                                  _isDataSourceExpanded
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 145,
                      left: 25,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: 250,
                        height: _isDataSourceExpanded ? 120 : 0, // Expand height on tap
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: Colors.white, // Фон меню белый
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView(
                          children: [
                            _buildMenuItem('Гистограмма', setState),
                            _buildMenuItem('Круговая диаграмма', setState),
                            _buildMenuItem('График корреляции', setState),
                          ],
                        ),
                      ),
                    ),
                    // Новый прямоугольник для выбора источника данных
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      top: _isDataSourceExpanded ? 285 : 145, // Сдвиг вниз
                      left: 25,
                      child: Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFFDDFFE4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(0x65656587), width: 1),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isFileSourceExpanded = !_isFileSourceExpanded;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Центрируем по горизонтали
                            crossAxisAlignment: CrossAxisAlignment.center, // Центрируем по вертикали
                            children: [
                                Text(
                                  wayEnter ?? 'Источник данных',
                                  textAlign: TextAlign.center, // Центрируем текст
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Roboto', // Дефолтный шрифт
                                  ),
                                ),
                              Icon(
                                _isFileSourceExpanded
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Меню для выбора файла или ручного ввода
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      top: _isDataSourceExpanded ? 345 : 205, // Сдвиг вниз
                      left: 25,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: 250,
                        height: _isFileSourceExpanded ? 80 : 0,
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: Colors.white, // Фон меню белый
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView(
                          children: [
                            _buildFileSourceItem('Файл формата', setState),
                            _buildFileSourceItem('Ручной ввод', setState),
                          ],
                        ),
                      ),
                    ),
                  ],

                  if (handHist && isLastWidget) ...[
  Column(
    children: [
      Container(
        width: 250,
        height: 40,
        alignment: Alignment.center,
        child: SizedBox(
          width: 250,
          child: Text(
            'Введите значения',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Divider(
          color: Colors.black,
          thickness: 0.5,
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: (colCount) * 50 + 100, // Ограничиваем высоту
                child: Stack(
                  children: List.generate(colCount, (index) {
                    while (_textControllers.length <= index) {
                      _textControllers.add(TextEditingController());
                    }

                    return Positioned(
                      top: 25 + (index * 50), // Смещение вниз для каждого элемента
                      right: 25, // Смещение вправо
                      child: SizedBox(
                        width: 250,
                        child: Row(
                          children: [
                            // Контейнер с текстом "Значение"
                            Container(
                              width: 100,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Значение ${index + 1}',
                                style: TextStyle(fontSize: 14, color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              height: 45,
                              width: 120, // Задаем ширину поля ввода
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFDDFFE4), // Цвет фона
                                  borderRadius: BorderRadius.circular(10), // Скругление углов
                                  border: Border.all(
                                    color: Color(0x65656587), // Цвет рамки
                                    width: 1, // Ширина рамки
                                  ),
                                ),
                                child: TextField(
                                  style: TextStyle(color: Colors.black),
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.black,
                                  textAlign: TextAlign.center,
                                  controller: _textControllers[index],
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    labelText: '',
                                    border: InputBorder.none, // Убираем стандартную рамку
                                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Отступы по вертикали
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 20), // Отступ перед кнопкой
      showOkButton(handEnter), // Вставляем виджет OkButton
      SizedBox(height: 20), // Отступ после кнопки
    ],
  ),
],

                  if (handCorel && isLastWidget) ...[
  Column(
    children: [
      Container(
        width: 250,
        height: 40,
        alignment: Alignment.center,
        child: SizedBox(
          width: 250,
          child: Text(
            'Введите координаты точек',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Divider(
          color: Colors.black,
          thickness: 0.5,
        ),
      ),
      Expanded(
  child: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.only(left: 40.0),
      child: Column(
        children: List.generate(colCount, (index) {
          // Проверяем, нужно ли добавить новые контроллеры
          while (_textControllers.length <= index + colCount) {
            _textControllers.add(TextEditingController());
          }

          String labelX = 'X${index + 1}:';
          String labelY = 'Y${index + 1}:';

          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Метка для X
                Container(
                  width: 30,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 4.0),
                  child: Text(
                    labelX,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Поле ввода для X
                SizedBox(
                  height: 40,
                  width: 70,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFDDFFE4), // Цвет фона
                      borderRadius: BorderRadius.circular(10), // Скругление углов
                      border: Border.all(
                        color: Color(0x65656587), // Цвет рамки
                        width: 1, // Ширина рамки
                      ),
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.black,
                      textAlign: TextAlign.center,
                      controller: _textControllers[index],
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        labelText: '',
                        border: InputBorder.none, // Убираем стандартную рамку
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Отступы
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // Метка для Y
                Container(
                  width: 30,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 4.0),
                  child: Text(
                    labelY,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Поле ввода для Y
                SizedBox(
                  height: 40,
                  width: 70,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFDDFFE4), // Цвет фона
                      borderRadius: BorderRadius.circular(10), // Скругление углов
                      border: Border.all(
                        color: Color(0x65656587), // Цвет рамки
                        width: 1, // Ширина рамки
                      ),
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.black,
                      textAlign: TextAlign.center,
                      controller: _textControllers[index + colCount],
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        labelText: '',
                        border: InputBorder.none, // Убираем стандартную рамку
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Отступы
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    ),
  ),
),
      SizedBox(height: 20), // Отступ перед кнопкой
      showOkButton(handEnter), // Вставляем виджет OkButton
      SizedBox(height: 20), // Отступ после кнопки
    ],
  ),
],

                  if (handCircle) ...[
  Column(
    children: [
      Container(
        width: 250,
        height: 40,
        alignment: Alignment.center,
        child: Text(
          'Введите название сектора и значение',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Divider(
          color: Colors.black,
          thickness: 0.5,
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Column(
              children: List.generate(colCount * 2, (index) {
                // Обеспечиваем наличие достаточного количества контроллеров
                if (_textControllers.length <= index) {
                  _textControllers.add(TextEditingController());
                }

                // Определяем текст для сектора или значения
                String labelText = (index % 2 == 0) ? 'Сектор ${index ~/ 2 + 1}' : 'Значение ${index ~/ 2 + 1}';

                return SizedBox(
                  height: 50, // Высота для каждого элемента
                  child: Row(
                    children: [
                      // Контейнер для текста сектора или значения
                      Container(
                        width: 100,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          labelText,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Поле ввода
                      SizedBox(
                          height: 40,
                          width: 70,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFDDFFE4), // Цвет фона
                              borderRadius: BorderRadius.circular(10), // Скругление углов
                              border: Border.all(
                                color: Color(0x65656587), // Цвет рамки
                                width: 1, // Ширина рамки
                              ),
                            ),
                            child: TextField(
                              style: TextStyle(color: Colors.black),
                              keyboardType: TextInputType.number,
                              cursorColor: Colors.black,
                              textAlign: TextAlign.center,
                              controller: _textControllers[index],
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                labelText: '',
                                border: InputBorder.none, // Убираем стандартную рамку
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Отступы по вертикали
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      SizedBox(height: 20), // Отступ перед кнопкой
      showOkButton(handEnter), // Вставляем виджет OkButton
      SizedBox(height: 15), // Отступ после кнопки
    ],
  ),
],

                  
                  ///////////////////////////////////////////////////////////////////////////
                  if (wayEnter == 'Файл формата' || formHist != 'Круговая диаграмма') ...[
                    Positioned(
                      top: 85,
                      left: 25,
                      child: Visibility(
                        visible: (wayEnter == 'Файл формата' && formHist == 'График корреляции' && isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Гистограмма' && isLastWidget) || (!isWidgetsVisible && !isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Круговая диаграмма' && !isWidgetsVisible) ? true : false,
                        child: SizedBox(
                          height: 40,
                          width: 250,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFDDFFE4), // Цвет фона
                              borderRadius: BorderRadius.circular(10), // Скругление углов
                              border: Border.all(
                                color: Color(0x65656587), // Цвет рамки
                                width: 1, // Ширина рамки
                              ),
                            ),
                            child: TextField(
                              style: TextStyle(color: Colors.black),
                              keyboardType: TextInputType.number,
                              cursorColor: Colors.black,
                              textAlign: TextAlign.center,
                              controller: firstController,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                labelText: '',
                                border: InputBorder.none, // Убираем стандартную рамку
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Отступы по вертикали
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 185,
                      left: 25,
                      child: Visibility(
                        visible: (wayEnter == 'Файл формата' && formHist == 'График корреляции' && isLastWidget) || (!isWidgetsVisible && formHist != 'Гистограмма' && !isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Круговая диаграмма' && !isWidgetsVisible)? true : false,
                        child: SizedBox(
                          height: 40,
                          width: 250,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFDDFFE4), // Цвет фона
                              borderRadius: BorderRadius.circular(10), // Скругление углов
                              border: Border.all(
                                color: Color(0x65656587), // Цвет рамки
                                width: 1, // Ширина рамки
                              ),
                            ),
                            child: TextField(
                              style: TextStyle(color: Colors.black),
                              keyboardType: TextInputType.number,
                              cursorColor: Colors.black,
                              textAlign: TextAlign.center,
                              controller: firstController,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                labelText: '',
                                border: InputBorder.none, // Убираем стандартную рамку
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Отступы по вертикали
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 25, // Положение сверху
                      left: 40, // Положение слева
                      child: Visibility(
                        visible: (wayEnter == 'Файл формата' && formHist == 'График корреляции' && isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Гистограмма' && isLastWidget) || (!isWidgetsVisible && !isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Круговая диаграмма' && !isWidgetsVisible) ? true : false,
                        child: SizedBox(
                          width: 218, // Ширина
                          height: 37, // Высота
                          child: Center(
                            child: Text(
                              formHist == 'Круговая диаграмма'
                                  ? 'Укажите название столбца с данными'
                                  : formHist == 'Гистограмма'
                                      ? 'Укажите название столбца с данными для оси OX'
                                      : formHist == 'График корреляции'
                                          ? 'Укажите название столбца с данными для оси OX'
                                          : '',
                              textAlign: TextAlign.center, // Выравнивание текста
                              style: TextStyle(
                                fontSize: 14, // Размер шрифта
                                color: Colors.black, // Цвет текста
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 130, // Положение сверху
                      left: 40, // Положение слева
                      child: Visibility(
                        visible: (wayEnter == 'Файл формата' && formHist == 'График корреляции' && isLastWidget) || (!isWidgetsVisible && formHist != 'Гистограмма' && !isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Круговая диаграмма' && !isWidgetsVisible) ? true : false,
                        child: SizedBox(
                          width: 218, // Ширина
                          height: 37, // Высота
                          child: Center(
                            child: Text(
                              formHist == 'График корреляции'
                                  ? 'Укажите название столбца с данными для оси OY'
                                  : 'Укажите название столбца с категориями',
                              textAlign: TextAlign.center, // Выравнивание текста
                              style: TextStyle(
                                fontSize: 14, // Размер шрифта
                                color: Colors.black, // Цвет текста
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if ((handHist && !isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Гистограмма' && isLastWidget)) ... [
                    Positioned(
                          bottom: handHist ? 65 : 125,
                          right: 40,
                          child: Row(
                            children: [
                              Text(
                                'Укажите количество столбцов:',
                                style: TextStyle(fontSize: 12, color: Colors.black),
                              ),
                              SizedBox(width: 10), // Отступ между текстом и полем
                              SizedBox(
                                width: 50,
                                height: 30,
                                child: TextField(
                                  style: TextStyle(color: Colors.black),
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black), // Черная рамка при фокусировке
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4), // Отступы по вертикали
                                    ),
                                  onChanged: (value) {
                                    colCount = 0;
                                    if (int.tryParse(value) != null) {
                                      colCount = int.parse(value);
                                    }
                                    else {
                                      colCount = 0;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    if (handHist && !isLastWidget) ... [
                        Positioned(
                          bottom: 15,
                          right: 25,
                          child: showOkButton(handEnter),
                        ),
                    ],
                  ],
                    if (handCorel && !isLastWidget) ... [
                      Positioned(
                          bottom: 55,
                          right: 40,
                          child: Row(
                            children: [
                              Text(
                                'Укажите количество точек:',
                                style: TextStyle(fontSize: 12, color: Colors.black),
                              ),
                              SizedBox(width: 10), // Отступ между текстом и полем
                              SizedBox(
                                width: 50,
                                height: 30,
                                child: TextField(
                                  style: TextStyle(color: Colors.black),
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black), // Черная рамка при фокусировке
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 4), // Отступы по вертикали
                                    ),
                                  onChanged: (value) { 
                                    colCount = 0;
                                    if (int.tryParse(value) != null) {
                                    colCount = int.parse(value);
                                  }
                                  else {
                                    colCount = 0;
                                  }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  //ок
                    if (!isWidgetsVisible && isLastWidget && (handCircle && handHist && handCorel)) ... [
                      showOkButton(handEnter)
                    ],
                    //далее
                    Positioned(
                      bottom: 15,
                      right: 25,
                      child: Visibility(
                        visible: !isWidgetsVisible && !isLastWidget ? true : false,
                      child: SizedBox(
                        width: 120,
                        height: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8FFF9A),
                          ),
                          onPressed: () {
                            if (colCount != 0) {
                              if (colCount > 10) {
                                showErrorCount();
                              }
                              else {
                                setState(() {
                                isWidgetsVisible = false;
                                
                                if (wayEnter == 'Ручной ввод' && formHist == 'Круговая диаграмма') {
                                  dialogWidth = 300;
                                  dialogHeight = 480;
                                  handCircle = true;
                                  isLastWidget = true;
                                  }
                                if (wayEnter == 'Ручной ввод' && formHist == 'Гистограмма') {
                                dialogWidth = 300;
                                dialogHeight = 320;
                                handHist = true;
                                isLastWidget = true;
                                }
                                if (wayEnter == 'Ручной ввод' && formHist == 'График корреляции') {
                                dialogWidth = 300;
                                dialogHeight = 310;
                                handCorel = true;
                                isLastWidget = true;
                                }
                                });
                              }
                            }
                            else {
                              showErrorWindow();
                            }
                            
                          },
                          child: Text(
                            'Далее',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    ),
                    if (!isWidgetsVisible) ... [
                      if (wayEnter == 'Файл формата') ...[
                        Positioned(
                          bottom: 55,
                          right: 60,
                          child: SizedBox(
                            width: 183,
                            height: 42,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 197, 197, 197),
                              ),
                              onPressed: () {
                                Future.delayed(Duration.zero, (){
                                  if(mounted)
                                  {
                                    a.openImageFile(formHist);
                                  }
                                });
                                isLastWidget = true;
                              },
                              child: Text(
                                'Выбрать файл',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          right: 25,
                          child: showOkButton(handEnter),
                        ),
                      ] else if (formHist == 'Круговая диаграмма') ...[
                        Positioned(
                          bottom: 55,
                          right: 40,
                          child: Visibility(
                        visible: isLastWidget ? false : true,
                          child: Row(
                            children: [
                              Text(
                                'Укажите количество секторов:',
                                style: TextStyle(fontSize: 12, color: Colors.black),
                              ),
                              SizedBox(width: 10), // Отступ между текстом и полем
                              SizedBox(
                                width: 50,
                                height: 30,
                                child: TextField(
                                  style: TextStyle(color: Colors.black),
                                  keyboardType: TextInputType.number,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black), // Черная рамка при фокусировке
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 4), // Отступы по вертикали
                                    ),
                                  onChanged: (value) {
                                    colCount = 0;
                                    if (int.tryParse(value) != null) {
                                    colCount = int.parse(value);
                                  }
                                  else {
                                    colCount = 0;
                                  }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  // Метод для построения кастомного элемента выпадающего меню
  Widget _buildMenuItem(String value, Function setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          formHist = value;
           // присваиваем выбранное значение
          _isDataSourceExpanded = false; // скрываем меню после выбора
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8), // отступы для линии
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xff65656587), width: 1), // линия между элементами
          ),
        ),
        child: Center(child: Text(value, style: TextStyle(color: Colors.black))),
      ),
    );
  }

  // Метод для построения элементов второго меню для выбора источника данных
  Widget _buildFileSourceItem(String value, Function setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          wayEnter = value; // присваиваем выбранный источник данных
          _isFileSourceExpanded = false; // скрываем меню после выбора
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xff65656587), width: 1),
          ),
        ),
        child: Center(child: Text(value, style: TextStyle(color: Colors.black))),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(this.text, {super.key, required this.style, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
