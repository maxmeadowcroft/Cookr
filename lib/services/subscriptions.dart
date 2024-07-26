import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../database/user_data_database_helper.dart';

class SubscriptionService {
  static const String _premiumSubscriptionId = 'com.yourapp.premium';
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final UserDataDatabaseHelper _userDataDatabaseHelper = UserDataDatabaseHelper();

  void init() {
    _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      _onPurchaseUpdated(purchaseDetailsList);
    }, onError: (error) {
      _handleError(error);
    });
  }

  Future<void> buyPremiumSubscription() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      // The store is not available
      return;
    }

    const Set<String> _kIds = <String>{_premiumSubscriptionId};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error
      return;
    }

    final List<ProductDetails> products = response.productDetails;
    final ProductDetails productDetails = products.firstWhere((product) => product.id == _premiumSubscriptionId);

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased) {
        await _handlePurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _handleError(purchaseDetails.error!);
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == _premiumSubscriptionId) {
      final userId = 1; // Replace with the actual user ID
      final user = await _userDataDatabaseHelper.getUserData(userId);
      if (user != null) {
        final updatedUser = UserData(
          id: user.id,
          activityLevel: user.activityLevel,
          seenRecipes: user.seenRecipes,
          cookedRecipes: user.cookedRecipes,
          hasPremium: 1,
          goals: user.goals,
        );
        await _userDataDatabaseHelper.updateUserData(updatedUser);
      }
    }
  }

  void _handleError(IAPError error) {
    // Handle purchase error
    debugPrint('Purchase error: $error');
  }
}
