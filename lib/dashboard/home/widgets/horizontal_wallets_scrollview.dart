import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:genius_wallet/widgets/components/sgnus/sgnus_wallet.dart';
import 'package:genius_wallet/widgets/components/wallet_preview.g.dart';
import 'package:go_router/go_router.dart';

class HorizontalWalletsScrollview extends StatefulWidget {
  const HorizontalWalletsScrollview({Key? key}) : super(key: key);

  @override
  State<HorizontalWalletsScrollview> createState() =>
      _HorizontalWalletsScrollviewState();
}

class _HorizontalWalletsScrollviewState
    extends State<HorizontalWalletsScrollview> {
  final ScrollController _scrollController = ScrollController();

  bool _showLeftArrow = false;
  bool _showRightArrow = true;
  bool _isHovering = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrowVisibility);
  }

  void _updateArrowVisibility() {
    setState(() {
      _showLeftArrow = _scrollController.position.pixels > 0;
      _showRightArrow = _scrollController.position.pixels <
          _scrollController.position.maxScrollExtent;
    });
  }

  void _onHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
      if (isHovering) {
        _hideTimer?.cancel(); // Cancel any existing hide timer
      } else {
        _startHideTimer(); // Start a new hide timer
      }
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _isHovering = false;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state.wallets.isEmpty) {
          return const Center(
            child: AutoSizeText(
              "You Have No Wallets!",
              style: TextStyle(fontSize: 20),
            ),
          );
        }

        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: Stack(
            children: [
              // Scrollable Wallet List
              Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: StreamBuilder<SGNUSConnection>(
                    stream:
                        context.read<GeniusApi>().getSGNUSConnectionStream(),
                    builder: (context, snapshot) {
                      final connection = snapshot.data;
                      final sortedWallets = state.wallets;

                      // Sort connected wallet to the front
                      sortedWallets.sort((a, b) {
                        if (a.address == connection?.walletAddress &&
                            b.address != connection?.walletAddress) {
                          return -1;
                        } else if (b.address == connection?.walletAddress &&
                            a.address != connection?.walletAddress) {
                          return 1;
                        } else {
                          return 0;
                        }
                      });

                      return Row(
                        children: [
                          if (connection != null && connection.isConnected) ...[
                            WalletContainerButton(
                              onPressed: () {},
                              child: const SGNUSWallet(),
                            ),
                            const SizedBox(width: 16),
                          ],
                          for (int i = 0; i < sortedWallets.length; i++) ...[
                            WalletContainerButton(
                              onPressed: () {
                                context.push(
                                    '/wallets/${sortedWallets[i].address}');
                              },
                              child: WalletPreview(
                                isConnected: connection != null &&
                                    connection.isConnected &&
                                    connection.walletAddress ==
                                        sortedWallets[i].address,
                                ovrWalletBalance: sortedWallets[i].balance == 0
                                    ? '0'
                                    : sortedWallets[i]
                                        .balance
                                        .toStringAsFixed(3),
                                walletAddress: sortedWallets[i].address,
                                walletType: sortedWallets[i].walletType,
                                ovrCoinSymbol: sortedWallets[i].currencySymbol,
                                walletName: sortedWallets[i].walletName,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          WalletContainerButton(
                            width: 250,
                            onPressed: () =>
                                context.push('/landing_screen', extra: true),
                            child: const Center(
                              child: Text(
                                GeniusWalletText.btnAddWallet,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: GeniusWalletColors.lightGreenPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Left Arrow
              if (_showLeftArrow && _isHovering)
                Positioned(
                  left: 4,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      _scrollController.animateTo(
                        _scrollController.position.pixels - 200,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: GeniusWalletColors.deepBlueTertiary
                            .withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      width: 40,
                      height: 40,
                      child: Transform.translate(
                        offset:
                            const Offset(4, 0), // Adjust the horizontal offset
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: GeniusWalletColors.lightGreenPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

              // Right Arrow
              if (_showRightArrow && _isHovering)
                Positioned(
                  right: 4,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      _scrollController.animateTo(
                        _scrollController.position.pixels + 200,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: GeniusWalletColors.deepBlueTertiary
                            .withOpacity(0.8), // Circular background
                        shape: BoxShape.circle,
                      ),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: GeniusWalletColors.lightGreenPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class WalletContainerButton extends StatelessWidget {
  final Widget child; // The content inside the button
  final VoidCallback? onPressed; // The callback for button press
  final double width; // Customizable width
  final double borderRadius; // Border radius
  final Color color; // Background color

  const WalletContainerButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.width = 330.0,
    this.borderRadius = GeniusWalletConsts.borderRadiusCard,
    this.color = GeniusWalletColors.deepBlueCardColor, // Default color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: MaterialButton(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        color: color,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
