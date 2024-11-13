import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class SyncRepository {

  Future<Response> sync(String storeId, { bool syncStaff = false }) async {

    Directory appDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = appDir.listSync();

    final box = Hive.box("storage");

    showModalSyncLoader();
    
    String url = "/sync";
    Response response = await postFetch(url, data: { "store_id": storeId });

    if (response.statusCode != 200) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("${response.data["message"]! ?? response.statusMessage}"),
          backgroundColor: Colors.red,
        ),
      );
    } else {

      final _staffs = response.data["data"]["staffs"];
      await box.put("staffs", _staffs);

      if (!syncStaff) {

        final _store = response.data["data"]["store"];
        final _products = response.data["data"]["products"];
        final _variants = response.data["data"]["variants"];
        final _packets = response.data["data"]["packets"];
        final _discounts = response.data["data"]["discounts"];
        final _sales = response.data["data"]["sales"];
        final _ingredients = response.data["data"]["ingredients"];
        final _paymentTypes = response.data["data"]["paymenttypes"];
        final _overviews = response.data["data"]["overviews"];

        debugPrint(response.data["data"]!["overviews"].toString());

        await box.put("store", _store);
        await box.put("products", _products);
        await box.put("variants", _variants);
        await box.put("packets", _packets);
        await box.put("discounts", _discounts);
        await box.put("prevSales", _sales);
        await box.put("ingredients", _ingredients);
        await box.put("paymenttypes", _paymentTypes);
        await box.put("overviews", _overviews);

        final storedImages = files.where((e) => e.path.contains(".png") || e.path.contains(".jpg") || e.path.contains(".jpeg")).map((e) => e.path.split("${appDir.path}/").last).toList();
        final downloadableImages = [];
        final images = [];

        for (var item in _products) {
          if (item["img"] != null) {
            images.add(item["img"]);
          }
          if (item["variants"] != null) {
            for (var variant in item["variants"]) {
              if (variant["img"] != null) {
                images.add(variant["img"]);
              }
            }
          }
        }

        for (var item in _ingredients) {
          if (item["img"] != null) {
            images.add(item["img"]);
          }
        }

        for (var item in images) {
          bool exist = false;
          String _item = item.split("/images/").last;
          for (var stored in storedImages) {
            if (_item == stored) {
              exist = true;
              break;
            }
          }
          if (!exist) {
            downloadableImages.add(item);
          }
        }

        for (var item in downloadableImages) {
          downloadImage(item, item.split("/images/").last);
        }

      }

    }

    rootNavigatorKey.currentState?.pop();
    
    return response;
  }

  Future<Response> syncSales(String storeId, {List<dynamic> sales = const []}) async {

    showModalSyncLoader();

    String url = "/sync/sales";

    Response response = await postFetch(url, data: { "store_id": storeId, "items": sales });
    
    rootNavigatorKey.currentState?.pop();

    return response;
  }

  Future<Response> syncStocks(String storeId, {List<dynamic> incomingStocks = const [], List<dynamic> outgoingStocks = const []}) async {

    String url = "/sync/stock";

    Response response = await postFetch(url, data: { "store_id": storeId, "incomings": incomingStocks, "outgoings": outgoingStocks });

    return response;
  }

  Future<Response> uploadImage(Object? data) async {

    String url = "/upload-photo";
    Response response = await postFetch(url, data: data, options: Options(headers: {"Content-Type": "multipart/form-data"}));

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

  Future<bool> syncAll(String storeId) async {

    showModalSyncLoader();

    final box = Hive.box("storage");
    final sales = await box.get("sales");
    final incomingStocks = await box.get("incomingStocks");
    final outgoingStocks = await box.get("outgoingStocks");

    if (sales != null && sales?.isNotEmpty) {

      for (var item in sales) {
        if (item["invoice"]?["payment"]?["img"]?.isNotEmpty ?? false) {

          FormData formData = FormData.fromMap({
            "file": await MultipartFile.fromFile(
              item["invoice"]!["payment"]!["img"], 
              filename: item["invoice"]!["payment"]!["img"]?.split("/").last
            ),
          });
          
          Response response = await uploadImage(formData);
          if (response.statusCode != 200) {
            rootNavigatorKey.currentState?.pop();
            return false;
          }
          
          item["invoice"]!["payment"]!["img"] = response.data["data"]!;
        }

      }

      Response syncSale = await syncSales(storeId, sales: sales);

      if (syncSale.statusCode != 200) {
        
        rootNavigatorKey.currentState?.pop();

        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("${syncSale.data["message"]! ?? syncSale.statusMessage}"),
            backgroundColor: Colors.red,
          ),
        );
        
        return false;
      }

      await box.delete("sales");
    }

    if ((incomingStocks != null && incomingStocks?.isNotEmpty) ||( outgoingStocks != null && outgoingStocks?.isNotEmpty)) {

      Response syncStock = await syncStocks(storeId, incomingStocks: incomingStocks ?? [], outgoingStocks: outgoingStocks ?? []);

      if (syncStock.statusCode != 200) {

        rootNavigatorKey.currentState?.pop();

        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("${syncStock.data["message"]! ?? syncStock.statusMessage}"),
            backgroundColor: Colors.red,
          ),
        );  

        return false;
      }

      await box.delete("incomingStocks");
      await box.delete("outgoingStocks");
    }

    await Future.delayed(const Duration(milliseconds: 3000));

    Response syncing = await sync(storeId);

    if (syncing.statusCode != 200) {

      rootNavigatorKey.currentState?.pop();

      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("${syncing.data["message"]! ?? syncing.statusMessage}"),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    }

    rootNavigatorKey.currentState?.pop();

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text("${syncing.data["message"]! ?? syncing.statusMessage}"),
        backgroundColor: Colors.green,
      ),
    );

    return true;
  }

}