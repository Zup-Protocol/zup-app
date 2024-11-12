part of 'token_amount_card_user_balance_cubit.dart';

@freezed
class TokenAmountCardUserBalanceState with _$TokenAmountCardUserBalanceState {
  const factory TokenAmountCardUserBalanceState.loadingUserBalance() = _Loading;
  const factory TokenAmountCardUserBalanceState.showUserBalance(double amount) = _Show;
  const factory TokenAmountCardUserBalanceState.hideUserBalance() = _Hide;
  const factory TokenAmountCardUserBalanceState.error() = _Error;
}
