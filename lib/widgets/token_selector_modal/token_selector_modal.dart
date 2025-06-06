import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/token_card.dart';
import 'package:zup_app/widgets/token_selector_modal/token_selector_modal_cubit.dart';
import 'package:zup_app/widgets/zup_skeletonizer.dart';
import 'package:zup_core/mixins/device_info_mixin.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class TokenSelectorModal extends StatefulWidget {
  const TokenSelectorModal({super.key, required this.onSelectToken});

  final Function(TokenDto token) onSelectToken;

  static void show(
    BuildContext context, {
    required bool showAsBottomSheet,
    required Function(TokenDto token) onSelectToken,
  }) async {
    return ZupModal.show(
      context,
      showAsBottomSheet: showAsBottomSheet,
      content: BlocProvider.value(
        value: inject<TokenSelectorModalCubit>(),
        child: TokenSelectorModal(onSelectToken: onSelectToken),
      ),
      size: const Size(450, 600),
      title: S.of(context).tokenSelectorModalTitle,
      description: S.of(context).tokenSelectorModalDescription,
      padding: const EdgeInsets.all(0).copyWith(bottom: 1),
    );
  }

  @override
  State<TokenSelectorModal> createState() => _TokenSelectorModalState();
}

class _TokenSelectorModalState extends State<TokenSelectorModal> with DeviceInfoMixin {
  final double _horizontalPadding = 20;
  final EdgeInsetsGeometry _paddingBetweenListItems = const EdgeInsets.symmetric(vertical: 5);

  final _debouncer = inject<Debouncer>();
  final _cubit = inject<TokenSelectorModalCubit>();
  final _appCubit = inject<AppCubit>();

  void _selectToken(TokenDto token) {
    widget.onSelectToken(token);
    Navigator.of(context).pop();
  }

  Widget _buildSectionTitle(String title, {double topPadding = 20}) => Padding(
        padding: EdgeInsets.symmetric(horizontal: _horizontalPadding).copyWith(top: topPadding, bottom: 5),
        child: Text(title, style: const TextStyle(fontSize: 14, color: ZupColors.gray)),
      );

  Widget _buildSliverSectionTitle(String title, {double topPadding = 20}) {
    return SliverToBoxAdapter(
      child: Align(
        alignment: Alignment.centerLeft,
        child: _buildSectionTitle(title, topPadding: topPadding),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _cubit.fetchTokenList());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TokenSelectorModalCubit, TokenSelectorModalState>(
      builder: (context, state) {
        return ScrollbarTheme(
          data: const ScrollbarThemeData(mainAxisMargin: 20, crossAxisMargin: 3),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                leading: const SizedBox.shrink(),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                titleSpacing: 20,
                toolbarHeight: _appCubit.selectedNetwork.isAllNetworks ? 100 : 60,
                automaticallyImplyLeading: false,
                leadingWidth: 0,
                floating: true,
                snap: true,
                title: Column(
                  children: [
                    ZupTextField(
                      key: const Key("search-token-field"),
                      hintText: _appCubit.selectedNetwork.isAllNetworks
                          ? S.of(context).tokenSelectorModalSearchTitleAllNetworks
                          : S.of(context).tokenSelectorModalSearchTitle,
                      onChanged: (query) {
                        _debouncer.run(() async {
                          if (query.isEmpty) return _cubit.fetchTokenList();
                          _cubit.searchToken(query);
                        });
                      },
                    ),
                    if (_appCubit.selectedNetwork.isAllNetworks) ...[
                      const SizedBox(height: 8),
                      Text(
                        maxLines: 4,
                        S.of(context).tokenSelectorModalSearchAlertForAllNetworks,
                        style: const TextStyle(color: ZupColors.gray, fontSize: 12),
                      )
                    ]
                  ],
                ),
              ),
              ...state.maybeWhen(
                orElse: () => _buildSuccessOrLoadingSlivers(state),
                error: () => _buildErrorStateSlivers(),
                searchSuccess: (_) => _buildSearchSuccessOrSearchLoadingSlivers(state),
                searchLoading: () => _buildSearchSuccessOrSearchLoadingSlivers(state),
                searchNotFound: (searchedTerm) => _buildSearchNotFoundSlivers(searchedTerm),
                searchError: (searchedTerm) => _buildSearchErrorSlivers(searchedTerm),
              )
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildErrorStateSlivers() => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: ZupInfoState(
                iconSize: 80,
                icon: const Text(":(", style: TextStyle(color: ZupColors.brand)),
                title: S.of(context).somethingWhenWrong,
                description: S.of(context).tokenSelectorModalErrorDescription,
                helpButtonTitle: S.of(context).letsGiveItAnotherShot,
                helpButtonIcon: Assets.icons.arrowClockwise.svg(),
                onHelpButtonTap: () => _cubit.fetchTokenList(),
              ),
            ),
          ),
        ),
      ];

  List<Widget> _buildSearchErrorSlivers(String searchedTerm) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: ZupInfoState(
                iconSize: 60,
                icon: Assets.icons.sadMagnifyingglass.svg(
                  colorFilter: const ColorFilter.mode(ZupColors.brand, BlendMode.srcIn),
                ),
                title: S.of(context).somethingWhenWrong,
                description: S.of(context).tokenSelectorModalSearchErrorDescription(searchedTerm: searchedTerm),
                helpButtonTitle: S.of(context).letsGiveItAnotherShot,
                helpButtonIcon: Assets.icons.arrowClockwise.svg(),
                onHelpButtonTap: () => _cubit.searchToken(searchedTerm),
              ),
            ),
          ),
        ),
      ];

  List<Widget> _buildSearchNotFoundSlivers(String searchedTerm) => [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  style: const TextStyle(fontSize: 17),
                  children: [
                    TextSpan(
                      text: S.of(context).noResultsFor,
                      style: const TextStyle(color: ZupColors.gray, fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: " \"$searchedTerm\"",
                      style: const TextStyle(color: ZupColors.black, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ];

  List<Widget> _buildSearchSuccessOrSearchLoadingSlivers(TokenSelectorModalState state) => [
        ZupSkeletonizer(
          enabled: state == const TokenSelectorModalState.searchLoading(),
          child: _buildSliverSectionTitle(S.of(context).searchResults, topPadding: 10),
        ).sliver(),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
          sliver: state.maybeWhen(
            searchSuccess: (searchResult) => SliverList.builder(
              itemCount: searchResult.length,
              itemBuilder: (context, index) => Padding(
                padding: _paddingBetweenListItems,
                child: TokenCard(
                  asset: searchResult[index],
                  onClick: () => _selectToken(searchResult[index]),
                ),
              ),
            ),
            orElse: () => ZupSkeletonizer(
              child: SliverList(
                delegate: SliverChildListDelegate(
                  List.generate(
                    3,
                    (index) => Padding(
                      padding: _paddingBetweenListItems,
                      child: TokenCard(asset: TokenDto.fixture(), onClick: () {}),
                    ),
                  ),
                ),
              ),
            ).sliver(),
          ),
        ),
      ];

  List<Widget> _buildSuccessOrLoadingSlivers(TokenSelectorModalState state) => [
        state.maybeWhen(
          success: (popularTokens) => _buildSliverSectionTitle(S.of(context).popularTokens),
          orElse: () => const SliverToBoxAdapter(),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
          sliver: state.whenOrNull(
            loading: () => ZupSkeletonizer(
              child: SliverList(
                  delegate: SliverChildListDelegate(
                List.generate(
                  4,
                  (index) => Padding(
                    padding: _paddingBetweenListItems,
                    child: TokenCard(asset: TokenDto.fixture(), onClick: () {}),
                  ),
                ),
              )),
            ).sliver(),
            success: (popularTokens) => SliverList.builder(
              itemCount: popularTokens.length,
              itemBuilder: (context, index) {
                final popularToken = popularTokens[index];

                return Padding(
                  padding: _paddingBetweenListItems,
                  child: TokenCard(
                    key: Key("popular-token-$index"),
                    asset: popularToken,
                    onClick: () => _selectToken(popularToken),
                  ),
                );
              },
            ),
          ),
        ),
      ];
}
