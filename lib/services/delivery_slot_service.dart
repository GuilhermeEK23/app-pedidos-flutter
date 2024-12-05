import 'package:cloud_firestore/cloud_firestore.dart';

class DeliverySlotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inicializa a coleção de dias e horários no Firestore
  Future<void> initializeDeliveryDays(int daysAhead) async {
    DateTime now = DateTime.now();
    for (int i = 0; i < daysAhead; i++) {
      String date = DateTime(now.year, now.month, now.day + i)
          .toIso8601String()
          .split('T')[0];
      DocumentReference dateDocRef =
          _firestore.collection('deliveryDays').doc(date);

      // Verifica se o documento do dia já existe
      final docSnapshot = await dateDocRef.get();
      if (!docSnapshot.exists) {
        // Se o documento não existe, cria e inicializa os horários para esse dia
        await dateDocRef.set(<String, dynamic>{}); // Garante que seja Map<String, dynamic>
        await _initializeSlotsForDate(date);
      }
    }
  }

  // Adiciona horários iniciais para uma data específica
  Future<void> _initializeSlotsForDate(String date) async {
    final slots = ["9hr - 10hr", "13hr - 14hr", "15hr - 16hr"];
    final dateRef =
        _firestore.collection('deliveryDays').doc(date).collection('slots');

    for (var slot in slots) {
      // Garantir que os dados estejam no formato correto antes de definir
      Map<String, dynamic> slotData = {'orderCount': 0};
      await dateRef.doc(slot).set(slotData);
    }
  }

  // Busca e atualiza horários disponíveis
  Future<Map<String, List<String>>> getAndUpdateAvailableSlots(
      String date) async {
    final dateRef = _firestore.collection('deliveryDays').doc(date);
    QuerySnapshot? slotsSnapshot;

    try {
      // Obter snapshot de slots com conversão explícita
      slotsSnapshot = await dateRef.collection('slots').get();
    } catch (e) {
      return {};
    }

    // Verifica se existem slots para a data
    if (slotsSnapshot.docs.isEmpty) {
      // Se não houver slots, inicializa os slots para a data
      await _initializeSlotsForDate(date);

      // Tenta recarregar os dados para obter os slots recém-criados
      try {
        slotsSnapshot = await dateRef.collection('slots').get();
      } catch (e) {
        return {};
      }
    }

    Map<String, List<String>> availableSlots = {date: []};
    List<String> slotsForDate = [];

    for (var doc in slotsSnapshot.docs) {
      try {
        // Inspeciona o tipo de dados retornado
        var data = doc.data();

        // Verifica se o dado é um Map e converte para Map<String, dynamic> se possível
        if (data is Map<String, dynamic>) {
          if (data.containsKey('orderCount') && data['orderCount'] is int) {
            final int orderCount = data['orderCount'];

            // Adiciona o horário ao array apenas se orderCount for menor que 2
            if (orderCount < 2) {
              slotsForDate.add(doc.id);
            }
          }
        }
      } catch (e) {
        return {};
      }
    }

    // Se houver horários disponíveis, adiciona ao mapa e ordena os horários
    if (slotsForDate.isNotEmpty) {
      // Ordena os horários antes de adicionar ao mapa
      slotsForDate.sort((a, b) {
        int hourA = int.parse(a.split('hr')[0]);
        int hourB = int.parse(b.split('hr')[0]);
        return hourA.compareTo(hourB);
      });
      availableSlots[date] = slotsForDate;
    } else {
      // Se não houver horários disponíveis, remove o dia do mapa
      availableSlots.remove(date);
    }

    // Retorna apenas os dias com horários disponíveis
    return availableSlots;
  }
  
  // Atualiza o contador de pedidos em um horário específico
  Future<void> incrementOrderCount(String date, String slot) async {
    final slotRef = _firestore
        .collection('deliveryDays')
        .doc(date)
        .collection('slots')
        .doc(slot);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(slotRef);

      if (!snapshot.exists) {
        // Caso o slot não exista, inicializa o contador para evitar erros
        transaction.set(slotRef, {'orderCount': 1});
      } else {
        final currentCount = snapshot.get('orderCount') as int;
        if (currentCount < 2) {
          transaction.update(slotRef, {'orderCount': currentCount + 1});
        } else {
          throw Exception('Horário indisponível');
        }
      }
    });
  }
}
