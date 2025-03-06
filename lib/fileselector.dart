import 'package:excel/excel.dart' as ex;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
class Fileselector {
  List<int> data = [];
Future <List<int>> readExcelFile(XFile file) async {
  try {
    // Чтение байтов из файла
    final bytes = await file.readAsBytes();

    // Декодирование Excel файла
    var excel = ex.Excel.decodeBytes(bytes);
    List<int> result = [];
    // Перебор всех листов в файле
    for (var table in excel.tables.keys) {

      // Перебор всех строк в листе
      for (var row in excel.tables[table]!.rows) {
        // Преобразование строки в список значений
        var rowData = row.map((cell) => cell?.value.toString()).toString();
        rowData = rowData.replaceAll('(', '').replaceAll(')', '');
        var rowDataDouble = int.tryParse(rowData) ?? -1;
        result.add(rowDataDouble);
      }
    }
    return result;
  } catch (e) {
    print("Ошибка при чтении файла: $e");
    List<int> a = [];
    return a;
  }
}
  Future<void> openImageFile(BuildContext context) async {
    const XTypeGroup typeGroup = XTypeGroup(
      extensions: <String>['xlsx'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file != null)
    {
    // Если файл выбран, читаем его
     data = await readExcelFile(file);
    }
  }
}
