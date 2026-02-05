import 'package:flutter/material.dart';

class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api';
  static const int timeoutSeconds = 30;
  static const String chatEndpoint = '/ai/chat';
  static const String chatResetEndpoint = '/ai/chat/reset';
  static const String chatStatusEndpoint = '/ai/chat/status';
}

class AppColors {
  static const Color primaryGreen = Color(0xFF2C5530);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color userMessageBg = Color(0xFF2C5530);
  static const Color assistantMessageBg = Color(0xFFFFFFFF);
  static const Color loadingGreen = Color(0xFF4CAF50);
}

