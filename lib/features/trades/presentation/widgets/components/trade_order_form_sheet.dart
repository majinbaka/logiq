import 'package:flutter/material.dart';
import 'package:logiq/core/database/models/trade_order_model.dart';
import 'package:logiq/core/widgets/formatted_number_input.dart';
import 'package:logiq/core/widgets/trading_ui_tokens.dart';
import 'package:logiq/l10n/app_localizations.dart';

class TradeOrderFormResult {
  const TradeOrderFormResult({
    required this.status,
    required this.plannedPrice,
    required this.quantity,
  });

  final String status;
  final String? plannedPrice;
  final String? quantity;
}

class TradeOrderFormSheet extends StatefulWidget {
  const TradeOrderFormSheet({super.key, required this.existing});

  final TradeOrderModel? existing;

  @override
  State<TradeOrderFormSheet> createState() => _TradeOrderFormSheetState();
}

class _TradeOrderFormSheetState extends State<TradeOrderFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.existing?.plannedPrice ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.existing?.quantity ?? '',
    );
    _status = widget.existing?.status.toLowerCase() ?? 'planned';
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: TradingUiSpacing.md,
        right: TradingUiSpacing.md,
        top: TradingUiSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + TradingUiSpacing.md,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existing == null
                  ? l10n.tradesOrderCreateTitle
                  : l10n.tradesOrderEditTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TradingUiSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _status,
              items: [
                DropdownMenuItem(
                  value: 'planned',
                  child: Text(l10n.tradesOrderStatusPlanned),
                ),
                DropdownMenuItem(
                  value: 'placed',
                  child: Text(l10n.tradesOrderStatusPlaced),
                ),
                DropdownMenuItem(
                  value: 'filled',
                  child: Text(l10n.tradesOrderStatusFilled),
                ),
                DropdownMenuItem(
                  value: 'canceled',
                  child: Text(l10n.tradesOrderStatusCanceled),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _status = value);
              },
              decoration: InputDecoration(
                labelText: '${l10n.tradesStatusLabel} *',
              ),
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            FormattedNumberInput(
              controller: _priceController,
              label: l10n.tradesOrderPlannedPriceLabel,
              requiredErrorText: l10n.tradesRequiredFieldValidationError,
              numberErrorText: l10n.tradesNumberValidationError,
              positiveNumberErrorText: l10n.tradesPositiveNumberValidationError,
              nonNegativeNumberErrorText:
                  l10n.tradesNonNegativeNumberValidationError,
              suffixText: l10n.tradesUnitCurrency,
              required: true,
              mustBePositive: true,
            ),
            const SizedBox(height: TradingUiSpacing.sm),
            FormattedNumberInput(
              controller: _quantityController,
              label: l10n.tradesQuantityLabel,
              requiredErrorText: l10n.tradesRequiredFieldValidationError,
              numberErrorText: l10n.tradesNumberValidationError,
              positiveNumberErrorText: l10n.tradesPositiveNumberValidationError,
              nonNegativeNumberErrorText:
                  l10n.tradesNonNegativeNumberValidationError,
              suffixText: l10n.tradesUnitQuantity,
              required: true,
              mustBePositive: true,
            ),
            const SizedBox(height: TradingUiSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.tradesCancel),
                  ),
                ),
                const SizedBox(width: TradingUiSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(l10n.tradesSave),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      TradeOrderFormResult(
        status: _status,
        plannedPrice: _asNullableDecimal(_priceController.text),
        quantity: _asNullableDecimal(_quantityController.text),
      ),
    );
  }

  String? _asNullableDecimal(String value) {
    final trimmed = FormattedNumberInput.normalizeNumberText(value);
    return trimmed.isEmpty ? null : trimmed;
  }
}
