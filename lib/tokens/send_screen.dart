import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/qr_scanner/gw_qr_scanner.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/tokens/address_book.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

/// Send flow — pick an asset, paste a recipient, set an amount, review.
///
/// The actual broadcast is wired to the wallet backend later; the review sheet
/// confirms with a demo toast so the screen is fully reviewable in mock mode.
class SendScreen extends StatefulWidget {
  const SendScreen({super.key, this.initialCoin});

  /// Pre-selected asset (e.g. when opened from a token detail).
  final Coin? initialCoin;

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final TextEditingController _recipient = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  Coin? _coin;

  @override
  void initState() {
    super.initState();
    _coin = widget.initialCoin;
  }

  @override
  void dispose() {
    _recipient.dispose();
    _amount.dispose();
    super.dispose();
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v
        .toStringAsFixed(6)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
      builder: (context, state) {
        final coins = state.coins;
        final coin = _coin ??
            state.selectedCoin ??
            (coins.isNotEmpty ? coins.first : null);
        final balance = coin?.balance ?? 0;
        final amount = double.tryParse(_amount.text.trim()) ?? 0;
        final overBalance = amount > balance;
        final valid =
            _recipient.text.trim().length >= 6 && amount > 0 && !overBalance;

        return GWCanvasBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: const Text('Send'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(GeniusWalletConsts.space6),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ----- asset -----
                        Text('Asset',
                            style: GeniusWalletTypography.labelMd.copyWith(
                                color: GeniusWalletColors.textSecondary)),
                        const SizedBox(height: GeniusWalletConsts.space4),
                        _AssetSelector(
                          coin: coin,
                          balanceLabel:
                              '${_fmt(balance)} ${coin?.symbol ?? ''}',
                          onTap: coins.length > 1
                              ? () => _pickAsset(context, coins)
                              : null,
                        ),
                        const SizedBox(height: GeniusWalletConsts.space10),

                        // ----- recipient -----
                        GWTextField(
                          controller: _recipient,
                          label: 'Recipient',
                          hint: 'Wallet address',
                          onChanged: (_) => setState(() {}),
                          prefix: const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 20,
                              color: GeniusWalletColors.textSecondary),
                          suffix: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Scan QR code',
                                icon: const Icon(Icons.qr_code_scanner_rounded,
                                    size: 18,
                                    color: GeniusWalletColors.textSecondary),
                                onPressed: () async {
                                  final scanned = await GWQrScanner.show(
                                    context,
                                    title: 'Scan address',
                                    hint:
                                        'Point at a wallet-address QR code',
                                    // Ignore WalletConnect pairing codes —
                                    // they are not addresses.
                                    accept: (raw) => raw.startsWith('wc:')
                                        ? null
                                        : extractWalletAddress(raw),
                                  );
                                  if (scanned != null && mounted) {
                                    _recipient.text = scanned;
                                    setState(() {});
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: 'Address book',
                                icon: const Icon(Icons.contacts_outlined,
                                    size: 18,
                                    color: GeniusWalletColors.textSecondary),
                                onPressed: () async {
                                  final picked = await showAddressBookPicker(
                                    context,
                                    draftAddress: _recipient.text.trim(),
                                  );
                                  if (picked != null && mounted) {
                                    _recipient.text = picked;
                                    setState(() {});
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: 'Paste',
                                icon: const Icon(Icons.content_paste_rounded,
                                    size: 18,
                                    color: GeniusWalletColors.textSecondary),
                                onPressed: () async {
                                  final data =
                                      await Clipboard.getData('text/plain');
                                  if (data?.text != null) {
                                    _recipient.text = data!.text!.trim();
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: GeniusWalletConsts.space10),

                        // ----- amount -----
                        Text('Amount',
                            style: GeniusWalletTypography.labelMd.copyWith(
                                color: GeniusWalletColors.textSecondary)),
                        const SizedBox(height: GeniusWalletConsts.space4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GeniusWalletConsts.space8,
                            vertical: GeniusWalletConsts.space6,
                          ),
                          decoration: GWDecorations.surface(
                              radius: GeniusWalletConsts.radiusLg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _amount,
                                      onChanged: (_) => setState(() {}),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      style: GeniusWalletTypography
                                          .numericHeadline
                                          .copyWith(fontSize: 28),
                                      cursorColor:
                                          GeniusWalletColors.brandPrimary,
                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        border: InputBorder.none,
                                        hintText: '0',
                                        hintStyle: GeniusWalletTypography
                                            .numericHeadline
                                            .copyWith(
                                                fontSize: 28,
                                                color: GeniusWalletColors
                                                    .textPrimary38),
                                      ),
                                    ),
                                  ),
                                  GWButton(
                                    label: 'Max',
                                    variant: GWButtonVariant.tertiary,
                                    size: GWButtonSize.sm,
                                    onPressed: balance > 0
                                        ? () {
                                            _amount.text = _fmt(balance);
                                            setState(() {});
                                          }
                                        : null,
                                  ),
                                  const SizedBox(
                                      width: GeniusWalletConsts.space4),
                                  Text(coin?.symbol ?? '',
                                      style: GeniusWalletTypography.titleMd),
                                ],
                              ),
                              const SizedBox(height: GeniusWalletConsts.space4),
                              Text(
                                overBalance
                                    ? 'Insufficient balance'
                                    : 'Available: ${_fmt(balance)} ${coin?.symbol ?? ''}',
                                style: GeniusWalletTypography.bodySm.copyWith(
                                  color: overBalance
                                      ? GeniusWalletColors.statusError
                                      : GeniusWalletColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: GeniusWalletConsts.space6),

                        // ----- network fee (estimated) -----
                        _FeeRow(network: state.selectedNetwork?.name),
                        const SizedBox(height: GeniusWalletConsts.space16),

                        // ----- CTA -----
                        GWButton(
                          label: 'Review',
                          variant: GWButtonVariant.gradient,
                          size: GWButtonSize.lg,
                          expand: true,
                          onPressed: valid
                              ? () => _review(context, coin!, amount)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _pickAsset(BuildContext context, List<Coin> coins) {
    ResponsiveDrawer.show<void>(
      context: context,
      title: 'Select asset',
      children: [
        for (final c in coins)
          ListTile(
            onTap: () {
              setState(() => _coin = c);
              Navigator.of(context).pop();
            },
            leading: SizedBox(
              width: 36,
              height: 36,
              child: buildTokenIcon(iconPath: c.iconPath ?? '', size: 36),
            ),
            title: Text(c.name ?? c.symbol ?? 'Token',
                style: GeniusWalletTypography.titleMd),
            subtitle: Text('${_fmt(c.balance ?? 0)} ${c.symbol ?? ''}',
                style: GeniusWalletTypography.bodySm
                    .copyWith(color: GeniusWalletColors.textSecondary)),
          ),
      ],
    );
  }

  void _review(BuildContext context, Coin coin, double amount) {
    ResponsiveDrawer.show<void>(
      context: context,
      title: 'Review',
      children: [
        const SizedBox(height: GeniusWalletConsts.space4),
        _SummaryRow('Asset', '${coin.name ?? coin.symbol}'),
        _SummaryRow('Amount', '${_fmt(amount)} ${coin.symbol ?? ''}'),
        _SummaryRow('To', _short(_recipient.text.trim())),
        const _SummaryRow('Network fee', '≈ \$0.00'),
        const SizedBox(height: GeniusWalletConsts.space8),
        GWButton(
          label: 'Confirm & Send',
          variant: GWButtonVariant.gradient,
          size: GWButtonSize.lg,
          expand: true,
          onPressed: () {
            Navigator.of(context).pop(); // close review sheet
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Transaction submitted (demo)'),
                backgroundColor: GeniusWalletColors.surfaceMenu,
              ),
            );
            if (context.mounted) context.go('/dashboard');
          },
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
      ],
    );
  }

  String _short(String a) =>
      a.length > 14 ? '${a.substring(0, 8)}…${a.substring(a.length - 4)}' : a;
}

class _AssetSelector extends StatelessWidget {
  const _AssetSelector(
      {required this.coin, required this.balanceLabel, this.onTap});
  final Coin? coin;
  final String balanceLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(GeniusWalletConsts.space6),
          decoration:
              GWDecorations.surface(radius: GeniusWalletConsts.radiusLg),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: buildTokenIcon(iconPath: coin?.iconPath ?? '', size: 36),
              ),
              const SizedBox(width: GeniusWalletConsts.space6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coin?.name ?? coin?.symbol ?? 'Select asset',
                        style: GeniusWalletTypography.titleMd,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('Balance: $balanceLabel',
                        style: GeniusWalletTypography.bodySm
                            .copyWith(color: GeniusWalletColors.textSecondary)),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: GeniusWalletColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({this.network});
  final String? network;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space8,
        vertical: GeniusWalletConsts.space6,
      ),
      decoration: GWDecorations.surface(radius: GeniusWalletConsts.radiusLg),
      child: Row(
        children: [
          const Icon(Icons.local_gas_station_outlined,
              size: 18, color: GeniusWalletColors.textSecondary),
          const SizedBox(width: GeniusWalletConsts.space4),
          Text('Network fee${network != null ? ' · $network' : ''}',
              style: GeniusWalletTypography.bodyMd
                  .copyWith(color: GeniusWalletColors.textSecondary)),
          const Spacer(),
          Text('≈ \$0.00', style: GeniusWalletTypography.numericBody),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GeniusWalletTypography.bodyMd
                  .copyWith(color: GeniusWalletColors.textSecondary)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: GeniusWalletTypography.numericBody,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
