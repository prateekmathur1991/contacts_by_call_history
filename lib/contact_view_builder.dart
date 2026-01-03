import 'package:contacts_by_call_history/fetch_data.dart';
import 'package:flutter/material.dart';

class ContactViewBuilder extends StatelessWidget {

  final List<ContactHistoryWrapper> contacts;

  const ContactViewBuilder({super.key, required this.contacts});

  @override
  Widget build(BuildContext buildContext) {

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
  }
}