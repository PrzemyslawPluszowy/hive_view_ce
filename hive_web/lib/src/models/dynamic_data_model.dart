import 'dart:developer';

class DynamicDataModel {
  final Map<String, Map<String, dynamic>> data;

  DynamicDataModel({required this.data});

  factory DynamicDataModel.fromJson(Map<String, dynamic> json) {
    final parsedData = <String, Map<String, dynamic>>{};

    json.forEach((key, value) {
      parsedData[key] = _parseDynamicMap(value);
    });

    return DynamicDataModel(data: parsedData);
  }

  static Map<String, String> _parseDynamicMap(String? dartString) {
    if (dartString == null || dartString.isEmpty) {
      return {};
    }

    try {
      var cleanedString = dartString.trim().substring(1, dartString.length - 1);

      final Map<String, String> resultMap = {};
      String? currentKey;
      final StringBuffer currentValue = StringBuffer();
      int bracketBalance = 0;

      for (int i = 0; i < cleanedString.length; i++) {
        final char = cleanedString[i];

        if (currentKey == null) {
          if (char == ':') {
            final keyString = cleanedString.substring(0, i).trim();
            currentKey = keyString;
            cleanedString = cleanedString.substring(i + 1).trim();
            i = -1;
            continue;
          }
        } else {
          if (char == '{') {
            bracketBalance++;
          } else if (char == '}') {
            bracketBalance--;
          }

          if (char == ',' && bracketBalance == 0) {
            resultMap[currentKey] = currentValue.toString().trim();
            currentKey = null;
            currentValue.clear();
            cleanedString = cleanedString.substring(i + 1).trim();
            i = -1;
            continue;
          } else {
            currentValue.write(char);
          }
        }
      }

      if (currentKey != null) {
        resultMap[currentKey] = currentValue.toString().trim();
      }

      return resultMap;
    } catch (e, s) {
      log('Error parsing dynamic data: $e $s');
      return {};
    }
  }
}
