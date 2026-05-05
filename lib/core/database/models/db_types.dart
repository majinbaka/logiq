typedef DbDecimal = String;

typedef DbJson = Map<String, dynamic>;

DateTime? parseDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

DateTime parseRequiredDateTime(dynamic value, String fieldName) {
  final parsed = parseDateTime(value);
  if (parsed == null) {
    throw FormatException('Invalid or missing DateTime for field: $fieldName');
  }
  return parsed;
}

String? parseString(dynamic value) {
  if (value == null) {
    return null;
  }
  return value.toString();
}

int? parseInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

bool? parseBool(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
  }
  return null;
}

DbDecimal? parseDecimal(dynamic value) {
  if (value == null) {
    return null;
  }
  return value.toString();
}
