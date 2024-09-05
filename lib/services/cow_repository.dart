import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CowRepository {
  static const String baseUrl = 'http://140.116.86.242:25581';

  Future<List<int>> fetchCowIds(int startTime, int endTime) async {
    final response = await http.get(Uri.parse(
      '$baseUrl/get_database_object_id_list?timestamp_start=$startTime&timestamp_end=$endTime',
    ));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
        return List<int>.from(jsonResponse['data']);
      } else {
        throw Exception('Invalid response format: $jsonResponse');
      }
    } else {
      if (kDebugMode) {
        print(
            'Failed to load cow IDs: ${response.statusCode} - ${response.body}');
      }
      throw Exception('Failed to load cow IDs');
    }
  }

  Future<List<Cow>> fetchCowData(
      int startTime, int endTime, int objectId) async {
    final response = await http.get(Uri.parse(
      '$baseUrl/get_database_object_id?timestamp_start=$startTime&timestamp_end=$endTime&object_id=$objectId',
    ));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
        List<dynamic> cowDataList = jsonResponse['data'];

        List<Cow> cows = cowDataList.map<Cow>((data) {
          if (data.length < 6) {
            // Adjusted to ensure at least 6 elements
            throw Exception('Invalid cow data entry: $data');
          }
          return Cow(
            x: double.tryParse(data[0].toString()) ?? 0.0, // X coordinate
            y: double.tryParse(data[1].toString()) ?? 0.0, // Y coordinate
            w: double.tryParse(data[2].toString()) ?? 0.0, // Width
            h: double.tryParse(data[3].toString()) ?? 0.0, // Height
            action: data[4] as String, // Action
            timestamp: data[5].toString(), // Timestamp as String
          );
        }).toList();

        return cows;
      } else {
        throw Exception('Invalid response format: $jsonResponse');
      }
    } else {
      if (kDebugMode) {
        print(
            'Failed to load cow data: ${response.statusCode} - ${response.body}');
      }
      throw Exception('Failed to load cow data');
    }
  }
}

class Cow {
  final double x;
  final double y;
  final double w;
  final double h;
  final String action;
  final String timestamp;

  Cow(
      {required this.x,
      required this.y,
      required this.w,
      required this.h,
      required this.action,
      required this.timestamp});

  factory Cow.fromJson(Map<String, dynamic> json) {
    return Cow(
      x: json['x'],
      y: json['y'],
      w: json['w'],
      h: json['h'],
      action: json['action'],
      timestamp: json['timestamp'],
    );
  }

}
