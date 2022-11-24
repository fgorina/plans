import 'dart:io';

import 'package:http/http.dart' as http;
import '/model/RowProtocol.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:convert';


class SQLDatabase {

  String host = '192.168.1.19';
  int port = 8080;
  String scheme = 'http' ;
  String basePath = 'crud/';

  Map<String, Row> _tables = {};

  http.Client? _client;

  http.Client get client {
    if(_client == null){
      _client = http.Client();
    }
    return _client!;
  }

  SQLDatabase();

  void registerTable(Row row){
    _tables[row.tableName] = row;
    print(row.tableName);
  }

  Future<List<Row>> fetch(String tableName ) async{
    var table = _tables[tableName];
    if(table == null){
      return [];
    }

    String path = basePath + tableName;
    var url = Uri(scheme: scheme,host: host, port: port, path : path);
    var response = await client.get(url);
    var body = response.body;
    List result = json.decode(body);
    return result.map((e) => table.newRowFromMap(e)).toList();
  }

  Future<Row?> find(String tableName, int id ) async{
    var table = _tables[tableName];
    if(table == null){
      return null;
    }

    String path = basePath + tableName + "/" + "$id";
    var url = Uri(scheme: scheme,host: host, port: port, path : path);
    var response = await client.get(url);
    var body = response.body;
    List result = json.decode(body);
    return result.isEmpty ? null : table.newRowFromMap(result[0]);
  }

  Future<List<Row>> search (String tableName, Map<String, dynamic> searchItems) async{

    var table = _tables[tableName];
    if(table == null){
      return [];
    }

    String path = basePath + tableName + "/search";

    var url = Uri(scheme: scheme,host: host, port: port, path : path, queryParameters: searchItems);
    var response = await client.get(url);
    var body = response.body;
    List result = json.decode(body);
    return result.map((e) => table.newRowFromMap(e)).toList();

  }

  Future<Row?> update(Row record, int id) async{
    var tableName = record.tableName;

    String path = basePath + tableName + "/" + "$id";;
    var url = Uri(scheme: scheme,host: host, port: port, path : path);
    var s = record.toJSON();
    var response = await client.put(url,headers: {'content-type' : 'application/json'} , body: s);
    var body = response.body;
    List result = json.decode(body);
    return result.isEmpty ? null : record.newRowFromMap(result[0]);

  }

  Future<Row?> create(Row record) async{
    var tableName = record.tableName;

    String path = basePath + tableName ;
    var url = Uri(scheme: scheme,host: host, port: port, path : path);
    var s = record.toJSON();
    var response = await client.post(url,headers: {'content-type' : 'application/json'} , body: s);
    var body = response.body;
    List result = json.decode(body);
    return result.isEmpty ? null : record.newRowFromMap(result[0]);

  }

  Future<Row?> delete(Row record, int id) async{
    var tableName = record.tableName;


    String path = basePath + tableName + "/" + "$id";

    var url = Uri(scheme: scheme,host: host, port: port, path : path);
    var s = record.toJSON();
    var response = await client.delete(url);
    var body = response.body;
    List result = json.decode(body);
    return result.isEmpty ? null : record.newRowFromMap(result[0]);

  }

  void dispose(){
    if (_client != null) {
      _client!.close();
    }
  }


}