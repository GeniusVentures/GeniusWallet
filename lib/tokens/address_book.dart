import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// A saved send recipient.
class AddressBookEntry {
  const AddressBookEntry({required this.name, required this.address});

  final String name;
  final String address;
}

/// Device-local address book for the Send flow, persisted in Hive as plain
/// name/address pairs (no sync, no address validation — see HANDOFF.md §6).
class AddressBook {
  static Box get _box => Hive.box(addressBookBoxName);

  static List<AddressBookEntry> all() {
    final raw =
        _box.get(addressBookContactsKey, defaultValue: const []) as List;
    return raw
        .whereType<Map>()
        .map((m) => AddressBookEntry(
              name: (m['name'] ?? '') as String,
              address: (m['address'] ?? '') as String,
            ))
        .where((e) => e.address.isNotEmpty)
        .toList();
  }

  /// Adds [entry]; an existing entry with the same address is replaced.
  static Future<void> add(AddressBookEntry entry) {
    final entries = all()
      ..removeWhere((e) => e.address == entry.address)
      ..add(entry);
    return _save(entries);
  }

  static Future<void> remove(String address) {
    final entries = all()..removeWhere((e) => e.address == address);
    return _save(entries);
  }

  static Future<void> _save(List<AddressBookEntry> entries) => _box.put(
        addressBookContactsKey,
        [
          for (final e in entries) {'name': e.name, 'address': e.address}
        ],
      );
}

/// Opens the address book drawer; resolves to the picked address (null when
/// dismissed). [draftAddress] pre-fills the add-contact form so a recipient
/// the user already typed can be saved in one tap.
Future<String?> showAddressBookPicker(
  BuildContext context, {
  String? draftAddress,
}) {
  return ResponsiveDrawer.show<String>(
    context: context,
    title: 'Address book',
    children: [_AddressBookSheet(draftAddress: draftAddress)],
  );
}

class _AddressBookSheet extends StatefulWidget {
  const _AddressBookSheet({this.draftAddress});

  final String? draftAddress;

  @override
  State<_AddressBookSheet> createState() => _AddressBookSheetState();
}

class _AddressBookSheetState extends State<_AddressBookSheet> {
  String _short(String a) =>
      a.length > 14 ? '${a.substring(0, 8)}…${a.substring(a.length - 4)}' : a;

  Future<void> _addContact() async {
    final saved = await ResponsiveDrawer.show<bool>(
      context: context,
      title: 'Add contact',
      children: [_AddContactForm(initialAddress: widget.draftAddress)],
    );
    if (saved == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final entries = AddressBook.all();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: GeniusWalletConsts.space12,
            ),
            child: Text(
              'No saved addresses yet.',
              textAlign: TextAlign.center,
              style: GeniusWalletTypography.bodyMd
                  .copyWith(color: GeniusWalletColors.textSecondary),
            ),
          )
        else
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: GeniusWalletConsts.space2,
              ),
              child: Container(
                decoration:
                    GWDecorations.surface(radius: GeniusWalletConsts.radius2xl),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: GeniusWalletConsts.space6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(GeniusWalletConsts.radius2xl),
                  ),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        GeniusWalletColors.brandPrimary.withAlpha(38),
                    child: Text(
                      entry.name.isEmpty
                          ? '?'
                          : entry.name.substring(0, 1).toUpperCase(),
                      style: GeniusWalletTypography.labelMd
                          .copyWith(color: GeniusWalletColors.brandPrimary),
                    ),
                  ),
                  title: Text(
                    entry.name,
                    style: GeniusWalletTypography.titleMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _short(entry.address),
                    style: GeniusWalletTypography.bodySm
                        .copyWith(color: GeniusWalletColors.textSecondary),
                  ),
                  trailing: IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: GeniusWalletColors.textSecondary,
                    ),
                    onPressed: () async {
                      await AddressBook.remove(entry.address);
                      if (mounted) setState(() {});
                    },
                  ),
                  onTap: () => Navigator.of(context).pop(entry.address),
                ),
              ),
            ),
        const SizedBox(height: GeniusWalletConsts.space6),
        GWButton(
          label: 'Add contact',
          variant: GWButtonVariant.secondary,
          expand: true,
          leading: const Icon(Icons.person_add_alt_1_rounded, size: 18),
          onPressed: _addContact,
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
      ],
    );
  }
}

class _AddContactForm extends StatefulWidget {
  const _AddContactForm({this.initialAddress});

  final String? initialAddress;

  @override
  State<_AddContactForm> createState() => _AddContactFormState();
}

class _AddContactFormState extends State<_AddContactForm> {
  final TextEditingController _name = TextEditingController();
  late final TextEditingController _address =
      TextEditingController(text: widget.initialAddress ?? '');

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valid =
        _name.text.trim().isNotEmpty && _address.text.trim().length >= 6;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: GeniusWalletConsts.space4),
        GWTextField(
          controller: _name,
          label: 'Name',
          hint: 'e.g. Alice',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: GeniusWalletConsts.space8),
        GWTextField(
          controller: _address,
          label: 'Address',
          hint: 'Wallet address',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        GWButton(
          label: 'Save',
          variant: GWButtonVariant.gradient,
          size: GWButtonSize.lg,
          expand: true,
          onPressed: valid
              ? () async {
                  await AddressBook.add(AddressBookEntry(
                    name: _name.text.trim(),
                    address: _address.text.trim(),
                  ));
                  if (context.mounted) Navigator.of(context).pop(true);
                }
              : null,
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
      ],
    );
  }
}
