import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({Key? key, required this.order}) : super(key: key);

  final Order order;

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            DateFormat('dd/MM/yyyy').format(widget.order.dateTime),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          'Pedido código: ${widget.order.id}',
          style: const TextStyle(color: Colors.black),
        ),
        subtitle: Text(
          'Valor: R\$${widget.order.amount.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.black),
        ),
        children: [
          ...widget.order.products.map((orderDetails) {
            return ListTile(
              title: Text(orderDetails.name),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  '${orderDetails.quantity.toString()}x',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              trailing:
                  Text('R\$${orderDetails.quantity * orderDetails.price}'),
            );
          }),
        ],
      ),
    );
  }
}
