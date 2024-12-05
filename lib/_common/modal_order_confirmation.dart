import 'package:app_colono/components/cart_provider.dart';
import 'package:app_colono/models/order_model.dart';
import 'package:app_colono/services/delivery_slot_service.dart';
import 'package:app_colono/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModalOrderConfirmation extends StatefulWidget {
  final OrderModel orderClient;
  final OrderService orderService;

  const ModalOrderConfirmation({
    super.key,
    required this.orderClient,
    required this.orderService,
  });

  @override
  State<ModalOrderConfirmation> createState() => _ModalOrderConfirmationState();
}

class _ModalOrderConfirmationState extends State<ModalOrderConfirmation> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  String? _address;
  String? _selectedDate;
  String? _selectedTime;
  int _selectedPage = 0;

  List<String> availableDates = []; // Armazena as datas para navegação
  Map<String, List<String>> availableTimeSlots = {}; // Horários por data

  @override
  void initState() {
    super.initState();
    DeliverySlotService().initializeDeliveryDays(3);
    _loadAvailableTimeSlots(); // Carrega os horários ao inicializar o modal
  }

  Future<void> _loadAvailableTimeSlots() async {
    DateTime now = DateTime.now();
    availableTimeSlots.clear(); // Limpa slots anteriores
    availableDates.clear();

    int daysChecked = 0; // Contador de dias verificados
    int requiredDays = 3; // Quantidade mínima de dias a exibir

    // Loop até encontrarmos 3 dias com horários disponíveis
    while (availableDates.length < requiredDays) {
      String date = DateTime(now.year, now.month, now.day + daysChecked)
          .toIso8601String()
          .split('T')[0];

      // Carrega os horários disponíveis para o dia atual
      Map<String, List<String>> daySlots =
          await DeliverySlotService().getAndUpdateAvailableSlots(date);

      // Só adiciona o dia se houver horários disponíveis
      if (daySlots[date]?.isNotEmpty ?? false) {
        availableTimeSlots[date] = daySlots[date]!;
        availableDates.add(date);
      }

      daysChecked++; // Incrementa o contador de dias verificados
    }

    // Atualiza as datas disponíveis
    availableDates = availableTimeSlots.keys.toList();
    _selectedDate = availableDates.isNotEmpty ? availableDates.first : null;

    setState(
        () {}); // Atualiza o estado para renderizar as datas e horários carregados
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                "Detalhes do Pedido",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Endereço",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, insira seu endereço";
                  }
                  return null;
                },
                onSaved: (value) => _address = value,
              ),
              const SizedBox(height: 24),
              const Text(
                "Selecione Horário e Data para Entrega",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              // Navegação e exibição de datas e horários
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedPage = index;
                      _selectedDate = availableDates[index];
                      _selectedTime = null;
                    });
                  },
                  itemCount: availableDates.length,
                  itemBuilder: (context, index) {
                    String date = availableDates[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: (availableTimeSlots[date] ?? [])
                              .map((time) => ChoiceChip(
                                    label: Text(time),
                                    labelStyle: TextStyle(
                                      color: _selectedTime == time
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    selectedColor: Colors.deepPurple,
                                    backgroundColor: Colors.grey[200],
                                    selected: _selectedTime == time,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedTime = selected ? time : null;
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.deepPurple,
                    onPressed: () {
                      if (_selectedPage > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    color: Colors.deepPurple,
                    onPressed: () {
                      if (_selectedPage < availableDates.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _confirmOrder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  "Finalizar Pedido",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmOrder() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      _formKey.currentState!.save();

      widget.orderClient.address = _address!;
      widget.orderClient.deliveryDate = _selectedDate!;
      widget.orderClient.deliveryTime = _selectedTime!;

      // Finalizar pedido
      cartProvider.finishOrder();
      widget.orderService.addOrder(widget.orderClient);

      // Incrementar o orderCount no Firebase para a data e horário escolhidos
      incrementOrderCount() async {
        DeliverySlotService()
            .incrementOrderCount(_selectedDate!, _selectedTime!);
      }

      incrementOrderCount();

      Navigator.pop(context);
    } else {
      // Exibe o AlertDialog para a validação, visível sobre o modal
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Atenção"),
          content: const Text("Por favor, selecione uma data e horário para entrega."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    }
  }
}
