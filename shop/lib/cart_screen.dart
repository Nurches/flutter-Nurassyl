import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: const [_ClearButton()],
      ),
      body: Column(
        children: [
          // Consumer: the builder already holds the cart, no verb needed inside.
          Expanded(
            child: Consumer<Cart>(
              builder: (context, cart, _) => cart.count == 0
                  ? const Center(child: Text('Your cart is empty'))
                  : ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, i) {
                        final b = cart.items[i];
                        return ListTile(
                          title: Text(b.title),
                          subtitle: Text('${b.price} ₸'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '×${cart.qtyOf(b)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
                                tooltip: 'One more',
                                icon: const Icon(Icons.add),
                                onPressed: () => cart.increment(b),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                icon: const Icon(Icons.close),
                                onPressed: () => cart.remove(b),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            // Only the number changes; the icon + label is built once
            // and handed back to the builder as `child` on every notify.
            child: Consumer<Cart>(
              builder: (context, cart, child) => Row(
                children: [
                  child!,
                  const Spacer(),
                  Text(
                    '${cart.total} ₸',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              child: const _TotalLabel(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalLabel extends StatelessWidget {
  const _TotalLabel();

  @override
  Widget build(BuildContext context) {
    debugPrint('total label build');
    return Row(
      children: [
        const Icon(Icons.receipt_long_outlined),
        const SizedBox(width: 8),
        Text('Total', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

/// Asks first (the question lives in the widget), clears only on "yes"
/// (the clearing lives in the model).
class _ClearButton extends StatelessWidget {
  const _ClearButton();

  @override
  Widget build(BuildContext context) {
    final empty = context.select<Cart, bool>((c) => c.count == 0);
    return IconButton(
      tooltip: 'Clear cart',
      icon: const Icon(Icons.delete_sweep_outlined),
      onPressed: empty ? null : () => _confirm(context),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Every book will be removed from the cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    // After an await the screen may be gone: check before using context.
    if (!context.mounted) return;
    if (yes ?? false) context.read<Cart>().clear();
  }
}
