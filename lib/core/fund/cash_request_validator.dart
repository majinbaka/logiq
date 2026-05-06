class CashValidationException implements Exception {
  const CashValidationException(this.code);

  final String code;

  @override
  String toString() => 'CashValidationException($code)';
}

class CashRequestValidator {
  const CashRequestValidator();

  void validateDeposit({
    required String accountStatus,
    required String amount,
    required String currency,
    String? idempotencyKey,
  }) {
    _validateAccount(accountStatus);
    _validateAmount(amount);
    _validateCurrency(currency);
    if (idempotencyKey != null && idempotencyKey.trim().isEmpty) {
      throw const CashValidationException('invalid_idempotency_key');
    }
  }

  void validateWithdrawal({
    required String accountStatus,
    required String amount,
    required String currency,
    required String availableCash,
  }) {
    _validateAccount(accountStatus);
    _validateAmount(amount);
    _validateCurrency(currency);
    final requested = _parseMoney(amount);
    final available = _parseMoney(availableCash);
    if (requested > available) {
      throw const CashValidationException('insufficient_available_cash');
    }
  }

  void _validateAccount(String status) {
    if (status.trim().toLowerCase() != 'active') {
      throw const CashValidationException('account_not_active');
    }
  }

  void _validateAmount(String amount) {
    if (_parseMoney(amount) <= BigInt.zero) {
      throw const CashValidationException('amount_must_be_positive');
    }
  }

  void _validateCurrency(String currency) {
    final normalized = currency.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(normalized)) {
      throw const CashValidationException('invalid_currency');
    }
  }

  BigInt _parseMoney(String raw) {
    final normalized = raw.trim();
    if (!RegExp(r'^\d+(\.\d{1,8})?$').hasMatch(normalized)) {
      throw const CashValidationException('invalid_amount');
    }
    final parts = normalized.split('.');
    final whole = BigInt.parse(parts.first) * BigInt.from(100000000);
    final fraction = parts.length == 1
        ? BigInt.zero
        : BigInt.parse(parts.last.padRight(8, '0'));
    return whole + fraction;
  }
}
