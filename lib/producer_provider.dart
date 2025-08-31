import 'package:flutter/foundation.dart';
import 'models/producer_model.dart';

class ProducerProvider with ChangeNotifier {
  Producer? _producer;

  Producer? get producer => _producer;

  void setProducer(Map<String, dynamic> producerData) {
    _producer = Producer.fromJson(producerData);
    notifyListeners();
  }

  void clearProducer() {
    _producer = null;
    notifyListeners();
  }
}
