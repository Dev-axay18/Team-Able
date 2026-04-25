import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: '1',
      type: PaymentType.card,
      cardNumber: '**** **** **** 4532',
      cardHolderName: 'Arjun Sharma',
      expiryDate: '12/25',
      isDefault: true,
      cardBrand: 'Visa',
    ),
    PaymentMethod(
      id: '2',
      type: PaymentType.card,
      cardNumber: '**** **** **** 8765',
      cardHolderName: 'Arjun Sharma',
      expiryDate: '08/26',
      isDefault: false,
      cardBrand: 'Mastercard',
    ),
    PaymentMethod(
      id: '3',
      type: PaymentType.upi,
      upiId: 'arjun@paytm',
      isDefault: false,
    ),
  ];

  void _setDefaultPayment(String id) {
    setState(() {
      for (var method in _paymentMethods) {
        method.isDefault = method.id == id;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Default payment method updated'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _deletePaymentMethod(String id) {
    setState(() {
      _paymentMethods.removeWhere((method) => method.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment method removed'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  Future<void> _addPaymentMethod() async {
    final result = await showModalBottomSheet<PaymentType>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddPaymentMethodSheet(),
    );

    if (result != null) {
      if (result == PaymentType.card) {
        _showAddCardDialog();
      } else if (result == PaymentType.upi) {
        _showAddUpiDialog();
      }
    }
  }

  Future<void> _showAddCardDialog() async {
    final formKey = GlobalKey<FormState>();
    final cardNumberController = TextEditingController();
    final cardHolderController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Card'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: cardNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    hintText: '1234 5678 9012 3456',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cardHolderController,
                  decoration: InputDecoration(
                    labelText: 'Card Holder Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card holder name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: expiryController,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        decoration: InputDecoration(
                          labelText: 'Expiry',
                          hintText: 'MM/YY',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: cvvController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _paymentMethods.add(
                    PaymentMethod(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      type: PaymentType.card,
                      cardNumber: '**** **** **** ${cardNumberController.text.substring(cardNumberController.text.length - 4)}',
                      cardHolderName: cardHolderController.text,
                      expiryDate: expiryController.text,
                      isDefault: false,
                      cardBrand: 'Visa',
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Card added successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Card'),
          ),
        ],
      ),
    );

    cardNumberController.dispose();
    cardHolderController.dispose();
    expiryController.dispose();
    cvvController.dispose();
  }

  Future<void> _showAddUpiDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add UPI ID'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'UPI ID',
            hintText: 'username@upi',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _paymentMethods.add(
                    PaymentMethod(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      type: PaymentType.upi,
                      upiId: controller.text,
                      isDefault: false,
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('UPI ID added successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Info Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your payment information is encrypted and secure',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Payment Methods List
          const Text(
            'Saved Payment Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          if (_paymentMethods.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.payment_rounded,
                    size: 64,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No payment methods added',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ...(_paymentMethods.map((method) {
              if (method.type == PaymentType.card) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CardPaymentTile(
                    method: method,
                    onSetDefault: () => _setDefaultPayment(method.id),
                    onDelete: () => _deletePaymentMethod(method.id),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _UpiPaymentTile(
                    method: method,
                    onSetDefault: () => _setDefaultPayment(method.id),
                    onDelete: () => _deletePaymentMethod(method.id),
                  ),
                );
              }
            }).toList()),

          const SizedBox(height: 12),

          // Add Payment Method Button
          OutlinedButton.icon(
            onPressed: _addPaymentMethod,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Payment Method'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardPaymentTile extends StatelessWidget {
  final PaymentMethod method;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _CardPaymentTile({
    required this.method,
    required this.onSetDefault,
    required this.onDelete,
  });

  IconData _getCardIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return Icons.credit_card_rounded;
      case 'mastercard':
        return Icons.credit_card_rounded;
      default:
        return Icons.credit_card_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: method.isDefault
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCardIcon(method.cardBrand ?? ''),
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method.cardBrand ?? 'Card',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (method.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.cardNumber ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      'Expires ${method.expiryDate}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert_rounded),
                itemBuilder: (context) => [
                  if (!method.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 20),
                          SizedBox(width: 12),
                          Text('Set as Default'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 20, color: AppTheme.errorColor),
                        SizedBox(width: 12),
                        Text('Remove', style: TextStyle(color: AppTheme.errorColor)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'default') {
                    onSetDefault();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpiPaymentTile extends StatelessWidget {
  final PaymentMethod method;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _UpiPaymentTile({
    required this.method,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: method.isDefault
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'UPI',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (method.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  method.upiId ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (context) => [
              if (!method.isDefault)
                const PopupMenuItem(
                  value: 'default',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 20),
                      SizedBox(width: 12),
                      Text('Set as Default'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 20, color: AppTheme.errorColor),
                    SizedBox(width: 12),
                    Text('Remove', style: TextStyle(color: AppTheme.errorColor)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'default') {
                onSetDefault();
              } else if (value == 'delete') {
                onDelete();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AddPaymentMethodSheet extends StatelessWidget {
  const _AddPaymentMethodSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Add Payment Method',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _PaymentMethodOption(
            icon: Icons.credit_card_rounded,
            title: 'Credit/Debit Card',
            subtitle: 'Add a card for payments',
            onTap: () => Navigator.pop(context, PaymentType.card),
          ),
          const SizedBox(height: 12),
          _PaymentMethodOption(
            icon: Icons.account_balance_rounded,
            title: 'UPI',
            subtitle: 'Add UPI ID for instant payments',
            onTap: () => Navigator.pop(context, PaymentType.upi),
          ),
          const SizedBox(height: 12),
          _PaymentMethodOption(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Wallet',
            subtitle: 'Coming soon',
            onTap: null,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _PaymentMethodOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onTap != null ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: onTap != null
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: onTap != null ? AppTheme.primaryColor : Colors.grey,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: onTap != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: onTap != null ? AppTheme.textLight : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

enum PaymentType { card, upi, wallet }

class PaymentMethod {
  final String id;
  final PaymentType type;
  final String? cardNumber;
  final String? cardHolderName;
  final String? expiryDate;
  final String? cardBrand;
  final String? upiId;
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.cardBrand,
    this.upiId,
    this.isDefault = false,
  });
}
