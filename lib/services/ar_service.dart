import 'package:flutter/material.dart';

/// AR Service stub - camera package not configured.
/// TODO: Add camera dependency and implement AR features.
class ArService {
  static final ArService _instance = ArService._();
  factory ArService() => _instance;
  ArService._();

  bool get isAvailable => false;
}
