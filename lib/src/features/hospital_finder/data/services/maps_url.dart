/// Biên dịch URL Google Maps chỉ đường từ tọa độ.
/// Template URL lấy từ env (--dart-define-from-file=env.json) kèm
/// {lat}/{lng} làm placeholder; mặc định là Google Maps directions.
const String _template = String.fromEnvironment(
  'GOOGLE_MAPS_DIRECTIONS_URL',
  defaultValue:
      'https://www.google.com/maps/dir/?api=1&destination={lat},{lng}&travelmode=driving',
);

String googleMapsDirectionsUrl(double latitude, double longitude) => _template
    .replaceAll('{lat}', '$latitude')
    .replaceAll('{lng}', '$longitude');