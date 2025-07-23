import 'package:flutter/material.dart';
import 'package:flutter_paystack_payment_plus/src/api/service/contracts/cards_service_contract.dart';
import 'package:flutter_paystack_payment_plus/src/common/exceptions.dart';
import 'package:flutter_paystack_payment_plus/src/common/my_strings.dart';
import 'package:flutter_paystack_payment_plus/src/common/paystack.dart';
import 'package:flutter_paystack_payment_plus/src/common/utils.dart';
import 'package:flutter_paystack_payment_plus/src/models/card.dart';
import 'package:flutter_paystack_payment_plus/src/models/charge.dart';
import 'package:flutter_paystack_payment_plus/src/models/checkout_response.dart';
import 'package:flutter_paystack_payment_plus/src/transaction/card_transaction_manager.dart';
import 'package:flutter_paystack_payment_plus/src/ui/checkout/base_checkout.dart';
import 'package:flutter_paystack_payment_plus/src/ui/checkout/checkout_widget.dart';
import 'package:flutter_paystack_payment_plus/src/ui/input/card_input.dart';

class CardCheckout extends StatefulWidget {
  final Charge charge;
  final OnResponse<CheckoutResponse> onResponse;
  final ValueChanged<bool> onProcessingChange;
  final ValueChanged<PaymentCard?> onCardChange;
  final bool hideAmount;
  final CardServiceContract service;
  final String publicKey;
  final String? extraInfo;

  const CardCheckout({
    Key? key,
    required this.charge,
    required this.onResponse,
    required this.onProcessingChange,
    required this.onCardChange,
    required this.service,
    required this.publicKey,
    this.hideAmount = false,
    this.extraInfo,
  }) : super(key: key);

  @override
  _CardCheckoutState createState() => _CardCheckoutState(charge, onResponse);
}

class _CardCheckoutState extends BaseCheckoutMethodState<CardCheckout> {
  final Charge _charge;

  _CardCheckoutState(this._charge, OnResponse<CheckoutResponse> onResponse) : super(onResponse, CheckoutMethod.card);

  @override
  Widget buildAnimatedChild() {
    var amountText = _charge.amount.isNegative ? '' : Utils.formatAmount(_charge.amount);
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          if (widget.extraInfo != null) ...[
            Text(
              widget.extraInfo ?? "",
              key: Key("extraInfo"),
              style: TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20.0,
            ),
          ],
          const Text(
            Strings.cardInputInstruction,
            key: Key("InstructionKey"),
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 20.0,
          ),
          CardInput(
            key: const Key("CardInput"),
            buttonText: widget.hideAmount ? "Continue" : 'Pay: $amountText',
            card: _charge.card,
            onValidated: _onCardValidated,
          ),
        ],
      ),
    );
  }

  void _onCardValidated(PaymentCard? card) {
    if (card == null) return;
    _charge.card = card;
    widget.onCardChange(_charge.card);
    widget.onProcessingChange(true);

    if ((_charge.accessCode != null && _charge.accessCode!.isNotEmpty) || _charge.reference != null && _charge.reference!.isNotEmpty) {
      _chargeCard(_charge);
    } else {
      // This should never happen. Validation has already been done in [PaystackPayment .checkout]
      throw ChargeException(Strings.noAccessCodeReference);
    }
  }

  void _chargeCard(Charge charge) async {
    final response = await CardTransactionManager(
      charge: charge,
      context: context,
      service: widget.service,
      publicKey: widget.publicKey,
    ).chargeCard();
    onResponse(response);
  }
}
