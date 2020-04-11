import 'dart:convert';

import 'package:http/http.dart' as http;

class LocationHelper {
  static String generateLocationPreviewImage({
    double lat,
    double lng,
    String googleApiKey,
  }) {
    return "https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$lat,$lng&key=$googleApiKey";
  }

  static String generateStaticCustomMap({
    double lat,
    double lng,
    int zoom,
    int width,
    int height,
    String googleApiKey,
  }) {
    String customMap = "https://maps.googleapis.com/maps/api/staticmap?key=$googleApiKey&center=$lat,$lng&zoom=$zoom&size=$width" +
        "x$height&format=png&maptype=roadmap&&style=color:0x11FFA4%7Cvisibility:simplified&style=element:geometry%7Ccolor:0x212121&style=element:geometry.fill%7Ccolor:0x11FFA4%7Cvisibility:simplified&style=element:labels%7Cvisibility:off&style=element:labels.icon%7Cvisibility:off&style=element:labels.text.fill%7Ccolor:0x757575&style=element:labels.text.stroke%7Ccolor:0x212121&style=feature:administrative%7Celement:geometry%7Ccolor:0x757575%7Cvisibility:off&style=feature:administrative.country%7Ccolor:0x0d0b00%7Cvisibility:on%7Cweight:1&style=feature:administrative.country%7Celement:geometry.stroke%7Cvisibility:simplified&style=feature:administrative.country%7Celement:labels.text.fill%7Ccolor:0x9e9e9e%7Cvisibility:simplified&style=feature:administrative.country%7Celement:labels.text.stroke%7Ccolor:0x000000%7Cvisibility:on&style=feature:administrative.land_parcel%7Cvisibility:off&style=feature:administrative.neighborhood%7Cvisibility:off&style=feature:poi%7Cvisibility:off&style=feature:poi%7Celement:labels.text.fill%7Ccolor:0x757575&style=feature:poi.medical%7Ccolor:0x27f136%7Cvisibility:on&style=feature:poi.medical%7Celement:geometry.fill%7Ccolor:0x27f136%7Cvisibility:on&style=feature:poi.medical%7Celement:labels.text%7Ccolor:0x27f136%7Cvisibility:on&style=feature:poi.medical%7Celement:labels.text.fill%7Ccolor:0x27f136%7Cvisibility:simplified&style=feature:poi.medical%7Celement:labels.text.stroke%7Ccolor:0x000000%7Cvisibility:on&style=feature:poi.park%7Celement:geometry%7Cvisibility:off&style=feature:poi.park%7Celement:labels.text.fill%7Cvisibility:off&style=feature:poi.park%7Celement:labels.text.stroke%7Cvisibility:off&style=feature:road%7Cvisibility:off&style=feature:road%7Celement:geometry.fill%7Cvisibility:off&style=feature:road%7Celement:labels.icon%7Cvisibility:off&style=feature:road%7Celement:labels.text.fill%7Cvisibility:off&style=feature:road.arterial%7Celement:geometry%7Ccolor:0x373737&style=feature:road.highway%7Celement:geometry%7Ccolor:0x3c3c3c&style=feature:road.highway.controlled_access%7Celement:geometry%7Ccolor:0x4e4e4e&style=feature:road.local%7Celement:labels.text.fill%7Ccolor:0x616161&style=feature:transit%7Cvisibility:off&style=feature:transit%7Celement:labels.text.fill%7Ccolor:0x757575&style=feature:water%7Ccolor:0xffffff%7Cvisibility:on&style=feature:water%7Celement:geometry%7Ccolor:0x000000&style=feature:water%7Celement:geometry.fill%7Ccolor:0x000000%7Cvisibility:on&style=feature:water%7Celement:labels.text.fill%7Ccolor:0x3d3d3d&";
    return customMap;
  }

  static Future<String> getPlaceAddress(
    double lat,
    double lng,
    String googleApiKey,
  ) async {
    final url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey";
    final response = await http.get(
      url,
    );
    return json.decode(response.body)['results'][0]['formatted_address'];
  }

  static Future<String> getCountry(
    double lat,
    double lng,
    String googleApiKey,
  ) async {
    final url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey";
    final response = await http.get(
      url,
    );
    var fullAddress = json.decode(response.body)['results'][0]['address_components'] as List;
    return (fullAddress.last['long_name'] as String).toLowerCase();
  }

  static Future<String> getCity(
    double lat,
    double lng,
    String googleApiKey,
  ) async {
    final url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey";
    final response = await http.get(
      url,
    );
    var fullAddress = json.decode(response.body)['results'][0]['address_components'] as List;
    int index = fullAddress.length - 2;
    return (fullAddress[index]['long_name'] as String).toLowerCase();
  }
}
