import 'package:dio/dio.dart';
import 'package:haiyowangi_pos/src/index.dart';

class UnitRepository {

  Future<Response> getData() async {

    String url = "/uom";
    Response response = await getFetch(url);
    return response;
  }
}