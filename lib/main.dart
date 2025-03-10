import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_selector_aurora/file_selector_aurora.dart';
import 'package:vizflow/guidence.dart';
import 'package:vizflow/pie.dart';
import 'package:vizflow/histogram.dart';
import 'package:vizflow/lrgraph.dart';
import 'fileselector.dart' as fs;
import 'package:provider/provider.dart';
import 'darktheme.dart';
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  FileSelectorAuroraKeyContainer.navigatorKey = navigatorKey;
  runApp(ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: VizFlowApp()));
}

class VizFlowApp extends StatelessWidget {
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
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String? formHist; // переменная для выбранного элемента
  String? wayEnter; // переменная для выбранного источника данных
  String? rowName;
  String? colName;
  late var a = fs.Fileselector();
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
  List<List<String?>> chartsData = [];
  List<dynamic> filesData = [];
  bool darkTheme = false;
// Позиции виджетов
  bool _isPlusWidgetMoved = false; // Флаг для отслеживания смещения
  List<Widget> greenWidgets = []; // Список зеленых виджетов

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

  void ErrorWindow() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
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

  void _addGreenWidget() {
    setState(() {
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
  void fillPieData()
  {
    for(int i = 0; i < _textControllers.length - 1; i++)
      {
        if(i%2 == 0)
          pieData.add(PieData(_textControllers[i].text, int.parse(_textControllers[i+1].text)));
        else
          continue;
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
    for(int i =0; i < filesData[index].length; i++)
    {
      gistData.add(filesData[index][i]);
    }
  }
  void fillGistData(){
    for(int i = 0; i < _textControllers.length; i++)
    {
      gistData.add(int.parse(_textControllers[i].text));
    }
  }
  void fillLRDataFile(index)
  {
    for(int i = 0; i < filesData[index].length; i++)
    {
      LRData.add(Offset(double.parse(filesData[index][i][0]), double.parse(filesData[index][i][1])));
    }
  }
  void fillLRData()
  {
    for(int i = 0; i < _textControllers.length; i++)
    {
      if(i%2 == 0)
        LRData.add(Offset(double.parse(_textControllers[i].text), double.parse(_textControllers[i+1].text)));
      else
        continue;
    }
  }
  void _saveData(String name, String? position, String? source) {
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
    filesData.add(a.data);
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
                        builder: (context) => HistogramPage(userData: gistData, userColCount: colCount,),
                        )
                      );
                    }
                    else{
                      gistData = [];
                      fillGistData();
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistogramPage(userData: gistData, userColCount: colCount),
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
                      fillPieData();
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
                      fillLRData();
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
          margin: EdgeInsets.all(50),
          width: 170,
          height: 170,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          actions: [
            IconButton(
            onPressed: (){}, 
            icon: Image.asset('assets/images/question.png',width: 32,height: 32)),
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
          backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          Divider(),
          Expanded(
            child: Stack(
              children: [
                Visibility(
                        visible: widgetFinished ? false : true,
                // Анимированный виджет с плюсом
                child: AnimatedAlign(
                  alignment: setAlignment(alignInt),
                  duration: Duration(milliseconds: 300), // Длительность анимации
                  child: GestureDetector(
                    onTap: () {
                      _showParameterDialog(context);
                    },
                    child: Container(
                      margin: EdgeInsets.all(50),
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
                ),
                ),
                // Зеленые виджеты
                ...greenWidgets,
              ],
            ),
          ),
          Divider(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
    color: themeProvider.isDarkMode ? Colors.black : Colors.white, // Цвет BottomAppBar
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
                  backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white, // Цвет фона диалога
                  child: Container(
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
                              Text("${themeProvider.isDarkMode ? "Светлая" : "Тёмная"} тема", style: TextStyle(fontSize: 20), selectionColor: themeProvider.isDarkMode ? Colors.white : Colors.black,),
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
                                  backgroundColor: Color(0xFFF2F2F2), // Цвет фона кнопки
                                  shadowColor: Colors.black.withOpacity(0.2), // Цвет тени
                                  elevation: 5, // Уровень тени
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Ок',
                                  style: TextStyle(color: Colors.black),
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
    TextEditingController textController = TextEditingController();
    TextEditingController firstController = TextEditingController(); // Контроллер для первого TextField
    TextEditingController secondController = TextEditingController(); // Контроллер для второго TextField
    bool HandCorel = false;
    bool HandHist = false;
    bool HandCircle = false;
    bool _isWidgetsVisible = true;
    bool _isLastWidget = false;
    formHist = null;
    wayEnter = null;
    String inputValue = '';
    _isDataSourceExpanded = false; // состояние для управления видимостью выпадающего меню
    _isFileSourceExpanded = false; // состояние для управления видимостью второго меню (Файл формата или Ручной ввод)
    widgetFinished = false;
    dialogWidth = 300;
    dialogHeight = 480;
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  gradient: LinearGradient(
                    colors: [Color(0xFF75EC8E), Color(0xFF91E5E6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (_isWidgetsVisible) ... [
                    Positioned(
                      bottom: 15,
                      right: 25,
                      child: Container(
                        width: 120,
                        height: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8FFF9A),
                          ),
                          onPressed: () {
                            if (textController.text != "" && formHist != null && wayEnter != null) {
                              _saveData(textController.text, formHist, wayEnter);
                              setState(() {
                                dialogHeight = 335;
                                dialogWidth = 307;
                                _isWidgetsVisible = false;
                                if (formHist == 'Круговая диаграмма') {
                                if (wayEnter == 'Файл формата') {
                                  _isLastWidget = true;
                                }
                                else {
                                  dialogHeight = 122;
                                  dialogWidth = 307;
                                }
                                }
                                if (formHist == 'Гистограмма') {
                                  dialogHeight = 240;
                                  dialogWidth = 307;
                                  if(wayEnter == 'Ручной ввод') { 
                                  HandHist = true;
                                } else {
                                  dialogHeight = 305;
                                  dialogWidth = 307;
                                  _isLastWidget = true;
                                }
                                }
                                if (formHist == 'График корреляции') {
                                  dialogHeight = 335;
                                  dialogWidth = 307;
                                  if (wayEnter == 'Ручной ввод') { 
                                  HandCorel = true;
                                }
                                else {
                                  _isLastWidget = true;
                                }
                                }
                              });
                            }
                            else {
                                ErrorWindow();
                              }
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
                                Expanded(
                                  child: Text(
                                    formHist ?? 'Тип графика',
                                    textAlign: TextAlign.center, // Центрируем текст
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Roboto', // Дефолтный шрифт
                                    ),
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
                              Expanded(
                                child: Text(
                                  wayEnter ?? 'Источник данных',
                                  textAlign: TextAlign.center, // Центрируем текст
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Roboto', // Дефолтный шрифт
                                  ),
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

                  if (HandHist && _isLastWidget) ...[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                              Container(
                                width: 250,
                                height: 40,
                                alignment: Alignment.center, // Выравниваем текст
                                child: Text(
                                  'Введите данные',
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
                            SizedBox(
                      height: (colCount) * 50 + 100, // Учитываем количество элементов
                      child: Stack(
                        children: List.generate(colCount, (index) {
                          if (index >= _textControllers.length) {
                            _textControllers.add(TextEditingController());
                          }

                          // Определяем текст для названия сектора или значения
                          String labelText = 'Значение ${index + 1}';

                          return Positioned(
                            top: 25 + (index * 50), // Смещение вниз для каждого элемента
                            right: 25, // Смещение вправо
                            child: Container(
                              width: 250, // Установите ширину контейнера, если это необходимо
                              child: Row(
                                children: [
                                  // Контейнер с текстом "Сектор" или "Значение"
                                  Container(
                                    width: 100, // Ширина для текста
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(left: 8.0), // Отступ слева для текста
                                    child: Text(
                                      labelText,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  // Поле ввода
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFDDFFE4),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Color(0x65656587), width: 1),
                                      ),
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        controller: _textControllers[index], //контроллеры(Артему)//////////////////////////////////////////////////
                                        decoration: InputDecoration(
                                          labelText: '',
                                          contentPadding: EdgeInsets.symmetric(vertical: 13),
                                          border: InputBorder.none,
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
                  ],

                  if (HandCorel && _isLastWidget) ...[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                              Container(
                                width: 250,
                                height: 40,
                                alignment: Alignment.center, // Выравниваем текст
                                child: Text(
                                  'Введите координаты точек',
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
SizedBox(
  height: (colCount * 2) * 50 + 100, // Учитываем количество элементов
  child: Padding(
    padding: const EdgeInsets.only(left: 40.0), // Отступ слева на 20 пикселей
    child: Column(
      children: List.generate(colCount, (index) {
        // Инициализация контроллеров, если это необходимо
        if (index * 2 >= _textControllers.length) {
          _textControllers.add(TextEditingController());
          _textControllers.add(TextEditingController());
        }

        // Определяем текст для названия
        String labelX = 'X${index + 1}:';
        String labelY = 'Y${index + 1}:';

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0), // Отступ между строками
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start, // Выравнивание по левому краю
            children: [
              // Контейнер с текстом "X" и полем ввода
              Container(
                width: 30, // Ширина для текста
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 4.0), // Уменьшаем отступ слева для текста
                child: Text(
                  labelX,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              // Поле ввода для X
              Container(
                width: 70, // Ширина поля ввода
                height: 40, // Высота поля ввода
                decoration: BoxDecoration(
                  color: Color(0xFFDDFFE4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0x65656587), width: 1),
                ),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: _textControllers[index * 2], // Контроллер для X
                  decoration: InputDecoration(
                    labelText: '',
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(width: 10), // Горизонтальный отступ между X и Y
              // Контейнер с текстом "Y" и полем ввода
              Container(
                width: 30, // Ширина для текста
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 4.0), // Уменьшаем отступ слева для текста
                child: Text(
                  labelY,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              // Поле ввода для Y
              Container(
                width: 70, // Ширина поля ввода
                height: 40, // Высота поля ввода
                decoration: BoxDecoration(
                  color: Color(0xFFDDFFE4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0x65656587), width: 1),
                ),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: _textControllers[index * 2 + 1], // Контроллер для Y
                  decoration: InputDecoration(
                    labelText: '',
                    contentPadding: EdgeInsets.symmetric(vertical: 13), // Убираем вертикальные отступы
                    border: InputBorder.none,
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
                                ],
                              ),
                            ),
                    ),
                  ],

                  if (HandCircle) ...[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                              Container(
                                width: 250,
                                height: 40,
                                alignment: Alignment.center, // Выравниваем текст
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
                            SizedBox(
                      height: (colCount * 2) * 50 + 100, // Учитываем количество элементов
                      child: Stack(
                        children: List.generate(colCount * 2, (index) {
                          if (index >= _textControllers.length) {
                            _textControllers.add(TextEditingController());
                          }

                          // Определяем текст для названия сектора или значения
                          String labelText = (index % 2 == 0) ? 'Сектор ${index ~/ 2 + 1}' : 'Значение ${index ~/ 2 + 1}';

                          return Positioned(
                            top: 25 + (index * 50), // Смещение вниз для каждого элемента
                            right: 25, // Смещение вправо
                            child: Container(
                              width: 250, // Установите ширину контейнера, если это необходимо
                              child: Row(
                                children: [
                                  // Контейнер с текстом "Сектор" или "Значение"
                                  Container(
                                    width: 100, // Ширина для текста
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(left: 8.0), // Отступ слева для текста
                                    child: Text(
                                      labelText,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  // Поле ввода
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFDDFFE4),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Color(0x65656587), width: 1),
                                      ),
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        controller: _textControllers[index], //контроллеры(Артему)//////////////////////////////////////////////////
                                        decoration: InputDecoration(
                                          labelText: '',
                                          contentPadding: EdgeInsets.symmetric(vertical: 13),
                                          border: InputBorder.none,
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
                  ],

                  
                  ///////////////////////////////////////////////////////////////////////////
                  if (wayEnter == 'Файл формата' || formHist != 'Круговая диаграмма') ...[
                    Positioned(
                      top: 85,
                      left: 25,
                      child: Visibility(
                        visible: (wayEnter == 'Файл формата' && formHist == 'График корреляции' && _isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Гистограмма' && _isLastWidget) || (!_isWidgetsVisible && !_isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Круговая диаграмма' && !_isWidgetsVisible) ? true : false,
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
                            textAlign: TextAlign.center,
                            controller: firstController,
                            decoration: InputDecoration(
                              labelText: '',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 13), // Отступы по вертикали
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 185,
                      left: 25,
                      child: Visibility(
                        visible: (wayEnter == 'Файл формата' && formHist == 'График корреляции' && _isLastWidget) || (!_isWidgetsVisible && formHist != 'Гистограмма' && !_isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Круговая диаграмма' && !_isWidgetsVisible)? true : false,
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
                            textAlign: TextAlign.center,
                            controller: secondController,
                            decoration: InputDecoration(
                              labelText: '',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 13), // Отступы по вертикали
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 25, // Положение сверху
                      left: 40, // Положение слева
                      child: Visibility(
                        visible: (wayEnter == 'Файл формата' && formHist == 'График корреляции' && _isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Гистограмма' && _isLastWidget) || (!_isWidgetsVisible && !_isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Круговая диаграмма' && !_isWidgetsVisible) ? true : false,
                        child: Container(
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
                        visible: (wayEnter == 'Файл формата' && formHist == 'График корреляции' && _isLastWidget) || (!_isWidgetsVisible && formHist != 'Гистограмма' && !_isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Круговая диаграмма' && !_isWidgetsVisible) ? true : false,
                        child: Container(
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
                    if ((HandHist && !_isLastWidget) || (wayEnter == 'Файл формата' && formHist == 'Гистограмма' && _isLastWidget)) ... [
                    Positioned(
                          bottom: HandHist ? 65 : 125,
                          right: 40,
                          child: Row(
                            children: [
                              Text(
                                'Укажите количество столбцов:',
                                style: TextStyle(fontSize: 12, color: Colors.black),
                              ),
                              SizedBox(width: 10), // Отступ между текстом и полем
                              Container(
                                width: 50,
                                height: 30,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 13), // Отступы по вертикали
                                  ),
                                  onChanged: (value) { ////////////Артему
                                    inputValue = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                    if (HandCorel && !_isLastWidget) ... [
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
                              Container(
                                width: 50,
                                height: 30,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 13), // Отступы по вертикали
                                  ),
                                  onChanged: (value) { ////////////Артему
                                    inputValue = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  //ок
                    Positioned(
                      bottom: 15,
                      right: 25,
                      child: Visibility(
                        visible: !_isWidgetsVisible && _isLastWidget ? true : false,
                      child: Container(
                        width: 120,
                        height: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8FFF9A),
                          ),
                          onPressed: () {
                            chartsData.add([formHist, wayEnter]);
                            _addGreenWidget(); // Добавление нового зеленого виджета
                            _updateWidgetPosition();
                            HandCircle = false;
                            if (alignInt == 5) {
                            widgetFinished = true;
                            }
                            Navigator.pop(context);
                            alignInt++;
                          },
                          child: Text(
                            'Ок',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    ),
                    //далее
                    Positioned(
                      bottom: 15,
                      right: 25,
                      child: Visibility(
                        visible: !_isWidgetsVisible && !_isLastWidget ? true : false,
                      child: Container(
                        width: 120,
                        height: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8FFF9A),
                          ),
                          onPressed: () {
                            print(firstController.text);
                            print(secondController.text);
                            print(colCount);

                            setState(() {
                            _isWidgetsVisible = false;
                            
                            if (wayEnter == 'Ручной ввод' && formHist == 'Круговая диаграмма') {
                              dialogWidth = 300;
                              dialogHeight = 480;
                              HandCircle = true;
                              _isLastWidget = true;
                              }
                            if (wayEnter == 'Ручной ввод' && formHist == 'Гистограмма') {
                            dialogWidth = 300;
                            dialogHeight = 320;
                            HandHist = true;
                            _isLastWidget = true;
                            }
                            if (wayEnter == 'Ручной ввод' && formHist == 'График корреляции') {
                            dialogWidth = 300;
                            dialogHeight = 310;
                            HandCorel = true;
                            _isLastWidget = true;
                            }
                            if (inputValue.isNotEmpty)
                              colCount = int.parse(inputValue);
                            });
                          },
                          child: Text(
                            'Далее',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    ),
                    if (!_isWidgetsVisible) ... [
                      if (wayEnter == 'Файл формата') ...[
                        Positioned(
                          bottom: 55,
                          right: 60,
                          child: Container(
                            width: 183,
                            height: 42,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 197, 197, 197),
                              ),
                              onPressed: () {
                                a.openImageFile(context, formHist);
                                _isLastWidget = true;
                              },
                              child: Text(
                                'Выбрать файл',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ] else if (formHist == 'Круговая диаграмма') ...[
                        Positioned(
                          bottom: 55,
                          right: 40,
                          child: Visibility(
                        visible: _isLastWidget ? false : true,
                          child: Row(
                            children: [
                              Text(
                                'Укажите количество секторов:',
                                style: TextStyle(fontSize: 12, color: Colors.black),
                              ),
                              SizedBox(width: 10), // Отступ между текстом и полем
                              Container(
                                width: 50,
                                height: 30,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 13), // Отступы по вертикали
                                  ),
                                  onChanged: (value) {
                                    inputValue = value;
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
            bottom: BorderSide(color: Color(0xFF65656587), width: 1), // линия между элементами
          ),
        ),
        child: Center(child: Text(value)),
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
            bottom: BorderSide(color: Color(0xFF65656587), width: 1),
          ),
        ),
        child: Center(child: Text(value)),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  GradientText(this.text, {required this.style, required this.gradient});

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
