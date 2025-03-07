import 'package:excel/excel.dart' as ex;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
class Fileselector {
  List<dynamic> data = [];
Future <List<dynamic>> readExcelFile(XFile file, String? formHist) async {
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
  Future<void> openImageFile(BuildContext context, String? formHist) async {
    const XTypeGroup typeGroup = XTypeGroup(
      extensions: <String>['xlsx'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file != null)
    {
    // Если файл выбран, читаем его
     data = await readExcelFile(file, formHist);
    }
  }
}
