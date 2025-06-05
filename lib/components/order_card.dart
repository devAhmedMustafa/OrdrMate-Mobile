import 'package:flutter/material.dart';
import 'package:ordrmate/pages/order_page.dart';
import '../models/Order.dart';
import '../ui/theme/app_theme.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final Color statusColor;

  const OrderCard({
    super.key,
    required this.order,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacingM),
      color: AppTheme.surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusL),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusL),
        onTap: () {
          // Navigate to OrderDetailsPage when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(orderId: order.id)
            )
          );
        },
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.restaurantName ?? 'Unknown Restaurant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusM),
                    ),
                    child: Text(
                      order.status!,
                      style: TextStyle(
                        color: AppTheme.surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  SizedBox(width: AppTheme.spacingS),
                  Text(
                    order.createdAt.toLocal().toString().split('.')[0],
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacingS),
              Row(
                children: [
                  Icon(
                    Icons.payment,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  SizedBox(width: AppTheme.spacingS),
                  Text(
                    '${order.paymentMethod} ${order.isPaid ? "(Paid)" : "(Unpaid)"}',
                    style: TextStyle(
                      color: order.isPaid
                          ? const Color(0xFF4CAF50)
                          : AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacingS),
              Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  SizedBox(width: AppTheme.spacingS),
                  Text(
                    '${order.orderType.name}${order.orderType == OrderType.takeaway ? ' #${order.orderNumber}' : order.orderType == OrderType.dineIn ? ' Table ${order.tableNumber}' : ''}',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacingM),
              Container(
                padding: EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusS),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: AppTheme.surfaceColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${order.totalAmount.toStringAsFixed(2)} EGP',
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 