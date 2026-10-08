import 'package:flutter/material.dart';

import 'contacts.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.contact});
  
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        // Without Expanded: A RenderFlex overflowed by 214 pixels on the right.
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(child: Text(contact.initial)),
                if(contact.unread > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.surface, width: 2),
                      ),
                      child: Text(
                        '${contact.unread}',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onError),
                      ),
                    )
                  ),
              ],
            ),
            const SizedBox(width: 12,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(contact.name, style: textTheme.titleMedium),
                  Text(contact.email, style: textTheme.bodySmall)
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        )
      ),
    );
  }
}