import 'package:contacts_by_call_history/contact_view_builder.dart';
import 'package:flutter/material.dart';
import 'package:contacts_by_call_history/fetch_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SortOption _selectedSort = SortOption.leastUsed;
  List<ContactHistoryWrapper> _contacts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      _contacts = await fetchContactsWithCallHistory();
      _sortContacts();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _sortContacts() {
    switch (_selectedSort) {
      case SortOption.leastUsed:
        _contacts.sort((a, b) => a.callCount.compareTo(b.callCount));
        break;
      case SortOption.mostUsed:
        _contacts.sort((a, b) => b.callCount.compareTo(a.callCount));
        break;
      case SortOption.alphabetical:
        _contacts.sort((a, b) => a.contact.displayName.compareTo(b.contact.displayName));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Least Used Contacts'),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (SortOption result) {
              setState(() {
                _selectedSort = result;
                _sortContacts();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              for (var option in SortOption.values)
                PopupMenuItem<SortOption>(
                  value: option,
                  child: Row(
                    children: [
                      if (_selectedSort == option)
                        const Icon(Icons.check, color: Colors.blue)
                      else
                        const SizedBox(width: 24),
                      const SizedBox(width: 8),
                      Text(option.label),
                    ],
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContacts,
          ),
        ],
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _contacts.isEmpty
                  ? const Center(child: Text('No data found.'))
                  : ContactViewBuilder(contacts: _contacts),
    );
  }
}
