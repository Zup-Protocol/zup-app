part of 'preview_deposit_modal_cubit.dart';

@freezed
class PreviewDepositModalState with _$PreviewDepositModalState {
  const factory PreviewDepositModalState.loading() = _Loading;
  const factory PreviewDepositModalState.initial({required BigInt token0Allowance, required BigInt token1Allowance}) =
      _Initial;
  const factory PreviewDepositModalState.waitingTransaction({required String txId}) = _WaitingTransaction;
  const factory PreviewDepositModalState.depositSuccess({required String txId}) = _DepositSucess;
  const factory PreviewDepositModalState.approveSuccess({required String txId, required String symbol}) =
      _ApproveSuccess;
  const factory PreviewDepositModalState.transactionError() = _TransactionError;
  const factory PreviewDepositModalState.approvingToken(String symbol) = _ApprovingToken;
  const factory PreviewDepositModalState.depositing() = _Depositing;
}
