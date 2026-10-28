import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/gnus_bridge/gnus_connection_store.dart';
import 'package:genius_wallet/settings/connected_sites_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:intl/intl.dart';

/// The sites that may use the bridge, each with a Revoke button. Reads only
/// the cubit, which reads the store.
class ConnectedSitesSection extends StatelessWidget {
  const ConnectedSitesSection({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        ConnectedSitesCubit(context.read<GnusConnectionStore>()),
    child: const _ConnectedSitesList(),
  );
}

class _ConnectedSitesList extends StatelessWidget {
  const _ConnectedSitesList();

  @override
  Widget build(BuildContext context) {
    final gw = context.gw;
    return BlocBuilder<ConnectedSitesCubit, List<GnusConnection>>(
      builder: (context, sites) {
        if (sites.isEmpty) {
          return Text(
            'No sites connected',
            style: GeniusWalletTypography.bodyMd.copyWith(
              color: gw.textSecondary,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: GeniusWalletConsts.space6,
          children: [for (final site in sites) _ConnectedSiteRow(site: site)],
        );
      },
    );
  }
}

class _ConnectedSiteRow extends StatelessWidget {
  const _ConnectedSiteRow({required this.site});

  final GnusConnection site;

  @override
  Widget build(BuildContext context) {
    final gw = context.gw;
    final when = DateFormat.yMMMd().add_jm().format(site.connectedAt.toLocal());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          // Wraps, never ellipsizes: a look-alike origin must be readable.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                site.origin.value,
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: gw.textPrimary,
                ),
              ),
              Text(
                '${site.origin.transport.label}, connected $when',
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: GeniusWalletConsts.space6),
        GWButton(
          label: 'Revoke',
          variant: GWButtonVariant.tertiary,
          size: GWButtonSize.sm,
          semanticLabel: 'Revoke ${site.origin.value}',
          onPressed: () async {
            final revoked = await context.read<ConnectedSitesCubit>().revoke(
              site.origin,
            );
            if (revoked || !context.mounted) {
              return;
            }
            showToast(
              context,
              'Could not revoke this site. It is still connected.',
              type: ToastType.error,
            );
          },
        ),
      ],
    );
  }
}
