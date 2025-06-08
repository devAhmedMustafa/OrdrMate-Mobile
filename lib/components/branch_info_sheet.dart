import 'package:flutter/material.dart';
import 'package:ordrmate/pages/restaurant_profile_page.dart';
import 'package:ordrmate/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../models/Branch.dart';
import '../services/restaurant_service.dart';
import '../ui/theme/app_theme.dart';

class BranchInfoSheet extends StatefulWidget {
  final Branch branch;
  final VoidCallback onClose;

  const BranchInfoSheet({
    super.key,
    required this.branch,
    required this.onClose,
  });

  @override
  State<BranchInfoSheet> createState() => _BranchInfoSheetState();
}

class _BranchInfoSheetState extends State<BranchInfoSheet> {
  BranchInfo? _branchInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBranchInfo();
  }

  Future<void> _loadBranchInfo() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final RestaurantService _restaurantService = RestaurantService(authService);
      final branchInfo = await _restaurantService.getBranchInfo(widget.branch.id);
      setState(() {
        _branchInfo = branchInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatWaitingTime(double minutes) {
    final hours = (minutes / 60).floor();
    final mins = minutes.round() % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.errorColor,
                        size: 48,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        'Error: $_error',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      ElevatedButton.icon(
                        onPressed: _loadBranchInfo,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.surfaceColor,
                        ),
                      ),
                    ],
                  ),
                )
              else if (_branchInfo != null)
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _branchInfo!.restaurantName,
                              style: TextStyle(
                                color: AppTheme.textPrimaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusS),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RestaurantProfilePage(
                                      restaurantId: widget.branch.restaurantId,
                                      branchId: widget.branch.id,
                                      selectedBranch: widget.branch,
                                    ),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.arrow_forward,
                                color: AppTheme.surfaceColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Row(
                        children: [
                          Icon(Icons.star, color: AppTheme.primaryColor),
                          const SizedBox(width: AppTheme.spacingXS),
                          Text(
                            '4.0',
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        'Address: ${_branchInfo!.branchAddress}',
                        style: TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_branchInfo!.branchPhoneNumber != null) ...[
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          'Phone: ${_branchInfo!.branchPhoneNumber}',
                          style: TextStyle(
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppTheme.spacingL),
                      Row(
                        children: [
                          Icon(Icons.table_bar, color: AppTheme.textPrimaryColor),
                          const SizedBox(width: AppTheme.spacingS),
                          Text(
                            'Free tables: ${_branchInfo!.freeTables}',
                            style: TextStyle(
                              color: AppTheme.textPrimaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Row(
                        children: [
                          Icon(Icons.people, color: AppTheme.textPrimaryColor),
                          const SizedBox(width: AppTheme.spacingS),
                          Text(
                            'Orders in queue: ${_branchInfo!.ordersInQueue}',
                            style: TextStyle(
                              color: AppTheme.textPrimaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: AppTheme.textPrimaryColor),
                          const SizedBox(width: AppTheme.spacingS),
                          Text(
                            'Waiting time: ${_formatWaitingTime(_branchInfo!.averageWaitingTime)}',
                            style: TextStyle(
                              color: AppTheme.textPrimaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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