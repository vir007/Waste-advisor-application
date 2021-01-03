import 'dart:io';
import 'package:dio/dio.dart';

Future<String> uploadImage(File file) async {
  String fileName = file.path.split('/').last;

  FormData data = FormData.fromMap({
    "file": await MultipartFile.fromFile(
      file.path,
      filename: fileName,
    ),
  });

  Dio dio = new Dio();

  Response response = await dio.post("http://34.123.100.48/upload", data: data);
  return response.data['Prediction'].toString();
}
