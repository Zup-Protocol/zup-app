import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/app/create/deposit/widgets/token_amount_input_card/token_amount_input_card_cubit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_price_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/mixins/keys_mixin.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';
import 'package:zup_core/zup_core.dart';

import '../../../../../mocks.dart';

class _KeysMixinWrapper with KeysMixin {}

void main() {
  late TokenAmountInputCardCubit sut;
  late TokensRepository tokensRepository;
  late ZupSingletonCache zupSingletonCache;
  late ZupHolder zupHolder;

  setUp(() {
    registerFallbackValue(AppNetworks.base);

    tokensRepository = TokensRepositoryMock();
    zupSingletonCache = ZupSingletonCache.shared;
    zupHolder = ZupHolder();

    sut = TokenAmountInputCardCubit(tokensRepository, zupSingletonCache, zupHolder);

    when(() => tokensRepository.getTokenPrice(any(), any())).thenAnswer((_) async => TokenPriceDto.fixture());
  });

  test("When calling `getTokenPrice` it should use ZupHolder to not make too many requests at once", () async {
    zupHolder = ZupHolderMock();

    when(() => zupHolder.hold<num>(any())).thenAnswer((_) async => 31);
    final sut0 = TokenAmountInputCardCubit(tokensRepository, zupSingletonCache, zupHolder);

    await sut0.getTokenPrice(token: TokenDto.fixture(), network: AppNetworks.base);
    verify(() => zupHolder.hold<num>(any())).called(1);
  });

  test("When calling `getTokenPrice` it should use ZupSingletonCache with a expiration of 1 minute", () async {
    zupSingletonCache = ZupSingletonCacheMock();
    final sut0 = TokenAmountInputCardCubit(tokensRepository, zupSingletonCache, zupHolder);
    final token = TokenDto.fixture();
    const network = AppNetworks.base;

    when(() => zupSingletonCache.run<num>(any(), expiration: any(named: "expiration"), key: any(named: "key")))
        .thenAnswer((_) async => 31);

    await sut0.getTokenPrice(token: token, network: network);
    verify(() => zupSingletonCache.run<num>(any(),
        expiration: const Duration(minutes: 1),
        key: _KeysMixinWrapper()
            .tokenPriceCacheKey(tokenAddress: token.addresses[network.chainId]!, network: network))).called(1);
  });

  test("When calling `getTokenPrice` it should use tokensRepository to get the token price", () async {
    final token = TokenDto.fixture();
    const network = AppNetworks.base;

    await sut.getTokenPrice(token: token, network: network);
    verify(() => tokensRepository.getTokenPrice(token.addresses[network.chainId]!, network)).called(1);
  });
}
