import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'data/http_budget_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final baseUrl = dotenv.env['BACKEND_URL']!;
  final api = HttpBudgetApi(baseUrl: baseUrl);
  runApp(FinanceApp(api: api));
}
