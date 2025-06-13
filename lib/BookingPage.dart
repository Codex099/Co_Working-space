import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RoomBookingPage extends StatefulWidget {
  final Map<String, dynamic> room;

  const RoomBookingPage({super.key, required this.room});

  @override
  State<RoomBookingPage> createState() => _RoomBookingPageState();
}

class _RoomBookingPageState extends State<RoomBookingPage> {
  int daysToShow = 7;
  List<Map<String, dynamic>> availability = [];
  String? selectedDate;
  String? selectedStart;
  String? selectedEnd;

  @override
  void initState() {
    super.initState();
    fetchAvailability();
  }

  Future<void> fetchAvailability() async {
    final now = DateTime.now();
    final start = now.toIso8601String().split('T')[0];
    final end = now.add(Duration(days: 6)).toIso8601String().split('T')[0];

    final response = await http.get(
      Uri.parse(
        'https://1c84-129-45-8-202.ngrok-free.app/rooms/${widget.room['id']}/slots?start=$start&end=$end',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      List<Map<String, dynamic>> temp = [];
      data.forEach((date, slotsData) {
        List<Map<String, dynamic>> slots = [];
        for (var slot in slotsData['available_slots']) {
          slots.add({"slot": slot, "status": "available"});
        }
        for (var slot in slotsData['unavailable_slots']) {
          slots.add({"slot": slot, "status": "booked"});
        }
        // Trie les slots par heure
        slots.sort((a, b) => a['slot'].compareTo(b['slot']));
        temp.add({"date": date, "time_slots": slots});
      });
      setState(() => availability = temp);
    }
  }

  void selectSlot(String date, String slot) {
    if (selectedDate != date) {
      selectedDate = date;
      selectedStart = slot;
      selectedEnd = null;
    } else if (selectedStart != null && selectedEnd == null) {
      selectedEnd = slot;
    } else {
      selectedStart = slot;
      selectedEnd = null;
    }
    setState(() {});
  }

  Future<void> confirmReservation(int slotCount, double totalPrice) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Utilisateur non connecté")));
      return;
    }

    final response = await http.post(
      Uri.parse('https://1c84-129-45-8-202.ngrok-free.app/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "user_id": userId,
        "room_id": widget.room['id'],
        "date": selectedDate,
        "start_time": selectedStart,
        "slot_count": slotCount,
        "total_price": totalPrice,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vous avez bien réservé !")));
      fetchAvailability();
    } else {
      final resp = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp['error'] ?? "Erreur lors de la réservation"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Réservation - ${widget.room['name']}'),backgroundColor: Color.fromARGB(255, 46, 104, 69),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            availability.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: availability.length,
                  itemBuilder: (context, index) {
                    final day = availability[index];
                    final date = day['date'];
                    final slots = day['time_slots'];

                    return ExpansionTile(
                      title: Text("Date: $date"),
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 2.5,
                              ),
                          itemCount: slots.length,
                          itemBuilder: (context, i) {
                            final slot = slots[i];
                            final isAvailable = slot['status'] == 'available';
                            final isSelected =
                                date == selectedDate &&
                                (slot['slot'] == selectedStart ||
                                    slot['slot'] == selectedEnd);

                            return GestureDetector(
                              onTap:
                                  isAvailable
                                      ? () => selectSlot(date, slot['slot'])
                                      : null,
                              child: Container(
                                margin: EdgeInsets.all(4),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.blue
                                          : isAvailable
                                          ? Colors.green[200]
                                          : Colors.grey[400],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    slot['slot'],
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (date == selectedDate) SizedBox(height: 12),
                      ],
                    );
                  },
                ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed:
              selectedDate != null &&
                      selectedStart != null &&
                      selectedEnd != null
                  ? () async {
                    // Calcule le nombre de slots et le montant total
                    int startHour = int.parse(selectedStart!.split(':')[0]);
                    int endHour = int.parse(selectedEnd!.split(':')[0]);
                    int slotCount = endHour - startHour;
                    double slotPrice =
                        widget.room['slot_price'] is int
                            ? (widget.room['slot_price'] as int).toDouble()
                            : widget.room['slot_price'] ?? 0.0;
                    double totalPrice = slotCount * slotPrice;

                    // Affiche le dialog de confirmation
                    bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Confirmer la réservation'),
                            content: Text(
                              'Date : $selectedDate\n'
                              'De : $selectedStart à $selectedEnd\n'
                              'Nombre de créneaux : $slotCount\n'
                              'Montant total : $totalPrice DZD\n\n'
                              'Voulez-vous confirmer la réservation ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Confirmer'),
                              ),
                            ],
                          ),
                    );

                    if (confirmed == true) {
                      await confirmReservation(slotCount, totalPrice);
                    }
                  }
                  : null,
          child: Text("Confirmer la réservation"),
        ),
      ),
    );
  }
}
