import 'package:flutter/material.dart';
import 'package:contacts_by_call_history/fetch_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Least Used Contacts')),
      body: FutureBuilder(
        future: fetchContactsWithCallHistory(),
        builder:
            (BuildContext context, AsyncSnapshot<List<ContactHistoryWrapper>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: const CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final contacts = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: (contacts[index].contact.photo != null && contacts[index].contact.photo!.isNotEmpty)
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(contacts[index].contact.photo!),
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                      title: Text(contacts[index].contact.displayName),
                      trailing: Text('Calls: ${contacts[index].callCount}'),
                    );
                  }
                );
              } else {
                return Center(child: const Text('No data found.'));
              }
            },
      ),
    );
  }
}
