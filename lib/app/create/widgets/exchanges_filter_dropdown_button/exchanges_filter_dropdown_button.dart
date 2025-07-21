import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zup_app/app/create/widgets/exchanges_filter_dropdown_button/exchanges_filter_dropdown_button_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/repositories/protocol_repository.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_singleton_cache.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class ExchangesFilterDropdownButton extends StatefulWidget {
  const ExchangesFilterDropdownButton({super.key});

  @override
  State<ExchangesFilterDropdownButton> createState() => _ExchangesFilterDropdownButtonState();
}

class _ExchangesFilterDropdownButtonState extends State<ExchangesFilterDropdownButton> {
  final zupSingletonCache = inject<ZupSingletonCache>();
  final protocolRepository = inject<ProtocolRepository>();
  final zupCachedImage = inject<ZupCachedImage>();
  final cache = inject<Cache>();

  ExchangesFilterDropdownButtonCubit? cubit;

  num get allowedProtocolsCount => cubit!.protocols
      .where(
        (protocol) => !cache.blockedProtocolsIds.contains(protocol.rawId),
      )
      .length;

  Color get buttonForegroundColor {
    if (allowedProtocolsCount == 0 && cubit!.protocols.isNotEmpty) return ZupColors.red;

    if (allowedProtocolsCount == cubit!.protocols.length) return ZupColors.gray;
    return ZupColors.brand;
  }

  String get protocolCounter {
    if (allowedProtocolsCount == 0) return "0";

    if (allowedProtocolsCount == cubit!.protocols.length) return "${cubit!.protocols.length}";

    return "$allowedProtocolsCount/${cubit!.protocols.length}";
  }

  @override
  void initState() {
    cubit = ExchangesFilterDropdownButtonCubit(protocolRepository, zupSingletonCache);

    WidgetsBinding.instance.addPostFrameCallback((_) => cubit!.getSupportedProtocols());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExchangesFilterDropdownButtonCubit, ExchangesFilterDropdownButtonState>(
      bloc: cubit,
      builder: (context, state) {
        return ZupPrimaryButton(
          key: const Key("exchanges-filter-dropdown-button"),
          backgroundColor: Colors.transparent,
          foregroundColor: buttonForegroundColor,
          border: const BorderSide(color: ZupColors.gray4),
          hoverElevation: 0,
          icon: Assets.icons.switch2.svg(),
          title: state.maybeWhen(
            success: (protocols) => S.of(context).exchangesFilterDropdownButtonTitleNumered(
                  exchangesCount: protocolCounter,
                ),
            orElse: () => S.of(context).exchangesFilterDropdownButtonTitle,
          ),
          height: 40,
          isLoading: state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          ),
          onPressed: state == const ExchangesFilterDropdownButtonState.loading()
              ? null
              : (buttonContext) => state.whenOrNull(
                    error: () async {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          ZupSnackBar(
                            context,
                            message: S.of(context).exchangesFilterDropdownButtonErrorSnackBarMessage,
                            type: ZupSnackBarType.error,
                            maxWidth: 400,
                          ),
                        );
                      });
                      return null;
                    },
                    success: (protocols) => ZupCheckboxListPopover.show(
                      buttonContext,
                      positionAdjustment: const Offset(-130, 10),
                      allSelectionButtonText: (
                        clearAll: S.of(context).exchangesFilterDropdownButtonDropdownClearAll,
                        selectAll: S.of(context).exchangesFilterDropdownButtonDropdownSelectAll
                      ),
                      searchHintText: S.of(context).exchangesFilterDropdownButtonDropdownSearchHint,
                      searchNotFoundStateText: (
                        description: S.of(context).exchangesFilterDropdownButtonDropdownNotFoundStateDescription,
                        title: S.of(context).exchangesFilterDropdownButtonDropdownNotFoundStateTitle
                      ),
                      onValueChanged: (items) {
                        setState(
                          () {
                            cache.saveBlockedProtocolIds(
                              blockedProtocolIds: items
                                  .where((item) => !item.isChecked)
                                  .map(
                                    (item) => item.id!,
                                  )
                                  .toList(),
                            );
                          },
                        );
                      },
                      items: protocols
                          .map(
                            (protocol) => ZupCheckboxItem(
                              id: protocol.rawId,
                              title: protocol.name,
                              icon: zupCachedImage.build(protocol.logo, radius: 50),
                              isChecked: !cache.blockedProtocolsIds.contains(protocol.rawId),
                              isDisabled: false,
                            ),
                          )
                          .toList(),
                    ),
                  ),
        );
      },
    );
  }
}
