import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api_service.dart';
import '../models/event_model.dart';
import '../producer_provider.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final producerId = Provider.of<ProducerProvider>(context, listen: false).producer!.id;
    setState(() {
      _eventsFuture = apiService
          .getEvents(producerId)
          .then((events) => events.map((e) => Event.fromJson(e)).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Events'),
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found. Add one!'));
          }

          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event.title),
                subtitle: Text('${event.eventDate?.toLocal().toString().split(' ')[0] ?? 'No Date'} - \$${event.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEventDialog(event: event),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteEvent(event.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteEvent(int eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to permanently delete this event?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        await apiService.deleteEvent(eventId);
        _loadEvents(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete event: $e')));
      }
    }
  }

  Future<void> _showEventDialog({Event? event}) async {
    final _formKey = GlobalKey<FormState>();
    String title = event?.title ?? '';
    String description = event?.description ?? '';
    String price = event?.price.toString() ?? '0.0';
    // TODO: Add date and time pickers

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event == null ? 'Create Event' : 'Edit Event'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) => value!.isEmpty ? 'Title cannot be empty' : null,
                    onSaved: (value) => title = value!,
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) => description = value!,
                  ),
                  TextFormField(
                    initialValue: price,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Price cannot be empty' : null,
                    onSaved: (value) => price = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  final apiService = Provider.of<ApiService>(context, listen: false);
                  final producerId = Provider.of<ProducerProvider>(context, listen: false).producer!.id;

                  final data = {
                    'producer_id': producerId,
                    'title': title,
                    'description': description,
                    'price': double.tryParse(price) ?? 0.0,
                    // TODO: Pass date and time
                  };

                  try {
                    if (event == null) {
                      await apiService.createEvent(data);
                    } else {
                      await apiService.updateEvent(event.id, data);
                    }
                    Navigator.of(context).pop();
                    _loadEvents(); // Refresh list
                  } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save event: $e')));
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
