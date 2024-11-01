import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi_pos/src/index.dart';

class StaffRepository {

  Future<Response> getData(String storeId, {Map<String, dynamic>? queryParams}) async {
    
    String url = "/staff/store/$storeId";
    Response response = await getFetch(url, queryParameters: queryParams);
    return response;
  }

  Future<Response> getDetail(String id) async {
    
    String url = "/staff/$id";
    Response response = await getFetch(url);
    
    return response;
  }

  Future<Response> create(Map<String, dynamic> data) async {

    showModalLoader();
    
    String url = "/staff";
    Response response = await postFetch(url, data: data);

    rootNavigatorKey.currentState?.pop();

    if (response.statusCode != 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    return response;
  }

  Future<Response> uploadImage(String id, Object? data) async {

    String url = "/staff/update-photo/$id";
    Response response = await putFetch(url, data: data, options: Options(headers: {"Content-Type": "multipart/form-data"}));

    if (response.statusCode != 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }

    return response;
  }

  Future<Response> update(String id, Map<String, dynamic> data) async {

    showModalLoader();

    String url = "/staff/$id";
    Response response = await putFetch(url, data: data);

    rootNavigatorKey.currentState?.pop();

    if (response.statusCode != 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }

    return response;
  }

  Future<Response> delete(String id) async {

    showModalLoader();
    
    String url = "/staff/$id";
    Response response = await delFetch(url);

    rootNavigatorKey.currentState?.pop();

    if (response.statusCode != 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(response.data["message"]! ?? response.statusMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    return response;
  }
}