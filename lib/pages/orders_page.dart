import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/app_drawer.dart';
import '../components/order.dart';
import '../models/order_list.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Provider.of<OrderList>(context, listen: false).loadOrders().then((_) {
      setState(() => _isLoading = false);
    });
  }

  Future<void> _refreshOrders(BuildContext context) async {
    await Provider.of<OrderList>(context, listen: false).loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final OrderList orders = Provider.of(context);
    bool ordersEmpty = orders.itemsCount == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ordersEmpty
              ? const Center(child: Text("There is any order registered yet."))
              : RefreshIndicator(
                  onRefresh: () => _refreshOrders(context),
                  child: ListView.builder(
                    itemCount: orders.itemsCount,
                    itemBuilder: (ctx, index) =>
                        OrderWidget(order: orders.items[index]),
                  ),
                ),
      drawer: const AppDrawer(),
    );
  }
}
