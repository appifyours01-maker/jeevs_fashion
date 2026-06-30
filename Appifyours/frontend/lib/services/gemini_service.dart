import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;
  List<Map<String, dynamic>> _products = [];
  Map<String, dynamic> _storeInfo = {};
  Map<String, dynamic> _businessDetails = {};

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      print('Warning: GEMINI_API_KEY not found in .env file');
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  void updateProducts(List<Map<String, dynamic>> products) {
    _products = products;
  }

  void updateStoreInfo(Map<String, dynamic> storeInfo) {
    _storeInfo = storeInfo;
  }

  void updateBusinessDetails(Map<String, dynamic> businessDetails) {
    _businessDetails = businessDetails;
  }

  Future<String> sendMessage(String message) async {
    try {
      final context = _buildContext();
      final prompt = '''
You are a helpful customer service assistant for ${_storeInfo['storeName'] ?? 'our store'}.

Store Information:
- Store Name: ${_storeInfo['storeName'] ?? 'N/A'}
- Address: ${_storeInfo['address'] ?? 'N/A'}
- Email: ${_storeInfo['email'] ?? 'N/A'}
- Phone: ${_storeInfo['phone'] ?? 'N/A'}
- Website: ${_storeInfo['website'] ?? 'N/A'}

Available Products (${_products.length}):
${_formatProducts()}

Customer Question: $message

Please provide a helpful, friendly response. If asked about products, reference the available products above. If asked about store details, use the store information provided. Keep responses concise and helpful.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'I apologize, but I could not generate a response.';
    } catch (e) {
      print('Error in GeminiService: $e');
      return 'I apologize, but I encountered an error processing your request. Please try again.';
    }
  }

  String _buildContext() {
    return '''
Store: ${_storeInfo['storeName'] ?? 'Unknown'}
Products: ${_products.length} items
Business Details: ${_businessDetails.length} fields
''';
  }

  String _formatProducts() {
    if (_products.isEmpty) return 'No products available';
    
    final buffer = StringBuffer();
    for (var i = 0; i < _products.length && i < 20; i++) {
      final product = _products[i];
      buffer.writeln('- ${product['name'] ?? 'Unnamed'}: \$${product['price'] ?? '0.00'} (Stock: ${product['stock'] ?? 'N/A'})');
    }
    if (_products.length > 20) {
      buffer.writeln('... and ${_products.length - 20} more products');
    }
    return buffer.toString();
  }
}
