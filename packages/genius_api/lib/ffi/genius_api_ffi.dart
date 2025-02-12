// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

/// TWAccount
class NativeLibrary {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeLibrary(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeLibrary.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  /// Creates a block of data from a byte array.
  ///
  /// \param bytes Non-null raw bytes buffer
  /// \param size size of the buffer
  /// \return Non-null filled block of data.
  ffi.Pointer<TWData> TWDataCreateWithBytes(
    ffi.Pointer<ffi.Uint8> bytes,
    int size,
  ) {
    return _TWDataCreateWithBytes(
      bytes,
      size,
    );
  }

  late final _TWDataCreateWithBytesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(
              ffi.Pointer<ffi.Uint8>, ffi.Size)>>('TWDataCreateWithBytes');
  late final _TWDataCreateWithBytes = _TWDataCreateWithBytesPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<ffi.Uint8>, int)>();

  /// Creates an uninitialized block of data with the provided size.
  ///
  /// \param size size for the block of data
  /// \return Non-null uninitialized block of data with the provided size
  ffi.Pointer<TWData> TWDataCreateWithSize(
    int size,
  ) {
    return _TWDataCreateWithSize(
      size,
    );
  }

  late final _TWDataCreateWithSizePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWData> Function(ffi.Size)>>(
          'TWDataCreateWithSize');
  late final _TWDataCreateWithSize =
      _TWDataCreateWithSizePtr.asFunction<ffi.Pointer<TWData> Function(int)>();

  /// Creates a block of data by copying another block of data.
  ///
  /// \param data buffer that need to be copied
  /// \return Non-null filled block of data.
  ffi.Pointer<TWData> TWDataCreateWithData(
    ffi.Pointer<TWData> data,
  ) {
    return _TWDataCreateWithData(
      data,
    );
  }

  late final _TWDataCreateWithDataPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>(
      'TWDataCreateWithData');
  late final _TWDataCreateWithData = _TWDataCreateWithDataPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Creates a block of data from a hexadecimal string.  Odd length is invalid (intended grouping to bytes is not obvious).
  ///
  /// \param hex input hex string
  /// \return Non-null filled block of data
  ffi.Pointer<TWData> TWDataCreateWithHexString(
    ffi.Pointer<TWString> hex,
  ) {
    return _TWDataCreateWithHexString(
      hex,
    );
  }

  late final _TWDataCreateWithHexStringPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWString>)>>(
      'TWDataCreateWithHexString');
  late final _TWDataCreateWithHexString = _TWDataCreateWithHexStringPtr
      .asFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWString>)>();

  /// Returns the size in bytes.
  ///
  /// \param data A non-null valid block of data
  /// \return the size of the given block of data
  int TWDataSize(
    ffi.Pointer<TWData> data,
  ) {
    return _TWDataSize(
      data,
    );
  }

  late final _TWDataSizePtr =
      _lookup<ffi.NativeFunction<ffi.Size Function(ffi.Pointer<TWData>)>>(
          'TWDataSize');
  late final _TWDataSize =
      _TWDataSizePtr.asFunction<int Function(ffi.Pointer<TWData>)>();

  /// Returns the raw pointer to the contents of data.
  ///
  /// \param data A non-null valid block of data
  /// \return the raw pointer to the contents of data
  ffi.Pointer<ffi.Uint8> TWDataBytes(
    ffi.Pointer<TWData> data,
  ) {
    return _TWDataBytes(
      data,
    );
  }

  late final _TWDataBytesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Uint8> Function(ffi.Pointer<TWData>)>>('TWDataBytes');
  late final _TWDataBytes = _TWDataBytesPtr.asFunction<
      ffi.Pointer<ffi.Uint8> Function(ffi.Pointer<TWData>)>();

  /// Returns the byte at the provided index.
  ///
  /// \param data A non-null valid block of data
  /// \param index index of the byte that we want to fetch - index need to be < TWDataSize(data)
  /// \return the byte at the provided index
  int TWDataGet(
    ffi.Pointer<TWData> data,
    int index,
  ) {
    return _TWDataGet(
      data,
      index,
    );
  }

  late final _TWDataGetPtr = _lookup<
      ffi.NativeFunction<
          ffi.Uint8 Function(ffi.Pointer<TWData>, ffi.Size)>>('TWDataGet');
  late final _TWDataGet =
      _TWDataGetPtr.asFunction<int Function(ffi.Pointer<TWData>, int)>();

  /// Sets the byte at the provided index.
  ///
  /// \param data A non-null valid block of data
  /// \param index index of the byte that we want to set - index need to be < TWDataSize(data)
  /// \param byte Given byte to be written in data
  void TWDataSet(
    ffi.Pointer<TWData> data,
    int index,
    int byte,
  ) {
    return _TWDataSet(
      data,
      index,
      byte,
    );
  }

  late final _TWDataSetPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<TWData>, ffi.Size, ffi.Uint8)>>('TWDataSet');
  late final _TWDataSet =
      _TWDataSetPtr.asFunction<void Function(ffi.Pointer<TWData>, int, int)>();

  /// Copies a range of bytes into the provided buffer.
  ///
  /// \param data A non-null valid block of data
  /// \param start starting index of the range - index need to be < TWDataSize(data)
  /// \param size size of the range we want to copy - size need to be < TWDataSize(data) - start
  /// \param output The output buffer where we want to copy the data.
  void TWDataCopyBytes(
    ffi.Pointer<TWData> data,
    int start,
    int size,
    ffi.Pointer<ffi.Uint8> output,
  ) {
    return _TWDataCopyBytes(
      data,
      start,
      size,
      output,
    );
  }

  late final _TWDataCopyBytesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<TWData>, ffi.Size, ffi.Size,
              ffi.Pointer<ffi.Uint8>)>>('TWDataCopyBytes');
  late final _TWDataCopyBytes = _TWDataCopyBytesPtr.asFunction<
      void Function(ffi.Pointer<TWData>, int, int, ffi.Pointer<ffi.Uint8>)>();

  /// Replaces a range of bytes with the contents of the provided buffer.
  ///
  /// \param data A non-null valid block of data
  /// \param start starting index of the range - index need to be < TWDataSize(data)
  /// \param size size of the range we want to replace - size need to be < TWDataSize(data) - start
  /// \param bytes The buffer that will replace the range of data
  void TWDataReplaceBytes(
    ffi.Pointer<TWData> data,
    int start,
    int size,
    ffi.Pointer<ffi.Uint8> bytes,
  ) {
    return _TWDataReplaceBytes(
      data,
      start,
      size,
      bytes,
    );
  }

  late final _TWDataReplaceBytesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<TWData>, ffi.Size, ffi.Size,
              ffi.Pointer<ffi.Uint8>)>>('TWDataReplaceBytes');
  late final _TWDataReplaceBytes = _TWDataReplaceBytesPtr.asFunction<
      void Function(ffi.Pointer<TWData>, int, int, ffi.Pointer<ffi.Uint8>)>();

  /// Appends data from a byte array.
  ///
  /// \param data A non-null valid block of data
  /// \param bytes Non-null byte array
  /// \param size The size of the byte array
  void TWDataAppendBytes(
    ffi.Pointer<TWData> data,
    ffi.Pointer<ffi.Uint8> bytes,
    int size,
  ) {
    return _TWDataAppendBytes(
      data,
      bytes,
      size,
    );
  }

  late final _TWDataAppendBytesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<TWData>, ffi.Pointer<ffi.Uint8>,
              ffi.Size)>>('TWDataAppendBytes');
  late final _TWDataAppendBytes = _TWDataAppendBytesPtr.asFunction<
      void Function(ffi.Pointer<TWData>, ffi.Pointer<ffi.Uint8>, int)>();

  /// Appends a single byte.
  ///
  /// \param data A non-null valid block of data
  /// \param byte A single byte
  void TWDataAppendByte(
    ffi.Pointer<TWData> data,
    int byte,
  ) {
    return _TWDataAppendByte(
      data,
      byte,
    );
  }

  late final _TWDataAppendBytePtr = _lookup<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<TWData>, ffi.Uint8)>>(
      'TWDataAppendByte');
  late final _TWDataAppendByte = _TWDataAppendBytePtr.asFunction<
      void Function(ffi.Pointer<TWData>, int)>();

  /// Appends a block of data.
  ///
  /// \param data A non-null valid block of data
  /// \param append A non-null valid block of data
  void TWDataAppendData(
    ffi.Pointer<TWData> data,
    ffi.Pointer<TWData> append,
  ) {
    return _TWDataAppendData(
      data,
      append,
    );
  }

  late final _TWDataAppendDataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<TWData>, ffi.Pointer<TWData>)>>('TWDataAppendData');
  late final _TWDataAppendData = _TWDataAppendDataPtr.asFunction<
      void Function(ffi.Pointer<TWData>, ffi.Pointer<TWData>)>();

  /// Reverse the bytes.
  ///
  /// \param data A non-null valid block of data
  void TWDataReverse(
    ffi.Pointer<TWData> data,
  ) {
    return _TWDataReverse(
      data,
    );
  }

  late final _TWDataReversePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWData>)>>(
          'TWDataReverse');
  late final _TWDataReverse =
      _TWDataReversePtr.asFunction<void Function(ffi.Pointer<TWData>)>();

  /// Sets all bytes to the given value.
  ///
  /// \param data A non-null valid block of data
  void TWDataReset(
    ffi.Pointer<TWData> data,
  ) {
    return _TWDataReset(
      data,
    );
  }

  late final _TWDataResetPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWData>)>>(
          'TWDataReset');
  late final _TWDataReset =
      _TWDataResetPtr.asFunction<void Function(ffi.Pointer<TWData>)>();

  /// Deletes a block of data created with a `TWDataCreate*` method.
  ///
  /// \param data A non-null valid block of data
  void TWDataDelete(
    ffi.Pointer<TWData> data,
  ) {
    return _TWDataDelete(
      data,
    );
  }

  late final _TWDataDeletePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWData>)>>(
          'TWDataDelete');
  late final _TWDataDelete =
      _TWDataDeletePtr.asFunction<void Function(ffi.Pointer<TWData>)>();

  /// Determines whether two data blocks are equal.
  ///
  /// \param lhs left non null block of data to be compared
  /// \param rhs right non null block of data to be compared
  /// \return true if both block of data are equal, false otherwise
  bool TWDataEqual(
    ffi.Pointer<TWData> lhs,
    ffi.Pointer<TWData> rhs,
  ) {
    return _TWDataEqual(
      lhs,
      rhs,
    );
  }

  late final _TWDataEqualPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(
              ffi.Pointer<TWData>, ffi.Pointer<TWData>)>>('TWDataEqual');
  late final _TWDataEqual = _TWDataEqualPtr.asFunction<
      bool Function(ffi.Pointer<TWData>, ffi.Pointer<TWData>)>();

  /// Creates a TWString from a null-terminated UTF8 byte array. It must be deleted at the end.
  ///
  /// \param bytes a null-terminated UTF8 byte array.
  ffi.Pointer<TWString> TWStringCreateWithUTF8Bytes(
    ffi.Pointer<Utf8> bytes,
  ) {
    return _TWStringCreateWithUTF8Bytes(
      bytes,
    );
  }

  late final _TWStringCreateWithUTF8BytesPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWString> Function(ffi.Pointer<Utf8>)>>(
      'TWStringCreateWithUTF8Bytes');
  late final _TWStringCreateWithUTF8Bytes = _TWStringCreateWithUTF8BytesPtr
      .asFunction<ffi.Pointer<TWString> Function(ffi.Pointer<Utf8>)>();

  /// Creates a string from a raw byte array and size. It must be deleted at the end.
  ///
  /// \param bytes a raw byte array.
  /// \param size the size of the byte array.
  ffi.Pointer<TWString> TWStringCreateWithRawBytes(
    ffi.Pointer<ffi.Uint8> bytes,
    int size,
  ) {
    return _TWStringCreateWithRawBytes(
      bytes,
      size,
    );
  }

  late final _TWStringCreateWithRawBytesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<ffi.Uint8>, ffi.Size)>>('TWStringCreateWithRawBytes');
  late final _TWStringCreateWithRawBytes =
      _TWStringCreateWithRawBytesPtr.asFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<ffi.Uint8>, int)>();

  /// Creates a hexadecimal string from a block of data. It must be deleted at the end.
  ///
  /// \param data a block of data.
  ffi.Pointer<TWString> TWStringCreateWithHexData(
    ffi.Pointer<TWData> data,
  ) {
    return _TWStringCreateWithHexData(
      data,
    );
  }

  late final _TWStringCreateWithHexDataPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWString> Function(ffi.Pointer<TWData>)>>(
      'TWStringCreateWithHexData');
  late final _TWStringCreateWithHexData = _TWStringCreateWithHexDataPtr
      .asFunction<ffi.Pointer<TWString> Function(ffi.Pointer<TWData>)>();

  /// Returns the string size in bytes.
  ///
  /// \param string a TWString pointer.
  int TWStringSize(
    ffi.Pointer<TWString> string,
  ) {
    return _TWStringSize(
      string,
    );
  }

  late final _TWStringSizePtr =
      _lookup<ffi.NativeFunction<ffi.Size Function(ffi.Pointer<TWString>)>>(
          'TWStringSize');
  late final _TWStringSize =
      _TWStringSizePtr.asFunction<int Function(ffi.Pointer<TWString>)>();

  /// Returns the byte at the provided index.
  ///
  /// \param string a TWString pointer.
  /// \param index the index of the byte.
  int TWStringGet(
    ffi.Pointer<TWString> string,
    int index,
  ) {
    return _TWStringGet(
      string,
      index,
    );
  }

  late final _TWStringGetPtr = _lookup<
      ffi.NativeFunction<
          ffi.Char Function(ffi.Pointer<TWString>, ffi.Size)>>('TWStringGet');
  late final _TWStringGet =
      _TWStringGetPtr.asFunction<int Function(ffi.Pointer<TWString>, int)>();

  /// Returns the raw pointer to the string's UTF8 bytes (null-terminated).
  ///
  /// \param string a TWString pointer.
  ffi.Pointer<TWString> TWStringUTF8Bytes(
    ffi.Pointer<TWString> string,
  ) {
    return _TWStringUTF8Bytes(
      string,
    );
  }

  late final _TWStringUTF8BytesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWString>)>>('TWStringUTF8Bytes');
  late final _TWStringUTF8Bytes = _TWStringUTF8BytesPtr.asFunction<
      ffi.Pointer<TWString> Function(ffi.Pointer<TWString>)>();

  /// Deletes a string created with a `TWStringCreate*` method and frees the memory.
  ///
  /// \param string a TWString pointer.
  void TWStringDelete(
    ffi.Pointer<TWString> string,
  ) {
    return _TWStringDelete(
      string,
    );
  }

  late final _TWStringDeletePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWString>)>>(
          'TWStringDelete');
  late final _TWStringDelete =
      _TWStringDeletePtr.asFunction<void Function(ffi.Pointer<TWString>)>();

  /// Determines whether two string blocks are equal.
  ///
  /// \param lhs a TWString pointer.
  /// \param rhs another TWString pointer.
  bool TWStringEqual(
    ffi.Pointer<TWString> lhs,
    ffi.Pointer<TWString> rhs,
  ) {
    return _TWStringEqual(
      lhs,
      rhs,
    );
  }

  late final _TWStringEqualPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(
              ffi.Pointer<TWString>, ffi.Pointer<TWString>)>>('TWStringEqual');
  late final _TWStringEqual = _TWStringEqualPtr.asFunction<
      bool Function(ffi.Pointer<TWString>, ffi.Pointer<TWString>)>();

  /// Converts a Filecoin address to Ethereum.
  ///
  /// \param filecoinAddress: a Filecoin address.
  /// \returns the Ethereum address. On invalid input empty string is returned. Returned object needs to be deleted after use.
  ffi.Pointer<TWString> TWFilecoinAddressConverterConvertToEthereum(
    ffi.Pointer<TWString> filecoinAddress,
  ) {
    return _TWFilecoinAddressConverterConvertToEthereum(
      filecoinAddress,
    );
  }

  late final _TWFilecoinAddressConverterConvertToEthereumPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWString> Function(ffi.Pointer<TWString>)>>(
      'TWFilecoinAddressConverterConvertToEthereum');
  late final _TWFilecoinAddressConverterConvertToEthereum =
      _TWFilecoinAddressConverterConvertToEthereumPtr.asFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWString>)>();

  /// Converts an Ethereum address to Filecoin.
  ///
  /// \param ethAddress: an Ethereum address.
  /// \returns the Filecoin address. On invalid input empty string is returned. Returned object needs to be deleted after use.
  ffi.Pointer<TWString> TWFilecoinAddressConverterConvertFromEthereum(
    ffi.Pointer<TWString> ethAddress,
  ) {
    return _TWFilecoinAddressConverterConvertFromEthereum(
      ethAddress,
    );
  }

  late final _TWFilecoinAddressConverterConvertFromEthereumPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWString> Function(ffi.Pointer<TWString>)>>(
      'TWFilecoinAddressConverterConvertFromEthereum');
  late final _TWFilecoinAddressConverterConvertFromEthereum =
      _TWFilecoinAddressConverterConvertFromEthereumPtr.asFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWString>)>();

  /// Determine if the HD Version is public
  ///
  /// \param version HD version
  /// \return true if the version is public, false otherwise
  bool TWHDVersionIsPublic(
    int version,
  ) {
    return _TWHDVersionIsPublic(
      version,
    );
  }

  late final _TWHDVersionIsPublicPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Int32)>>(
          'TWHDVersionIsPublic');
  late final _TWHDVersionIsPublic =
      _TWHDVersionIsPublicPtr.asFunction<bool Function(int)>();

  /// Determine if the HD Version is private
  ///
  /// \param version HD version
  /// \return true if the version is private, false otherwise
  bool TWHDVersionIsPrivate(
    int version,
  ) {
    return _TWHDVersionIsPrivate(
      version,
    );
  }

  late final _TWHDVersionIsPrivatePtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Int32)>>(
          'TWHDVersionIsPrivate');
  late final _TWHDVersionIsPrivate =
      _TWHDVersionIsPrivatePtr.asFunction<bool Function(int)>();

  ffi.Pointer<Utf8> GeniusSDKInit(
    ffi.Pointer<Utf8> base_path,
    ffi.Pointer<Utf8> eth_private_key,
    bool autodht,
    bool process,
    int baseport,
  ) {
    return _GeniusSDKInit(
      base_path,
      eth_private_key,
      autodht ? 1 : 0,
      process ? 1 : 0,
      baseport,
    );
  }

  late final _GeniusSDKInitPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>,
              ffi.Int32, ffi.Int32, ffi.Int32)>>('GeniusSDKInit');
  late final _GeniusSDKInit = _GeniusSDKInitPtr.asFunction<
      ffi.Pointer<Utf8> Function(
          ffi.Pointer<Utf8>, ffi.Pointer<Utf8>, int, int, int)>();

  void GeniusSDKProcess(ffi.Pointer<ffi.Char> jsondata) {
    _GeniusSDKProcess(jsondata);
  }

  late final _GeniusSDKProcessPtr = _lookup<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char> jsondata)>>(
      'GeniusSDKProcess');
  late final _GeniusSDKProcess = _GeniusSDKProcessPtr.asFunction<
      void Function(ffi.Pointer<ffi.Char> jsondata)>();

  int GeniusSDKGetBalance() {
    return _GeniusSDKGetBalance();
  }

  late final _GeniusSDKGetBalancePtr =
      _lookup<ffi.NativeFunction<ffi.Uint64 Function()>>('GeniusSDKGetBalance');
  late final _GeniusSDKGetBalance =
      _GeniusSDKGetBalancePtr.asFunction<int Function()>();

  GeniusTokenValue GeniusSDKGetBalanceAsString() {
    return _GeniusSDKGetBalanceAsString();
  }

  late final _GeniusSDKGetBalanceAsStringPtr =
      _lookup<ffi.NativeFunction<GeniusTokenValue Function()>>(
          'GeniusSDKGetBalanceAsString');
  late final _GeniusSDKGetBalanceAsString =
      _GeniusSDKGetBalanceAsStringPtr.asFunction<GeniusTokenValue Function()>();

  int GeniusSDKGetCost(ffi.Pointer<ffi.Char> jsondata) {
    return _GeniusSDKGetCost(jsondata);
  }

  late final _GeniusSDKGetCostPtr = _lookup<
          ffi
          .NativeFunction<ffi.Uint64 Function(ffi.Pointer<ffi.Char> jsondata)>>(
      'GeniusSDKGetCost');
  late final _GeniusSDKGetCost = _GeniusSDKGetCostPtr.asFunction<
      int Function(ffi.Pointer<ffi.Char> jsondata)>();

  GeniusTokenValue GeniusSDKGetCostAsString(ffi.Pointer<ffi.Char> jsondata) {
    return _GeniusSDKGetCostAsString(jsondata);
  }

  late final _GeniusSDKGetCostAsStringPtr = _lookup<
      ffi.NativeFunction<GeniusTokenValue Function(ffi.Pointer<ffi.Char>)>>(
    'GeniusSDKGetCostAsString',
  );
  late final _GeniusSDKGetCostAsString = _GeniusSDKGetCostAsStringPtr
      .asFunction<GeniusTokenValue Function(ffi.Pointer<ffi.Char>)>();

  GeniusMatrix GeniusSDKGetOutTransactions() {
    return _GeniusSDKGetOutTransactions();
  }

  late final _GeniusSDKGetOutTransactionsPtr =
      _lookup<ffi.NativeFunction<GeniusMatrix Function()>>(
          'GeniusSDKGetOutTransactions');
  late final _GeniusSDKGetOutTransactions =
      _GeniusSDKGetOutTransactionsPtr.asFunction<GeniusMatrix Function()>();

  void GeniusSDKFreeTransactions(
    GeniusMatrix matrix,
  ) {
    return _GeniusSDKFreeTransactions(
      matrix,
    );
  }

  late final _GeniusSDKFreeTransactionsPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(GeniusMatrix)>>(
          'GeniusSDKFreeTransactions');
  late final _GeniusSDKFreeTransactions =
      _GeniusSDKFreeTransactionsPtr.asFunction<void Function(GeniusMatrix)>();

  void GeniusSDKShutdown() {
    return _GeniusSDKShutdown();
  }

  late final _GeniusSDKShutdownPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('GeniusSDKShutdown');
  late final _GeniusSDKShutdown =
      _GeniusSDKShutdownPtr.asFunction<void Function()>();

  void GeniusSDKMintTokens(int amount, ffi.Pointer<Utf8> transaction_hash,
      ffi.Pointer<Utf8> chain_id, ffi.Pointer<Utf8> token_id) {
    return _GeniusSDKMintTokens(amount, transaction_hash, chain_id, token_id);
  }

  late final _GeniusSDKMintTokensPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Uint64, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>,
              ffi.Pointer<Utf8>)>>('GeniusSDKMintTokens');
  late final _GeniusSDKMintTokens = _GeniusSDKMintTokensPtr.asFunction<
      void Function(
          int, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>();

  void GeniusSDKMintTokensWithString(
    ffi.Pointer<GeniusTokenValue> gnus,
    ffi.Pointer<Utf8> transaction_hash,
    ffi.Pointer<Utf8> chain_id,
    ffi.Pointer<Utf8> token_id,
  ) {
    return _GeniusSDKMintTokensWithString(
        gnus, transaction_hash, chain_id, token_id);
  }

  late final _GeniusSDKMintTokensWithStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<GeniusTokenValue>,
              ffi.Pointer<Utf8>,
              ffi.Pointer<Utf8>,
              ffi.Pointer<Utf8>)>>('GeniusSDKMintTokensWithString');
  late final _GeniusSDKMintTokensWithString =
      _GeniusSDKMintTokensWithStringPtr.asFunction<
          void Function(ffi.Pointer<GeniusTokenValue>, ffi.Pointer<Utf8>,
              ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>();

  GeniusAddress GeniusSDKGetAddress() {
    return _GeniusSDKGetAddress();
  }

  late final _GeniusSDKGetAddressPtr =
      _lookup<ffi.NativeFunction<GeniusAddress Function()>>(
          'GeniusSDKGetAddress');
  late final _GeniusSDKGetAddress =
      _GeniusSDKGetAddressPtr.asFunction<GeniusAddress Function()>();

  bool GeniusSDKTransferTokens(
    int amount,
    ffi.Pointer<GeniusAddress> dest,
  ) {
    return _GeniusSDKTransferTokens(
      amount,
      dest,
    );
  }

  late final _GeniusSDKTransferTokensPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Uint64,
              ffi.Pointer<GeniusAddress>)>>('GeniusSDKTransferTokens');
  late final _GeniusSDKTransferTokens = _GeniusSDKTransferTokensPtr.asFunction<
      bool Function(int, ffi.Pointer<GeniusAddress>)>();

  bool GeniusSDKTransferTokensWithString(
    ffi.Pointer<GeniusTokenValue> gnus,
    ffi.Pointer<GeniusAddress> dest,
  ) {
    return _GeniusSDKTransferTokensWithString(gnus, dest);
  }

  late final _GeniusSDKTransferTokensWithStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(
              ffi.Pointer<GeniusTokenValue>, ffi.Pointer<GeniusAddress>)>>(
    'GeniusSDKTransferTokensWithString',
  );
  late final _GeniusSDKTransferTokensWithString =
      _GeniusSDKTransferTokensWithStringPtr.asFunction<
          bool Function(
              ffi.Pointer<GeniusTokenValue>, ffi.Pointer<GeniusAddress>)>();

  int GeniusSDKToMinions(
    ffi.Pointer<GeniusTokenValue> gnus,
  ) {
    return _GeniusSDKToMinions(gnus);
  }

  late final _GeniusSDKToMinionsPtr = _lookup<
      ffi.NativeFunction<ffi.Uint64 Function(ffi.Pointer<GeniusTokenValue>)>>(
    'GeniusSDKToMinions',
  );
  late final _GeniusSDKToMinions = _GeniusSDKToMinionsPtr.asFunction<
      int Function(ffi.Pointer<GeniusTokenValue>)>();

  GeniusTokenValue GeniusSDKToGenius(int minions) {
    return _GeniusSDKToGenius(minions);
  }

  late final _GeniusSDKToGeniusPtr =
      _lookup<ffi.NativeFunction<GeniusTokenValue Function(ffi.Uint64)>>(
    'GeniusSDKToGenius',
  );
  late final _GeniusSDKToGenius =
      _GeniusSDKToGeniusPtr.asFunction<GeniusTokenValue Function(int)>();

  ffi.Pointer<ffi.Char> stringForHRP(
    int hrp,
  ) {
    return _stringForHRP(
      hrp,
    );
  }

  late final _stringForHRPPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Int32)>>(
          'stringForHRP');
  late final _stringForHRP =
      _stringForHRPPtr.asFunction<ffi.Pointer<ffi.Char> Function(int)>();

  int hrpForString(
    ffi.Pointer<ffi.Char> string,
  ) {
    return _hrpForString(
      string,
    );
  }

  late final _hrpForStringPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<ffi.Char>)>>(
          'hrpForString');
  late final _hrpForString =
      _hrpForStringPtr.asFunction<int Function(ffi.Pointer<ffi.Char>)>();

  /// Returns the blockchain for a coin type.
  ///
  /// \param coin A coin type
  /// \return blockchain associated to the given coin type
  int TWCoinTypeBlockchain(
    int coin,
  ) {
    return _TWCoinTypeBlockchain(
      coin,
    );
  }

  late final _TWCoinTypeBlockchainPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypeBlockchain');
  late final _TWCoinTypeBlockchain =
      _TWCoinTypeBlockchainPtr.asFunction<int Function(int)>();

  /// Returns the purpose for a coin type.
  ///
  /// \param coin A coin type
  /// \return purpose associated to the given coin type
  int TWCoinTypePurpose(
    int coin,
  ) {
    return _TWCoinTypePurpose(
      coin,
    );
  }

  late final _TWCoinTypePurposePtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypePurpose');
  late final _TWCoinTypePurpose =
      _TWCoinTypePurposePtr.asFunction<int Function(int)>();

  /// Returns the curve that should be used for a coin type.
  ///
  /// \param coin A coin type
  /// \return curve that should be used for the given coin type
  int TWCoinTypeCurve(
    int coin,
  ) {
    return _TWCoinTypeCurve(
      coin,
    );
  }

  late final _TWCoinTypeCurvePtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypeCurve');
  late final _TWCoinTypeCurve =
      _TWCoinTypeCurvePtr.asFunction<int Function(int)>();

  /// Returns the xpub HD version that should be used for a coin type.
  ///
  /// \param coin A coin type
  /// \return xpub HD version that should be used for the given coin type
  int TWCoinTypeXpubVersion(
    int coin,
  ) {
    return _TWCoinTypeXpubVersion(
      coin,
    );
  }

  late final _TWCoinTypeXpubVersionPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypeXpubVersion');
  late final _TWCoinTypeXpubVersion =
      _TWCoinTypeXpubVersionPtr.asFunction<int Function(int)>();

  /// Returns the xprv HD version that should be used for a coin type.
  ///
  /// \param coin A coin type
  /// \return the xprv HD version that should be used for the given coin type.
  int TWCoinTypeXprvVersion(
    int coin,
  ) {
    return _TWCoinTypeXprvVersion(
      coin,
    );
  }

  late final _TWCoinTypeXprvVersionPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypeXprvVersion');
  late final _TWCoinTypeXprvVersion =
      _TWCoinTypeXprvVersionPtr.asFunction<int Function(int)>();

  /// Validates an address string.
  ///
  /// \param coin A coin type
  /// \param address A public address
  /// \return true if the address is a valid public address of the given coin, false otherwise.
  bool TWCoinTypeValidate(
    int coin,
    ffi.Pointer<TWString1> address,
  ) {
    return _TWCoinTypeValidate(
      coin,
      address,
    );
  }

  late final _TWCoinTypeValidatePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(
              ffi.Int32, ffi.Pointer<TWString1>)>>('TWCoinTypeValidate');
  late final _TWCoinTypeValidate = _TWCoinTypeValidatePtr.asFunction<
      bool Function(int, ffi.Pointer<TWString1>)>();

  /// Returns the default derivation path for a particular coin.
  ///
  /// \param coin A coin type
  /// \return the default derivation path for the given coin type.
  ffi.Pointer<TWString1> TWCoinTypeDerivationPath(
    int coin,
  ) {
    return _TWCoinTypeDerivationPath(
      coin,
    );
  }

  late final _TWCoinTypeDerivationPathPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWString1> Function(ffi.Int32)>>(
          'TWCoinTypeDerivationPath');
  late final _TWCoinTypeDerivationPath = _TWCoinTypeDerivationPathPtr
      .asFunction<ffi.Pointer<TWString1> Function(int)>();

  /// Returns the derivation path for a particular coin with the explicit given derivation.
  ///
  /// \param coin A coin type
  /// \param derivation A derivation type
  /// \return the derivation path for the given coin with the explicit given derivation
  ffi.Pointer<TWString1> TWCoinTypeDerivationPathWithDerivation(
    int coin,
    int derivation,
  ) {
    return _TWCoinTypeDerivationPathWithDerivation(
      coin,
      derivation,
    );
  }

  late final _TWCoinTypeDerivationPathWithDerivationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Int32, ffi.Int32)>>('TWCoinTypeDerivationPathWithDerivation');
  late final _TWCoinTypeDerivationPathWithDerivation =
      _TWCoinTypeDerivationPathWithDerivationPtr.asFunction<
          ffi.Pointer<TWString1> Function(int, int)>();

  /// Derives the address for a particular coin from the private key.
  ///
  /// \param coin A coin type
  /// \param privateKey A valid private key
  /// \return Derived address for the given coin from the private key.
  ffi.Pointer<TWString1> TWCoinTypeDeriveAddress(
    int coin,
    ffi.Pointer<TWPrivateKey> privateKey,
  ) {
    return _TWCoinTypeDeriveAddress(
      coin,
      privateKey,
    );
  }

  late final _TWCoinTypeDeriveAddressPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(ffi.Int32,
              ffi.Pointer<TWPrivateKey>)>>('TWCoinTypeDeriveAddress');
  late final _TWCoinTypeDeriveAddress = _TWCoinTypeDeriveAddressPtr.asFunction<
      ffi.Pointer<TWString1> Function(int, ffi.Pointer<TWPrivateKey>)>();

  /// Derives the address for a particular coin from the public key.
  ///
  /// \param coin A coin type
  /// \param publicKey A valid public key
  /// \return Derived address for the given coin from the public key.
  ffi.Pointer<TWString1> TWCoinTypeDeriveAddressFromPublicKey(
    int coin,
    ffi.Pointer<TWPublicKey> publicKey,
  ) {
    return _TWCoinTypeDeriveAddressFromPublicKey(
      coin,
      publicKey,
    );
  }

  late final _TWCoinTypeDeriveAddressFromPublicKeyPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWString1> Function(
                  ffi.Int32, ffi.Pointer<TWPublicKey>)>>(
      'TWCoinTypeDeriveAddressFromPublicKey');
  late final _TWCoinTypeDeriveAddressFromPublicKey =
      _TWCoinTypeDeriveAddressFromPublicKeyPtr.asFunction<
          ffi.Pointer<TWString1> Function(int, ffi.Pointer<TWPublicKey>)>();

  /// HRP for this coin type
  ///
  /// \param coin A coin type
  /// \return HRP of the given coin type.
  int TWCoinTypeHRP(
    int coin,
  ) {
    return _TWCoinTypeHRP(
      coin,
    );
  }

  late final _TWCoinTypeHRPPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypeHRP');
  late final _TWCoinTypeHRP = _TWCoinTypeHRPPtr.asFunction<int Function(int)>();

  /// P2PKH prefix for this coin type
  ///
  /// \param coin A coin type
  /// \return P2PKH prefix for the given coin type
  int TWCoinTypeP2pkhPrefix(
    int coin,
  ) {
    return _TWCoinTypeP2pkhPrefix(
      coin,
    );
  }

  late final _TWCoinTypeP2pkhPrefixPtr =
      _lookup<ffi.NativeFunction<ffi.Uint8 Function(ffi.Int32)>>(
          'TWCoinTypeP2pkhPrefix');
  late final _TWCoinTypeP2pkhPrefix =
      _TWCoinTypeP2pkhPrefixPtr.asFunction<int Function(int)>();

  /// P2SH prefix for this coin type
  ///
  /// \param coin A coin type
  /// \return P2SH prefix for the given coin type
  int TWCoinTypeP2shPrefix(
    int coin,
  ) {
    return _TWCoinTypeP2shPrefix(
      coin,
    );
  }

  late final _TWCoinTypeP2shPrefixPtr =
      _lookup<ffi.NativeFunction<ffi.Uint8 Function(ffi.Int32)>>(
          'TWCoinTypeP2shPrefix');
  late final _TWCoinTypeP2shPrefix =
      _TWCoinTypeP2shPrefixPtr.asFunction<int Function(int)>();

  /// Static prefix for this coin type
  ///
  /// \param coin A coin type
  /// \return Static prefix for the given coin type
  int TWCoinTypeStaticPrefix(
    int coin,
  ) {
    return _TWCoinTypeStaticPrefix(
      coin,
    );
  }

  late final _TWCoinTypeStaticPrefixPtr =
      _lookup<ffi.NativeFunction<ffi.Uint8 Function(ffi.Int32)>>(
          'TWCoinTypeStaticPrefix');
  late final _TWCoinTypeStaticPrefix =
      _TWCoinTypeStaticPrefixPtr.asFunction<int Function(int)>();

  /// ChainID for this coin type.
  ///
  /// \param coin A coin type
  /// \return ChainID for the given coin type.
  /// \note Caller must free returned object.
  ffi.Pointer<TWString1> TWCoinTypeChainId(
    int coin,
  ) {
    return _TWCoinTypeChainId(
      coin,
    );
  }

  late final _TWCoinTypeChainIdPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWString1> Function(ffi.Int32)>>(
          'TWCoinTypeChainId');
  late final _TWCoinTypeChainId =
      _TWCoinTypeChainIdPtr.asFunction<ffi.Pointer<TWString1> Function(int)>();

  /// SLIP-0044 id for this coin type
  ///
  /// \param coin A coin type
  /// \return SLIP-0044 id for the given coin type
  int TWCoinTypeSlip44Id(
    int coin,
  ) {
    return _TWCoinTypeSlip44Id(
      coin,
    );
  }

  late final _TWCoinTypeSlip44IdPtr =
      _lookup<ffi.NativeFunction<ffi.Uint32 Function(ffi.Int32)>>(
          'TWCoinTypeSlip44Id');
  late final _TWCoinTypeSlip44Id =
      _TWCoinTypeSlip44IdPtr.asFunction<int Function(int)>();

  /// SS58Prefix for this coin type
  ///
  /// \param coin A coin type
  /// \return SS58Prefix for the given coin type
  int TWCoinTypeSS58Prefix(
    int coin,
  ) {
    return _TWCoinTypeSS58Prefix(
      coin,
    );
  }

  late final _TWCoinTypeSS58PrefixPtr =
      _lookup<ffi.NativeFunction<ffi.Uint32 Function(ffi.Int32)>>(
          'TWCoinTypeSS58Prefix');
  late final _TWCoinTypeSS58Prefix =
      _TWCoinTypeSS58PrefixPtr.asFunction<int Function(int)>();

  /// public key type for this coin type
  ///
  /// \param coin A coin type
  /// \return public key type for the given coin type
  int TWCoinTypePublicKeyType(
    int coin,
  ) {
    return _TWCoinTypePublicKeyType(
      coin,
    );
  }

  late final _TWCoinTypePublicKeyTypePtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32)>>(
          'TWCoinTypePublicKeyType');
  late final _TWCoinTypePublicKeyType =
      _TWCoinTypePublicKeyTypePtr.asFunction<int Function(int)>();

  /// Compares two addresses for equality.
  ///
  /// \param lhs The first address to compare.
  /// \param rhs The second address to compare.
  /// \return bool indicating the addresses are equal.
  bool TWNervosAddressEqual(
    ffi.Pointer<TWNervosAddress> lhs,
    ffi.Pointer<TWNervosAddress> rhs,
  ) {
    return _TWNervosAddressEqual(
      lhs,
      rhs,
    );
  }

  late final _TWNervosAddressEqualPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWNervosAddress>,
              ffi.Pointer<TWNervosAddress>)>>('TWNervosAddressEqual');
  late final _TWNervosAddressEqual = _TWNervosAddressEqualPtr.asFunction<
      bool Function(
          ffi.Pointer<TWNervosAddress>, ffi.Pointer<TWNervosAddress>)>();

  /// Determines if the string is a valid Nervos address.
  ///
  /// \param string string to validate.
  /// \return bool indicating if the address is valid.
  bool TWNervosAddressIsValidString(
    ffi.Pointer<TWString> string,
  ) {
    return _TWNervosAddressIsValidString(
      string,
    );
  }

  late final _TWNervosAddressIsValidStringPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWString>)>>(
          'TWNervosAddressIsValidString');
  late final _TWNervosAddressIsValidString = _TWNervosAddressIsValidStringPtr
      .asFunction<bool Function(ffi.Pointer<TWString>)>();

  /// Initializes an address from a sring representaion.
  ///
  /// \param string Bech32 string to initialize the address from.
  /// \return TWNervosAddress pointer or nullptr if string is invalid.
  ffi.Pointer<TWNervosAddress> TWNervosAddressCreateWithString(
    ffi.Pointer<TWString> string,
  ) {
    return _TWNervosAddressCreateWithString(
      string,
    );
  }

  late final _TWNervosAddressCreateWithStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWNervosAddress> Function(
              ffi.Pointer<TWString>)>>('TWNervosAddressCreateWithString');
  late final _TWNervosAddressCreateWithString =
      _TWNervosAddressCreateWithStringPtr.asFunction<
          ffi.Pointer<TWNervosAddress> Function(ffi.Pointer<TWString>)>();

  /// Deletes a Nervos address.
  ///
  /// \param address Address to delete.
  void TWNervosAddressDelete(
    ffi.Pointer<TWNervosAddress> address,
  ) {
    return _TWNervosAddressDelete(
      address,
    );
  }

  late final _TWNervosAddressDeletePtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWNervosAddress>)>>(
      'TWNervosAddressDelete');
  late final _TWNervosAddressDelete = _TWNervosAddressDeletePtr.asFunction<
      void Function(ffi.Pointer<TWNervosAddress>)>();

  /// Returns the address string representation.
  ///
  /// \param address Address to get the string representation of.
  ffi.Pointer<TWString> TWNervosAddressDescription(
    ffi.Pointer<TWNervosAddress> address,
  ) {
    return _TWNervosAddressDescription(
      address,
    );
  }

  late final _TWNervosAddressDescriptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWNervosAddress>)>>('TWNervosAddressDescription');
  late final _TWNervosAddressDescription =
      _TWNervosAddressDescriptionPtr.asFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWNervosAddress>)>();

  /// Returns the Code hash
  ///
  /// \param address Address to get the keyhash data of.
  ffi.Pointer<TWData> TWNervosAddressCodeHash(
    ffi.Pointer<TWNervosAddress> address,
  ) {
    return _TWNervosAddressCodeHash(
      address,
    );
  }

  late final _TWNervosAddressCodeHashPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(
              ffi.Pointer<TWNervosAddress>)>>('TWNervosAddressCodeHash');
  late final _TWNervosAddressCodeHash = _TWNervosAddressCodeHashPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWNervosAddress>)>();

  /// Returns the address hash type
  ///
  /// \param address Address to get the hash type of.
  ffi.Pointer<TWString> TWNervosAddressHashType(
    ffi.Pointer<TWNervosAddress> address,
  ) {
    return _TWNervosAddressHashType(
      address,
    );
  }

  late final _TWNervosAddressHashTypePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWNervosAddress>)>>('TWNervosAddressHashType');
  late final _TWNervosAddressHashType = _TWNervosAddressHashTypePtr.asFunction<
      ffi.Pointer<TWString> Function(ffi.Pointer<TWNervosAddress>)>();

  /// Returns the address args data.
  ///
  /// \param address Address to get the args data of.
  ffi.Pointer<TWData> TWNervosAddressArgs(
    ffi.Pointer<TWNervosAddress> address,
  ) {
    return _TWNervosAddressArgs(
      address,
    );
  }

  late final _TWNervosAddressArgsPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(
              ffi.Pointer<TWNervosAddress>)>>('TWNervosAddressArgs');
  late final _TWNervosAddressArgs = _TWNervosAddressArgsPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWNervosAddress>)>();

  /// Creates a Vector of Data.
  ///
  /// \note Must be deleted with \TWDataVectorDelete
  /// \return a non-null Vector of Data.
  ffi.Pointer<TWDataVector> TWDataVectorCreate() {
    return _TWDataVectorCreate();
  }

  late final _TWDataVectorCreatePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWDataVector> Function()>>(
          'TWDataVectorCreate');
  late final _TWDataVectorCreate =
      _TWDataVectorCreatePtr.asFunction<ffi.Pointer<TWDataVector> Function()>();

  /// Creates a Vector of Data with the given element
  ///
  /// \param data A non-null valid block of data
  /// \return A Vector of data with a single given element
  ffi.Pointer<TWDataVector> TWDataVectorCreateWithData(
    ffi.Pointer<TWData1> data,
  ) {
    return _TWDataVectorCreateWithData(
      data,
    );
  }

  late final _TWDataVectorCreateWithDataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWDataVector> Function(
              ffi.Pointer<TWData1>)>>('TWDataVectorCreateWithData');
  late final _TWDataVectorCreateWithData = _TWDataVectorCreateWithDataPtr
      .asFunction<ffi.Pointer<TWDataVector> Function(ffi.Pointer<TWData1>)>();

  /// Delete/Deallocate a Vector of Data
  ///
  /// \param dataVector A non-null Vector of data
  void TWDataVectorDelete(
    ffi.Pointer<TWDataVector> dataVector,
  ) {
    return _TWDataVectorDelete(
      dataVector,
    );
  }

  late final _TWDataVectorDeletePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWDataVector>)>>(
          'TWDataVectorDelete');
  late final _TWDataVectorDelete = _TWDataVectorDeletePtr.asFunction<
      void Function(ffi.Pointer<TWDataVector>)>();

  /// Add an element to a Vector of Data. Element is cloned
  ///
  /// \param dataVector A non-null Vector of data
  /// \param data A non-null valid block of data
  /// \note data input parameter must be deleted on its own
  void TWDataVectorAdd(
    ffi.Pointer<TWDataVector> dataVector,
    ffi.Pointer<TWData1> data,
  ) {
    return _TWDataVectorAdd(
      dataVector,
      data,
    );
  }

  late final _TWDataVectorAddPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<TWDataVector>,
              ffi.Pointer<TWData1>)>>('TWDataVectorAdd');
  late final _TWDataVectorAdd = _TWDataVectorAddPtr.asFunction<
      void Function(ffi.Pointer<TWDataVector>, ffi.Pointer<TWData1>)>();

  /// Retrieve the number of elements
  ///
  /// \param dataVector A non-null Vector of data
  /// \return the size of the given vector.
  int TWDataVectorSize(
    ffi.Pointer<TWDataVector> dataVector,
  ) {
    return _TWDataVectorSize(
      dataVector,
    );
  }

  late final _TWDataVectorSizePtr =
      _lookup<ffi.NativeFunction<ffi.Size Function(ffi.Pointer<TWDataVector>)>>(
          'TWDataVectorSize');
  late final _TWDataVectorSize = _TWDataVectorSizePtr.asFunction<
      int Function(ffi.Pointer<TWDataVector>)>();

  /// Retrieve the n-th element.
  ///
  /// \param dataVector A non-null Vector of data
  /// \param index index element of the vector to be retrieved, need to be < TWDataVectorSize
  /// \note Returned element must be freed with \TWDataDelete
  /// \return A non-null block of data
  ffi.Pointer<TWData1> TWDataVectorGet(
    ffi.Pointer<TWDataVector> dataVector,
    int index,
  ) {
    return _TWDataVectorGet(
      dataVector,
      index,
    );
  }

  late final _TWDataVectorGetPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWDataVector>, ffi.Size)>>('TWDataVectorGet');
  late final _TWDataVectorGet = _TWDataVectorGetPtr.asFunction<
      ffi.Pointer<TWData1> Function(ffi.Pointer<TWDataVector>, int)>();

  /// Builds a coin-specific SigningInput (proto object) from a simple transaction.
  ///
  /// \param coin coin type.
  /// \param from sender of the transaction.
  /// \param to receiver of the transaction.
  /// \param amount transaction amount in string
  /// \param asset optional asset name, like "BNB"
  /// \param memo optional memo
  /// \param chainId optional chainId to override default
  /// \return serialized data of the SigningInput proto object.
  ffi.Pointer<TWData1> TWTransactionCompilerBuildInput(
    int coinType,
    ffi.Pointer<TWString1> from,
    ffi.Pointer<TWString1> to,
    ffi.Pointer<TWString1> amount,
    ffi.Pointer<TWString1> asset,
    ffi.Pointer<TWString1> memo,
    ffi.Pointer<TWString1> chainId,
  ) {
    return _TWTransactionCompilerBuildInput(
      coinType,
      from,
      to,
      amount,
      asset,
      memo,
      chainId,
    );
  }

  late final _TWTransactionCompilerBuildInputPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Int32,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>)>>('TWTransactionCompilerBuildInput');
  late final _TWTransactionCompilerBuildInput =
      _TWTransactionCompilerBuildInputPtr.asFunction<
          ffi.Pointer<TWData1> Function(
              int,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>)>();

  /// Obtains pre-signing hashes of a transaction.
  ///
  /// We provide a default `PreSigningOutput` in TransactionCompiler.proto.
  /// For some special coins, such as bitcoin, we will create a custom `PreSigningOutput` object in its proto file.
  /// \param coin coin type.
  /// \param txInputData The serialized data of a signing input
  /// \return serialized data of a proto object `PreSigningOutput` includes hash.
  ffi.Pointer<TWData1> TWTransactionCompilerPreImageHashes(
    int coinType,
    ffi.Pointer<TWData1> txInputData,
  ) {
    return _TWTransactionCompilerPreImageHashes(
      coinType,
      txInputData,
    );
  }

  late final _TWTransactionCompilerPreImageHashesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(ffi.Int32,
              ffi.Pointer<TWData1>)>>('TWTransactionCompilerPreImageHashes');
  late final _TWTransactionCompilerPreImageHashes =
      _TWTransactionCompilerPreImageHashesPtr.asFunction<
          ffi.Pointer<TWData1> Function(int, ffi.Pointer<TWData1>)>();

  /// Compiles a complete transation with one or more external signatures.
  ///
  /// Puts together from transaction input and provided public keys and signatures. The signatures must match the hashes
  /// returned by TWTransactionCompilerPreImageHashes, in the same order. The publicKeyHash attached
  /// to the hashes enable identifying the private key needed for signing the hash.
  /// \param coin coin type.
  /// \param txInputData The serialized data of a signing input.
  /// \param signatures signatures to compile, using TWDataVector.
  /// \param publicKeys public keys for signers to match private keys, using TWDataVector.
  /// \return serialized data of a proto object `SigningOutput`.
  ffi.Pointer<TWData1> TWTransactionCompilerCompileWithSignatures(
    int coinType,
    ffi.Pointer<TWData1> txInputData,
    ffi.Pointer<TWDataVector> signatures,
    ffi.Pointer<TWDataVector> publicKeys,
  ) {
    return _TWTransactionCompilerCompileWithSignatures(
      coinType,
      txInputData,
      signatures,
      publicKeys,
    );
  }

  late final _TWTransactionCompilerCompileWithSignaturesPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWData1> Function(ffi.Int32, ffi.Pointer<TWData1>,
                  ffi.Pointer<TWDataVector>, ffi.Pointer<TWDataVector>)>>(
      'TWTransactionCompilerCompileWithSignatures');
  late final _TWTransactionCompilerCompileWithSignatures =
      _TWTransactionCompilerCompileWithSignaturesPtr.asFunction<
          ffi.Pointer<TWData1> Function(int, ffi.Pointer<TWData1>,
              ffi.Pointer<TWDataVector>, ffi.Pointer<TWDataVector>)>();

  /// Signs a transaction specified by the signing input and coin type.
  ///
  /// \param input The serialized data of a signing input (e.g. TW.Bitcoin.Proto.SigningInput).
  /// \param coin The given coin type to sign the transaction for.
  /// \return The serialized data of a `SigningOutput` proto object. (e.g. TW.Bitcoin.Proto.SigningOutput).
  ffi.Pointer<TWData1> TWAnySignerSign(
    ffi.Pointer<TWData1> input,
    int coin,
  ) {
    return _TWAnySignerSign(
      input,
      coin,
    );
  }

  late final _TWAnySignerSignPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWData1>, ffi.Int32)>>('TWAnySignerSign');
  late final _TWAnySignerSign = _TWAnySignerSignPtr.asFunction<
      ffi.Pointer<TWData1> Function(ffi.Pointer<TWData1>, int)>();

  /// Signs a transaction specified by the JSON representation of signing input, coin type and a private key, returning the JSON representation of the signing output.
  ///
  /// \param json JSON representation of a signing input
  /// \param key The private key to sign with.
  /// \param coin The given coin type to sign the transaction for.
  /// \return The JSON representation of a `SigningOutput` proto object.
  ffi.Pointer<TWString1> TWAnySignerSignJSON(
    ffi.Pointer<TWString1> json,
    ffi.Pointer<TWData1> key,
    int coin,
  ) {
    return _TWAnySignerSignJSON(
      json,
      key,
      coin,
    );
  }

  late final _TWAnySignerSignJSONPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWString1>,
              ffi.Pointer<TWData1>, ffi.Int32)>>('TWAnySignerSignJSON');
  late final _TWAnySignerSignJSON = _TWAnySignerSignJSONPtr.asFunction<
      ffi.Pointer<TWString1> Function(
          ffi.Pointer<TWString1>, ffi.Pointer<TWData1>, int)>();

  /// Check if AnySigner supports signing JSON representation of signing input.
  ///
  /// \param coin The given coin type to sign the transaction for.
  /// \return true if AnySigner supports signing JSON representation of signing input for a given coin.
  bool TWAnySignerSupportsJSON(
    int coin,
  ) {
    return _TWAnySignerSupportsJSON(
      coin,
    );
  }

  late final _TWAnySignerSupportsJSONPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Int32)>>(
          'TWAnySignerSupportsJSON');
  late final _TWAnySignerSupportsJSON =
      _TWAnySignerSupportsJSONPtr.asFunction<bool Function(int)>();

  /// Plans a transaction (for UTXO chains only).
  ///
  /// \param input The serialized data of a signing input
  /// \param coin The given coin type to plan the transaction for.
  /// \return The serialized data of a `TransactionPlan` proto object.
  ffi.Pointer<TWData1> TWAnySignerPlan(
    ffi.Pointer<TWData1> input,
    int coin,
  ) {
    return _TWAnySignerPlan(
      input,
      coin,
    );
  }

  late final _TWAnySignerPlanPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWData1>, ffi.Int32)>>('TWAnySignerPlan');
  late final _TWAnySignerPlan = _TWAnySignerPlanPtr.asFunction<
      ffi.Pointer<TWData1> Function(ffi.Pointer<TWData1>, int)>();

  late final ffi.Pointer<ffi.Size> _TWPublicKeyCompressedSize =
      _lookup<ffi.Size>('TWPublicKeyCompressedSize');

  int get TWPublicKeyCompressedSize => _TWPublicKeyCompressedSize.value;

  set TWPublicKeyCompressedSize(int value) =>
      _TWPublicKeyCompressedSize.value = value;

  late final ffi.Pointer<ffi.Size> _TWPublicKeyUncompressedSize =
      _lookup<ffi.Size>('TWPublicKeyUncompressedSize');

  int get TWPublicKeyUncompressedSize => _TWPublicKeyUncompressedSize.value;

  set TWPublicKeyUncompressedSize(int value) =>
      _TWPublicKeyUncompressedSize.value = value;

  /// Create a public key from a block of data
  ///
  /// \param data Non-null block of data representing the public key
  /// \param type type of the public key
  /// \note Should be deleted with \TWPublicKeyDelete
  /// \return Nullable pointer to the public key
  ffi.Pointer<TWPublicKey> TWPublicKeyCreateWithData(
    ffi.Pointer<TWData> data,
    int type,
  ) {
    return _TWPublicKeyCreateWithData(
      data,
      type,
    );
  }

  late final _TWPublicKeyCreateWithDataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPublicKey> Function(
              ffi.Pointer<TWData>, ffi.Int32)>>('TWPublicKeyCreateWithData');
  late final _TWPublicKeyCreateWithData =
      _TWPublicKeyCreateWithDataPtr.asFunction<
          ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWData>, int)>();

  /// Delete the given public key
  ///
  /// \param pk Non-null pointer to a public key
  void TWPublicKeyDelete(
    ffi.Pointer<TWPublicKey> pk,
  ) {
    return _TWPublicKeyDelete(
      pk,
    );
  }

  late final _TWPublicKeyDeletePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWPublicKey>)>>(
          'TWPublicKeyDelete');
  late final _TWPublicKeyDelete = _TWPublicKeyDeletePtr.asFunction<
      void Function(ffi.Pointer<TWPublicKey>)>();

  /// Determines if the given public key is valid or not
  ///
  /// \param data Non-null block of data representing the public key
  /// \param type type of the public key
  /// \return true if the block of data is a valid public key, false otherwise
  bool TWPublicKeyIsValid(
    ffi.Pointer<TWData> data,
    int type,
  ) {
    return _TWPublicKeyIsValid(
      data,
      type,
    );
  }

  late final _TWPublicKeyIsValidPtr = _lookup<
          ffi
          .NativeFunction<ffi.Bool Function(ffi.Pointer<TWData>, ffi.Int32)>>(
      'TWPublicKeyIsValid');
  late final _TWPublicKeyIsValid = _TWPublicKeyIsValidPtr.asFunction<
      bool Function(ffi.Pointer<TWData>, int)>();

  /// Determines if the given public key is compressed or not
  ///
  /// \param pk Non-null pointer to a public key
  /// \return true if the public key is compressed, false otherwise
  bool TWPublicKeyIsCompressed(
    ffi.Pointer<TWPublicKey> pk,
  ) {
    return _TWPublicKeyIsCompressed(
      pk,
    );
  }

  late final _TWPublicKeyIsCompressedPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWPublicKey>)>>(
          'TWPublicKeyIsCompressed');
  late final _TWPublicKeyIsCompressed = _TWPublicKeyIsCompressedPtr.asFunction<
      bool Function(ffi.Pointer<TWPublicKey>)>();

  /// Give the compressed public key of the given non-compressed public key
  ///
  /// \param from Non-null pointer to a non-compressed public key
  /// \return Non-null pointer to the corresponding compressed public-key
  ffi.Pointer<TWPublicKey> TWPublicKeyCompressed(
    ffi.Pointer<TWPublicKey> from,
  ) {
    return _TWPublicKeyCompressed(
      from,
    );
  }

  late final _TWPublicKeyCompressedPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPublicKey> Function(
              ffi.Pointer<TWPublicKey>)>>('TWPublicKeyCompressed');
  late final _TWPublicKeyCompressed = _TWPublicKeyCompressedPtr.asFunction<
      ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPublicKey>)>();

  /// Give the non-compressed public key of a corresponding compressed public key
  ///
  /// \param from Non-null pointer to the corresponding compressed public key
  /// \return Non-null pointer to the corresponding non-compressed public key
  ffi.Pointer<TWPublicKey> TWPublicKeyUncompressed(
    ffi.Pointer<TWPublicKey> from,
  ) {
    return _TWPublicKeyUncompressed(
      from,
    );
  }

  late final _TWPublicKeyUncompressedPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPublicKey> Function(
              ffi.Pointer<TWPublicKey>)>>('TWPublicKeyUncompressed');
  late final _TWPublicKeyUncompressed = _TWPublicKeyUncompressedPtr.asFunction<
      ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPublicKey>)>();

  /// Gives the raw data of a given public-key
  ///
  /// \param pk Non-null pointer to a public key
  /// \return Non-null pointer to the raw block of data of the given public key
  ffi.Pointer<TWData> TWPublicKeyData(
    ffi.Pointer<TWPublicKey> pk,
  ) {
    return _TWPublicKeyData(
      pk,
    );
  }

  late final _TWPublicKeyDataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(
              ffi.Pointer<TWPublicKey>)>>('TWPublicKeyData');
  late final _TWPublicKeyData = _TWPublicKeyDataPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWPublicKey>)>();

  /// Verify the validity of a signature and a message using the given public key
  ///
  /// \param pk Non-null pointer to a public key
  /// \param signature Non-null pointer to a block of data corresponding to the signature
  /// \param message Non-null pointer to a block of data corresponding to the message
  /// \return true if the signature and the message belongs to the given public key, false otherwise
  bool TWPublicKeyVerify(
    ffi.Pointer<TWPublicKey> pk,
    ffi.Pointer<TWData> signature,
    ffi.Pointer<TWData> message,
  ) {
    return _TWPublicKeyVerify(
      pk,
      signature,
      message,
    );
  }

  late final _TWPublicKeyVerifyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWData>,
              ffi.Pointer<TWData>)>>('TWPublicKeyVerify');
  late final _TWPublicKeyVerify = _TWPublicKeyVerifyPtr.asFunction<
      bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWData>,
          ffi.Pointer<TWData>)>();

  /// Verify the validity as DER of a signature and a message using the given public key
  ///
  /// \param pk Non-null pointer to a public key
  /// \param signature Non-null pointer to a block of data corresponding to the signature
  /// \param message Non-null pointer to a block of data corresponding to the message
  /// \return true if the signature and the message belongs to the given public key, false otherwise
  bool TWPublicKeyVerifyAsDER(
    ffi.Pointer<TWPublicKey> pk,
    ffi.Pointer<TWData> signature,
    ffi.Pointer<TWData> message,
  ) {
    return _TWPublicKeyVerifyAsDER(
      pk,
      signature,
      message,
    );
  }

  late final _TWPublicKeyVerifyAsDERPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWData>,
              ffi.Pointer<TWData>)>>('TWPublicKeyVerifyAsDER');
  late final _TWPublicKeyVerifyAsDER = _TWPublicKeyVerifyAsDERPtr.asFunction<
      bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWData>,
          ffi.Pointer<TWData>)>();

  /// Verify a Zilliqa schnorr signature with a signature and message.
  ///
  /// \param pk Non-null pointer to a public key
  /// \param signature Non-null pointer to a block of data corresponding to the signature
  /// \param message Non-null pointer to a block of data corresponding to the message
  /// \return true if the signature and the message belongs to the given public key, false otherwise
  bool TWPublicKeyVerifyZilliqaSchnorr(
    ffi.Pointer<TWPublicKey> pk,
    ffi.Pointer<TWData> signature,
    ffi.Pointer<TWData> message,
  ) {
    return _TWPublicKeyVerifyZilliqaSchnorr(
      pk,
      signature,
      message,
    );
  }

  late final _TWPublicKeyVerifyZilliqaSchnorrPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWData>,
              ffi.Pointer<TWData>)>>('TWPublicKeyVerifyZilliqaSchnorr');
  late final _TWPublicKeyVerifyZilliqaSchnorr =
      _TWPublicKeyVerifyZilliqaSchnorrPtr.asFunction<
          bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWData>,
              ffi.Pointer<TWData>)>();

  /// Give the public key type (eliptic) of a given public key
  ///
  /// \param publicKey Non-null pointer to a public key
  /// \return The public key type of the given public key (eliptic)
  int TWPublicKeyKeyType(
    ffi.Pointer<TWPublicKey> publicKey,
  ) {
    return _TWPublicKeyKeyType(
      publicKey,
    );
  }

  late final _TWPublicKeyKeyTypePtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<TWPublicKey>)>>(
          'TWPublicKeyKeyType');
  late final _TWPublicKeyKeyType = _TWPublicKeyKeyTypePtr.asFunction<
      int Function(ffi.Pointer<TWPublicKey>)>();

  /// Get the public key description from a given public key
  ///
  /// \param publicKey Non-null pointer to a public key
  /// \return Non-null pointer to a string representing the description of the public key
  ffi.Pointer<TWString> TWPublicKeyDescription(
    ffi.Pointer<TWPublicKey> publicKey,
  ) {
    return _TWPublicKeyDescription(
      publicKey,
    );
  }

  late final _TWPublicKeyDescriptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWPublicKey>)>>('TWPublicKeyDescription');
  late final _TWPublicKeyDescription = _TWPublicKeyDescriptionPtr.asFunction<
      ffi.Pointer<TWString> Function(ffi.Pointer<TWPublicKey>)>();

  /// Try to get a public key from a given signature and a message
  ///
  /// \param signature Non-null pointer to a block of data corresponding to the signature
  /// \param message Non-null pointer to a block of data corresponding to the message
  /// \return Null pointer if the public key can't be recover from the given signature and message,
  /// pointer to the public key otherwise
  ffi.Pointer<TWPublicKey> TWPublicKeyRecover(
    ffi.Pointer<TWData> signature,
    ffi.Pointer<TWData> message,
  ) {
    return _TWPublicKeyRecover(
      signature,
      message,
    );
  }

  late final _TWPublicKeyRecoverPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPublicKey> Function(
              ffi.Pointer<TWData>, ffi.Pointer<TWData>)>>('TWPublicKeyRecover');
  late final _TWPublicKeyRecover = _TWPublicKeyRecoverPtr.asFunction<
      ffi.Pointer<TWPublicKey> Function(
          ffi.Pointer<TWData>, ffi.Pointer<TWData>)>();

  late final ffi.Pointer<ffi.Size> _TWPrivateKeySize =
      _lookup<ffi.Size>('TWPrivateKeySize');

  int get TWPrivateKeySize => _TWPrivateKeySize.value;

  set TWPrivateKeySize(int value) => _TWPrivateKeySize.value = value;

  /// Create a random private key
  ///
  /// \note Should be deleted with \TWPrivateKeyDelete
  /// \return Non-null Private key
  ffi.Pointer<TWPrivateKey> TWPrivateKeyCreate() {
    return _TWPrivateKeyCreate();
  }

  late final _TWPrivateKeyCreatePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWPrivateKey> Function()>>(
          'TWPrivateKeyCreate');
  late final _TWPrivateKeyCreate =
      _TWPrivateKeyCreatePtr.asFunction<ffi.Pointer<TWPrivateKey> Function()>();

  /// Create a private key with the given block of data
  ///
  /// \param data a block of data
  /// \note Should be deleted with \TWPrivateKeyDelete
  /// \return Nullable pointer to Private Key
  ffi.Pointer<TWPrivateKey> TWPrivateKeyCreateWithData(
    ffi.Pointer<TWData> data,
  ) {
    return _TWPrivateKeyCreateWithData(
      data,
    );
  }

  late final _TWPrivateKeyCreateWithDataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPrivateKey> Function(
              ffi.Pointer<TWData>)>>('TWPrivateKeyCreateWithData');
  late final _TWPrivateKeyCreateWithData = _TWPrivateKeyCreateWithDataPtr
      .asFunction<ffi.Pointer<TWPrivateKey> Function(ffi.Pointer<TWData>)>();

  /// Deep copy a given private key
  ///
  /// \param key Non-null private key to be copied
  /// \note Should be deleted with \TWPrivateKeyDelete
  /// \return Deep copy, Nullable pointer to Private key
  ffi.Pointer<TWPrivateKey> TWPrivateKeyCreateCopy(
    ffi.Pointer<TWPrivateKey> key,
  ) {
    return _TWPrivateKeyCreateCopy(
      key,
    );
  }

  late final _TWPrivateKeyCreateCopyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPrivateKey> Function(
              ffi.Pointer<TWPrivateKey>)>>('TWPrivateKeyCreateCopy');
  late final _TWPrivateKeyCreateCopy = _TWPrivateKeyCreateCopyPtr.asFunction<
      ffi.Pointer<TWPrivateKey> Function(ffi.Pointer<TWPrivateKey>)>();

  /// Delete the given private key
  ///
  /// \param pk Non-null pointer to private key
  void TWPrivateKeyDelete(
    ffi.Pointer<TWPrivateKey> pk,
  ) {
    return _TWPrivateKeyDelete(
      pk,
    );
  }

  late final _TWPrivateKeyDeletePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWPrivateKey>)>>(
          'TWPrivateKeyDelete');
  late final _TWPrivateKeyDelete = _TWPrivateKeyDeletePtr.asFunction<
      void Function(ffi.Pointer<TWPrivateKey>)>();

  /// Determines if the given private key is valid or not.
  ///
  /// \param data block of data (private key bytes)
  /// \param curve Eliptic curve of the private key
  /// \return true if the private key is valid, false otherwise
  bool TWPrivateKeyIsValid(
    ffi.Pointer<TWData> data,
    int curve,
  ) {
    return _TWPrivateKeyIsValid(
      data,
      curve,
    );
  }

  late final _TWPrivateKeyIsValidPtr = _lookup<
          ffi
          .NativeFunction<ffi.Bool Function(ffi.Pointer<TWData>, ffi.Int32)>>(
      'TWPrivateKeyIsValid');
  late final _TWPrivateKeyIsValid = _TWPrivateKeyIsValidPtr.asFunction<
      bool Function(ffi.Pointer<TWData>, int)>();

  /// Convert the given private key to raw-bytes block of data
  ///
  /// \param pk Non-null pointer to the private key
  /// \return Non-null block of data (raw bytes) of the given private key
  ffi.Pointer<TWData> TWPrivateKeyData(
    ffi.Pointer<TWPrivateKey> pk,
  ) {
    return _TWPrivateKeyData(
      pk,
    );
  }

  late final _TWPrivateKeyDataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(
              ffi.Pointer<TWPrivateKey>)>>('TWPrivateKeyData');
  late final _TWPrivateKeyData = _TWPrivateKeyDataPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWPrivateKey>)>();

  /// Returns the public key associated with the given coinType and privateKey
  ///
  /// \param pk Non-null pointer to the private key
  /// \param coinType coinType of the given private key
  /// \return Non-null pointer to the corresponding public key
  ffi.Pointer<TWPublicKey> TWPrivateKeyGetPublicKey(
    ffi.Pointer<TWPrivateKey> pk,
    int coinType,
  ) {
    return _TWPrivateKeyGetPublicKey(
      pk,
      coinType,
    );
  }

  late final _TWPrivateKeyGetPublicKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>,
              ffi.Int32)>>('TWPrivateKeyGetPublicKey');
  late final _TWPrivateKeyGetPublicKey =
      _TWPrivateKeyGetPublicKeyPtr.asFunction<
          ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>, int)>();

  /// Returns the public key associated with the given pubkeyType and privateKey
  ///
  /// \param pk Non-null pointer to the private key
  /// \param pubkeyType pubkeyType of the given private key
  /// \return Non-null pointer to the corresponding public key
  ffi.Pointer<TWPublicKey> TWPrivateKeyGetPublicKeyByType(
    ffi.Pointer<TWPrivateKey> pk,
    int pubkeyType,
  ) {
    return _TWPrivateKeyGetPublicKeyByType(
      pk,
      pubkeyType,
    );
  }

  late final _TWPrivateKeyGetPublicKeyByTypePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>,
              ffi.Int32)>>('TWPrivateKeyGetPublicKeyByType');
  late final _TWPrivateKeyGetPublicKeyByType =
      _TWPrivateKeyGetPublicKeyByTypePtr.asFunction<
          ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>, int)>();

  /// Returns the Secp256k1 public key associated with the given private key
  ///
  /// \param pk Non-null pointer to the private key
  /// \param compressed if the given private key is compressed or not
  /// \return Non-null pointer to the corresponding public key
  ffi.Pointer<TWPublicKey> TWPrivateKeyGetPublicKeySecp256k1(
    ffi.Pointer<TWPrivateKey> pk,
    bool compressed,
  ) {
    return _TWPrivateKeyGetPublicKeySecp256k1(
      pk,
      compressed,
    );
  }

  late final _TWPrivateKeyGetPublicKeySecp256k1Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>,
              ffi.Bool)>>('TWPrivateKeyGetPublicKeySecp256k1');
  late final _TWPrivateKeyGetPublicKeySecp256k1 =
      _TWPrivateKeyGetPublicKeySecp256k1Ptr.asFunction<
          ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>, bool)>();

  /// Returns the Nist256p1 public key associated with the given private key
  ///
  /// \param pk Non-null pointer to the private key
  /// \return Non-null pointer to the corresponding public key
  ffi.Pointer<TWPublicKey> TWPrivateKeyGetPublicKeyNist256p1(
    ffi.Pointer<TWPrivateKey> pk,
  ) {
    return _TWPrivateKeyGetPublicKeyNist256p1(
      pk,
    );
  }

  late final _TWPrivateKeyGetPublicKeyNist256p1Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPublicKey> Function(
              ffi.Pointer<TWPrivateKey>)>>('TWPrivateKeyGetPublicKeyNist256p1');
  late final _TWPrivateKeyGetPublicKeyNist256p1 =
      _TWPrivateKeyGetPublicKeyNist256p1Ptr.asFunction<
          ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>)>();

  /// Returns the Ed25519 public key associated with the given private key
  ///
  /// \param pk Non-null pointer to the private key
  /// \return Non-null pointer to the corresponding public key
  ffi.Pointer<TWPublicKey> TWPrivateKeyGetPublicKeyEd25519(
    ffi.Pointer<TWPrivateKey> pk,
  ) {
    return _TWPrivateKeyGetPublicKeyEd25519(
      pk,
    );
  }

  late final _TWPrivateKeyGetPublicKeyEd25519Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPublicKey> Function(
              ffi.Pointer<TWPrivateKey>)>>('TWPrivateKeyGetPublicKeyEd25519');
  late final _TWPrivateKeyGetPublicKeyEd25519 =
      _TWPrivateKeyGetPublicKeyEd25519Ptr.asFunction<
          ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>)>();

  /// Returns the Ed25519Blake2b public key associated with the given private key
  ///
  /// \param pk Non-null pointer to the private key
  /// \return Non-null pointer to the corresponding public key
  ffi.Pointer<TWPublicKey> TWPrivateKeyGetPublicKeyEd25519Blake2b(
    ffi.Pointer<TWPrivateKey> pk,
  ) {
    return _TWPrivateKeyGetPublicKeyEd25519Blake2b(
      pk,
    );
  }

  late final _TWPrivateKeyGetPublicKeyEd25519Blake2bPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>)>>(
      'TWPrivateKeyGetPublicKeyEd25519Blake2b');
  late final _TWPrivateKeyGetPublicKeyEd25519Blake2b =
      _TWPrivateKeyGetPublicKeyEd25519Blake2bPtr.asFunction<
          ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>)>();

  /// Returns the Ed25519Cardano public key associated with the given private key
  ///
  /// \param pk Non-null pointer to the private key
  /// \return Non-null pointer to the corresponding public key
  ffi.Pointer<TWPublicKey> TWPrivateKeyGetPublicKeyEd25519Cardano(
    ffi.Pointer<TWPrivateKey> pk,
  ) {
    return _TWPrivateKeyGetPublicKeyEd25519Cardano(
      pk,
    );
  }

  late final _TWPrivateKeyGetPublicKeyEd25519CardanoPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>)>>(
      'TWPrivateKeyGetPublicKeyEd25519Cardano');
  late final _TWPrivateKeyGetPublicKeyEd25519Cardano =
      _TWPrivateKeyGetPublicKeyEd25519CardanoPtr.asFunction<
          ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>)>();

  /// Returns the Curve25519 public key associated with the given private key
  ///
  /// \param pk Non-null pointer to the private key
  /// \return Non-null pointer to the corresponding public key
  ffi.Pointer<TWPublicKey> TWPrivateKeyGetPublicKeyCurve25519(
    ffi.Pointer<TWPrivateKey> pk,
  ) {
    return _TWPrivateKeyGetPublicKeyCurve25519(
      pk,
    );
  }

  late final _TWPrivateKeyGetPublicKeyCurve25519Ptr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>)>>(
      'TWPrivateKeyGetPublicKeyCurve25519');
  late final _TWPrivateKeyGetPublicKeyCurve25519 =
      _TWPrivateKeyGetPublicKeyCurve25519Ptr.asFunction<
          ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWPrivateKey>)>();

  /// Computes an EC Diffie-Hellman secret in constant time
  /// Supported curves: secp256k1
  ///
  /// \param pk Non-null pointer to a Private key
  /// \param publicKey Non-null pointer to the corresponding public key
  /// \param curve Eliptic curve
  /// \return The corresponding shared key as a non-null block of data
  ffi.Pointer<TWData> TWPrivateKeyGetSharedKey(
    ffi.Pointer<TWPrivateKey> pk,
    ffi.Pointer<TWPublicKey> publicKey,
    int curve,
  ) {
    return _TWPrivateKeyGetSharedKey(
      pk,
      publicKey,
      curve,
    );
  }

  late final _TWPrivateKeyGetSharedKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(
              ffi.Pointer<TWPrivateKey>,
              ffi.Pointer<TWPublicKey>,
              ffi.Int32)>>('TWPrivateKeyGetSharedKey');
  late final _TWPrivateKeyGetSharedKey =
      _TWPrivateKeyGetSharedKeyPtr.asFunction<
          ffi.Pointer<TWData> Function(
              ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWPublicKey>, int)>();

  /// Signs a digest using ECDSA and given curve.
  ///
  /// \param pk  Non-null pointer to a Private key
  /// \param digest Non-null digest block of data
  /// \param curve Eliptic curve
  /// \return Signature as a Non-null block of data
  ffi.Pointer<TWData> TWPrivateKeySign(
    ffi.Pointer<TWPrivateKey> pk,
    ffi.Pointer<TWData> digest,
    int curve,
  ) {
    return _TWPrivateKeySign(
      pk,
      digest,
      curve,
    );
  }

  late final _TWPrivateKeySignPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWPrivateKey>,
              ffi.Pointer<TWData>, ffi.Int32)>>('TWPrivateKeySign');
  late final _TWPrivateKeySign = _TWPrivateKeySignPtr.asFunction<
      ffi.Pointer<TWData> Function(
          ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWData>, int)>();

  /// Signs a digest using ECDSA. The result is encoded with DER.
  ///
  /// \param pk  Non-null pointer to a Private key
  /// \param digest Non-null digest block of data
  /// \return Signature as a Non-null block of data
  ffi.Pointer<TWData> TWPrivateKeySignAsDER(
    ffi.Pointer<TWPrivateKey> pk,
    ffi.Pointer<TWData> digest,
  ) {
    return _TWPrivateKeySignAsDER(
      pk,
      digest,
    );
  }

  late final _TWPrivateKeySignAsDERPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWPrivateKey>,
              ffi.Pointer<TWData>)>>('TWPrivateKeySignAsDER');
  late final _TWPrivateKeySignAsDER = _TWPrivateKeySignAsDERPtr.asFunction<
      ffi.Pointer<TWData> Function(
          ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWData>)>();

  /// Signs a digest using ECDSA and Zilliqa schnorr signature scheme.
  ///
  /// \param pk Non-null pointer to a Private key
  /// \param message Non-null message
  /// \return Signature as a Non-null block of data
  ffi.Pointer<TWData> TWPrivateKeySignZilliqaSchnorr(
    ffi.Pointer<TWPrivateKey> pk,
    ffi.Pointer<TWData> message,
  ) {
    return _TWPrivateKeySignZilliqaSchnorr(
      pk,
      message,
    );
  }

  late final _TWPrivateKeySignZilliqaSchnorrPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWPrivateKey>,
              ffi.Pointer<TWData>)>>('TWPrivateKeySignZilliqaSchnorr');
  late final _TWPrivateKeySignZilliqaSchnorr =
      _TWPrivateKeySignZilliqaSchnorrPtr.asFunction<
          ffi.Pointer<TWData> Function(
              ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWData>)>();

  /// Sign a message.
  ///
  /// \param privateKey: the private key used for signing
  /// \param message: A custom message which is input to the signing.
  /// \returns the signature, Hex-encoded. On invalid input empty string is returned. Returned object needs to be deleted after use.
  ffi.Pointer<TWString> TWTronMessageSignerSignMessage(
    ffi.Pointer<TWPrivateKey> privateKey,
    ffi.Pointer<TWString> message,
  ) {
    return _TWTronMessageSignerSignMessage(
      privateKey,
      message,
    );
  }

  late final _TWTronMessageSignerSignMessagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWPrivateKey>,
              ffi.Pointer<TWString>)>>('TWTronMessageSignerSignMessage');
  late final _TWTronMessageSignerSignMessage =
      _TWTronMessageSignerSignMessagePtr.asFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWString>)>();

  /// Verify signature for a message.
  ///
  /// \param pubKey: pubKey that will verify and recover the message from the signature
  /// \param message: the message signed (without prefix)
  /// \param signature: in Hex-encoded form.
  /// \returns false on any invalid input (does not throw), true if the message can be recovered from the signature
  bool TWTronMessageSignerVerifyMessage(
    ffi.Pointer<TWPublicKey> pubKey,
    ffi.Pointer<TWString> message,
    ffi.Pointer<TWString> signature,
  ) {
    return _TWTronMessageSignerVerifyMessage(
      pubKey,
      message,
      signature,
    );
  }

  late final _TWTronMessageSignerVerifyMessagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>>('TWTronMessageSignerVerifyMessage');
  late final _TWTronMessageSignerVerifyMessage =
      _TWTronMessageSignerVerifyMessagePtr.asFunction<
          bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>();

  /// Create a NEAR Account
  ///
  /// \param string Account name
  /// \note Account should be deleted by calling \TWNEARAccountDelete
  /// \return Pointer to a nullable NEAR Account.
  ffi.Pointer<TWNEARAccount> TWNEARAccountCreateWithString(
    ffi.Pointer<TWString1> string,
  ) {
    return _TWNEARAccountCreateWithString(
      string,
    );
  }

  late final _TWNEARAccountCreateWithStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWNEARAccount> Function(
              ffi.Pointer<TWString1>)>>('TWNEARAccountCreateWithString');
  late final _TWNEARAccountCreateWithString =
      _TWNEARAccountCreateWithStringPtr.asFunction<
          ffi.Pointer<TWNEARAccount> Function(ffi.Pointer<TWString1>)>();

  /// Delete the given Near Account
  ///
  /// \param account Pointer to a non-null NEAR Account
  void TWNEARAccountDelete(
    ffi.Pointer<TWNEARAccount> account,
  ) {
    return _TWNEARAccountDelete(
      account,
    );
  }

  late final _TWNEARAccountDeletePtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWNEARAccount>)>>(
      'TWNEARAccountDelete');
  late final _TWNEARAccountDelete = _TWNEARAccountDeletePtr.asFunction<
      void Function(ffi.Pointer<TWNEARAccount>)>();

  /// Returns the user friendly string representation.
  ///
  /// \param account Pointer to a non-null NEAR Account
  /// \return Non-null string account description
  ffi.Pointer<TWString1> TWNEARAccountDescription(
    ffi.Pointer<TWNEARAccount> account,
  ) {
    return _TWNEARAccountDescription(
      account,
    );
  }

  late final _TWNEARAccountDescriptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWNEARAccount>)>>('TWNEARAccountDescription');
  late final _TWNEARAccountDescription =
      _TWNEARAccountDescriptionPtr.asFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWNEARAccount>)>();

  /// Compares two addresses for equality.
  ///
  /// \param lhs The first address to compare.
  /// \param rhs The second address to compare.
  /// \return bool indicating the addresses are equal.
  bool TWBitcoinAddressEqual(
    ffi.Pointer<TWBitcoinAddress> lhs,
    ffi.Pointer<TWBitcoinAddress> rhs,
  ) {
    return _TWBitcoinAddressEqual(
      lhs,
      rhs,
    );
  }

  late final _TWBitcoinAddressEqualPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWBitcoinAddress>,
              ffi.Pointer<TWBitcoinAddress>)>>('TWBitcoinAddressEqual');
  late final _TWBitcoinAddressEqual = _TWBitcoinAddressEqualPtr.asFunction<
      bool Function(
          ffi.Pointer<TWBitcoinAddress>, ffi.Pointer<TWBitcoinAddress>)>();

  /// Determines if the data is a valid Bitcoin address.
  ///
  /// \param data data to validate.
  /// \return bool indicating if the address data is valid.
  bool TWBitcoinAddressIsValid(
    ffi.Pointer<TWData> data,
  ) {
    return _TWBitcoinAddressIsValid(
      data,
    );
  }

  late final _TWBitcoinAddressIsValidPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWData>)>>(
          'TWBitcoinAddressIsValid');
  late final _TWBitcoinAddressIsValid = _TWBitcoinAddressIsValidPtr.asFunction<
      bool Function(ffi.Pointer<TWData>)>();

  /// Determines if the string is a valid Bitcoin address.
  ///
  /// \param string string to validate.
  /// \return bool indicating if the address string is valid.
  bool TWBitcoinAddressIsValidString(
    ffi.Pointer<TWString> string,
  ) {
    return _TWBitcoinAddressIsValidString(
      string,
    );
  }

  late final _TWBitcoinAddressIsValidStringPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWString>)>>(
          'TWBitcoinAddressIsValidString');
  late final _TWBitcoinAddressIsValidString = _TWBitcoinAddressIsValidStringPtr
      .asFunction<bool Function(ffi.Pointer<TWString>)>();

  /// Initializes an address from a Base58 sring. Must be deleted with TWBitcoinAddressDelete after use.
  ///
  /// \param string Base58 string to initialize the address from.
  /// \return TWBitcoinAddress pointer or nullptr if string is invalid.
  ffi.Pointer<TWBitcoinAddress> TWBitcoinAddressCreateWithString(
    ffi.Pointer<TWString> string,
  ) {
    return _TWBitcoinAddressCreateWithString(
      string,
    );
  }

  late final _TWBitcoinAddressCreateWithStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWBitcoinAddress> Function(
              ffi.Pointer<TWString>)>>('TWBitcoinAddressCreateWithString');
  late final _TWBitcoinAddressCreateWithString =
      _TWBitcoinAddressCreateWithStringPtr.asFunction<
          ffi.Pointer<TWBitcoinAddress> Function(ffi.Pointer<TWString>)>();

  /// Initializes an address from raw data.
  ///
  /// \param data Raw data to initialize the address from. Must be deleted with TWBitcoinAddressDelete after use.
  /// \return TWBitcoinAddress pointer or nullptr if data is invalid.
  ffi.Pointer<TWBitcoinAddress> TWBitcoinAddressCreateWithData(
    ffi.Pointer<TWData> data,
  ) {
    return _TWBitcoinAddressCreateWithData(
      data,
    );
  }

  late final _TWBitcoinAddressCreateWithDataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWBitcoinAddress> Function(
              ffi.Pointer<TWData>)>>('TWBitcoinAddressCreateWithData');
  late final _TWBitcoinAddressCreateWithData =
      _TWBitcoinAddressCreateWithDataPtr.asFunction<
          ffi.Pointer<TWBitcoinAddress> Function(ffi.Pointer<TWData>)>();

  /// Initializes an address from a public key and a prefix byte.
  ///
  /// \param publicKey Public key to initialize the address from.
  /// \param prefix Prefix byte (p2pkh, p2sh, etc).
  /// \return TWBitcoinAddress pointer or nullptr if public key is invalid.
  ffi.Pointer<TWBitcoinAddress> TWBitcoinAddressCreateWithPublicKey(
    ffi.Pointer<TWPublicKey> publicKey,
    int prefix,
  ) {
    return _TWBitcoinAddressCreateWithPublicKey(
      publicKey,
      prefix,
    );
  }

  late final _TWBitcoinAddressCreateWithPublicKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWBitcoinAddress> Function(ffi.Pointer<TWPublicKey>,
              ffi.Uint8)>>('TWBitcoinAddressCreateWithPublicKey');
  late final _TWBitcoinAddressCreateWithPublicKey =
      _TWBitcoinAddressCreateWithPublicKeyPtr.asFunction<
          ffi.Pointer<TWBitcoinAddress> Function(
              ffi.Pointer<TWPublicKey>, int)>();

  /// Deletes a legacy Bitcoin address.
  ///
  /// \param address Address to delete.
  void TWBitcoinAddressDelete(
    ffi.Pointer<TWBitcoinAddress> address,
  ) {
    return _TWBitcoinAddressDelete(
      address,
    );
  }

  late final _TWBitcoinAddressDeletePtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWBitcoinAddress>)>>(
      'TWBitcoinAddressDelete');
  late final _TWBitcoinAddressDelete = _TWBitcoinAddressDeletePtr.asFunction<
      void Function(ffi.Pointer<TWBitcoinAddress>)>();

  /// Returns the address in Base58 string representation.
  ///
  /// \param address Address to get the string representation of.
  ffi.Pointer<TWString> TWBitcoinAddressDescription(
    ffi.Pointer<TWBitcoinAddress> address,
  ) {
    return _TWBitcoinAddressDescription(
      address,
    );
  }

  late final _TWBitcoinAddressDescriptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWBitcoinAddress>)>>('TWBitcoinAddressDescription');
  late final _TWBitcoinAddressDescription =
      _TWBitcoinAddressDescriptionPtr.asFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWBitcoinAddress>)>();

  /// Returns the address prefix.
  ///
  /// \param address Address to get the prefix of.
  int TWBitcoinAddressPrefix(
    ffi.Pointer<TWBitcoinAddress> address,
  ) {
    return _TWBitcoinAddressPrefix(
      address,
    );
  }

  late final _TWBitcoinAddressPrefixPtr = _lookup<
          ffi
          .NativeFunction<ffi.Uint8 Function(ffi.Pointer<TWBitcoinAddress>)>>(
      'TWBitcoinAddressPrefix');
  late final _TWBitcoinAddressPrefix = _TWBitcoinAddressPrefixPtr.asFunction<
      int Function(ffi.Pointer<TWBitcoinAddress>)>();

  /// Returns the key hash data.
  ///
  /// \param address Address to get the keyhash data of.
  ffi.Pointer<TWData> TWBitcoinAddressKeyhash(
    ffi.Pointer<TWBitcoinAddress> address,
  ) {
    return _TWBitcoinAddressKeyhash(
      address,
    );
  }

  late final _TWBitcoinAddressKeyhashPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(
              ffi.Pointer<TWBitcoinAddress>)>>('TWBitcoinAddressKeyhash');
  late final _TWBitcoinAddressKeyhash = _TWBitcoinAddressKeyhashPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWBitcoinAddress>)>();

  /// Encode function to Eth ABI binary
  ///
  /// \param fn Non-null Eth abi function
  /// \return Non-null encoded block of data
  ffi.Pointer<TWData1> TWEthereumAbiEncode(
    ffi.Pointer<TWEthereumAbiFunction> fn,
  ) {
    return _TWEthereumAbiEncode(
      fn,
    );
  }

  late final _TWEthereumAbiEncodePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWEthereumAbiFunction>)>>('TWEthereumAbiEncode');
  late final _TWEthereumAbiEncode = _TWEthereumAbiEncodePtr.asFunction<
      ffi.Pointer<TWData1> Function(ffi.Pointer<TWEthereumAbiFunction>)>();

  /// Decode function output from Eth ABI binary, fill output parameters
  ///
  /// \param[in] fn Non-null Eth abi function
  /// \param[out] encoded Non-null block of data
  /// \return true if encoded have been filled correctly, false otherwise
  bool TWEthereumAbiDecodeOutput(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    ffi.Pointer<TWData1> encoded,
  ) {
    return _TWEthereumAbiDecodeOutput(
      fn,
      encoded,
    );
  }

  late final _TWEthereumAbiDecodeOutputPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Pointer<TWData1>)>>('TWEthereumAbiDecodeOutput');
  late final _TWEthereumAbiDecodeOutput =
      _TWEthereumAbiDecodeOutputPtr.asFunction<
          bool Function(
              ffi.Pointer<TWEthereumAbiFunction>, ffi.Pointer<TWData1>)>();

  /// Decode function call data to human readable json format, according to input abi json
  ///
  /// \param data Non-null block of data
  /// \param abi Non-null string
  /// \return Non-null json string function call data
  ffi.Pointer<TWString1> TWEthereumAbiDecodeCall(
    ffi.Pointer<TWData1> data,
    ffi.Pointer<TWString1> abi,
  ) {
    return _TWEthereumAbiDecodeCall(
      data,
      abi,
    );
  }

  late final _TWEthereumAbiDecodeCallPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWData1>,
              ffi.Pointer<TWString1>)>>('TWEthereumAbiDecodeCall');
  late final _TWEthereumAbiDecodeCall = _TWEthereumAbiDecodeCallPtr.asFunction<
      ffi.Pointer<TWString1> Function(
          ffi.Pointer<TWData1>, ffi.Pointer<TWString1>)>();

  /// Compute the hash of a struct, used for signing, according to EIP712 ("v4").
  /// Input is a Json object (as string), with following fields:
  /// - types: map of used struct types (see makeTypes())
  /// - primaryType: the type of the message (string)
  /// - domain: EIP712 domain specifier values
  /// - message: the message (object).
  /// Throws on error.
  /// Example input:
  /// R"({
  /// "types": {
  /// "EIP712Domain": [
  /// {"name": "name", "type": "string"},
  /// {"name": "version", "type": "string"},
  /// {"name": "chainId", "type": "uint256"},
  /// {"name": "verifyingContract", "type": "address"}
  /// ],
  /// "Person": [
  /// {"name": "name", "type": "string"},
  /// {"name": "wallet", "type": "address"}
  /// ]
  /// },
  /// "primaryType": "Person",
  /// "domain": {
  /// "name": "Ether Person",
  /// "version": "1",
  /// "chainId": 1,
  /// "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"
  /// },
  /// "message": {
  /// "name": "Cow",
  /// "wallet": "CD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"
  /// }
  /// })");
  /// On error, empty Data is returned.
  /// Returned data must be deleted (hint: use WRAPD() macro).
  ///
  /// \param messageJson Non-null json abi input
  /// \return Non-null block of data, encoded abi input
  ffi.Pointer<TWData1> TWEthereumAbiEncodeTyped(
    ffi.Pointer<TWString1> messageJson,
  ) {
    return _TWEthereumAbiEncodeTyped(
      messageJson,
    );
  }

  late final _TWEthereumAbiEncodeTypedPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWString1>)>>('TWEthereumAbiEncodeTyped');
  late final _TWEthereumAbiEncodeTyped = _TWEthereumAbiEncodeTypedPtr
      .asFunction<ffi.Pointer<TWData1> Function(ffi.Pointer<TWString1>)>();

  /// Compares two addresses for equality.
  ///
  /// \param lhs left Non-null GroestlCoin address to be compared
  /// \param rhs right Non-null GroestlCoin address to be compared
  /// \return true if both address are equal, false otherwise
  bool TWGroestlcoinAddressEqual(
    ffi.Pointer<TWGroestlcoinAddress> lhs,
    ffi.Pointer<TWGroestlcoinAddress> rhs,
  ) {
    return _TWGroestlcoinAddressEqual(
      lhs,
      rhs,
    );
  }

  late final _TWGroestlcoinAddressEqualPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWGroestlcoinAddress>,
              ffi.Pointer<TWGroestlcoinAddress>)>>('TWGroestlcoinAddressEqual');
  late final _TWGroestlcoinAddressEqual =
      _TWGroestlcoinAddressEqualPtr.asFunction<
          bool Function(ffi.Pointer<TWGroestlcoinAddress>,
              ffi.Pointer<TWGroestlcoinAddress>)>();

  /// Determines if the string is a valid Groestlcoin address.
  ///
  /// \param string Non-null string.
  /// \return true if it's a valid address, false otherwise
  bool TWGroestlcoinAddressIsValidString(
    ffi.Pointer<TWString1> string,
  ) {
    return _TWGroestlcoinAddressIsValidString(
      string,
    );
  }

  late final _TWGroestlcoinAddressIsValidStringPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWString1>)>>(
          'TWGroestlcoinAddressIsValidString');
  late final _TWGroestlcoinAddressIsValidString =
      _TWGroestlcoinAddressIsValidStringPtr.asFunction<
          bool Function(ffi.Pointer<TWString1>)>();

  /// Create an address from a base58 string representation.
  ///
  /// \param string Non-null string
  /// \note Must be deleted with \TWGroestlcoinAddressDelete
  /// \return Non-null GroestlcoinAddress
  ffi.Pointer<TWGroestlcoinAddress> TWGroestlcoinAddressCreateWithString(
    ffi.Pointer<TWString1> string,
  ) {
    return _TWGroestlcoinAddressCreateWithString(
      string,
    );
  }

  late final _TWGroestlcoinAddressCreateWithStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWGroestlcoinAddress> Function(
              ffi.Pointer<TWString1>)>>('TWGroestlcoinAddressCreateWithString');
  late final _TWGroestlcoinAddressCreateWithString =
      _TWGroestlcoinAddressCreateWithStringPtr.asFunction<
          ffi.Pointer<TWGroestlcoinAddress> Function(ffi.Pointer<TWString1>)>();

  /// Create an address from a public key and a prefix byte.
  ///
  /// \param publicKey Non-null public key
  /// \param prefix public key prefix
  /// \note Must be deleted with \TWGroestlcoinAddressDelete
  /// \return Non-null GroestlcoinAddress
  ffi.Pointer<TWGroestlcoinAddress> TWGroestlcoinAddressCreateWithPublicKey(
    ffi.Pointer<TWPublicKey> publicKey,
    int prefix,
  ) {
    return _TWGroestlcoinAddressCreateWithPublicKey(
      publicKey,
      prefix,
    );
  }

  late final _TWGroestlcoinAddressCreateWithPublicKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWGroestlcoinAddress> Function(ffi.Pointer<TWPublicKey>,
              ffi.Uint8)>>('TWGroestlcoinAddressCreateWithPublicKey');
  late final _TWGroestlcoinAddressCreateWithPublicKey =
      _TWGroestlcoinAddressCreateWithPublicKeyPtr.asFunction<
          ffi.Pointer<TWGroestlcoinAddress> Function(
              ffi.Pointer<TWPublicKey>, int)>();

  /// Delete a Groestlcoin address
  ///
  /// \param address Non-null GroestlcoinAddress
  void TWGroestlcoinAddressDelete(
    ffi.Pointer<TWGroestlcoinAddress> address,
  ) {
    return _TWGroestlcoinAddressDelete(
      address,
    );
  }

  late final _TWGroestlcoinAddressDeletePtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<TWGroestlcoinAddress>)>>(
      'TWGroestlcoinAddressDelete');
  late final _TWGroestlcoinAddressDelete = _TWGroestlcoinAddressDeletePtr
      .asFunction<void Function(ffi.Pointer<TWGroestlcoinAddress>)>();

  /// Returns the address base58 string representation.
  ///
  /// \param address Non-null GroestlcoinAddress
  /// \return Address description as a non-null string
  ffi.Pointer<TWString1> TWGroestlcoinAddressDescription(
    ffi.Pointer<TWGroestlcoinAddress> address,
  ) {
    return _TWGroestlcoinAddressDescription(
      address,
    );
  }

  late final _TWGroestlcoinAddressDescriptionPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWString1> Function(
                  ffi.Pointer<TWGroestlcoinAddress>)>>(
      'TWGroestlcoinAddressDescription');
  late final _TWGroestlcoinAddressDescription =
      _TWGroestlcoinAddressDescriptionPtr.asFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWGroestlcoinAddress>)>();

  /// Compares two addresses for equality.
  ///
  /// \param lhs The first address to compare.
  /// \param rhs The second address to compare.
  /// \return bool indicating the addresses are equal.
  bool TWAnyAddressEqual(
    ffi.Pointer<TWAnyAddress> lhs,
    ffi.Pointer<TWAnyAddress> rhs,
  ) {
    return _TWAnyAddressEqual(
      lhs,
      rhs,
    );
  }

  late final _TWAnyAddressEqualPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWAnyAddress>,
              ffi.Pointer<TWAnyAddress>)>>('TWAnyAddressEqual');
  late final _TWAnyAddressEqual = _TWAnyAddressEqualPtr.asFunction<
      bool Function(ffi.Pointer<TWAnyAddress>, ffi.Pointer<TWAnyAddress>)>();

  /// Determines if the string is a valid Any address.
  ///
  /// \param string address to validate.
  /// \param coin coin type of the address.
  /// \return bool indicating if the address is valid.
  bool TWAnyAddressIsValid(
    ffi.Pointer<TWString1> string,
    int coin,
  ) {
    return _TWAnyAddressIsValid(
      string,
      coin,
    );
  }

  late final _TWAnyAddressIsValidPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(
              ffi.Pointer<TWString1>, ffi.Int32)>>('TWAnyAddressIsValid');
  late final _TWAnyAddressIsValid = _TWAnyAddressIsValidPtr.asFunction<
      bool Function(ffi.Pointer<TWString1>, int)>();

  /// Determines if the string is a valid Any address with the given hrp.
  ///
  /// \param string address to validate.
  /// \param coin coin type of the address.
  /// \param hrp explicit given hrp of the given address.
  /// \return bool indicating if the address is valid.
  bool TWAnyAddressIsValidBech32(
    ffi.Pointer<TWString1> string,
    int coin,
    ffi.Pointer<TWString1> hrp,
  ) {
    return _TWAnyAddressIsValidBech32(
      string,
      coin,
      hrp,
    );
  }

  late final _TWAnyAddressIsValidBech32Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWString1>, ffi.Int32,
              ffi.Pointer<TWString1>)>>('TWAnyAddressIsValidBech32');
  late final _TWAnyAddressIsValidBech32 =
      _TWAnyAddressIsValidBech32Ptr.asFunction<
          bool Function(ffi.Pointer<TWString1>, int, ffi.Pointer<TWString1>)>();

  /// Determines if the string is a valid Any address with the given SS58 network prefix.
  ///
  /// \param string address to validate.
  /// \param coin coin type of the address.
  /// \param ss58Prefix ss58Prefix of the given address.
  /// \return bool indicating if the address is valid.
  bool TWAnyAddressIsValidSS58(
    ffi.Pointer<TWString1> string,
    int coin,
    int ss58Prefix,
  ) {
    return _TWAnyAddressIsValidSS58(
      string,
      coin,
      ss58Prefix,
    );
  }

  late final _TWAnyAddressIsValidSS58Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWString1>, ffi.Int32,
              ffi.Uint32)>>('TWAnyAddressIsValidSS58');
  late final _TWAnyAddressIsValidSS58 = _TWAnyAddressIsValidSS58Ptr.asFunction<
      bool Function(ffi.Pointer<TWString1>, int, int)>();

  /// Creates an address from a string representation and a coin type. Must be deleted with TWAnyAddressDelete after use.
  ///
  /// \param string address to create.
  /// \param coin coin type of the address.
  /// \return TWAnyAddress pointer or nullptr if address and coin are invalid.
  ffi.Pointer<TWAnyAddress> TWAnyAddressCreateWithString(
    ffi.Pointer<TWString1> string,
    int coin,
  ) {
    return _TWAnyAddressCreateWithString(
      string,
      coin,
    );
  }

  late final _TWAnyAddressCreateWithStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWAnyAddress> Function(ffi.Pointer<TWString1>,
              ffi.Int32)>>('TWAnyAddressCreateWithString');
  late final _TWAnyAddressCreateWithString =
      _TWAnyAddressCreateWithStringPtr.asFunction<
          ffi.Pointer<TWAnyAddress> Function(ffi.Pointer<TWString1>, int)>();

  /// Creates an bech32 address from a string representation, a coin type and the given hrp. Must be deleted with TWAnyAddressDelete after use.
  ///
  /// \param string address to create.
  /// \param coin coin type of the address.
  /// \param hrp hrp of the address.
  /// \return TWAnyAddress pointer or nullptr if address and coin are invalid.
  ffi.Pointer<TWAnyAddress> TWAnyAddressCreateBech32(
    ffi.Pointer<TWString1> string,
    int coin,
    ffi.Pointer<TWString1> hrp,
  ) {
    return _TWAnyAddressCreateBech32(
      string,
      coin,
      hrp,
    );
  }

  late final _TWAnyAddressCreateBech32Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWAnyAddress> Function(ffi.Pointer<TWString1>, ffi.Int32,
              ffi.Pointer<TWString1>)>>('TWAnyAddressCreateBech32');
  late final _TWAnyAddressCreateBech32 =
      _TWAnyAddressCreateBech32Ptr.asFunction<
          ffi.Pointer<TWAnyAddress> Function(
              ffi.Pointer<TWString1>, int, ffi.Pointer<TWString1>)>();

  /// Creates an SS58 address from a string representation, a coin type and the given ss58Prefix. Must be deleted with TWAnyAddressDelete after use.
  ///
  /// \param string address to create.
  /// \param coin coin type of the address.
  /// \param ss58Prefix ss58Prefix of the SS58 address.
  /// \return TWAnyAddress pointer or nullptr if address and coin are invalid.
  ffi.Pointer<TWAnyAddress> TWAnyAddressCreateSS58(
    ffi.Pointer<TWString1> string,
    int coin,
    int ss58Prefix,
  ) {
    return _TWAnyAddressCreateSS58(
      string,
      coin,
      ss58Prefix,
    );
  }

  late final _TWAnyAddressCreateSS58Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWAnyAddress> Function(ffi.Pointer<TWString1>, ffi.Int32,
              ffi.Uint32)>>('TWAnyAddressCreateSS58');
  late final _TWAnyAddressCreateSS58 = _TWAnyAddressCreateSS58Ptr.asFunction<
      ffi.Pointer<TWAnyAddress> Function(ffi.Pointer<TWString1>, int, int)>();

  /// Creates an address from a public key.
  ///
  /// \param publicKey derivates the address from the public key.
  /// \param coin coin type of the address.
  /// \return TWAnyAddress pointer or nullptr if public key is invalid.
  ffi.Pointer<TWAnyAddress> TWAnyAddressCreateWithPublicKey(
    ffi.Pointer<TWPublicKey> publicKey,
    int coin,
  ) {
    return _TWAnyAddressCreateWithPublicKey(
      publicKey,
      coin,
    );
  }

  late final _TWAnyAddressCreateWithPublicKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWAnyAddress> Function(ffi.Pointer<TWPublicKey>,
              ffi.Int32)>>('TWAnyAddressCreateWithPublicKey');
  late final _TWAnyAddressCreateWithPublicKey =
      _TWAnyAddressCreateWithPublicKeyPtr.asFunction<
          ffi.Pointer<TWAnyAddress> Function(ffi.Pointer<TWPublicKey>, int)>();

  /// Creates an address from a public key and derivation option.
  ///
  /// \param publicKey derivates the address from the public key.
  /// \param coin coin type of the address.
  /// \param derivation the custom derivation to use.
  /// \return TWAnyAddress pointer or nullptr if public key is invalid.
  ffi.Pointer<TWAnyAddress> TWAnyAddressCreateWithPublicKeyDerivation(
    ffi.Pointer<TWPublicKey> publicKey,
    int coin,
    int derivation,
  ) {
    return _TWAnyAddressCreateWithPublicKeyDerivation(
      publicKey,
      coin,
      derivation,
    );
  }

  late final _TWAnyAddressCreateWithPublicKeyDerivationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWAnyAddress> Function(
              ffi.Pointer<TWPublicKey>,
              ffi.Int32,
              ffi.Int32)>>('TWAnyAddressCreateWithPublicKeyDerivation');
  late final _TWAnyAddressCreateWithPublicKeyDerivation =
      _TWAnyAddressCreateWithPublicKeyDerivationPtr.asFunction<
          ffi.Pointer<TWAnyAddress> Function(
              ffi.Pointer<TWPublicKey>, int, int)>();

  /// Creates an bech32 address from a public key and a given hrp.
  ///
  /// \param publicKey derivates the address from the public key.
  /// \param coin coin type of the address.
  /// \param hrp hrp of the address.
  /// \return TWAnyAddress pointer or nullptr if public key is invalid.
  ffi.Pointer<TWAnyAddress> TWAnyAddressCreateBech32WithPublicKey(
    ffi.Pointer<TWPublicKey> publicKey,
    int coin,
    ffi.Pointer<TWString1> hrp,
  ) {
    return _TWAnyAddressCreateBech32WithPublicKey(
      publicKey,
      coin,
      hrp,
    );
  }

  late final _TWAnyAddressCreateBech32WithPublicKeyPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWAnyAddress> Function(ffi.Pointer<TWPublicKey>,
                  ffi.Int32, ffi.Pointer<TWString1>)>>(
      'TWAnyAddressCreateBech32WithPublicKey');
  late final _TWAnyAddressCreateBech32WithPublicKey =
      _TWAnyAddressCreateBech32WithPublicKeyPtr.asFunction<
          ffi.Pointer<TWAnyAddress> Function(
              ffi.Pointer<TWPublicKey>, int, ffi.Pointer<TWString1>)>();

  /// Creates an SS58 address from a public key and a given ss58Prefix.
  ///
  /// \param publicKey derivates the address from the public key.
  /// \param coin coin type of the address.
  /// \param ss58Prefix ss58Prefix of the SS58 address.
  /// \return TWAnyAddress pointer or nullptr if public key is invalid.
  ffi.Pointer<TWAnyAddress> TWAnyAddressCreateSS58WithPublicKey(
    ffi.Pointer<TWPublicKey> publicKey,
    int coin,
    int ss58Prefix,
  ) {
    return _TWAnyAddressCreateSS58WithPublicKey(
      publicKey,
      coin,
      ss58Prefix,
    );
  }

  late final _TWAnyAddressCreateSS58WithPublicKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWAnyAddress> Function(ffi.Pointer<TWPublicKey>,
              ffi.Int32, ffi.Uint32)>>('TWAnyAddressCreateSS58WithPublicKey');
  late final _TWAnyAddressCreateSS58WithPublicKey =
      _TWAnyAddressCreateSS58WithPublicKeyPtr.asFunction<
          ffi.Pointer<TWAnyAddress> Function(
              ffi.Pointer<TWPublicKey>, int, int)>();

  /// Creates a Filecoin address from a public key and a given address type.
  ///
  /// \param publicKey derivates the address from the public key.
  /// \param filecoinAddressType Filecoin address type.
  /// \return TWAnyAddress pointer or nullptr if public key is invalid.
  ffi.Pointer<TWAnyAddress> TWAnyAddressCreateWithPublicKeyFilecoinAddressType(
    ffi.Pointer<TWPublicKey> publicKey,
    int filecoinAddressType,
  ) {
    return _TWAnyAddressCreateWithPublicKeyFilecoinAddressType(
      publicKey,
      filecoinAddressType,
    );
  }

  late final _TWAnyAddressCreateWithPublicKeyFilecoinAddressTypePtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWAnyAddress> Function(
                  ffi.Pointer<TWPublicKey>, ffi.Int32)>>(
      'TWAnyAddressCreateWithPublicKeyFilecoinAddressType');
  late final _TWAnyAddressCreateWithPublicKeyFilecoinAddressType =
      _TWAnyAddressCreateWithPublicKeyFilecoinAddressTypePtr.asFunction<
          ffi.Pointer<TWAnyAddress> Function(ffi.Pointer<TWPublicKey>, int)>();

  /// Deletes an address.
  ///
  /// \param address address to delete.
  void TWAnyAddressDelete(
    ffi.Pointer<TWAnyAddress> address,
  ) {
    return _TWAnyAddressDelete(
      address,
    );
  }

  late final _TWAnyAddressDeletePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWAnyAddress>)>>(
          'TWAnyAddressDelete');
  late final _TWAnyAddressDelete = _TWAnyAddressDeletePtr.asFunction<
      void Function(ffi.Pointer<TWAnyAddress>)>();

  /// Returns the address string representation.
  ///
  /// \param address address to get the string representation of.
  ffi.Pointer<TWString1> TWAnyAddressDescription(
    ffi.Pointer<TWAnyAddress> address,
  ) {
    return _TWAnyAddressDescription(
      address,
    );
  }

  late final _TWAnyAddressDescriptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWAnyAddress>)>>('TWAnyAddressDescription');
  late final _TWAnyAddressDescription = _TWAnyAddressDescriptionPtr.asFunction<
      ffi.Pointer<TWString1> Function(ffi.Pointer<TWAnyAddress>)>();

  /// Returns coin type of address.
  ///
  /// \param address address to get the coin type of.
  int TWAnyAddressCoin(
    ffi.Pointer<TWAnyAddress> address,
  ) {
    return _TWAnyAddressCoin(
      address,
    );
  }

  late final _TWAnyAddressCoinPtr = _lookup<
          ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<TWAnyAddress>)>>(
      'TWAnyAddressCoin');
  late final _TWAnyAddressCoin = _TWAnyAddressCoinPtr.asFunction<
      int Function(ffi.Pointer<TWAnyAddress>)>();

  /// Returns underlaying data (public key or key hash)
  ///
  /// \param address address to get the data of.
  ffi.Pointer<TWData1> TWAnyAddressData(
    ffi.Pointer<TWAnyAddress> address,
  ) {
    return _TWAnyAddressData(
      address,
    );
  }

  late final _TWAnyAddressDataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWAnyAddress>)>>('TWAnyAddressData');
  late final _TWAnyAddressData = _TWAnyAddressDataPtr.asFunction<
      ffi.Pointer<TWData1> Function(ffi.Pointer<TWAnyAddress>)>();

  /// Compares two addresses for equality.
  ///
  /// \param lhs left non-null pointer to a Bech32 Address
  /// \param rhs right non-null pointer to a Bech32 Address
  /// \return true if both address are equal, false otherwise
  bool TWSegwitAddressEqual(
    ffi.Pointer<TWSegwitAddress> lhs,
    ffi.Pointer<TWSegwitAddress> rhs,
  ) {
    return _TWSegwitAddressEqual(
      lhs,
      rhs,
    );
  }

  late final _TWSegwitAddressEqualPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWSegwitAddress>,
              ffi.Pointer<TWSegwitAddress>)>>('TWSegwitAddressEqual');
  late final _TWSegwitAddressEqual = _TWSegwitAddressEqualPtr.asFunction<
      bool Function(
          ffi.Pointer<TWSegwitAddress>, ffi.Pointer<TWSegwitAddress>)>();

  /// Determines if the string is a valid Bech32 address.
  ///
  /// \param string Non-null pointer to a Bech32 address as a string
  /// \return true if the string is a valid Bech32 address, false otherwise.
  bool TWSegwitAddressIsValidString(
    ffi.Pointer<TWString1> string,
  ) {
    return _TWSegwitAddressIsValidString(
      string,
    );
  }

  late final _TWSegwitAddressIsValidStringPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWString1>)>>(
          'TWSegwitAddressIsValidString');
  late final _TWSegwitAddressIsValidString = _TWSegwitAddressIsValidStringPtr
      .asFunction<bool Function(ffi.Pointer<TWString1>)>();

  /// Creates an address from a string representation.
  ///
  /// \param string Non-null pointer to a Bech32 address as a string
  /// \note should be deleted with \TWSegwitAddressDelete
  /// \return Pointer to a Bech32 address if the string is a valid Bech32 address, null pointer otherwise
  ffi.Pointer<TWSegwitAddress> TWSegwitAddressCreateWithString(
    ffi.Pointer<TWString1> string,
  ) {
    return _TWSegwitAddressCreateWithString(
      string,
    );
  }

  late final _TWSegwitAddressCreateWithStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWSegwitAddress> Function(
              ffi.Pointer<TWString1>)>>('TWSegwitAddressCreateWithString');
  late final _TWSegwitAddressCreateWithString =
      _TWSegwitAddressCreateWithStringPtr.asFunction<
          ffi.Pointer<TWSegwitAddress> Function(ffi.Pointer<TWString1>)>();

  /// Creates a segwit-version-0 address from a public key and HRP prefix.
  /// Taproot (v>=1) is not supported by this method.
  ///
  /// \param hrp HRP of the utxo coin targeted
  /// \param publicKey Non-null pointer to the public key of the targeted coin
  /// \note should be deleted with \TWSegwitAddressDelete
  /// \return Non-null pointer to the corresponding Segwit address
  ffi.Pointer<TWSegwitAddress> TWSegwitAddressCreateWithPublicKey(
    int hrp,
    ffi.Pointer<TWPublicKey> publicKey,
  ) {
    return _TWSegwitAddressCreateWithPublicKey(
      hrp,
      publicKey,
    );
  }

  late final _TWSegwitAddressCreateWithPublicKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWSegwitAddress> Function(ffi.Int32,
              ffi.Pointer<TWPublicKey>)>>('TWSegwitAddressCreateWithPublicKey');
  late final _TWSegwitAddressCreateWithPublicKey =
      _TWSegwitAddressCreateWithPublicKeyPtr.asFunction<
          ffi.Pointer<TWSegwitAddress> Function(
              int, ffi.Pointer<TWPublicKey>)>();

  /// Delete the given Segwit address
  ///
  /// \param address Non-null pointer to a Segwit address
  void TWSegwitAddressDelete(
    ffi.Pointer<TWSegwitAddress> address,
  ) {
    return _TWSegwitAddressDelete(
      address,
    );
  }

  late final _TWSegwitAddressDeletePtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWSegwitAddress>)>>(
      'TWSegwitAddressDelete');
  late final _TWSegwitAddressDelete = _TWSegwitAddressDeletePtr.asFunction<
      void Function(ffi.Pointer<TWSegwitAddress>)>();

  /// Returns the address string representation.
  ///
  /// \param address Non-null pointer to a Segwit Address
  /// \return Non-null pointer to the segwit address string representation
  ffi.Pointer<TWString1> TWSegwitAddressDescription(
    ffi.Pointer<TWSegwitAddress> address,
  ) {
    return _TWSegwitAddressDescription(
      address,
    );
  }

  late final _TWSegwitAddressDescriptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWSegwitAddress>)>>('TWSegwitAddressDescription');
  late final _TWSegwitAddressDescription =
      _TWSegwitAddressDescriptionPtr.asFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWSegwitAddress>)>();

  /// Returns the human-readable part.
  ///
  /// \param address Non-null pointer to a Segwit Address
  /// \return the HRP part of the given address
  int TWSegwitAddressHRP(
    ffi.Pointer<TWSegwitAddress> address,
  ) {
    return _TWSegwitAddressHRP(
      address,
    );
  }

  late final _TWSegwitAddressHRPPtr = _lookup<
          ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<TWSegwitAddress>)>>(
      'TWSegwitAddressHRP');
  late final _TWSegwitAddressHRP = _TWSegwitAddressHRPPtr.asFunction<
      int Function(ffi.Pointer<TWSegwitAddress>)>();

  /// Returns the human-readable part.
  ///
  /// \param address Non-null pointer to a Segwit Address
  /// \return returns the witness version of the given segwit address
  int TWSegwitAddressWitnessVersion(
    ffi.Pointer<TWSegwitAddress> address,
  ) {
    return _TWSegwitAddressWitnessVersion(
      address,
    );
  }

  late final _TWSegwitAddressWitnessVersionPtr = _lookup<
          ffi.NativeFunction<ffi.Int Function(ffi.Pointer<TWSegwitAddress>)>>(
      'TWSegwitAddressWitnessVersion');
  late final _TWSegwitAddressWitnessVersion = _TWSegwitAddressWitnessVersionPtr
      .asFunction<int Function(ffi.Pointer<TWSegwitAddress>)>();

  /// Returns the witness program
  ///
  /// \param address Non-null pointer to a Segwit Address
  /// \return returns the witness data of the given segwit address as a non-null pointer block of data
  ffi.Pointer<TWData1> TWSegwitAddressWitnessProgram(
    ffi.Pointer<TWSegwitAddress> address,
  ) {
    return _TWSegwitAddressWitnessProgram(
      address,
    );
  }

  late final _TWSegwitAddressWitnessProgramPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWSegwitAddress>)>>('TWSegwitAddressWitnessProgram');
  late final _TWSegwitAddressWitnessProgram =
      _TWSegwitAddressWitnessProgramPtr.asFunction<
          ffi.Pointer<TWData1> Function(ffi.Pointer<TWSegwitAddress>)>();

  /// Creates a new DerivationPath with a purpose, coin, account, change and address.
  /// Must be deleted with TWDerivationPathDelete after use.
  ///
  /// \param purpose The purpose of the Path.
  /// \param coin The coin type of the Path.
  /// \param account The derivation of the Path.
  /// \param change The derivation path of the Path.
  /// \param address hex encoded public key.
  /// \return A new DerivationPath.
  ffi.Pointer<TWDerivationPath> TWDerivationPathCreate(
    int purpose,
    int coin,
    int account,
    int change,
    int address,
  ) {
    return _TWDerivationPathCreate(
      purpose,
      coin,
      account,
      change,
      address,
    );
  }

  late final _TWDerivationPathCreatePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWDerivationPath> Function(ffi.Int32, ffi.Uint32,
              ffi.Uint32, ffi.Uint32, ffi.Uint32)>>('TWDerivationPathCreate');
  late final _TWDerivationPathCreate = _TWDerivationPathCreatePtr.asFunction<
      ffi.Pointer<TWDerivationPath> Function(int, int, int, int, int)>();

  /// Creates a new DerivationPath with a string
  ///
  /// \param string The string of the Path.
  /// \return A new DerivationPath or null if string is invalid.
  ffi.Pointer<TWDerivationPath> TWDerivationPathCreateWithString(
    ffi.Pointer<TWString1> string,
  ) {
    return _TWDerivationPathCreateWithString(
      string,
    );
  }

  late final _TWDerivationPathCreateWithStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWDerivationPath> Function(
              ffi.Pointer<TWString1>)>>('TWDerivationPathCreateWithString');
  late final _TWDerivationPathCreateWithString =
      _TWDerivationPathCreateWithStringPtr.asFunction<
          ffi.Pointer<TWDerivationPath> Function(ffi.Pointer<TWString1>)>();

  /// Deletes a DerivationPath.
  ///
  /// \param path DerivationPath to delete.
  void TWDerivationPathDelete(
    ffi.Pointer<TWDerivationPath> path,
  ) {
    return _TWDerivationPathDelete(
      path,
    );
  }

  late final _TWDerivationPathDeletePtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWDerivationPath>)>>(
      'TWDerivationPathDelete');
  late final _TWDerivationPathDelete = _TWDerivationPathDeletePtr.asFunction<
      void Function(ffi.Pointer<TWDerivationPath>)>();

  /// Returns the index component of a DerivationPath.
  ///
  /// \param path DerivationPath to get the index of.
  /// \param index The index component of the DerivationPath.
  /// \return DerivationPathIndex or null if index is invalid.
  ffi.Pointer<TWDerivationPathIndex> TWDerivationPathIndexAt(
    ffi.Pointer<TWDerivationPath> path,
    int index,
  ) {
    return _TWDerivationPathIndexAt(
      path,
      index,
    );
  }

  late final _TWDerivationPathIndexAtPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWDerivationPathIndex> Function(
              ffi.Pointer<TWDerivationPath>,
              ffi.Uint32)>>('TWDerivationPathIndexAt');
  late final _TWDerivationPathIndexAt = _TWDerivationPathIndexAtPtr.asFunction<
      ffi.Pointer<TWDerivationPathIndex> Function(
          ffi.Pointer<TWDerivationPath>, int)>();

  /// Returns the indices count of a DerivationPath.
  ///
  /// \param path DerivationPath to get the indices count of.
  /// \return The indices count of the DerivationPath.
  int TWDerivationPathIndicesCount(
    ffi.Pointer<TWDerivationPath> path,
  ) {
    return _TWDerivationPathIndicesCount(
      path,
    );
  }

  late final _TWDerivationPathIndicesCountPtr = _lookup<
          ffi
          .NativeFunction<ffi.Uint32 Function(ffi.Pointer<TWDerivationPath>)>>(
      'TWDerivationPathIndicesCount');
  late final _TWDerivationPathIndicesCount = _TWDerivationPathIndicesCountPtr
      .asFunction<int Function(ffi.Pointer<TWDerivationPath>)>();

  /// Returns the purpose enum of a DerivationPath.
  ///
  /// \param path DerivationPath to get the purpose of.
  /// \return DerivationPathPurpose.
  int TWDerivationPathPurpose(
    ffi.Pointer<TWDerivationPath> path,
  ) {
    return _TWDerivationPathPurpose(
      path,
    );
  }

  late final _TWDerivationPathPurposePtr = _lookup<
          ffi
          .NativeFunction<ffi.Int32 Function(ffi.Pointer<TWDerivationPath>)>>(
      'TWDerivationPathPurpose');
  late final _TWDerivationPathPurpose = _TWDerivationPathPurposePtr.asFunction<
      int Function(ffi.Pointer<TWDerivationPath>)>();

  /// Returns the coin value of a derivation path.
  ///
  /// \param path DerivationPath to get the coin of.
  /// \return The coin part of the DerivationPath.
  int TWDerivationPathCoin(
    ffi.Pointer<TWDerivationPath> path,
  ) {
    return _TWDerivationPathCoin(
      path,
    );
  }

  late final _TWDerivationPathCoinPtr = _lookup<
          ffi
          .NativeFunction<ffi.Uint32 Function(ffi.Pointer<TWDerivationPath>)>>(
      'TWDerivationPathCoin');
  late final _TWDerivationPathCoin = _TWDerivationPathCoinPtr.asFunction<
      int Function(ffi.Pointer<TWDerivationPath>)>();

  /// Returns the account value of a derivation path.
  ///
  /// \param path DerivationPath to get the account of.
  /// \return the account part of a derivation path.
  int TWDerivationPathAccount(
    ffi.Pointer<TWDerivationPath> path,
  ) {
    return _TWDerivationPathAccount(
      path,
    );
  }

  late final _TWDerivationPathAccountPtr = _lookup<
          ffi
          .NativeFunction<ffi.Uint32 Function(ffi.Pointer<TWDerivationPath>)>>(
      'TWDerivationPathAccount');
  late final _TWDerivationPathAccount = _TWDerivationPathAccountPtr.asFunction<
      int Function(ffi.Pointer<TWDerivationPath>)>();

  /// Returns the change value of a derivation path.
  ///
  /// \param path DerivationPath to get the change of.
  /// \return The change part of a derivation path.
  int TWDerivationPathChange(
    ffi.Pointer<TWDerivationPath> path,
  ) {
    return _TWDerivationPathChange(
      path,
    );
  }

  late final _TWDerivationPathChangePtr = _lookup<
          ffi
          .NativeFunction<ffi.Uint32 Function(ffi.Pointer<TWDerivationPath>)>>(
      'TWDerivationPathChange');
  late final _TWDerivationPathChange = _TWDerivationPathChangePtr.asFunction<
      int Function(ffi.Pointer<TWDerivationPath>)>();

  /// Returns the address value of a derivation path.
  ///
  /// \param path DerivationPath to get the address of.
  /// \return The address part of the derivation path.
  int TWDerivationPathAddress(
    ffi.Pointer<TWDerivationPath> path,
  ) {
    return _TWDerivationPathAddress(
      path,
    );
  }

  late final _TWDerivationPathAddressPtr = _lookup<
          ffi
          .NativeFunction<ffi.Uint32 Function(ffi.Pointer<TWDerivationPath>)>>(
      'TWDerivationPathAddress');
  late final _TWDerivationPathAddress = _TWDerivationPathAddressPtr.asFunction<
      int Function(ffi.Pointer<TWDerivationPath>)>();

  /// Returns the string description of a derivation path.
  ///
  /// \param path DerivationPath to get the address of.
  /// \return The string description of the derivation path.
  ffi.Pointer<TWString1> TWDerivationPathDescription(
    ffi.Pointer<TWDerivationPath> path,
  ) {
    return _TWDerivationPathDescription(
      path,
    );
  }

  late final _TWDerivationPathDescriptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWDerivationPath>)>>('TWDerivationPathDescription');
  late final _TWDerivationPathDescription =
      _TWDerivationPathDescriptionPtr.asFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWDerivationPath>)>();

  /// Creates a new HDWallet with a new random mnemonic with the provided strength in bits.
  ///
  /// \param strength strength in bits
  /// \param passphrase non-null passphrase
  /// \note Null is returned on invalid strength
  /// \note Returned object needs to be deleted with \TWHDWalletDelete
  /// \return Nullable TWHDWallet
  ffi.Pointer<TWHDWallet> TWHDWalletCreate(
    int strength,
    ffi.Pointer<TWString1> passphrase,
  ) {
    return _TWHDWalletCreate(
      strength,
      passphrase,
    );
  }

  late final _TWHDWalletCreatePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWHDWallet> Function(
              ffi.Int, ffi.Pointer<TWString1>)>>('TWHDWalletCreate');
  late final _TWHDWalletCreate = _TWHDWalletCreatePtr.asFunction<
      ffi.Pointer<TWHDWallet> Function(int, ffi.Pointer<TWString1>)>();

  /// Creates an HDWallet from a valid BIP39 English mnemonic and a passphrase.
  ///
  /// \param mnemonic non-null Valid BIP39 mnemonic
  /// \param passphrase  non-null passphrase
  /// \note Null is returned on invalid mnemonic
  /// \note Returned object needs to be deleted with \TWHDWalletDelete
  /// \return Nullable TWHDWallet
  ffi.Pointer<TWHDWallet> TWHDWalletCreateWithMnemonic(
    ffi.Pointer<TWString1> mnemonic,
    ffi.Pointer<TWString1> passphrase,
  ) {
    return _TWHDWalletCreateWithMnemonic(
      mnemonic,
      passphrase,
    );
  }

  late final _TWHDWalletCreateWithMnemonicPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWHDWallet> Function(ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>)>>('TWHDWalletCreateWithMnemonic');
  late final _TWHDWalletCreateWithMnemonic =
      _TWHDWalletCreateWithMnemonicPtr.asFunction<
          ffi.Pointer<TWHDWallet> Function(
              ffi.Pointer<TWString1>, ffi.Pointer<TWString1>)>();

  /// Creates an HDWallet from a BIP39 mnemonic, a passphrase and validation flag.
  ///
  /// \param mnemonic non-null Valid BIP39 mnemonic
  /// \param passphrase  non-null passphrase
  /// \param check validation flag
  /// \note Null is returned on invalid mnemonic
  /// \note Returned object needs to be deleted with \TWHDWalletDelete
  /// \return Nullable TWHDWallet
  ffi.Pointer<TWHDWallet> TWHDWalletCreateWithMnemonicCheck(
    ffi.Pointer<TWString1> mnemonic,
    ffi.Pointer<TWString1> passphrase,
    bool check,
  ) {
    return _TWHDWalletCreateWithMnemonicCheck(
      mnemonic,
      passphrase,
      check,
    );
  }

  late final _TWHDWalletCreateWithMnemonicCheckPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWHDWallet> Function(
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Bool)>>('TWHDWalletCreateWithMnemonicCheck');
  late final _TWHDWalletCreateWithMnemonicCheck =
      _TWHDWalletCreateWithMnemonicCheckPtr.asFunction<
          ffi.Pointer<TWHDWallet> Function(
              ffi.Pointer<TWString1>, ffi.Pointer<TWString1>, bool)>();

  /// Creates an HDWallet from entropy (corresponding to a mnemonic).
  ///
  /// \param entropy Non-null entropy data (corresponding to a mnemonic)
  /// \param passphrase non-null passphrase
  /// \note Null is returned on invalid input
  /// \note Returned object needs to be deleted with \TWHDWalletDelete
  /// \return Nullable TWHDWallet
  ffi.Pointer<TWHDWallet> TWHDWalletCreateWithEntropy(
    ffi.Pointer<TWData1> entropy,
    ffi.Pointer<TWString1> passphrase,
  ) {
    return _TWHDWalletCreateWithEntropy(
      entropy,
      passphrase,
    );
  }

  late final _TWHDWalletCreateWithEntropyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWHDWallet> Function(ffi.Pointer<TWData1>,
              ffi.Pointer<TWString1>)>>('TWHDWalletCreateWithEntropy');
  late final _TWHDWalletCreateWithEntropy =
      _TWHDWalletCreateWithEntropyPtr.asFunction<
          ffi.Pointer<TWHDWallet> Function(
              ffi.Pointer<TWData1>, ffi.Pointer<TWString1>)>();

  /// Deletes a wallet.
  ///
  /// \param wallet non-null TWHDWallet
  void TWHDWalletDelete(
    ffi.Pointer<TWHDWallet> wallet,
  ) {
    return _TWHDWalletDelete(
      wallet,
    );
  }

  late final _TWHDWalletDeletePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWHDWallet>)>>(
          'TWHDWalletDelete');
  late final _TWHDWalletDelete =
      _TWHDWalletDeletePtr.asFunction<void Function(ffi.Pointer<TWHDWallet>)>();

  /// Wallet seed.
  ///
  /// \param wallet non-null TWHDWallet
  /// \return The wallet seed as a Non-null block of data.
  ffi.Pointer<TWData1> TWHDWalletSeed(
    ffi.Pointer<TWHDWallet> wallet,
  ) {
    return _TWHDWalletSeed(
      wallet,
    );
  }

  late final _TWHDWalletSeedPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWHDWallet>)>>('TWHDWalletSeed');
  late final _TWHDWalletSeed = _TWHDWalletSeedPtr.asFunction<
      ffi.Pointer<TWData1> Function(ffi.Pointer<TWHDWallet>)>();

  /// Wallet Mnemonic
  ///
  /// \param wallet non-null TWHDWallet
  /// \return The wallet mnemonic as a non-null TWString
  ffi.Pointer<TWString1> TWHDWalletMnemonic(
    ffi.Pointer<TWHDWallet> wallet,
  ) {
    return _TWHDWalletMnemonic(
      wallet,
    );
  }

  late final _TWHDWalletMnemonicPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWHDWallet>)>>('TWHDWalletMnemonic');
  late final _TWHDWalletMnemonic = _TWHDWalletMnemonicPtr.asFunction<
      ffi.Pointer<TWString1> Function(ffi.Pointer<TWHDWallet>)>();

  /// Wallet entropy
  ///
  /// \param wallet non-null TWHDWallet
  /// \return The wallet entropy as a non-null block of data.
  ffi.Pointer<TWData1> TWHDWalletEntropy(
    ffi.Pointer<TWHDWallet> wallet,
  ) {
    return _TWHDWalletEntropy(
      wallet,
    );
  }

  late final _TWHDWalletEntropyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWHDWallet>)>>('TWHDWalletEntropy');
  late final _TWHDWalletEntropy = _TWHDWalletEntropyPtr.asFunction<
      ffi.Pointer<TWData1> Function(ffi.Pointer<TWHDWallet>)>();

  /// Returns master key.
  ///
  /// \param wallet non-null TWHDWallet
  /// \param curve  a curve
  /// \note Returned object needs to be deleted with \TWPrivateKeyDelete
  /// \return Non-null corresponding private key
  ffi.Pointer<TWPrivateKey> TWHDWalletGetMasterKey(
    ffi.Pointer<TWHDWallet> wallet,
    int curve,
  ) {
    return _TWHDWalletGetMasterKey(
      wallet,
      curve,
    );
  }

  late final _TWHDWalletGetMasterKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPrivateKey> Function(
              ffi.Pointer<TWHDWallet>, ffi.Int32)>>('TWHDWalletGetMasterKey');
  late final _TWHDWalletGetMasterKey = _TWHDWalletGetMasterKeyPtr.asFunction<
      ffi.Pointer<TWPrivateKey> Function(ffi.Pointer<TWHDWallet>, int)>();

  /// Generates the default private key for the specified coin, using default derivation.
  ///
  /// \see TWHDWalletGetKey
  /// \see TWHDWalletGetKeyDerivation
  /// \param wallet non-null TWHDWallet
  /// \param coin  a coin type
  /// \note Returned object needs to be deleted with \TWPrivateKeyDelete
  /// \return return the default private key for the specified coin
  ffi.Pointer<TWPrivateKey> TWHDWalletGetKeyForCoin(
    ffi.Pointer<TWHDWallet> wallet,
    int coin,
  ) {
    return _TWHDWalletGetKeyForCoin(
      wallet,
      coin,
    );
  }

  late final _TWHDWalletGetKeyForCoinPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPrivateKey> Function(
              ffi.Pointer<TWHDWallet>, ffi.Int32)>>('TWHDWalletGetKeyForCoin');
  late final _TWHDWalletGetKeyForCoin = _TWHDWalletGetKeyForCoinPtr.asFunction<
      ffi.Pointer<TWPrivateKey> Function(ffi.Pointer<TWHDWallet>, int)>();

  /// Generates the default address for the specified coin (without exposing intermediary private key), default derivation.
  ///
  /// \see TWHDWalletGetAddressDerivation
  /// \param wallet non-null TWHDWallet
  /// \param coin  a coin type
  /// \return return the default address for the specified coin as a non-null TWString
  ffi.Pointer<TWString1> TWHDWalletGetAddressForCoin(
    ffi.Pointer<TWHDWallet> wallet,
    int coin,
  ) {
    return _TWHDWalletGetAddressForCoin(
      wallet,
      coin,
    );
  }

  late final _TWHDWalletGetAddressForCoinPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWHDWallet>,
              ffi.Int32)>>('TWHDWalletGetAddressForCoin');
  late final _TWHDWalletGetAddressForCoin =
      _TWHDWalletGetAddressForCoinPtr.asFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWHDWallet>, int)>();

  /// Generates the default address for the specified coin and derivation (without exposing intermediary private key).
  ///
  /// \see TWHDWalletGetAddressForCoin
  /// \param wallet non-null TWHDWallet
  /// \param coin  a coin type
  /// \param derivation  a (custom) derivation to use
  /// \return return the default address for the specified coin as a non-null TWString
  ffi.Pointer<TWString1> TWHDWalletGetAddressDerivation(
    ffi.Pointer<TWHDWallet> wallet,
    int coin,
    int derivation,
  ) {
    return _TWHDWalletGetAddressDerivation(
      wallet,
      coin,
      derivation,
    );
  }

  late final _TWHDWalletGetAddressDerivationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWHDWallet>, ffi.Int32,
              ffi.Int32)>>('TWHDWalletGetAddressDerivation');
  late final _TWHDWalletGetAddressDerivation =
      _TWHDWalletGetAddressDerivationPtr.asFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWHDWallet>, int, int)>();

  /// Generates the private key for the specified derivation path.
  ///
  /// \see TWHDWalletGetKeyForCoin
  /// \see TWHDWalletGetKeyDerivation
  /// \param wallet non-null TWHDWallet
  /// \param coin a coin type
  /// \param derivationPath  a non-null derivation path
  /// \note Returned object needs to be deleted with \TWPrivateKeyDelete
  /// \return The private key for the specified derivation path/coin
  ffi.Pointer<TWPrivateKey> TWHDWalletGetKey(
    ffi.Pointer<TWHDWallet> wallet,
    int coin,
    ffi.Pointer<TWString1> derivationPath,
  ) {
    return _TWHDWalletGetKey(
      wallet,
      coin,
      derivationPath,
    );
  }

  late final _TWHDWalletGetKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPrivateKey> Function(ffi.Pointer<TWHDWallet>, ffi.Int32,
              ffi.Pointer<TWString1>)>>('TWHDWalletGetKey');
  late final _TWHDWalletGetKey = _TWHDWalletGetKeyPtr.asFunction<
      ffi.Pointer<TWPrivateKey> Function(
          ffi.Pointer<TWHDWallet>, int, ffi.Pointer<TWString1>)>();

  /// Generates the private key for the specified derivation.
  ///
  /// \see TWHDWalletGetKey
  /// \see TWHDWalletGetKeyForCoin
  /// \param wallet non-null TWHDWallet
  /// \param coin a coin type
  /// \param derivation a (custom) derivation to use
  /// \note Returned object needs to be deleted with \TWPrivateKeyDelete
  /// \return The private key for the specified derivation path/coin
  ffi.Pointer<TWPrivateKey> TWHDWalletGetKeyDerivation(
    ffi.Pointer<TWHDWallet> wallet,
    int coin,
    int derivation,
  ) {
    return _TWHDWalletGetKeyDerivation(
      wallet,
      coin,
      derivation,
    );
  }

  late final _TWHDWalletGetKeyDerivationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPrivateKey> Function(ffi.Pointer<TWHDWallet>, ffi.Int32,
              ffi.Int32)>>('TWHDWalletGetKeyDerivation');
  late final _TWHDWalletGetKeyDerivation =
      _TWHDWalletGetKeyDerivationPtr.asFunction<
          ffi.Pointer<TWPrivateKey> Function(
              ffi.Pointer<TWHDWallet>, int, int)>();

  /// Generates the private key for the specified derivation path and curve.
  ///
  /// \param wallet non-null TWHDWallet
  /// \param curve a curve
  /// \param derivationPath  a non-null derivation path
  /// \note Returned object needs to be deleted with \TWPrivateKeyDelete
  /// \return The private key for the specified derivation path/curve
  ffi.Pointer<TWPrivateKey> TWHDWalletGetKeyByCurve(
    ffi.Pointer<TWHDWallet> wallet,
    int curve,
    ffi.Pointer<TWString1> derivationPath,
  ) {
    return _TWHDWalletGetKeyByCurve(
      wallet,
      curve,
      derivationPath,
    );
  }

  late final _TWHDWalletGetKeyByCurvePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPrivateKey> Function(ffi.Pointer<TWHDWallet>, ffi.Int32,
              ffi.Pointer<TWString1>)>>('TWHDWalletGetKeyByCurve');
  late final _TWHDWalletGetKeyByCurve = _TWHDWalletGetKeyByCurvePtr.asFunction<
      ffi.Pointer<TWPrivateKey> Function(
          ffi.Pointer<TWHDWallet>, int, ffi.Pointer<TWString1>)>();

  /// Shortcut method to generate private key with the specified account/change/address (bip44 standard).
  ///
  /// \see https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
  ///
  /// \param wallet non-null TWHDWallet
  /// \param coin a coin type
  /// \param account valid bip44 account
  /// \param change valid bip44 change
  /// \param address valid bip44 address
  /// \note Returned object needs to be deleted with \TWPrivateKeyDelete
  /// \return The private key for the specified bip44 parameters
  ffi.Pointer<TWPrivateKey> TWHDWalletGetDerivedKey(
    ffi.Pointer<TWHDWallet> wallet,
    int coin,
    int account,
    int change,
    int address,
  ) {
    return _TWHDWalletGetDerivedKey(
      wallet,
      coin,
      account,
      change,
      address,
    );
  }

  late final _TWHDWalletGetDerivedKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPrivateKey> Function(ffi.Pointer<TWHDWallet>, ffi.Int32,
              ffi.Uint32, ffi.Uint32, ffi.Uint32)>>('TWHDWalletGetDerivedKey');
  late final _TWHDWalletGetDerivedKey = _TWHDWalletGetDerivedKeyPtr.asFunction<
      ffi.Pointer<TWPrivateKey> Function(
          ffi.Pointer<TWHDWallet>, int, int, int, int)>();

  /// Returns the extended private key (for default 0 account).
  ///
  /// \param wallet non-null TWHDWallet
  /// \param purpose a purpose
  /// \param coin a coin type
  /// \param version hd version
  /// \note Returned object needs to be deleted with \TWStringDelete
  /// \return  Extended private key as a non-null TWString
  ffi.Pointer<TWString1> TWHDWalletGetExtendedPrivateKey(
    ffi.Pointer<TWHDWallet> wallet,
    int purpose,
    int coin,
    int version,
  ) {
    return _TWHDWalletGetExtendedPrivateKey(
      wallet,
      purpose,
      coin,
      version,
    );
  }

  late final _TWHDWalletGetExtendedPrivateKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWHDWallet>, ffi.Int32,
              ffi.Int32, ffi.Int32)>>('TWHDWalletGetExtendedPrivateKey');
  late final _TWHDWalletGetExtendedPrivateKey =
      _TWHDWalletGetExtendedPrivateKeyPtr.asFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWHDWallet>, int, int, int)>();

  /// Returns the extended public key (for default 0 account).
  ///
  /// \param wallet non-null TWHDWallet
  /// \param purpose a purpose
  /// \param coin a coin type
  /// \param version hd version
  /// \note Returned object needs to be deleted with \TWStringDelete
  /// \return  Extended public key as a non-null TWString
  ffi.Pointer<TWString1> TWHDWalletGetExtendedPublicKey(
    ffi.Pointer<TWHDWallet> wallet,
    int purpose,
    int coin,
    int version,
  ) {
    return _TWHDWalletGetExtendedPublicKey(
      wallet,
      purpose,
      coin,
      version,
    );
  }

  late final _TWHDWalletGetExtendedPublicKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWHDWallet>, ffi.Int32,
              ffi.Int32, ffi.Int32)>>('TWHDWalletGetExtendedPublicKey');
  late final _TWHDWalletGetExtendedPublicKey =
      _TWHDWalletGetExtendedPublicKeyPtr.asFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWHDWallet>, int, int, int)>();

  /// Returns the extended private key, for custom account.
  ///
  /// \param wallet non-null TWHDWallet
  /// \param purpose a purpose
  /// \param coin a coin type
  /// \param derivation a derivation
  /// \param version an hd version
  /// \param account valid bip44 account
  /// \note Returned object needs to be deleted with \TWStringDelete
  /// \return  Extended private key as a non-null TWString
  ffi.Pointer<TWString1> TWHDWalletGetExtendedPrivateKeyAccount(
    ffi.Pointer<TWHDWallet> wallet,
    int purpose,
    int coin,
    int derivation,
    int version,
    int account,
  ) {
    return _TWHDWalletGetExtendedPrivateKeyAccount(
      wallet,
      purpose,
      coin,
      derivation,
      version,
      account,
    );
  }

  late final _TWHDWalletGetExtendedPrivateKeyAccountPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWHDWallet>,
              ffi.Int32,
              ffi.Int32,
              ffi.Int32,
              ffi.Int32,
              ffi.Uint32)>>('TWHDWalletGetExtendedPrivateKeyAccount');
  late final _TWHDWalletGetExtendedPrivateKeyAccount =
      _TWHDWalletGetExtendedPrivateKeyAccountPtr.asFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWHDWallet>, int, int, int, int, int)>();

  /// Returns the extended public key, for custom account.
  ///
  /// \param wallet non-null TWHDWallet
  /// \param purpose a purpose
  /// \param coin a coin type
  /// \param derivation a derivation
  /// \param version an hd version
  /// \param account valid bip44 account
  /// \note Returned object needs to be deleted with \TWStringDelete
  /// \return Extended public key as a non-null TWString
  ffi.Pointer<TWString1> TWHDWalletGetExtendedPublicKeyAccount(
    ffi.Pointer<TWHDWallet> wallet,
    int purpose,
    int coin,
    int derivation,
    int version,
    int account,
  ) {
    return _TWHDWalletGetExtendedPublicKeyAccount(
      wallet,
      purpose,
      coin,
      derivation,
      version,
      account,
    );
  }

  late final _TWHDWalletGetExtendedPublicKeyAccountPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWHDWallet>,
              ffi.Int32,
              ffi.Int32,
              ffi.Int32,
              ffi.Int32,
              ffi.Uint32)>>('TWHDWalletGetExtendedPublicKeyAccount');
  late final _TWHDWalletGetExtendedPublicKeyAccount =
      _TWHDWalletGetExtendedPublicKeyAccountPtr.asFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWHDWallet>, int, int, int, int, int)>();

  /// Returns the extended private key (for default 0 account with derivation).
  ///
  /// \param wallet non-null TWHDWallet
  /// \param purpose a purpose
  /// \param coin a coin type
  /// \param derivation a derivation
  /// \param version an hd version
  /// \note Returned object needs to be deleted with \TWStringDelete
  /// \return  Extended private key as a non-null TWString
  ffi.Pointer<TWString1> TWHDWalletGetExtendedPrivateKeyDerivation(
    ffi.Pointer<TWHDWallet> wallet,
    int purpose,
    int coin,
    int derivation,
    int version,
  ) {
    return _TWHDWalletGetExtendedPrivateKeyDerivation(
      wallet,
      purpose,
      coin,
      derivation,
      version,
    );
  }

  late final _TWHDWalletGetExtendedPrivateKeyDerivationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWHDWallet>,
              ffi.Int32,
              ffi.Int32,
              ffi.Int32,
              ffi.Int32)>>('TWHDWalletGetExtendedPrivateKeyDerivation');
  late final _TWHDWalletGetExtendedPrivateKeyDerivation =
      _TWHDWalletGetExtendedPrivateKeyDerivationPtr.asFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWHDWallet>, int, int, int, int)>();

  /// Returns the extended public key (for default 0 account with derivation).
  ///
  /// \param wallet non-null TWHDWallet
  /// \param purpose a purpose
  /// \param coin a coin type
  /// \param derivation a derivation
  /// \param version an hd version
  /// \note Returned object needs to be deleted with \TWStringDelete
  /// \return  Extended public key as a non-null TWString
  ffi.Pointer<TWString1> TWHDWalletGetExtendedPublicKeyDerivation(
    ffi.Pointer<TWHDWallet> wallet,
    int purpose,
    int coin,
    int derivation,
    int version,
  ) {
    return _TWHDWalletGetExtendedPublicKeyDerivation(
      wallet,
      purpose,
      coin,
      derivation,
      version,
    );
  }

  late final _TWHDWalletGetExtendedPublicKeyDerivationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWHDWallet>,
              ffi.Int32,
              ffi.Int32,
              ffi.Int32,
              ffi.Int32)>>('TWHDWalletGetExtendedPublicKeyDerivation');
  late final _TWHDWalletGetExtendedPublicKeyDerivation =
      _TWHDWalletGetExtendedPublicKeyDerivationPtr.asFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWHDWallet>, int, int, int, int)>();

  /// Computes the public key from an extended public key representation.
  ///
  /// \param extended extended public key
  /// \param coin a coin type
  /// \param derivationPath a derivation path
  /// \note Returned object needs to be deleted with \TWPublicKeyDelete
  /// \return Nullable TWPublic key
  ffi.Pointer<TWPublicKey> TWHDWalletGetPublicKeyFromExtended(
    ffi.Pointer<TWString1> extended,
    int coin,
    ffi.Pointer<TWString1> derivationPath,
  ) {
    return _TWHDWalletGetPublicKeyFromExtended(
      extended,
      coin,
      derivationPath,
    );
  }

  late final _TWHDWalletGetPublicKeyFromExtendedPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPublicKey> Function(ffi.Pointer<TWString1>, ffi.Int32,
              ffi.Pointer<TWString1>)>>('TWHDWalletGetPublicKeyFromExtended');
  late final _TWHDWalletGetPublicKeyFromExtended =
      _TWHDWalletGetPublicKeyFromExtendedPtr.asFunction<
          ffi.Pointer<TWPublicKey> Function(
              ffi.Pointer<TWString1>, int, ffi.Pointer<TWString1>)>();

  /// Loads a key from a file.
  ///
  /// \param path filepath to the key as a non-null string
  /// \note Returned object needs to be deleted with \TWStoredKeyDelete
  /// \return Nullptr if the key can't be load, the stored key otherwise
  ffi.Pointer<TWStoredKey> TWStoredKeyLoad(
    ffi.Pointer<TWString1> path,
  ) {
    return _TWStoredKeyLoad(
      path,
    );
  }

  late final _TWStoredKeyLoadPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWStoredKey> Function(
              ffi.Pointer<TWString1>)>>('TWStoredKeyLoad');
  late final _TWStoredKeyLoad = _TWStoredKeyLoadPtr.asFunction<
      ffi.Pointer<TWStoredKey> Function(ffi.Pointer<TWString1>)>();

  /// Imports a private key.
  ///
  /// \param privateKey Non-null Block of data private key
  /// \param name The name of the stored key to import as a non-null string
  /// \param password Non-null block of data, password of the stored key
  /// \param coin the coin type
  /// \note Returned object needs to be deleted with \TWStoredKeyDelete
  /// \return Nullptr if the key can't be imported, the stored key otherwise
  ffi.Pointer<TWStoredKey> TWStoredKeyImportPrivateKey(
    ffi.Pointer<TWData1> privateKey,
    ffi.Pointer<TWString1> name,
    ffi.Pointer<TWData1> password,
    int coin,
  ) {
    return _TWStoredKeyImportPrivateKey(
      privateKey,
      name,
      password,
      coin,
    );
  }

  late final _TWStoredKeyImportPrivateKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWStoredKey> Function(
              ffi.Pointer<TWData1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWData1>,
              ffi.Int32)>>('TWStoredKeyImportPrivateKey');
  late final _TWStoredKeyImportPrivateKey =
      _TWStoredKeyImportPrivateKeyPtr.asFunction<
          ffi.Pointer<TWStoredKey> Function(ffi.Pointer<TWData1>,
              ffi.Pointer<TWString1>, ffi.Pointer<TWData1>, int)>();

  /// Imports a private key.
  ///
  /// \param privateKey Non-null Block of data private key
  /// \param name The name of the stored key to import as a non-null string
  /// \param password Non-null block of data, password of the stored key
  /// \param coin the coin type
  /// \param encryption cipher encryption mode
  /// \note Returned object needs to be deleted with \TWStoredKeyDelete
  /// \return Nullptr if the key can't be imported, the stored key otherwise
  ffi.Pointer<TWStoredKey> TWStoredKeyImportPrivateKeyWithEncryption(
    ffi.Pointer<TWData1> privateKey,
    ffi.Pointer<TWString1> name,
    ffi.Pointer<TWData1> password,
    int coin,
    int encryption,
  ) {
    return _TWStoredKeyImportPrivateKeyWithEncryption(
      privateKey,
      name,
      password,
      coin,
      encryption,
    );
  }

  late final _TWStoredKeyImportPrivateKeyWithEncryptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWStoredKey> Function(
              ffi.Pointer<TWData1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWData1>,
              ffi.Int32,
              ffi.Int32)>>('TWStoredKeyImportPrivateKeyWithEncryption');
  late final _TWStoredKeyImportPrivateKeyWithEncryption =
      _TWStoredKeyImportPrivateKeyWithEncryptionPtr.asFunction<
          ffi.Pointer<TWStoredKey> Function(ffi.Pointer<TWData1>,
              ffi.Pointer<TWString1>, ffi.Pointer<TWData1>, int, int)>();

  /// Imports an HD wallet.
  ///
  /// \param mnemonic Non-null bip39 mnemonic
  /// \param name The name of the stored key to import as a non-null string
  /// \param password Non-null block of data, password of the stored key
  /// \param coin the coin type
  /// \note Returned object needs to be deleted with \TWStoredKeyDelete
  /// \return Nullptr if the key can't be imported, the stored key otherwise
  ffi.Pointer<TWStoredKey> TWStoredKeyImportHDWallet(
    ffi.Pointer<TWString1> mnemonic,
    ffi.Pointer<TWString1> name,
    ffi.Pointer<TWData1> password,
    int coin,
  ) {
    return _TWStoredKeyImportHDWallet(
      mnemonic,
      name,
      password,
      coin,
    );
  }

  late final _TWStoredKeyImportHDWalletPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWStoredKey> Function(
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWData1>,
              ffi.Int32)>>('TWStoredKeyImportHDWallet');
  late final _TWStoredKeyImportHDWallet =
      _TWStoredKeyImportHDWalletPtr.asFunction<
          ffi.Pointer<TWStoredKey> Function(ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>, ffi.Pointer<TWData1>, int)>();

  /// Imports an HD wallet.
  ///
  /// \param mnemonic Non-null bip39 mnemonic
  /// \param name The name of the stored key to import as a non-null string
  /// \param password Non-null block of data, password of the stored key
  /// \param coin the coin type
  /// \param encryption cipher encryption mode
  /// \note Returned object needs to be deleted with \TWStoredKeyDelete
  /// \return Nullptr if the key can't be imported, the stored key otherwise
  ffi.Pointer<TWStoredKey> TWStoredKeyImportHDWalletWithEncryption(
    ffi.Pointer<TWString1> mnemonic,
    ffi.Pointer<TWString1> name,
    ffi.Pointer<TWData1> password,
    int coin,
    int encryption,
  ) {
    return _TWStoredKeyImportHDWalletWithEncryption(
      mnemonic,
      name,
      password,
      coin,
      encryption,
    );
  }

  late final _TWStoredKeyImportHDWalletWithEncryptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWStoredKey> Function(
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWData1>,
              ffi.Int32,
              ffi.Int32)>>('TWStoredKeyImportHDWalletWithEncryption');
  late final _TWStoredKeyImportHDWalletWithEncryption =
      _TWStoredKeyImportHDWalletWithEncryptionPtr.asFunction<
          ffi.Pointer<TWStoredKey> Function(ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>, ffi.Pointer<TWData1>, int, int)>();

  /// Imports a key from JSON.
  ///
  /// \param json Json stored key import format as a non-null block of data
  /// \note Returned object needs to be deleted with \TWStoredKeyDelete
  /// \return Nullptr if the key can't be imported, the stored key otherwise
  ffi.Pointer<TWStoredKey> TWStoredKeyImportJSON(
    ffi.Pointer<TWData1> json,
  ) {
    return _TWStoredKeyImportJSON(
      json,
    );
  }

  late final _TWStoredKeyImportJSONPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWStoredKey> Function(
              ffi.Pointer<TWData1>)>>('TWStoredKeyImportJSON');
  late final _TWStoredKeyImportJSON = _TWStoredKeyImportJSONPtr.asFunction<
      ffi.Pointer<TWStoredKey> Function(ffi.Pointer<TWData1>)>();

  /// Creates a new key, with given encryption strength level. Returned object needs to be deleted.
  ///
  /// \param name The name of the key to be stored
  /// \param password Non-null block of data, password of the stored key
  /// \param encryptionLevel The level of encryption, see \TWStoredKeyEncryptionLevel
  /// \note Returned object needs to be deleted with \TWStoredKeyDelete
  /// \return The stored key as a non-null pointer
  ffi.Pointer<TWStoredKey> TWStoredKeyCreateLevel(
    ffi.Pointer<TWString1> name,
    ffi.Pointer<TWData1> password,
    int encryptionLevel,
  ) {
    return _TWStoredKeyCreateLevel(
      name,
      password,
      encryptionLevel,
    );
  }

  late final _TWStoredKeyCreateLevelPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWStoredKey> Function(ffi.Pointer<TWString1>,
              ffi.Pointer<TWData1>, ffi.Int32)>>('TWStoredKeyCreateLevel');
  late final _TWStoredKeyCreateLevel = _TWStoredKeyCreateLevelPtr.asFunction<
      ffi.Pointer<TWStoredKey> Function(
          ffi.Pointer<TWString1>, ffi.Pointer<TWData1>, int)>();

  /// Creates a new key, with given encryption strength level.  Returned object needs to be deleted.
  ///
  /// \param name The name of the key to be stored
  /// \param password Non-null block of data, password of the stored key
  /// \param encryptionLevel The level of encryption, see \TWStoredKeyEncryptionLevel
  /// \param encryption cipher encryption mode
  /// \note Returned object needs to be deleted with \TWStoredKeyDelete
  /// \return The stored key as a non-null pointer
  ffi.Pointer<TWStoredKey> TWStoredKeyCreateLevelAndEncryption(
    ffi.Pointer<TWString1> name,
    ffi.Pointer<TWData1> password,
    int encryptionLevel,
    int encryption,
  ) {
    return _TWStoredKeyCreateLevelAndEncryption(
      name,
      password,
      encryptionLevel,
      encryption,
    );
  }

  late final _TWStoredKeyCreateLevelAndEncryptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWStoredKey> Function(
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWData1>,
              ffi.Int32,
              ffi.Int32)>>('TWStoredKeyCreateLevelAndEncryption');
  late final _TWStoredKeyCreateLevelAndEncryption =
      _TWStoredKeyCreateLevelAndEncryptionPtr.asFunction<
          ffi.Pointer<TWStoredKey> Function(
              ffi.Pointer<TWString1>, ffi.Pointer<TWData1>, int, int)>();

  /// Creates a new key.
  ///
  /// \deprecated use TWStoredKeyCreateLevel.
  /// \param name The name of the key to be stored
  /// \param password Non-null block of data, password of the stored key
  /// \note Returned object needs to be deleted with \TWStoredKeyDelete
  /// \return The stored key as a non-null pointer
  ffi.Pointer<TWStoredKey> TWStoredKeyCreate(
    ffi.Pointer<TWString1> name,
    ffi.Pointer<TWData1> password,
  ) {
    return _TWStoredKeyCreate(
      name,
      password,
    );
  }

  late final _TWStoredKeyCreatePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWStoredKey> Function(ffi.Pointer<TWString1>,
              ffi.Pointer<TWData1>)>>('TWStoredKeyCreate');
  late final _TWStoredKeyCreate = _TWStoredKeyCreatePtr.asFunction<
      ffi.Pointer<TWStoredKey> Function(
          ffi.Pointer<TWString1>, ffi.Pointer<TWData1>)>();

  /// Creates a new key.
  ///
  /// \deprecated use TWStoredKeyCreateLevel.
  /// \param name The name of the key to be stored
  /// \param password Non-null block of data, password of the stored key
  /// \param encryption cipher encryption mode
  /// \note Returned object needs to be deleted with \TWStoredKeyDelete
  /// \return The stored key as a non-null pointer
  ffi.Pointer<TWStoredKey> TWStoredKeyCreateEncryption(
    ffi.Pointer<TWString1> name,
    ffi.Pointer<TWData1> password,
    int encryption,
  ) {
    return _TWStoredKeyCreateEncryption(
      name,
      password,
      encryption,
    );
  }

  late final _TWStoredKeyCreateEncryptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWStoredKey> Function(ffi.Pointer<TWString1>,
              ffi.Pointer<TWData1>, ffi.Int32)>>('TWStoredKeyCreateEncryption');
  late final _TWStoredKeyCreateEncryption =
      _TWStoredKeyCreateEncryptionPtr.asFunction<
          ffi.Pointer<TWStoredKey> Function(
              ffi.Pointer<TWString1>, ffi.Pointer<TWData1>, int)>();

  /// Delete a stored key
  ///
  /// \param key The key to be deleted
  void TWStoredKeyDelete(
    ffi.Pointer<TWStoredKey> key,
  ) {
    return _TWStoredKeyDelete(
      key,
    );
  }

  late final _TWStoredKeyDeletePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWStoredKey>)>>(
          'TWStoredKeyDelete');
  late final _TWStoredKeyDelete = _TWStoredKeyDeletePtr.asFunction<
      void Function(ffi.Pointer<TWStoredKey>)>();

  /// Stored key unique identifier.
  ///
  /// \param key Non-null pointer to a stored key
  /// \note Returned object needs to be deleted with \TWStringDelete
  /// \return The stored key unique identifier if it's found, null pointer otherwise.
  ffi.Pointer<TWString1> TWStoredKeyIdentifier(
    ffi.Pointer<TWStoredKey> key,
  ) {
    return _TWStoredKeyIdentifier(
      key,
    );
  }

  late final _TWStoredKeyIdentifierPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWStoredKey>)>>('TWStoredKeyIdentifier');
  late final _TWStoredKeyIdentifier = _TWStoredKeyIdentifierPtr.asFunction<
      ffi.Pointer<TWString1> Function(ffi.Pointer<TWStoredKey>)>();

  /// Stored key namer.
  ///
  /// \param key Non-null pointer to a stored key
  /// \note Returned object needs to be deleted with \TWStringDelete
  /// \return The stored key name as a non-null string pointer.
  ffi.Pointer<TWString1> TWStoredKeyName(
    ffi.Pointer<TWStoredKey> key,
  ) {
    return _TWStoredKeyName(
      key,
    );
  }

  late final _TWStoredKeyNamePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWStoredKey>)>>('TWStoredKeyName');
  late final _TWStoredKeyName = _TWStoredKeyNamePtr.asFunction<
      ffi.Pointer<TWString1> Function(ffi.Pointer<TWStoredKey>)>();

  /// Whether this key is a mnemonic phrase for a HD wallet.
  ///
  /// \param key Non-null pointer to a stored key
  /// \return true if the given stored key is a mnemonic, false otherwise
  bool TWStoredKeyIsMnemonic(
    ffi.Pointer<TWStoredKey> key,
  ) {
    return _TWStoredKeyIsMnemonic(
      key,
    );
  }

  late final _TWStoredKeyIsMnemonicPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWStoredKey>)>>(
          'TWStoredKeyIsMnemonic');
  late final _TWStoredKeyIsMnemonic = _TWStoredKeyIsMnemonicPtr.asFunction<
      bool Function(ffi.Pointer<TWStoredKey>)>();

  /// The number of accounts.
  ///
  /// \param key Non-null pointer to a stored key
  /// \return the number of accounts associated to the given stored key
  int TWStoredKeyAccountCount(
    ffi.Pointer<TWStoredKey> key,
  ) {
    return _TWStoredKeyAccountCount(
      key,
    );
  }

  late final _TWStoredKeyAccountCountPtr =
      _lookup<ffi.NativeFunction<ffi.Size Function(ffi.Pointer<TWStoredKey>)>>(
          'TWStoredKeyAccountCount');
  late final _TWStoredKeyAccountCount = _TWStoredKeyAccountCountPtr.asFunction<
      int Function(ffi.Pointer<TWStoredKey>)>();

  /// Returns the account at a given index.
  ///
  /// \param key Non-null pointer to a stored key
  /// \param index the account index to be retrieved
  /// \note Returned object needs to be deleted with \TWAccountDelete
  /// \return Null pointer if the associated account is not found, pointer to the account otherwise.
  ffi.Pointer<TWAccount> TWStoredKeyAccount(
    ffi.Pointer<TWStoredKey> key,
    int index,
  ) {
    return _TWStoredKeyAccount(
      key,
      index,
    );
  }

  late final _TWStoredKeyAccountPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWAccount> Function(
              ffi.Pointer<TWStoredKey>, ffi.Size)>>('TWStoredKeyAccount');
  late final _TWStoredKeyAccount = _TWStoredKeyAccountPtr.asFunction<
      ffi.Pointer<TWAccount> Function(ffi.Pointer<TWStoredKey>, int)>();

  /// Returns the account for a specific coin, creating it if necessary.
  ///
  /// \param key Non-null pointer to a stored key
  /// \param coin The coin type
  /// \param wallet The associated HD wallet, can be null.
  /// \note Returned object needs to be deleted with \TWAccountDelete
  /// \return Null pointer if the associated account is not found/not created, pointer to the account otherwise.
  ffi.Pointer<TWAccount> TWStoredKeyAccountForCoin(
    ffi.Pointer<TWStoredKey> key,
    int coin,
    ffi.Pointer<TWHDWallet> wallet,
  ) {
    return _TWStoredKeyAccountForCoin(
      key,
      coin,
      wallet,
    );
  }

  late final _TWStoredKeyAccountForCoinPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWAccount> Function(ffi.Pointer<TWStoredKey>, ffi.Int32,
              ffi.Pointer<TWHDWallet>)>>('TWStoredKeyAccountForCoin');
  late final _TWStoredKeyAccountForCoin =
      _TWStoredKeyAccountForCoinPtr.asFunction<
          ffi.Pointer<TWAccount> Function(
              ffi.Pointer<TWStoredKey>, int, ffi.Pointer<TWHDWallet>)>();

  /// Returns the account for a specific coin + derivation, creating it if necessary.
  ///
  /// \param key Non-null pointer to a stored key
  /// \param coin The coin type
  /// \param derivation The derivation for the given coin
  /// \param wallet the associated HD wallet, can be null.
  /// \note Returned object needs to be deleted with \TWAccountDelete
  /// \return Null pointer if the associated account is not found/not created, pointer to the account otherwise.
  ffi.Pointer<TWAccount> TWStoredKeyAccountForCoinDerivation(
    ffi.Pointer<TWStoredKey> key,
    int coin,
    int derivation,
    ffi.Pointer<TWHDWallet> wallet,
  ) {
    return _TWStoredKeyAccountForCoinDerivation(
      key,
      coin,
      derivation,
      wallet,
    );
  }

  late final _TWStoredKeyAccountForCoinDerivationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWAccount> Function(
              ffi.Pointer<TWStoredKey>,
              ffi.Int32,
              ffi.Int32,
              ffi.Pointer<TWHDWallet>)>>('TWStoredKeyAccountForCoinDerivation');
  late final _TWStoredKeyAccountForCoinDerivation =
      _TWStoredKeyAccountForCoinDerivationPtr.asFunction<
          ffi.Pointer<TWAccount> Function(
              ffi.Pointer<TWStoredKey>, int, int, ffi.Pointer<TWHDWallet>)>();

  /// Adds a new account, using given derivation (usually TWDerivationDefault)
  /// and derivation path (usually matches path from derivation, but custom possible).
  ///
  /// \param key Non-null pointer to a stored key
  /// \param address Non-null pointer to the address of the coin for this account
  /// \param coin coin type
  /// \param derivation derivation of the given coin type
  /// \param derivationPath HD bip44 derivation path of the given coin
  /// \param publicKey Non-null public key of the given coin/address
  /// \param extendedPublicKey Non-null extended public key of the given coin/address
  void TWStoredKeyAddAccountDerivation(
    ffi.Pointer<TWStoredKey> key,
    ffi.Pointer<TWString1> address,
    int coin,
    int derivation,
    ffi.Pointer<TWString1> derivationPath,
    ffi.Pointer<TWString1> publicKey,
    ffi.Pointer<TWString1> extendedPublicKey,
  ) {
    return _TWStoredKeyAddAccountDerivation(
      key,
      address,
      coin,
      derivation,
      derivationPath,
      publicKey,
      extendedPublicKey,
    );
  }

  late final _TWStoredKeyAddAccountDerivationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<TWStoredKey>,
              ffi.Pointer<TWString1>,
              ffi.Int32,
              ffi.Int32,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>)>>('TWStoredKeyAddAccountDerivation');
  late final _TWStoredKeyAddAccountDerivation =
      _TWStoredKeyAddAccountDerivationPtr.asFunction<
          void Function(
              ffi.Pointer<TWStoredKey>,
              ffi.Pointer<TWString1>,
              int,
              int,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>)>();

  /// Adds a new account, using given derivation path.
  ///
  /// \deprecated Use TWStoredKeyAddAccountDerivation (with TWDerivationDefault) instead.
  /// \param key Non-null pointer to a stored key
  /// \param address Non-null pointer to the address of the coin for this account
  /// \param coin coin type
  /// \param derivationPath HD bip44 derivation path of the given coin
  /// \param publicKey Non-null public key of the given coin/address
  /// \param extendedPublicKey Non-null extended public key of the given coin/address
  void TWStoredKeyAddAccount(
    ffi.Pointer<TWStoredKey> key,
    ffi.Pointer<TWString1> address,
    int coin,
    ffi.Pointer<TWString1> derivationPath,
    ffi.Pointer<TWString1> publicKey,
    ffi.Pointer<TWString1> extendedPublicKey,
  ) {
    return _TWStoredKeyAddAccount(
      key,
      address,
      coin,
      derivationPath,
      publicKey,
      extendedPublicKey,
    );
  }

  late final _TWStoredKeyAddAccountPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<TWStoredKey>,
              ffi.Pointer<TWString1>,
              ffi.Int32,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>)>>('TWStoredKeyAddAccount');
  late final _TWStoredKeyAddAccount = _TWStoredKeyAddAccountPtr.asFunction<
      void Function(
          ffi.Pointer<TWStoredKey>,
          ffi.Pointer<TWString1>,
          int,
          ffi.Pointer<TWString1>,
          ffi.Pointer<TWString1>,
          ffi.Pointer<TWString1>)>();

  /// Remove the account for a specific coin
  ///
  /// \param key Non-null pointer to a stored key
  /// \param coin Account coin type to be removed
  void TWStoredKeyRemoveAccountForCoin(
    ffi.Pointer<TWStoredKey> key,
    int coin,
  ) {
    return _TWStoredKeyRemoveAccountForCoin(
      key,
      coin,
    );
  }

  late final _TWStoredKeyRemoveAccountForCoinPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<TWStoredKey>,
              ffi.Int32)>>('TWStoredKeyRemoveAccountForCoin');
  late final _TWStoredKeyRemoveAccountForCoin =
      _TWStoredKeyRemoveAccountForCoinPtr.asFunction<
          void Function(ffi.Pointer<TWStoredKey>, int)>();

  /// Remove the account for a specific coin with the given derivation.
  ///
  /// \param key Non-null pointer to a stored key
  /// \param coin Account coin type to be removed
  /// \param derivation The derivation of the given coin type
  void TWStoredKeyRemoveAccountForCoinDerivation(
    ffi.Pointer<TWStoredKey> key,
    int coin,
    int derivation,
  ) {
    return _TWStoredKeyRemoveAccountForCoinDerivation(
      key,
      coin,
      derivation,
    );
  }

  late final _TWStoredKeyRemoveAccountForCoinDerivationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<TWStoredKey>, ffi.Int32,
              ffi.Int32)>>('TWStoredKeyRemoveAccountForCoinDerivation');
  late final _TWStoredKeyRemoveAccountForCoinDerivation =
      _TWStoredKeyRemoveAccountForCoinDerivationPtr.asFunction<
          void Function(ffi.Pointer<TWStoredKey>, int, int)>();

  /// Remove the account for a specific coin with the given derivation path.
  ///
  /// \param key Non-null pointer to a stored key
  /// \param coin Account coin type to be removed
  /// \param derivationPath The derivation path (bip44) of the given coin type
  void TWStoredKeyRemoveAccountForCoinDerivationPath(
    ffi.Pointer<TWStoredKey> key,
    int coin,
    ffi.Pointer<TWString1> derivationPath,
  ) {
    return _TWStoredKeyRemoveAccountForCoinDerivationPath(
      key,
      coin,
      derivationPath,
    );
  }

  late final _TWStoredKeyRemoveAccountForCoinDerivationPathPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<TWStoredKey>, ffi.Int32,
                  ffi.Pointer<TWString1>)>>(
      'TWStoredKeyRemoveAccountForCoinDerivationPath');
  late final _TWStoredKeyRemoveAccountForCoinDerivationPath =
      _TWStoredKeyRemoveAccountForCoinDerivationPathPtr.asFunction<
          void Function(
              ffi.Pointer<TWStoredKey>, int, ffi.Pointer<TWString1>)>();

  /// Saves the key to a file.
  ///
  /// \param key Non-null pointer to a stored key
  /// \param path Non-null string filepath where the key will be saved
  /// \return true if the key was successfully stored in the given filepath file, false otherwise
  bool TWStoredKeyStore(
    ffi.Pointer<TWStoredKey> key,
    ffi.Pointer<TWString1> path,
  ) {
    return _TWStoredKeyStore(
      key,
      path,
    );
  }

  late final _TWStoredKeyStorePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWStoredKey>,
              ffi.Pointer<TWString1>)>>('TWStoredKeyStore');
  late final _TWStoredKeyStore = _TWStoredKeyStorePtr.asFunction<
      bool Function(ffi.Pointer<TWStoredKey>, ffi.Pointer<TWString1>)>();

  /// Decrypts the private key.
  ///
  /// \param key Non-null pointer to a stored key
  /// \param password Non-null block of data, password of the stored key
  /// \return Decrypted private key as a block of data if success, null pointer otherwise
  ffi.Pointer<TWData1> TWStoredKeyDecryptPrivateKey(
    ffi.Pointer<TWStoredKey> key,
    ffi.Pointer<TWData1> password,
  ) {
    return _TWStoredKeyDecryptPrivateKey(
      key,
      password,
    );
  }

  late final _TWStoredKeyDecryptPrivateKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(ffi.Pointer<TWStoredKey>,
              ffi.Pointer<TWData1>)>>('TWStoredKeyDecryptPrivateKey');
  late final _TWStoredKeyDecryptPrivateKey =
      _TWStoredKeyDecryptPrivateKeyPtr.asFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWStoredKey>, ffi.Pointer<TWData1>)>();

  /// Decrypts the mnemonic phrase.
  ///
  /// \param key Non-null pointer to a stored key
  /// \param password Non-null block of data, password of the stored key
  /// \return Bip39 decrypted mnemonic if success, null pointer otherwise
  ffi.Pointer<TWString1> TWStoredKeyDecryptMnemonic(
    ffi.Pointer<TWStoredKey> key,
    ffi.Pointer<TWData1> password,
  ) {
    return _TWStoredKeyDecryptMnemonic(
      key,
      password,
    );
  }

  late final _TWStoredKeyDecryptMnemonicPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWStoredKey>,
              ffi.Pointer<TWData1>)>>('TWStoredKeyDecryptMnemonic');
  late final _TWStoredKeyDecryptMnemonic =
      _TWStoredKeyDecryptMnemonicPtr.asFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWStoredKey>, ffi.Pointer<TWData1>)>();

  /// Returns the private key for a specific coin.  Returned object needs to be deleted.
  ///
  /// \param key Non-null pointer to a stored key
  /// \param coin Account coin type to be queried
  /// \note Returned object needs to be deleted with \TWPrivateKeyDelete
  /// \return Null pointer on failure, pointer to the private key otherwise
  ffi.Pointer<TWPrivateKey> TWStoredKeyPrivateKey(
    ffi.Pointer<TWStoredKey> key,
    int coin,
    ffi.Pointer<TWData1> password,
  ) {
    return _TWStoredKeyPrivateKey(
      key,
      coin,
      password,
    );
  }

  late final _TWStoredKeyPrivateKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPrivateKey> Function(ffi.Pointer<TWStoredKey>,
              ffi.Int32, ffi.Pointer<TWData1>)>>('TWStoredKeyPrivateKey');
  late final _TWStoredKeyPrivateKey = _TWStoredKeyPrivateKeyPtr.asFunction<
      ffi.Pointer<TWPrivateKey> Function(
          ffi.Pointer<TWStoredKey>, int, ffi.Pointer<TWData1>)>();

  /// Decrypts and returns the HD Wallet for mnemonic phrase keys.  Returned object needs to be deleted.
  ///
  /// \param key Non-null pointer to a stored key
  /// \param password Non-null block of data, password of the stored key
  /// \note Returned object needs to be deleted with \TWHDWalletDelete
  /// \return Null pointer on failure, pointer to the HDWallet otherwise
  ffi.Pointer<TWHDWallet> TWStoredKeyWallet(
    ffi.Pointer<TWStoredKey> key,
    ffi.Pointer<TWData1> password,
  ) {
    return _TWStoredKeyWallet(
      key,
      password,
    );
  }

  late final _TWStoredKeyWalletPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWHDWallet> Function(ffi.Pointer<TWStoredKey>,
              ffi.Pointer<TWData1>)>>('TWStoredKeyWallet');
  late final _TWStoredKeyWallet = _TWStoredKeyWalletPtr.asFunction<
      ffi.Pointer<TWHDWallet> Function(
          ffi.Pointer<TWStoredKey>, ffi.Pointer<TWData1>)>();

  /// Exports the key as JSON
  ///
  /// \param key Non-null pointer to a stored key
  /// \return Null pointer on failure, pointer to a block of data containing the json otherwise
  ffi.Pointer<TWData1> TWStoredKeyExportJSON(
    ffi.Pointer<TWStoredKey> key,
  ) {
    return _TWStoredKeyExportJSON(
      key,
    );
  }

  late final _TWStoredKeyExportJSONPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWStoredKey>)>>('TWStoredKeyExportJSON');
  late final _TWStoredKeyExportJSON = _TWStoredKeyExportJSONPtr.asFunction<
      ffi.Pointer<TWData1> Function(ffi.Pointer<TWStoredKey>)>();

  /// Fills in empty and invalid addresses.
  /// This method needs the encryption password to re-derive addresses from private keys.
  ///
  /// \param key Non-null pointer to a stored key
  /// \param password Non-null block of data, password of the stored key
  /// \return `false` if the password is incorrect, true otherwise.
  bool TWStoredKeyFixAddresses(
    ffi.Pointer<TWStoredKey> key,
    ffi.Pointer<TWData1> password,
  ) {
    return _TWStoredKeyFixAddresses(
      key,
      password,
    );
  }

  late final _TWStoredKeyFixAddressesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWStoredKey>,
              ffi.Pointer<TWData1>)>>('TWStoredKeyFixAddresses');
  late final _TWStoredKeyFixAddresses = _TWStoredKeyFixAddressesPtr.asFunction<
      bool Function(ffi.Pointer<TWStoredKey>, ffi.Pointer<TWData1>)>();

  /// Retrieve stored key encoding parameters, as JSON string.
  ///
  /// \param key Non-null pointer to a stored key
  /// \return Null pointer on failure, encoding parameter as a json string otherwise.
  ffi.Pointer<TWString1> TWStoredKeyEncryptionParameters(
    ffi.Pointer<TWStoredKey> key,
  ) {
    return _TWStoredKeyEncryptionParameters(
      key,
    );
  }

  late final _TWStoredKeyEncryptionParametersPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWStoredKey>)>>('TWStoredKeyEncryptionParameters');
  late final _TWStoredKeyEncryptionParameters =
      _TWStoredKeyEncryptionParametersPtr.asFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWStoredKey>)>();

  /// Compares two addresses for equality.
  ///
  /// \param lhs left non-null pointer to a Ripple Address
  /// \param rhs right non-null pointer to a Ripple Address
  /// \return true if both address are equal, false otherwise
  bool TWRippleXAddressEqual(
    ffi.Pointer<TWRippleXAddress> lhs,
    ffi.Pointer<TWRippleXAddress> rhs,
  ) {
    return _TWRippleXAddressEqual(
      lhs,
      rhs,
    );
  }

  late final _TWRippleXAddressEqualPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWRippleXAddress>,
              ffi.Pointer<TWRippleXAddress>)>>('TWRippleXAddressEqual');
  late final _TWRippleXAddressEqual = _TWRippleXAddressEqualPtr.asFunction<
      bool Function(
          ffi.Pointer<TWRippleXAddress>, ffi.Pointer<TWRippleXAddress>)>();

  /// Determines if the string is a valid Ripple address.
  ///
  /// \param string Non-null pointer to a string that represent the Ripple Address to be checked
  /// \return true if the given address is a valid Ripple address, false otherwise
  bool TWRippleXAddressIsValidString(
    ffi.Pointer<TWString1> string,
  ) {
    return _TWRippleXAddressIsValidString(
      string,
    );
  }

  late final _TWRippleXAddressIsValidStringPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWString1>)>>(
          'TWRippleXAddressIsValidString');
  late final _TWRippleXAddressIsValidString = _TWRippleXAddressIsValidStringPtr
      .asFunction<bool Function(ffi.Pointer<TWString1>)>();

  /// Creates an address from a string representation.
  ///
  /// \param string Non-null pointer to a string that should be a valid ripple address
  /// \note Should be deleted with \TWRippleXAddressDelete
  /// \return Null pointer if the given string is an invalid ripple address, pointer to a Ripple address otherwise
  ffi.Pointer<TWRippleXAddress> TWRippleXAddressCreateWithString(
    ffi.Pointer<TWString1> string,
  ) {
    return _TWRippleXAddressCreateWithString(
      string,
    );
  }

  late final _TWRippleXAddressCreateWithStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWRippleXAddress> Function(
              ffi.Pointer<TWString1>)>>('TWRippleXAddressCreateWithString');
  late final _TWRippleXAddressCreateWithString =
      _TWRippleXAddressCreateWithStringPtr.asFunction<
          ffi.Pointer<TWRippleXAddress> Function(ffi.Pointer<TWString1>)>();

  /// Creates an address from a public key and destination tag.
  ///
  /// \param publicKey Non-null pointer to a public key
  /// \param tag valid ripple destination tag (1-10)
  /// \note Should be deleted with \TWRippleXAddressDelete
  /// \return Non-null pointer to a Ripple Address
  ffi.Pointer<TWRippleXAddress> TWRippleXAddressCreateWithPublicKey(
    ffi.Pointer<TWPublicKey> publicKey,
    int tag,
  ) {
    return _TWRippleXAddressCreateWithPublicKey(
      publicKey,
      tag,
    );
  }

  late final _TWRippleXAddressCreateWithPublicKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWRippleXAddress> Function(ffi.Pointer<TWPublicKey>,
              ffi.Uint32)>>('TWRippleXAddressCreateWithPublicKey');
  late final _TWRippleXAddressCreateWithPublicKey =
      _TWRippleXAddressCreateWithPublicKeyPtr.asFunction<
          ffi.Pointer<TWRippleXAddress> Function(
              ffi.Pointer<TWPublicKey>, int)>();

  /// Delete the given ripple address
  ///
  /// \param address Non-null pointer to a Ripple Address
  void TWRippleXAddressDelete(
    ffi.Pointer<TWRippleXAddress> address,
  ) {
    return _TWRippleXAddressDelete(
      address,
    );
  }

  late final _TWRippleXAddressDeletePtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWRippleXAddress>)>>(
      'TWRippleXAddressDelete');
  late final _TWRippleXAddressDelete = _TWRippleXAddressDeletePtr.asFunction<
      void Function(ffi.Pointer<TWRippleXAddress>)>();

  /// Returns the address string representation.
  ///
  /// \param address Non-null pointer to a Ripple Address
  /// \return Non-null pointer to the ripple address string representation
  ffi.Pointer<TWString1> TWRippleXAddressDescription(
    ffi.Pointer<TWRippleXAddress> address,
  ) {
    return _TWRippleXAddressDescription(
      address,
    );
  }

  late final _TWRippleXAddressDescriptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWRippleXAddress>)>>('TWRippleXAddressDescription');
  late final _TWRippleXAddressDescription =
      _TWRippleXAddressDescriptionPtr.asFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWRippleXAddress>)>();

  /// Returns the destination tag.
  ///
  /// \param address Non-null pointer to a Ripple Address
  /// \return The destination tag of the given Ripple Address (1-10)
  int TWRippleXAddressTag(
    ffi.Pointer<TWRippleXAddress> address,
  ) {
    return _TWRippleXAddressTag(
      address,
    );
  }

  late final _TWRippleXAddressTagPtr = _lookup<
          ffi
          .NativeFunction<ffi.Uint32 Function(ffi.Pointer<TWRippleXAddress>)>>(
      'TWRippleXAddressTag');
  late final _TWRippleXAddressTag = _TWRippleXAddressTagPtr.asFunction<
      int Function(ffi.Pointer<TWRippleXAddress>)>();

  /// Decode a Base64 input with the default alphabet (RFC4648 with '+', '/')
  ///
  /// \param string Encoded input to be decoded
  /// \return The decoded data, empty if decoding failed.
  ffi.Pointer<TWData> TWBase64Decode(
    ffi.Pointer<TWString> string,
  ) {
    return _TWBase64Decode(
      string,
    );
  }

  late final _TWBase64DecodePtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWString>)>>(
      'TWBase64Decode');
  late final _TWBase64Decode = _TWBase64DecodePtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWString>)>();

  /// Decode a Base64 input with the alphabet safe for URL-s and filenames (RFC4648 with '-', '_')
  ///
  /// \param string Encoded base64 input to be decoded
  /// \return The decoded data, empty if decoding failed.
  ffi.Pointer<TWData> TWBase64DecodeUrl(
    ffi.Pointer<TWString> string,
  ) {
    return _TWBase64DecodeUrl(
      string,
    );
  }

  late final _TWBase64DecodeUrlPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWString>)>>(
      'TWBase64DecodeUrl');
  late final _TWBase64DecodeUrl = _TWBase64DecodeUrlPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWString>)>();

  /// Encode an input to Base64 with the default alphabet (RFC4648 with '+', '/')
  ///
  /// \param data Data to be encoded (raw bytes)
  /// \return The encoded data
  ffi.Pointer<TWString> TWBase64Encode(
    ffi.Pointer<TWData> data,
  ) {
    return _TWBase64Encode(
      data,
    );
  }

  late final _TWBase64EncodePtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWString> Function(ffi.Pointer<TWData>)>>(
      'TWBase64Encode');
  late final _TWBase64Encode = _TWBase64EncodePtr.asFunction<
      ffi.Pointer<TWString> Function(ffi.Pointer<TWData>)>();

  /// Encode an input to Base64 with the alphabet safe for URL-s and filenames (RFC4648 with '-', '_')
  ///
  /// \param data Data to be encoded (raw bytes)
  /// \return The encoded data
  ffi.Pointer<TWString> TWBase64EncodeUrl(
    ffi.Pointer<TWData> data,
  ) {
    return _TWBase64EncodeUrl(
      data,
    );
  }

  late final _TWBase64EncodeUrlPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWString> Function(ffi.Pointer<TWData>)>>(
      'TWBase64EncodeUrl');
  late final _TWBase64EncodeUrl = _TWBase64EncodeUrlPtr.asFunction<
      ffi.Pointer<TWString> Function(ffi.Pointer<TWData>)>();

  /// Determines whether a BIP39 English mnemonic phrase is valid.
  ///
  /// \param mnemonic Non-null BIP39 english mnemonic
  /// \return true if the mnemonic is valid, false otherwise
  bool TWMnemonicIsValid(
    ffi.Pointer<TWString1> mnemonic,
  ) {
    return _TWMnemonicIsValid(
      mnemonic,
    );
  }

  late final _TWMnemonicIsValidPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWString1>)>>(
          'TWMnemonicIsValid');
  late final _TWMnemonicIsValid =
      _TWMnemonicIsValidPtr.asFunction<bool Function(ffi.Pointer<TWString1>)>();

  /// Determines whether word is a valid BIP39 English mnemonic word.
  ///
  /// \param word Non-null BIP39 English mnemonic word
  /// \return true if the word is a valid BIP39 English mnemonic word, false otherwise
  bool TWMnemonicIsValidWord(
    ffi.Pointer<TWString1> word,
  ) {
    return _TWMnemonicIsValidWord(
      word,
    );
  }

  late final _TWMnemonicIsValidWordPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWString1>)>>(
          'TWMnemonicIsValidWord');
  late final _TWMnemonicIsValidWord = _TWMnemonicIsValidWordPtr.asFunction<
      bool Function(ffi.Pointer<TWString1>)>();

  /// Return BIP39 English words that match the given prefix. A single string is returned, with space-separated list of words.
  ///
  /// \param prefix Non-null string prefix
  /// \return Single non-null string, space-separated list of words containing BIP39 words that match the given prefix.
  ffi.Pointer<TWString1> TWMnemonicSuggest(
    ffi.Pointer<TWString1> prefix,
  ) {
    return _TWMnemonicSuggest(
      prefix,
    );
  }

  late final _TWMnemonicSuggestPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWString1>)>>('TWMnemonicSuggest');
  late final _TWMnemonicSuggest = _TWMnemonicSuggestPtr.asFunction<
      ffi.Pointer<TWString1> Function(ffi.Pointer<TWString1>)>();

  /// Determines if the given sig hash is single
  ///
  /// \param type sig hash type
  /// \return true if the sigh hash type is single, false otherwise
  bool TWBitcoinSigHashTypeIsSingle(
    int type,
  ) {
    return _TWBitcoinSigHashTypeIsSingle(
      type,
    );
  }

  late final _TWBitcoinSigHashTypeIsSinglePtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Int32)>>(
          'TWBitcoinSigHashTypeIsSingle');
  late final _TWBitcoinSigHashTypeIsSingle =
      _TWBitcoinSigHashTypeIsSinglePtr.asFunction<bool Function(int)>();

  /// Determines if the given sig hash is none
  ///
  /// \param type sig hash type
  /// \return true if the sigh hash type is none, false otherwise
  bool TWBitcoinSigHashTypeIsNone(
    int type,
  ) {
    return _TWBitcoinSigHashTypeIsNone(
      type,
    );
  }

  late final _TWBitcoinSigHashTypeIsNonePtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Int32)>>(
          'TWBitcoinSigHashTypeIsNone');
  late final _TWBitcoinSigHashTypeIsNone =
      _TWBitcoinSigHashTypeIsNonePtr.asFunction<bool Function(int)>();

  /// Creates an empty script.
  ///
  /// \return A pointer to the script
  ffi.Pointer<TWBitcoinScript> TWBitcoinScriptCreate() {
    return _TWBitcoinScriptCreate();
  }

  late final _TWBitcoinScriptCreatePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWBitcoinScript> Function()>>(
          'TWBitcoinScriptCreate');
  late final _TWBitcoinScriptCreate = _TWBitcoinScriptCreatePtr.asFunction<
      ffi.Pointer<TWBitcoinScript> Function()>();

  /// Creates a script from a raw data representation.
  ///
  /// \param data The data buffer
  /// \note Must be deleted with \TWBitcoinScriptDelete
  /// \return A pointer to the script
  ffi.Pointer<TWBitcoinScript> TWBitcoinScriptCreateWithData(
    ffi.Pointer<TWData1> data,
  ) {
    return _TWBitcoinScriptCreateWithData(
      data,
    );
  }

  late final _TWBitcoinScriptCreateWithDataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWBitcoinScript> Function(
              ffi.Pointer<TWData1>)>>('TWBitcoinScriptCreateWithData');
  late final _TWBitcoinScriptCreateWithData =
      _TWBitcoinScriptCreateWithDataPtr.asFunction<
          ffi.Pointer<TWBitcoinScript> Function(ffi.Pointer<TWData1>)>();

  /// Creates a script from a raw bytes and size.
  ///
  /// \param bytes The buffer
  /// \param size The size of the buffer
  /// \note Must be deleted with \TWBitcoinScriptDelete
  /// \return A pointer to the script
  ffi.Pointer<TWBitcoinScript> TWBitcoinScriptCreateWithBytes(
    ffi.Pointer<ffi.Uint8> bytes,
    int size,
  ) {
    return _TWBitcoinScriptCreateWithBytes(
      bytes,
      size,
    );
  }

  late final _TWBitcoinScriptCreateWithBytesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWBitcoinScript> Function(ffi.Pointer<ffi.Uint8>,
              ffi.Size)>>('TWBitcoinScriptCreateWithBytes');
  late final _TWBitcoinScriptCreateWithBytes =
      _TWBitcoinScriptCreateWithBytesPtr.asFunction<
          ffi.Pointer<TWBitcoinScript> Function(ffi.Pointer<ffi.Uint8>, int)>();

  /// Creates a script by copying an existing script.
  ///
  /// \param script Non-null pointer to a script
  /// \note Must be deleted with \TWBitcoinScriptDelete
  /// \return A pointer to the script
  ffi.Pointer<TWBitcoinScript> TWBitcoinScriptCreateCopy(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptCreateCopy(
      script,
    );
  }

  late final _TWBitcoinScriptCreateCopyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWBitcoinScript> Function(
              ffi.Pointer<TWBitcoinScript>)>>('TWBitcoinScriptCreateCopy');
  late final _TWBitcoinScriptCreateCopy =
      _TWBitcoinScriptCreateCopyPtr.asFunction<
          ffi.Pointer<TWBitcoinScript> Function(
              ffi.Pointer<TWBitcoinScript>)>();

  /// Delete/Deallocate a given script.
  ///
  /// \param script Non-null pointer to a script
  void TWBitcoinScriptDelete(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptDelete(
      script,
    );
  }

  late final _TWBitcoinScriptDeletePtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWBitcoinScript>)>>(
      'TWBitcoinScriptDelete');
  late final _TWBitcoinScriptDelete = _TWBitcoinScriptDeletePtr.asFunction<
      void Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Get size of a script
  ///
  /// \param script Non-null pointer to a script
  /// \return size of the script
  int TWBitcoinScriptSize(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptSize(
      script,
    );
  }

  late final _TWBitcoinScriptSizePtr = _lookup<
          ffi.NativeFunction<ffi.Size Function(ffi.Pointer<TWBitcoinScript>)>>(
      'TWBitcoinScriptSize');
  late final _TWBitcoinScriptSize = _TWBitcoinScriptSizePtr.asFunction<
      int Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Get data of a script
  ///
  /// \param script Non-null pointer to a script
  /// \return data of the given script
  ffi.Pointer<TWData1> TWBitcoinScriptData(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptData(
      script,
    );
  }

  late final _TWBitcoinScriptDataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWBitcoinScript>)>>('TWBitcoinScriptData');
  late final _TWBitcoinScriptData = _TWBitcoinScriptDataPtr.asFunction<
      ffi.Pointer<TWData1> Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Return script hash of a script
  ///
  /// \param script Non-null pointer to a script
  /// \return script hash of the given script
  ffi.Pointer<TWData1> TWBitcoinScriptScriptHash(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptScriptHash(
      script,
    );
  }

  late final _TWBitcoinScriptScriptHashPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWBitcoinScript>)>>('TWBitcoinScriptScriptHash');
  late final _TWBitcoinScriptScriptHash =
      _TWBitcoinScriptScriptHashPtr.asFunction<
          ffi.Pointer<TWData1> Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Determines whether this is a pay-to-script-hash (P2SH) script.
  ///
  /// \param script Non-null pointer to a script
  /// \return true if this is a pay-to-script-hash (P2SH) script, false otherwise
  bool TWBitcoinScriptIsPayToScriptHash(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptIsPayToScriptHash(
      script,
    );
  }

  late final _TWBitcoinScriptIsPayToScriptHashPtr = _lookup<
          ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWBitcoinScript>)>>(
      'TWBitcoinScriptIsPayToScriptHash');
  late final _TWBitcoinScriptIsPayToScriptHash =
      _TWBitcoinScriptIsPayToScriptHashPtr.asFunction<
          bool Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Determines whether this is a pay-to-witness-script-hash (P2WSH) script.
  ///
  /// \param script Non-null pointer to a script
  /// \return true if this is a pay-to-witness-script-hash (P2WSH) script, false otherwise
  bool TWBitcoinScriptIsPayToWitnessScriptHash(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptIsPayToWitnessScriptHash(
      script,
    );
  }

  late final _TWBitcoinScriptIsPayToWitnessScriptHashPtr = _lookup<
          ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWBitcoinScript>)>>(
      'TWBitcoinScriptIsPayToWitnessScriptHash');
  late final _TWBitcoinScriptIsPayToWitnessScriptHash =
      _TWBitcoinScriptIsPayToWitnessScriptHashPtr.asFunction<
          bool Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Determines whether this is a pay-to-witness-public-key-hash (P2WPKH) script.
  ///
  /// \param script Non-null pointer to a script
  /// \return true if this is a pay-to-witness-public-key-hash (P2WPKH) script, false otherwise
  bool TWBitcoinScriptIsPayToWitnessPublicKeyHash(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptIsPayToWitnessPublicKeyHash(
      script,
    );
  }

  late final _TWBitcoinScriptIsPayToWitnessPublicKeyHashPtr = _lookup<
          ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWBitcoinScript>)>>(
      'TWBitcoinScriptIsPayToWitnessPublicKeyHash');
  late final _TWBitcoinScriptIsPayToWitnessPublicKeyHash =
      _TWBitcoinScriptIsPayToWitnessPublicKeyHashPtr.asFunction<
          bool Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Determines whether this is a witness program script.
  ///
  /// \param script Non-null pointer to a script
  /// \return true if this is a witness program script, false otherwise
  bool TWBitcoinScriptIsWitnessProgram(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptIsWitnessProgram(
      script,
    );
  }

  late final _TWBitcoinScriptIsWitnessProgramPtr = _lookup<
          ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<TWBitcoinScript>)>>(
      'TWBitcoinScriptIsWitnessProgram');
  late final _TWBitcoinScriptIsWitnessProgram =
      _TWBitcoinScriptIsWitnessProgramPtr.asFunction<
          bool Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Determines whether 2 scripts have the same content
  ///
  /// \param lhs Non-null pointer to the first script
  /// \param rhs Non-null pointer to the second script
  /// \return true if both script have the same content
  bool TWBitcoinScriptEqual(
    ffi.Pointer<TWBitcoinScript> lhs,
    ffi.Pointer<TWBitcoinScript> rhs,
  ) {
    return _TWBitcoinScriptEqual(
      lhs,
      rhs,
    );
  }

  late final _TWBitcoinScriptEqualPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWBitcoinScript>,
              ffi.Pointer<TWBitcoinScript>)>>('TWBitcoinScriptEqual');
  late final _TWBitcoinScriptEqual = _TWBitcoinScriptEqualPtr.asFunction<
      bool Function(
          ffi.Pointer<TWBitcoinScript>, ffi.Pointer<TWBitcoinScript>)>();

  /// Matches the script to a pay-to-public-key (P2PK) script.
  ///
  /// \param script Non-null pointer to a script
  /// \return The public key.
  ffi.Pointer<TWData1> TWBitcoinScriptMatchPayToPubkey(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptMatchPayToPubkey(
      script,
    );
  }

  late final _TWBitcoinScriptMatchPayToPubkeyPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWData1> Function(ffi.Pointer<TWBitcoinScript>)>>(
      'TWBitcoinScriptMatchPayToPubkey');
  late final _TWBitcoinScriptMatchPayToPubkey =
      _TWBitcoinScriptMatchPayToPubkeyPtr.asFunction<
          ffi.Pointer<TWData1> Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Matches the script to a pay-to-public-key-hash (P2PKH).
  ///
  /// \param script Non-null pointer to a script
  /// \return the key hash.
  ffi.Pointer<TWData1> TWBitcoinScriptMatchPayToPubkeyHash(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptMatchPayToPubkeyHash(
      script,
    );
  }

  late final _TWBitcoinScriptMatchPayToPubkeyHashPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWData1> Function(ffi.Pointer<TWBitcoinScript>)>>(
      'TWBitcoinScriptMatchPayToPubkeyHash');
  late final _TWBitcoinScriptMatchPayToPubkeyHash =
      _TWBitcoinScriptMatchPayToPubkeyHashPtr.asFunction<
          ffi.Pointer<TWData1> Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Matches the script to a pay-to-script-hash (P2SH).
  ///
  /// \param script Non-null pointer to a script
  /// \return the script hash.
  ffi.Pointer<TWData1> TWBitcoinScriptMatchPayToScriptHash(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptMatchPayToScriptHash(
      script,
    );
  }

  late final _TWBitcoinScriptMatchPayToScriptHashPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWData1> Function(ffi.Pointer<TWBitcoinScript>)>>(
      'TWBitcoinScriptMatchPayToScriptHash');
  late final _TWBitcoinScriptMatchPayToScriptHash =
      _TWBitcoinScriptMatchPayToScriptHashPtr.asFunction<
          ffi.Pointer<TWData1> Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Matches the script to a pay-to-witness-public-key-hash (P2WPKH).
  ///
  /// \param script Non-null pointer to a script
  /// \return the key hash.
  ffi.Pointer<TWData1> TWBitcoinScriptMatchPayToWitnessPublicKeyHash(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptMatchPayToWitnessPublicKeyHash(
      script,
    );
  }

  late final _TWBitcoinScriptMatchPayToWitnessPublicKeyHashPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWData1> Function(ffi.Pointer<TWBitcoinScript>)>>(
      'TWBitcoinScriptMatchPayToWitnessPublicKeyHash');
  late final _TWBitcoinScriptMatchPayToWitnessPublicKeyHash =
      _TWBitcoinScriptMatchPayToWitnessPublicKeyHashPtr.asFunction<
          ffi.Pointer<TWData1> Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Matches the script to a pay-to-witness-script-hash (P2WSH).
  ///
  /// \param script Non-null pointer to a script
  /// \return the script hash, a SHA256 of the witness script..
  ffi.Pointer<TWData1> TWBitcoinScriptMatchPayToWitnessScriptHash(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptMatchPayToWitnessScriptHash(
      script,
    );
  }

  late final _TWBitcoinScriptMatchPayToWitnessScriptHashPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWData1> Function(ffi.Pointer<TWBitcoinScript>)>>(
      'TWBitcoinScriptMatchPayToWitnessScriptHash');
  late final _TWBitcoinScriptMatchPayToWitnessScriptHash =
      _TWBitcoinScriptMatchPayToWitnessScriptHashPtr.asFunction<
          ffi.Pointer<TWData1> Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Encodes the script.
  ///
  /// \param script Non-null pointer to a script
  /// \return The encoded script
  ffi.Pointer<TWData1> TWBitcoinScriptEncode(
    ffi.Pointer<TWBitcoinScript> script,
  ) {
    return _TWBitcoinScriptEncode(
      script,
    );
  }

  late final _TWBitcoinScriptEncodePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWBitcoinScript>)>>('TWBitcoinScriptEncode');
  late final _TWBitcoinScriptEncode = _TWBitcoinScriptEncodePtr.asFunction<
      ffi.Pointer<TWData1> Function(ffi.Pointer<TWBitcoinScript>)>();

  /// Builds a standard 'pay to public key' script.
  ///
  /// \param pubkey Non-null pointer to a pubkey
  /// \note Must be deleted with \TWBitcoinScriptDelete
  /// \return A pointer to the built script
  ffi.Pointer<TWBitcoinScript> TWBitcoinScriptBuildPayToPublicKey(
    ffi.Pointer<TWData1> pubkey,
  ) {
    return _TWBitcoinScriptBuildPayToPublicKey(
      pubkey,
    );
  }

  late final _TWBitcoinScriptBuildPayToPublicKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWBitcoinScript> Function(
              ffi.Pointer<TWData1>)>>('TWBitcoinScriptBuildPayToPublicKey');
  late final _TWBitcoinScriptBuildPayToPublicKey =
      _TWBitcoinScriptBuildPayToPublicKeyPtr.asFunction<
          ffi.Pointer<TWBitcoinScript> Function(ffi.Pointer<TWData1>)>();

  /// Builds a standard 'pay to public key hash' script.
  ///
  /// \param hash Non-null pointer to a PublicKey hash
  /// \note Must be deleted with \TWBitcoinScriptDelete
  /// \return A pointer to the built script
  ffi.Pointer<TWBitcoinScript> TWBitcoinScriptBuildPayToPublicKeyHash(
    ffi.Pointer<TWData1> hash,
  ) {
    return _TWBitcoinScriptBuildPayToPublicKeyHash(
      hash,
    );
  }

  late final _TWBitcoinScriptBuildPayToPublicKeyHashPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWBitcoinScript> Function(
              ffi.Pointer<TWData1>)>>('TWBitcoinScriptBuildPayToPublicKeyHash');
  late final _TWBitcoinScriptBuildPayToPublicKeyHash =
      _TWBitcoinScriptBuildPayToPublicKeyHashPtr.asFunction<
          ffi.Pointer<TWBitcoinScript> Function(ffi.Pointer<TWData1>)>();

  /// Builds a standard 'pay to script hash' script.
  ///
  /// \param scriptHash Non-null pointer to a script hash
  /// \note Must be deleted with \TWBitcoinScriptDelete
  /// \return A pointer to the built script
  ffi.Pointer<TWBitcoinScript> TWBitcoinScriptBuildPayToScriptHash(
    ffi.Pointer<TWData1> scriptHash,
  ) {
    return _TWBitcoinScriptBuildPayToScriptHash(
      scriptHash,
    );
  }

  late final _TWBitcoinScriptBuildPayToScriptHashPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWBitcoinScript> Function(
              ffi.Pointer<TWData1>)>>('TWBitcoinScriptBuildPayToScriptHash');
  late final _TWBitcoinScriptBuildPayToScriptHash =
      _TWBitcoinScriptBuildPayToScriptHashPtr.asFunction<
          ffi.Pointer<TWBitcoinScript> Function(ffi.Pointer<TWData1>)>();

  /// Builds a pay-to-witness-public-key-hash (P2WPKH) script..
  ///
  /// \param hash Non-null pointer to a witness public key hash
  /// \note Must be deleted with \TWBitcoinScriptDelete
  /// \return A pointer to the built script
  ffi.Pointer<TWBitcoinScript> TWBitcoinScriptBuildPayToWitnessPubkeyHash(
    ffi.Pointer<TWData1> hash,
  ) {
    return _TWBitcoinScriptBuildPayToWitnessPubkeyHash(
      hash,
    );
  }

  late final _TWBitcoinScriptBuildPayToWitnessPubkeyHashPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWBitcoinScript> Function(ffi.Pointer<TWData1>)>>(
      'TWBitcoinScriptBuildPayToWitnessPubkeyHash');
  late final _TWBitcoinScriptBuildPayToWitnessPubkeyHash =
      _TWBitcoinScriptBuildPayToWitnessPubkeyHashPtr.asFunction<
          ffi.Pointer<TWBitcoinScript> Function(ffi.Pointer<TWData1>)>();

  /// Builds a pay-to-witness-script-hash (P2WSH) script.
  ///
  /// \param scriptHash Non-null pointer to a script hash
  /// \note Must be deleted with \TWBitcoinScriptDelete
  /// \return A pointer to the built script
  ffi.Pointer<TWBitcoinScript> TWBitcoinScriptBuildPayToWitnessScriptHash(
    ffi.Pointer<TWData1> scriptHash,
  ) {
    return _TWBitcoinScriptBuildPayToWitnessScriptHash(
      scriptHash,
    );
  }

  late final _TWBitcoinScriptBuildPayToWitnessScriptHashPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWBitcoinScript> Function(ffi.Pointer<TWData1>)>>(
      'TWBitcoinScriptBuildPayToWitnessScriptHash');
  late final _TWBitcoinScriptBuildPayToWitnessScriptHash =
      _TWBitcoinScriptBuildPayToWitnessScriptHashPtr.asFunction<
          ffi.Pointer<TWBitcoinScript> Function(ffi.Pointer<TWData1>)>();

  /// Builds a appropriate lock script for the given address..
  ///
  /// \param address Non-null pointer to an address
  /// \param coin coin type
  /// \note Must be deleted with \TWBitcoinScriptDelete
  /// \return A pointer to the built script
  ffi.Pointer<TWBitcoinScript> TWBitcoinScriptLockScriptForAddress(
    ffi.Pointer<TWString1> address,
    int coin,
  ) {
    return _TWBitcoinScriptLockScriptForAddress(
      address,
      coin,
    );
  }

  late final _TWBitcoinScriptLockScriptForAddressPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWBitcoinScript> Function(ffi.Pointer<TWString1>,
              ffi.Int32)>>('TWBitcoinScriptLockScriptForAddress');
  late final _TWBitcoinScriptLockScriptForAddress =
      _TWBitcoinScriptLockScriptForAddressPtr.asFunction<
          ffi.Pointer<TWBitcoinScript> Function(ffi.Pointer<TWString1>, int)>();

  /// Return the default HashType for the given coin, such as TWBitcoinSigHashTypeAll.
  ///
  /// \param coinType coin type
  /// \return default HashType for the given coin
  int TWBitcoinScriptHashTypeForCoin(
    int coinType,
  ) {
    return _TWBitcoinScriptHashTypeForCoin(
      coinType,
    );
  }

  late final _TWBitcoinScriptHashTypeForCoinPtr =
      _lookup<ffi.NativeFunction<ffi.Uint32 Function(ffi.Int32)>>(
          'TWBitcoinScriptHashTypeForCoin');
  late final _TWBitcoinScriptHashTypeForCoin =
      _TWBitcoinScriptHashTypeForCoinPtr.asFunction<int Function(int)>();

  /// Sign a typed message EIP-712 V4.
  ///
  /// \param privateKey: the private key used for signing
  /// \param messageJson: A custom typed data message in json
  /// \returns the signature, Hex-encoded. On invalid input empty string is returned. Returned object needs to be deleted after use.
  ffi.Pointer<TWString> TWEthereumMessageSignerSignTypedMessage(
    ffi.Pointer<TWPrivateKey> privateKey,
    ffi.Pointer<TWString> messageJson,
  ) {
    return _TWEthereumMessageSignerSignTypedMessage(
      privateKey,
      messageJson,
    );
  }

  late final _TWEthereumMessageSignerSignTypedMessagePtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWString> Function(
                  ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWString>)>>(
      'TWEthereumMessageSignerSignTypedMessage');
  late final _TWEthereumMessageSignerSignTypedMessage =
      _TWEthereumMessageSignerSignTypedMessagePtr.asFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWString>)>();

  /// Sign a typed message EIP-712 V4 with EIP-155 replay attack protection.
  ///
  /// \param privateKey: the private key used for signing
  /// \param messageJson: A custom typed data message in json
  /// \param chainId: chainId for eip-155 protection
  /// \returns the signature, Hex-encoded. On invalid input empty string is returned or invalid chainId error message. Returned object needs to be deleted after use.
  ffi.Pointer<TWString> TWEthereumMessageSignerSignTypedMessageEip155(
    ffi.Pointer<TWPrivateKey> privateKey,
    ffi.Pointer<TWString> messageJson,
    int chainId,
  ) {
    return _TWEthereumMessageSignerSignTypedMessageEip155(
      privateKey,
      messageJson,
      chainId,
    );
  }

  late final _TWEthereumMessageSignerSignTypedMessageEip155Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWPrivateKey>,
              ffi.Pointer<TWString>,
              ffi.Int)>>('TWEthereumMessageSignerSignTypedMessageEip155');
  late final _TWEthereumMessageSignerSignTypedMessageEip155 =
      _TWEthereumMessageSignerSignTypedMessageEip155Ptr.asFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWString>, int)>();

  /// Sign a message.
  ///
  /// \param privateKey: the private key used for signing
  /// \param message: A custom message which is input to the signing.
  /// \returns the signature, Hex-encoded. On invalid input empty string is returned. Returned object needs to be deleted after use.
  ffi.Pointer<TWString> TWEthereumMessageSignerSignMessage(
    ffi.Pointer<TWPrivateKey> privateKey,
    ffi.Pointer<TWString> message,
  ) {
    return _TWEthereumMessageSignerSignMessage(
      privateKey,
      message,
    );
  }

  late final _TWEthereumMessageSignerSignMessagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWPrivateKey>,
              ffi.Pointer<TWString>)>>('TWEthereumMessageSignerSignMessage');
  late final _TWEthereumMessageSignerSignMessage =
      _TWEthereumMessageSignerSignMessagePtr.asFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWString>)>();

  /// Sign a message with Immutable X msg type.
  ///
  /// \param privateKey: the private key used for signing
  /// \param message: A custom message which is input to the signing.
  /// \returns the signature, Hex-encoded. On invalid input empty string is returned. Returned object needs to be deleted after use.
  ffi.Pointer<TWString> TWEthereumMessageSignerSignMessageImmutableX(
    ffi.Pointer<TWPrivateKey> privateKey,
    ffi.Pointer<TWString> message,
  ) {
    return _TWEthereumMessageSignerSignMessageImmutableX(
      privateKey,
      message,
    );
  }

  late final _TWEthereumMessageSignerSignMessageImmutableXPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWString> Function(
                  ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWString>)>>(
      'TWEthereumMessageSignerSignMessageImmutableX');
  late final _TWEthereumMessageSignerSignMessageImmutableX =
      _TWEthereumMessageSignerSignMessageImmutableXPtr.asFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWString>)>();

  /// Sign a message with Eip-155 msg type.
  ///
  /// \param privateKey: the private key used for signing
  /// \param message: A custom message which is input to the signing.
  /// \param chainId: chainId for eip-155 protection
  /// \returns the signature, Hex-encoded. On invalid input empty string is returned. Returned object needs to be deleted after use.
  ffi.Pointer<TWString> TWEthereumMessageSignerSignMessageEip155(
    ffi.Pointer<TWPrivateKey> privateKey,
    ffi.Pointer<TWString> message,
    int chainId,
  ) {
    return _TWEthereumMessageSignerSignMessageEip155(
      privateKey,
      message,
      chainId,
    );
  }

  late final _TWEthereumMessageSignerSignMessageEip155Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWPrivateKey>,
              ffi.Pointer<TWString>,
              ffi.Int)>>('TWEthereumMessageSignerSignMessageEip155');
  late final _TWEthereumMessageSignerSignMessageEip155 =
      _TWEthereumMessageSignerSignMessageEip155Ptr.asFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWString>, int)>();

  /// Verify signature for a message.
  ///
  /// \param pubKey: pubKey that will verify and recover the message from the signature
  /// \param message: the message signed (without prefix)
  /// \param signature: in Hex-encoded form.
  /// \returns false on any invalid input (does not throw), true if the message can be recovered from the signature
  bool TWEthereumMessageSignerVerifyMessage(
    ffi.Pointer<TWPublicKey> pubKey,
    ffi.Pointer<TWString> message,
    ffi.Pointer<TWString> signature,
  ) {
    return _TWEthereumMessageSignerVerifyMessage(
      pubKey,
      message,
      signature,
    );
  }

  late final _TWEthereumMessageSignerVerifyMessagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>>('TWEthereumMessageSignerVerifyMessage');
  late final _TWEthereumMessageSignerVerifyMessage =
      _TWEthereumMessageSignerVerifyMessagePtr.asFunction<
          bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>();

  /// Sign a message.
  ///
  /// \param privateKey: the private key used for signing
  /// \param address: the address that matches the privateKey, must be a legacy address (P2PKH)
  /// \param message: A custom message which is input to the signing.
  /// \note Address is derived assuming compressed public key format.
  /// \returns the signature, Base64-encoded.  On invalid input empty string is returned. Returned object needs to be deleteed after use.
  ffi.Pointer<TWString> TWBitcoinMessageSignerSignMessage(
    ffi.Pointer<TWPrivateKey> privateKey,
    ffi.Pointer<TWString> address,
    ffi.Pointer<TWString> message,
  ) {
    return _TWBitcoinMessageSignerSignMessage(
      privateKey,
      address,
      message,
    );
  }

  late final _TWBitcoinMessageSignerSignMessagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWPrivateKey>,
              ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>>('TWBitcoinMessageSignerSignMessage');
  late final _TWBitcoinMessageSignerSignMessage =
      _TWBitcoinMessageSignerSignMessagePtr.asFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWPrivateKey>,
              ffi.Pointer<TWString>, ffi.Pointer<TWString>)>();

  /// Verify signature for a message.
  ///
  /// \param address: address to use, only legacy is supported
  /// \param message: the message signed (without prefix)
  /// \param signature: in Base64-encoded form.
  /// \returns false on any invalid input (does not throw).
  bool TWBitcoinMessageSignerVerifyMessage(
    ffi.Pointer<TWString> address,
    ffi.Pointer<TWString> message,
    ffi.Pointer<TWString> signature,
  ) {
    return _TWBitcoinMessageSignerVerifyMessage(
      address,
      message,
      signature,
    );
  }

  late final _TWBitcoinMessageSignerVerifyMessagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWString>, ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>>('TWBitcoinMessageSignerVerifyMessage');
  late final _TWBitcoinMessageSignerVerifyMessage =
      _TWBitcoinMessageSignerVerifyMessagePtr.asFunction<
          bool Function(ffi.Pointer<TWString>, ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>();

  late final ffi.Pointer<ffi.Size> _TWHashSHA1Length =
      _lookup<ffi.Size>('TWHashSHA1Length');

  int get TWHashSHA1Length => _TWHashSHA1Length.value;

  set TWHashSHA1Length(int value) => _TWHashSHA1Length.value = value;

  late final ffi.Pointer<ffi.Size> _TWHashSHA256Length =
      _lookup<ffi.Size>('TWHashSHA256Length');

  int get TWHashSHA256Length => _TWHashSHA256Length.value;

  set TWHashSHA256Length(int value) => _TWHashSHA256Length.value = value;

  late final ffi.Pointer<ffi.Size> _TWHashSHA512Length =
      _lookup<ffi.Size>('TWHashSHA512Length');

  int get TWHashSHA512Length => _TWHashSHA512Length.value;

  set TWHashSHA512Length(int value) => _TWHashSHA512Length.value = value;

  late final ffi.Pointer<ffi.Size> _TWHashRipemdLength =
      _lookup<ffi.Size>('TWHashRipemdLength');

  int get TWHashRipemdLength => _TWHashRipemdLength.value;

  set TWHashRipemdLength(int value) => _TWHashRipemdLength.value = value;

  /// Computes the SHA1 of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed SHA1 block of data
  ffi.Pointer<TWData> TWHashSHA1(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashSHA1(
      data,
    );
  }

  late final _TWHashSHA1Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>('TWHashSHA1');
  late final _TWHashSHA1 = _TWHashSHA1Ptr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the SHA256 of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed SHA256 block of data
  ffi.Pointer<TWData> TWHashSHA256(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashSHA256(
      data,
    );
  }

  late final _TWHashSHA256Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>('TWHashSHA256');
  late final _TWHashSHA256 = _TWHashSHA256Ptr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the SHA512 of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed SHA512 block of data
  ffi.Pointer<TWData> TWHashSHA512(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashSHA512(
      data,
    );
  }

  late final _TWHashSHA512Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>('TWHashSHA512');
  late final _TWHashSHA512 = _TWHashSHA512Ptr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the SHA512_256 of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed SHA512_256 block of data
  ffi.Pointer<TWData> TWHashSHA512_256(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashSHA512_256(
      data,
    );
  }

  late final _TWHashSHA512_256Ptr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>(
      'TWHashSHA512_256');
  late final _TWHashSHA512_256 = _TWHashSHA512_256Ptr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the Keccak256 of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed Keccak256 block of data
  ffi.Pointer<TWData> TWHashKeccak256(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashKeccak256(
      data,
    );
  }

  late final _TWHashKeccak256Ptr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>(
      'TWHashKeccak256');
  late final _TWHashKeccak256 = _TWHashKeccak256Ptr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the Keccak512 of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed Keccak512 block of data
  ffi.Pointer<TWData> TWHashKeccak512(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashKeccak512(
      data,
    );
  }

  late final _TWHashKeccak512Ptr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>(
      'TWHashKeccak512');
  late final _TWHashKeccak512 = _TWHashKeccak512Ptr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the SHA3_256 of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed SHA3_256 block of data
  ffi.Pointer<TWData> TWHashSHA3_256(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashSHA3_256(
      data,
    );
  }

  late final _TWHashSHA3_256Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>('TWHashSHA3_256');
  late final _TWHashSHA3_256 = _TWHashSHA3_256Ptr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the SHA3_512 of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed SHA3_512 block of data
  ffi.Pointer<TWData> TWHashSHA3_512(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashSHA3_512(
      data,
    );
  }

  late final _TWHashSHA3_512Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>('TWHashSHA3_512');
  late final _TWHashSHA3_512 = _TWHashSHA3_512Ptr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the RIPEMD of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed RIPEMD block of data
  ffi.Pointer<TWData> TWHashRIPEMD(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashRIPEMD(
      data,
    );
  }

  late final _TWHashRIPEMDPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>('TWHashRIPEMD');
  late final _TWHashRIPEMD = _TWHashRIPEMDPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the Blake256 of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed Blake256 block of data
  ffi.Pointer<TWData> TWHashBlake256(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashBlake256(
      data,
    );
  }

  late final _TWHashBlake256Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>('TWHashBlake256');
  late final _TWHashBlake256 = _TWHashBlake256Ptr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the Blake2b of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed Blake2b block of data
  ffi.Pointer<TWData> TWHashBlake2b(
    ffi.Pointer<TWData> data,
    int size,
  ) {
    return _TWHashBlake2b(
      data,
      size,
    );
  }

  late final _TWHashBlake2bPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(
              ffi.Pointer<TWData>, ffi.Size)>>('TWHashBlake2b');
  late final _TWHashBlake2b = _TWHashBlake2bPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>, int)>();

  /// Computes the Groestl512 of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed Groestl512 block of data
  ffi.Pointer<TWData> TWHashGroestl512(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashGroestl512(
      data,
    );
  }

  late final _TWHashGroestl512Ptr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>(
      'TWHashGroestl512');
  late final _TWHashGroestl512 = _TWHashGroestl512Ptr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the SHA256D of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed SHA256D block of data
  ffi.Pointer<TWData> TWHashSHA256SHA256(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashSHA256SHA256(
      data,
    );
  }

  late final _TWHashSHA256SHA256Ptr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>(
      'TWHashSHA256SHA256');
  late final _TWHashSHA256SHA256 = _TWHashSHA256SHA256Ptr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the SHA256RIPEMD of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed SHA256RIPEMD block of data
  ffi.Pointer<TWData> TWHashSHA256RIPEMD(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashSHA256RIPEMD(
      data,
    );
  }

  late final _TWHashSHA256RIPEMDPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>(
      'TWHashSHA256RIPEMD');
  late final _TWHashSHA256RIPEMD = _TWHashSHA256RIPEMDPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the SHA3_256RIPEMD of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed SHA3_256RIPEMD block of data
  ffi.Pointer<TWData> TWHashSHA3_256RIPEMD(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashSHA3_256RIPEMD(
      data,
    );
  }

  late final _TWHashSHA3_256RIPEMDPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>(
      'TWHashSHA3_256RIPEMD');
  late final _TWHashSHA3_256RIPEMD = _TWHashSHA3_256RIPEMDPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the Blake256D of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed Blake256D block of data
  ffi.Pointer<TWData> TWHashBlake256Blake256(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashBlake256Blake256(
      data,
    );
  }

  late final _TWHashBlake256Blake256Ptr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>(
      'TWHashBlake256Blake256');
  late final _TWHashBlake256Blake256 = _TWHashBlake256Blake256Ptr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the Blake256RIPEMD of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed Blake256RIPEMD block of data
  ffi.Pointer<TWData> TWHashBlake256RIPEMD(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashBlake256RIPEMD(
      data,
    );
  }

  late final _TWHashBlake256RIPEMDPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>(
      'TWHashBlake256RIPEMD');
  late final _TWHashBlake256RIPEMD = _TWHashBlake256RIPEMDPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Computes the Groestl512D of a block of data.
  ///
  /// \param data Non-null block of data
  /// \return Non-null computed Groestl512D block of data
  ffi.Pointer<TWData> TWHashGroestl512Groestl512(
    ffi.Pointer<TWData> data,
  ) {
    return _TWHashGroestl512Groestl512(
      data,
    );
  }

  late final _TWHashGroestl512Groestl512Ptr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>(
      'TWHashGroestl512Groestl512');
  late final _TWHashGroestl512Groestl512 = _TWHashGroestl512Groestl512Ptr
      .asFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Encode a bool according to Ethereum ABI, into 32 bytes.  Values are padded by 0 on the left, unless specified otherwise
  ///
  /// \param value a boolean value
  /// \return Encoded value stored in a block of data
  ffi.Pointer<TWData1> TWEthereumAbiValueEncodeBool(
    bool value,
  ) {
    return _TWEthereumAbiValueEncodeBool(
      value,
    );
  }

  late final _TWEthereumAbiValueEncodeBoolPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWData1> Function(ffi.Bool)>>(
          'TWEthereumAbiValueEncodeBool');
  late final _TWEthereumAbiValueEncodeBool = _TWEthereumAbiValueEncodeBoolPtr
      .asFunction<ffi.Pointer<TWData1> Function(bool)>();

  /// Encode a int32 according to Ethereum ABI, into 32 bytes. Values are padded by 0 on the left, unless specified otherwise
  ///
  /// \param value a int32 value
  /// \return Encoded value stored in a block of data
  ffi.Pointer<TWData1> TWEthereumAbiValueEncodeInt32(
    int value,
  ) {
    return _TWEthereumAbiValueEncodeInt32(
      value,
    );
  }

  late final _TWEthereumAbiValueEncodeInt32Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWData1> Function(ffi.Int32)>>(
          'TWEthereumAbiValueEncodeInt32');
  late final _TWEthereumAbiValueEncodeInt32 = _TWEthereumAbiValueEncodeInt32Ptr
      .asFunction<ffi.Pointer<TWData1> Function(int)>();

  /// Encode a uint32 according to Ethereum ABI, into 32 bytes.  Values are padded by 0 on the left, unless specified otherwise
  ///
  /// \param value a uint32 value
  /// \return Encoded value stored in a block of data
  ffi.Pointer<TWData1> TWEthereumAbiValueEncodeUInt32(
    int value,
  ) {
    return _TWEthereumAbiValueEncodeUInt32(
      value,
    );
  }

  late final _TWEthereumAbiValueEncodeUInt32Ptr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWData1> Function(ffi.Uint32)>>(
          'TWEthereumAbiValueEncodeUInt32');
  late final _TWEthereumAbiValueEncodeUInt32 =
      _TWEthereumAbiValueEncodeUInt32Ptr.asFunction<
          ffi.Pointer<TWData1> Function(int)>();

  /// Encode a int256 according to Ethereum ABI, into 32 bytes.  Values are padded by 0 on the left, unless specified otherwise
  ///
  /// \param value a int256 value stored in a block of data
  /// \return Encoded value stored in a block of data
  ffi.Pointer<TWData1> TWEthereumAbiValueEncodeInt256(
    ffi.Pointer<TWData1> value,
  ) {
    return _TWEthereumAbiValueEncodeInt256(
      value,
    );
  }

  late final _TWEthereumAbiValueEncodeInt256Ptr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData1> Function(ffi.Pointer<TWData1>)>>(
      'TWEthereumAbiValueEncodeInt256');
  late final _TWEthereumAbiValueEncodeInt256 =
      _TWEthereumAbiValueEncodeInt256Ptr.asFunction<
          ffi.Pointer<TWData1> Function(ffi.Pointer<TWData1>)>();

  /// Encode an int256 according to Ethereum ABI, into 32 bytes.  Values are padded by 0 on the left, unless specified otherwise
  ///
  /// \param value a int256 value stored in a block of data
  /// \return Encoded value stored in a block of data
  ffi.Pointer<TWData1> TWEthereumAbiValueEncodeUInt256(
    ffi.Pointer<TWData1> value,
  ) {
    return _TWEthereumAbiValueEncodeUInt256(
      value,
    );
  }

  late final _TWEthereumAbiValueEncodeUInt256Ptr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData1> Function(ffi.Pointer<TWData1>)>>(
      'TWEthereumAbiValueEncodeUInt256');
  late final _TWEthereumAbiValueEncodeUInt256 =
      _TWEthereumAbiValueEncodeUInt256Ptr.asFunction<
          ffi.Pointer<TWData1> Function(ffi.Pointer<TWData1>)>();

  /// Encode an address according to Ethereum ABI, 20 bytes of the address.
  ///
  /// \param value an address value stored in a block of data
  /// \return Encoded value stored in a block of data
  ffi.Pointer<TWData1> TWEthereumAbiValueEncodeAddress(
    ffi.Pointer<TWData1> value,
  ) {
    return _TWEthereumAbiValueEncodeAddress(
      value,
    );
  }

  late final _TWEthereumAbiValueEncodeAddressPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData1> Function(ffi.Pointer<TWData1>)>>(
      'TWEthereumAbiValueEncodeAddress');
  late final _TWEthereumAbiValueEncodeAddress =
      _TWEthereumAbiValueEncodeAddressPtr.asFunction<
          ffi.Pointer<TWData1> Function(ffi.Pointer<TWData1>)>();

  /// Encode a string according to Ethereum ABI by encoding its hash.
  ///
  /// \param value a string value
  /// \return Encoded value stored in a block of data
  ffi.Pointer<TWData1> TWEthereumAbiValueEncodeString(
    ffi.Pointer<TWString1> value,
  ) {
    return _TWEthereumAbiValueEncodeString(
      value,
    );
  }

  late final _TWEthereumAbiValueEncodeStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData1> Function(
              ffi.Pointer<TWString1>)>>('TWEthereumAbiValueEncodeString');
  late final _TWEthereumAbiValueEncodeString =
      _TWEthereumAbiValueEncodeStringPtr.asFunction<
          ffi.Pointer<TWData1> Function(ffi.Pointer<TWString1>)>();

  /// Encode a number of bytes, up to 32 bytes, padded on the right.  Longer arrays are truncated.
  ///
  /// \param value bunch of bytes
  /// \return Encoded value stored in a block of data
  ffi.Pointer<TWData1> TWEthereumAbiValueEncodeBytes(
    ffi.Pointer<TWData1> value,
  ) {
    return _TWEthereumAbiValueEncodeBytes(
      value,
    );
  }

  late final _TWEthereumAbiValueEncodeBytesPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData1> Function(ffi.Pointer<TWData1>)>>(
      'TWEthereumAbiValueEncodeBytes');
  late final _TWEthereumAbiValueEncodeBytes = _TWEthereumAbiValueEncodeBytesPtr
      .asFunction<ffi.Pointer<TWData1> Function(ffi.Pointer<TWData1>)>();

  /// Encode a dynamic number of bytes by encoding its hash
  ///
  /// \param value bunch of bytes
  /// \return Encoded value stored in a block of data
  ffi.Pointer<TWData1> TWEthereumAbiValueEncodeBytesDyn(
    ffi.Pointer<TWData1> value,
  ) {
    return _TWEthereumAbiValueEncodeBytesDyn(
      value,
    );
  }

  late final _TWEthereumAbiValueEncodeBytesDynPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData1> Function(ffi.Pointer<TWData1>)>>(
      'TWEthereumAbiValueEncodeBytesDyn');
  late final _TWEthereumAbiValueEncodeBytesDyn =
      _TWEthereumAbiValueEncodeBytesDynPtr.asFunction<
          ffi.Pointer<TWData1> Function(ffi.Pointer<TWData1>)>();

  /// Decodes input data (bytes longer than 32 will be truncated) as uint256
  ///
  /// \param input Data to be decoded
  /// \return Non-null decoded string value
  ffi.Pointer<TWString1> TWEthereumAbiValueDecodeUInt256(
    ffi.Pointer<TWData1> input,
  ) {
    return _TWEthereumAbiValueDecodeUInt256(
      input,
    );
  }

  late final _TWEthereumAbiValueDecodeUInt256Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWData1>)>>('TWEthereumAbiValueDecodeUInt256');
  late final _TWEthereumAbiValueDecodeUInt256 =
      _TWEthereumAbiValueDecodeUInt256Ptr.asFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWData1>)>();

  /// Decode an arbitrary type, return value as string
  ///
  /// \param input Data to be decoded
  /// \param type the underlying type that need to be decoded
  /// \return Non-null decoded string value
  ffi.Pointer<TWString1> TWEthereumAbiValueDecodeValue(
    ffi.Pointer<TWData1> input,
    ffi.Pointer<TWString1> type,
  ) {
    return _TWEthereumAbiValueDecodeValue(
      input,
      type,
    );
  }

  late final _TWEthereumAbiValueDecodeValuePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWData1>,
              ffi.Pointer<TWString1>)>>('TWEthereumAbiValueDecodeValue');
  late final _TWEthereumAbiValueDecodeValue =
      _TWEthereumAbiValueDecodeValuePtr.asFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWData1>, ffi.Pointer<TWString1>)>();

  /// Decode an array of given simple types.  Return a '\n'-separated string of elements
  ///
  /// \param input Data to be decoded
  /// \param type the underlying type that need to be decoded
  /// \return Non-null decoded string value
  ffi.Pointer<TWString1> TWEthereumAbiValueDecodeArray(
    ffi.Pointer<TWData1> input,
    ffi.Pointer<TWString1> type,
  ) {
    return _TWEthereumAbiValueDecodeArray(
      input,
      type,
    );
  }

  late final _TWEthereumAbiValueDecodeArrayPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWData1>,
              ffi.Pointer<TWString1>)>>('TWEthereumAbiValueDecodeArray');
  late final _TWEthereumAbiValueDecodeArray =
      _TWEthereumAbiValueDecodeArrayPtr.asFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWData1>, ffi.Pointer<TWString1>)>();

  /// Builds a THORChainSwap transaction input.
  ///
  /// \param input The serialized data of SwapInput.
  /// \return The serialized data of SwapOutput.
  ffi.Pointer<TWData> TWTHORChainSwapBuildSwap(
    ffi.Pointer<TWData> input,
  ) {
    return _TWTHORChainSwapBuildSwap(
      input,
    );
  }

  late final _TWTHORChainSwapBuildSwapPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>>(
      'TWTHORChainSwapBuildSwap');
  late final _TWTHORChainSwapBuildSwap = _TWTHORChainSwapBuildSwapPtr
      .asFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWData>)>();

  /// Generate a layer 2 eip2645 derivation path from eth address, layer, application and given index.
  ///
  /// \param wallet non-null TWHDWallet
  /// \param ethAddress non-null Ethereum address
  /// \param layer  non-null layer 2 name (E.G starkex)
  /// \param application non-null layer 2 application (E.G immutablex)
  /// \param index non-null layer 2 index (E.G 1)
  /// \return a valid eip2645 layer 2 derivation path as a string
  ffi.Pointer<TWString1> TWEthereumEip2645GetPath(
    ffi.Pointer<TWString1> ethAddress,
    ffi.Pointer<TWString1> layer,
    ffi.Pointer<TWString1> application,
    ffi.Pointer<TWString1> index,
  ) {
    return _TWEthereumEip2645GetPath(
      ethAddress,
      layer,
      application,
      index,
    );
  }

  late final _TWEthereumEip2645GetPathPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>)>>('TWEthereumEip2645GetPath');
  late final _TWEthereumEip2645GetPath =
      _TWEthereumEip2645GetPathPtr.asFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>)>();

  /// Generates a deployment address for a ERC-4337 compatible smart contract wallet
  ///
  /// \param factoryAddress non-null address of the account factory
  /// \param logicAddress non-null address of the wallet's logic smart contract
  /// \param ownerAddress  non-null address of the signing key that controls the smart contract wallet
  /// \return Ethereum resulting address
  ffi.Pointer<TWString1> TWEthereumEip4337GetDeploymentAddress(
    ffi.Pointer<TWString1> factoryAddress,
    ffi.Pointer<TWString1> logicAddress,
    ffi.Pointer<TWString1> ownerAddress,
  ) {
    return _TWEthereumEip4337GetDeploymentAddress(
      factoryAddress,
      logicAddress,
      ownerAddress,
    );
  }

  late final _TWEthereumEip4337GetDeploymentAddressPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWString1> Function(ffi.Pointer<TWString1>,
                  ffi.Pointer<TWString1>, ffi.Pointer<TWString1>)>>(
      'TWEthereumEip4337GetDeploymentAddress');
  late final _TWEthereumEip4337GetDeploymentAddress =
      _TWEthereumEip4337GetDeploymentAddressPtr.asFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>, ffi.Pointer<TWString1>)>();

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _TWStellarPassphrase_Stellar =
      _lookup<ffi.Pointer<ffi.Char>>('TWStellarPassphrase_Stellar');

  ffi.Pointer<ffi.Char> get TWStellarPassphrase_Stellar =>
      _TWStellarPassphrase_Stellar.value;

  set TWStellarPassphrase_Stellar(ffi.Pointer<ffi.Char> value) =>
      _TWStellarPassphrase_Stellar.value = value;

  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _TWStellarPassphrase_Kin =
      _lookup<ffi.Pointer<ffi.Char>>('TWStellarPassphrase_Kin');

  ffi.Pointer<ffi.Char> get TWStellarPassphrase_Kin =>
      _TWStellarPassphrase_Kin.value;

  set TWStellarPassphrase_Kin(ffi.Pointer<ffi.Char> value) =>
      _TWStellarPassphrase_Kin.value = value;

  /// Creates a new Index with a value and hardened flag.
  /// Must be deleted with TWDerivationPathIndexDelete after use.
  ///
  /// \param value Index value
  /// \param hardened Indicates if the Index is hardened.
  /// \return A new Index.
  ffi.Pointer<TWDerivationPathIndex> TWDerivationPathIndexCreate(
    int value,
    bool hardened,
  ) {
    return _TWDerivationPathIndexCreate(
      value,
      hardened,
    );
  }

  late final _TWDerivationPathIndexCreatePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWDerivationPathIndex> Function(
              ffi.Uint32, ffi.Bool)>>('TWDerivationPathIndexCreate');
  late final _TWDerivationPathIndexCreate = _TWDerivationPathIndexCreatePtr
      .asFunction<ffi.Pointer<TWDerivationPathIndex> Function(int, bool)>();

  /// Deletes an Index.
  ///
  /// \param index Index to delete.
  void TWDerivationPathIndexDelete(
    ffi.Pointer<TWDerivationPathIndex> index,
  ) {
    return _TWDerivationPathIndexDelete(
      index,
    );
  }

  late final _TWDerivationPathIndexDeletePtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<TWDerivationPathIndex>)>>(
      'TWDerivationPathIndexDelete');
  late final _TWDerivationPathIndexDelete = _TWDerivationPathIndexDeletePtr
      .asFunction<void Function(ffi.Pointer<TWDerivationPathIndex>)>();

  /// Returns numeric value of an Index.
  ///
  /// \param index Index to get the numeric value of.
  int TWDerivationPathIndexValue(
    ffi.Pointer<TWDerivationPathIndex> index,
  ) {
    return _TWDerivationPathIndexValue(
      index,
    );
  }

  late final _TWDerivationPathIndexValuePtr = _lookup<
          ffi.NativeFunction<
              ffi.Uint32 Function(ffi.Pointer<TWDerivationPathIndex>)>>(
      'TWDerivationPathIndexValue');
  late final _TWDerivationPathIndexValue = _TWDerivationPathIndexValuePtr
      .asFunction<int Function(ffi.Pointer<TWDerivationPathIndex>)>();

  /// Returns hardened flag of an Index.
  ///
  /// \param index Index to get hardened flag.
  /// \return true if hardened, false otherwise.
  bool TWDerivationPathIndexHardened(
    ffi.Pointer<TWDerivationPathIndex> index,
  ) {
    return _TWDerivationPathIndexHardened(
      index,
    );
  }

  late final _TWDerivationPathIndexHardenedPtr = _lookup<
          ffi.NativeFunction<
              ffi.Bool Function(ffi.Pointer<TWDerivationPathIndex>)>>(
      'TWDerivationPathIndexHardened');
  late final _TWDerivationPathIndexHardened = _TWDerivationPathIndexHardenedPtr
      .asFunction<bool Function(ffi.Pointer<TWDerivationPathIndex>)>();

  /// Returns the string description of a derivation path index.
  ///
  /// \param path Index to get the address of.
  /// \return The string description of the derivation path index.
  ffi.Pointer<TWString1> TWDerivationPathIndexDescription(
    ffi.Pointer<TWDerivationPathIndex> index,
  ) {
    return _TWDerivationPathIndexDescription(
      index,
    );
  }

  late final _TWDerivationPathIndexDescriptionPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWString1> Function(
                  ffi.Pointer<TWDerivationPathIndex>)>>(
      'TWDerivationPathIndexDescription');
  late final _TWDerivationPathIndexDescription =
      _TWDerivationPathIndexDescriptionPtr.asFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWDerivationPathIndex>)>();

  /// Calculates the minimum ADA amount needed for a UTXO.
  ///
  /// \deprecated consider using `TWCardanoOutputMinAdaAmount` instead.
  /// \see reference https://docs.cardano.org/native-tokens/minimum-ada-value-requirement
  /// \param tokenBundle serialized data of TW.Cardano.Proto.TokenBundle.
  /// \return the minimum ADA amount.
  int TWCardanoMinAdaAmount(
    ffi.Pointer<TWData> tokenBundle,
  ) {
    return _TWCardanoMinAdaAmount(
      tokenBundle,
    );
  }

  late final _TWCardanoMinAdaAmountPtr =
      _lookup<ffi.NativeFunction<ffi.Uint64 Function(ffi.Pointer<TWData>)>>(
          'TWCardanoMinAdaAmount');
  late final _TWCardanoMinAdaAmount =
      _TWCardanoMinAdaAmountPtr.asFunction<int Function(ffi.Pointer<TWData>)>();

  /// Calculates the minimum ADA amount needed for an output.
  ///
  /// \see reference https://docs.cardano.org/native-tokens/minimum-ada-value-requirement
  /// \param toAddress valid destination address, as string.
  /// \param tokenBundle serialized data of TW.Cardano.Proto.TokenBundle.
  /// \param coinsPerUtxoByte cost per one byte of a serialized UTXO.
  /// \return the minimum ADA amount.
  int TWCardanoOutputMinAdaAmount(
    ffi.Pointer<TWString> toAddress,
    ffi.Pointer<TWData> tokenBundle,
    int coinsPerUtxoByte,
  ) {
    return _TWCardanoOutputMinAdaAmount(
      toAddress,
      tokenBundle,
      coinsPerUtxoByte,
    );
  }

  late final _TWCardanoOutputMinAdaAmountPtr = _lookup<
      ffi.NativeFunction<
          ffi.Uint64 Function(ffi.Pointer<TWString>, ffi.Pointer<TWData>,
              ffi.Uint64)>>('TWCardanoOutputMinAdaAmount');
  late final _TWCardanoOutputMinAdaAmount =
      _TWCardanoOutputMinAdaAmountPtr.asFunction<
          int Function(ffi.Pointer<TWString>, ffi.Pointer<TWData>, int)>();

  /// Return the staking address associated to (contained in) this address. Must be a Base address.
  /// Empty string is returned on error. Result must be freed.
  /// \param baseAddress A valid base address, as string.
  /// \return the associated staking (reward) address, as string, or empty string on error.
  ffi.Pointer<TWString> TWCardanoGetStakingAddress(
    ffi.Pointer<TWString> baseAddress,
  ) {
    return _TWCardanoGetStakingAddress(
      baseAddress,
    );
  }

  late final _TWCardanoGetStakingAddressPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWString>)>>('TWCardanoGetStakingAddress');
  late final _TWCardanoGetStakingAddress = _TWCardanoGetStakingAddressPtr
      .asFunction<ffi.Pointer<TWString> Function(ffi.Pointer<TWString>)>();

  /// Returns stock symbol of coin
  ///
  /// \param type A coin type
  /// \return A non-null TWString stock symbol of coin
  /// \note Caller must free returned object
  ffi.Pointer<TWString1> TWCoinTypeConfigurationGetSymbol(
    int type,
  ) {
    return _TWCoinTypeConfigurationGetSymbol(
      type,
    );
  }

  late final _TWCoinTypeConfigurationGetSymbolPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWString1> Function(ffi.Int32)>>(
          'TWCoinTypeConfigurationGetSymbol');
  late final _TWCoinTypeConfigurationGetSymbol =
      _TWCoinTypeConfigurationGetSymbolPtr.asFunction<
          ffi.Pointer<TWString1> Function(int)>();

  /// Returns max count decimal places for minimal coin unit
  ///
  /// \param type A coin type
  /// \return Returns max count decimal places for minimal coin unit
  int TWCoinTypeConfigurationGetDecimals(
    int type,
  ) {
    return _TWCoinTypeConfigurationGetDecimals(
      type,
    );
  }

  late final _TWCoinTypeConfigurationGetDecimalsPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int32)>>(
          'TWCoinTypeConfigurationGetDecimals');
  late final _TWCoinTypeConfigurationGetDecimals =
      _TWCoinTypeConfigurationGetDecimalsPtr.asFunction<int Function(int)>();

  /// Returns transaction url in blockchain explorer
  ///
  /// \param type A coin type
  /// \param transactionID A transaction identifier
  /// \return Returns a non-null TWString transaction url in blockchain explorer
  ffi.Pointer<TWString1> TWCoinTypeConfigurationGetTransactionURL(
    int type,
    ffi.Pointer<TWString1> transactionID,
  ) {
    return _TWCoinTypeConfigurationGetTransactionURL(
      type,
      transactionID,
    );
  }

  late final _TWCoinTypeConfigurationGetTransactionURLPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWString1> Function(
                  ffi.Int32, ffi.Pointer<TWString1>)>>(
      'TWCoinTypeConfigurationGetTransactionURL');
  late final _TWCoinTypeConfigurationGetTransactionURL =
      _TWCoinTypeConfigurationGetTransactionURLPtr.asFunction<
          ffi.Pointer<TWString1> Function(int, ffi.Pointer<TWString1>)>();

  /// Returns account url in blockchain explorer
  ///
  /// \param type A coin type
  /// \param accountID an Account identifier
  /// \return Returns a non-null TWString account url in blockchain explorer
  ffi.Pointer<TWString1> TWCoinTypeConfigurationGetAccountURL(
    int type,
    ffi.Pointer<TWString1> accountID,
  ) {
    return _TWCoinTypeConfigurationGetAccountURL(
      type,
      accountID,
    );
  }

  late final _TWCoinTypeConfigurationGetAccountURLPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(ffi.Int32,
              ffi.Pointer<TWString1>)>>('TWCoinTypeConfigurationGetAccountURL');
  late final _TWCoinTypeConfigurationGetAccountURL =
      _TWCoinTypeConfigurationGetAccountURLPtr.asFunction<
          ffi.Pointer<TWString1> Function(int, ffi.Pointer<TWString1>)>();

  /// Returns full name of coin in lower case
  ///
  /// \param type A coin type
  /// \return Returns a non-null TWString, full name of coin in lower case
  ffi.Pointer<TWString1> TWCoinTypeConfigurationGetID(
    int type,
  ) {
    return _TWCoinTypeConfigurationGetID(
      type,
    );
  }

  late final _TWCoinTypeConfigurationGetIDPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWString1> Function(ffi.Int32)>>(
          'TWCoinTypeConfigurationGetID');
  late final _TWCoinTypeConfigurationGetID = _TWCoinTypeConfigurationGetIDPtr
      .asFunction<ffi.Pointer<TWString1> Function(int)>();

  /// Returns full name of coin
  ///
  /// \param type A coin type
  /// \return Returns a non-null TWString, full name of coin
  ffi.Pointer<TWString1> TWCoinTypeConfigurationGetName(
    int type,
  ) {
    return _TWCoinTypeConfigurationGetName(
      type,
    );
  }

  late final _TWCoinTypeConfigurationGetNamePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<TWString1> Function(ffi.Int32)>>(
          'TWCoinTypeConfigurationGetName');
  late final _TWCoinTypeConfigurationGetName =
      _TWCoinTypeConfigurationGetNamePtr.asFunction<
          ffi.Pointer<TWString1> Function(int)>();

  /// Creates a function object, with the given name and empty parameter list.  It must be deleted at the end.
  ///
  /// \param name function name
  /// \return Non-null Ethereum abi function
  ffi.Pointer<TWEthereumAbiFunction> TWEthereumAbiFunctionCreateWithString(
    ffi.Pointer<TWString> name,
  ) {
    return _TWEthereumAbiFunctionCreateWithString(
      name,
    );
  }

  late final _TWEthereumAbiFunctionCreateWithStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWEthereumAbiFunction> Function(
              ffi.Pointer<TWString>)>>('TWEthereumAbiFunctionCreateWithString');
  late final _TWEthereumAbiFunctionCreateWithString =
      _TWEthereumAbiFunctionCreateWithStringPtr.asFunction<
          ffi.Pointer<TWEthereumAbiFunction> Function(ffi.Pointer<TWString>)>();

  /// Deletes a function object created with a 'TWEthereumAbiFunctionCreateWithString' method.
  ///
  /// \param fn Non-null Ethereum abi function
  void TWEthereumAbiFunctionDelete(
    ffi.Pointer<TWEthereumAbiFunction> fn,
  ) {
    return _TWEthereumAbiFunctionDelete(
      fn,
    );
  }

  late final _TWEthereumAbiFunctionDeletePtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<TWEthereumAbiFunction>)>>(
      'TWEthereumAbiFunctionDelete');
  late final _TWEthereumAbiFunctionDelete = _TWEthereumAbiFunctionDeletePtr
      .asFunction<void Function(ffi.Pointer<TWEthereumAbiFunction>)>();

  /// Return the function type signature, of the form "baz(int32,uint256)"
  ///
  /// \param fn A Non-null eth abi function
  /// \return function type signature as a Non-null string.
  ffi.Pointer<TWString> TWEthereumAbiFunctionGetType(
    ffi.Pointer<TWEthereumAbiFunction> fn,
  ) {
    return _TWEthereumAbiFunctionGetType(
      fn,
    );
  }

  late final _TWEthereumAbiFunctionGetTypePtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<TWString> Function(
                  ffi.Pointer<TWEthereumAbiFunction>)>>(
      'TWEthereumAbiFunctionGetType');
  late final _TWEthereumAbiFunctionGetType =
      _TWEthereumAbiFunctionGetTypePtr.asFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWEthereumAbiFunction>)>();

  /// Add a uint8 type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamUInt8(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamUInt8(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamUInt8Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Uint8,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamUInt8');
  late final _TWEthereumAbiFunctionAddParamUInt8 =
      _TWEthereumAbiFunctionAddParamUInt8Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Add a uint16 type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamUInt16(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamUInt16(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamUInt16Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Uint16,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamUInt16');
  late final _TWEthereumAbiFunctionAddParamUInt16 =
      _TWEthereumAbiFunctionAddParamUInt16Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Add a uint32 type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamUInt32(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamUInt32(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamUInt32Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Uint32,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamUInt32');
  late final _TWEthereumAbiFunctionAddParamUInt32 =
      _TWEthereumAbiFunctionAddParamUInt32Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Add a uint64 type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamUInt64(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamUInt64(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamUInt64Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Uint64,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamUInt64');
  late final _TWEthereumAbiFunctionAddParamUInt64 =
      _TWEthereumAbiFunctionAddParamUInt64Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Add a uint256 type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamUInt256(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    ffi.Pointer<TWData> val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamUInt256(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamUInt256Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Pointer<TWData>,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamUInt256');
  late final _TWEthereumAbiFunctionAddParamUInt256 =
      _TWEthereumAbiFunctionAddParamUInt256Ptr.asFunction<
          int Function(
              ffi.Pointer<TWEthereumAbiFunction>, ffi.Pointer<TWData>, bool)>();

  /// Add a uint(bits) type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamUIntN(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int bits,
    ffi.Pointer<TWData> val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamUIntN(
      fn,
      bits,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamUIntNPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Int,
              ffi.Pointer<TWData>,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamUIntN');
  late final _TWEthereumAbiFunctionAddParamUIntN =
      _TWEthereumAbiFunctionAddParamUIntNPtr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int,
              ffi.Pointer<TWData>, bool)>();

  /// Add a int8 type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamInt8(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamInt8(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamInt8Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int8,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamInt8');
  late final _TWEthereumAbiFunctionAddParamInt8 =
      _TWEthereumAbiFunctionAddParamInt8Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Add a int16 type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamInt16(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamInt16(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamInt16Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int16,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamInt16');
  late final _TWEthereumAbiFunctionAddParamInt16 =
      _TWEthereumAbiFunctionAddParamInt16Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Add a int32 type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamInt32(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamInt32(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamInt32Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int32,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamInt32');
  late final _TWEthereumAbiFunctionAddParamInt32 =
      _TWEthereumAbiFunctionAddParamInt32Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Add a int64 type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamInt64(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamInt64(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamInt64Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int64,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamInt64');
  late final _TWEthereumAbiFunctionAddParamInt64 =
      _TWEthereumAbiFunctionAddParamInt64Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Add a int256 type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified (stored in a block of data)
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamInt256(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    ffi.Pointer<TWData> val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamInt256(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamInt256Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Pointer<TWData>,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamInt256');
  late final _TWEthereumAbiFunctionAddParamInt256 =
      _TWEthereumAbiFunctionAddParamInt256Ptr.asFunction<
          int Function(
              ffi.Pointer<TWEthereumAbiFunction>, ffi.Pointer<TWData>, bool)>();

  /// Add a int(bits) type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param bits Number of bits of the integer parameter
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamIntN(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int bits,
    ffi.Pointer<TWData> val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamIntN(
      fn,
      bits,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamIntNPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Int,
              ffi.Pointer<TWData>,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamIntN');
  late final _TWEthereumAbiFunctionAddParamIntN =
      _TWEthereumAbiFunctionAddParamIntNPtr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int,
              ffi.Pointer<TWData>, bool)>();

  /// Add a bool type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamBool(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    bool val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamBool(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamBoolPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Bool,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamBool');
  late final _TWEthereumAbiFunctionAddParamBool =
      _TWEthereumAbiFunctionAddParamBoolPtr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, bool, bool)>();

  /// Add a string type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamString(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    ffi.Pointer<TWString> val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamString(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Pointer<TWString>,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamString');
  late final _TWEthereumAbiFunctionAddParamString =
      _TWEthereumAbiFunctionAddParamStringPtr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Pointer<TWString>, bool)>();

  /// Add an address type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamAddress(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    ffi.Pointer<TWData> val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamAddress(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamAddressPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Pointer<TWData>,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamAddress');
  late final _TWEthereumAbiFunctionAddParamAddress =
      _TWEthereumAbiFunctionAddParamAddressPtr.asFunction<
          int Function(
              ffi.Pointer<TWEthereumAbiFunction>, ffi.Pointer<TWData>, bool)>();

  /// Add a bytes type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamBytes(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    ffi.Pointer<TWData> val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamBytes(
      fn,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamBytesPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Pointer<TWData>,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamBytes');
  late final _TWEthereumAbiFunctionAddParamBytes =
      _TWEthereumAbiFunctionAddParamBytesPtr.asFunction<
          int Function(
              ffi.Pointer<TWEthereumAbiFunction>, ffi.Pointer<TWData>, bool)>();

  /// Add a bytes[N] type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param size fixed size of the bytes array parameter (val).
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamBytesFix(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int size,
    ffi.Pointer<TWData> val,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamBytesFix(
      fn,
      size,
      val,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamBytesFixPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Size,
              ffi.Pointer<TWData>,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamBytesFix');
  late final _TWEthereumAbiFunctionAddParamBytesFix =
      _TWEthereumAbiFunctionAddParamBytesFixPtr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int,
              ffi.Pointer<TWData>, bool)>();

  /// Add a type[] type parameter
  ///
  /// \param fn A Non-null eth abi function
  /// \param val for output parameters, value has to be specified
  /// \param isOutput determines if the parameter is an input or output
  /// \return the index of the parameter (0-based).
  int TWEthereumAbiFunctionAddParamArray(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionAddParamArray(
      fn,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionAddParamArrayPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Bool)>>('TWEthereumAbiFunctionAddParamArray');
  late final _TWEthereumAbiFunctionAddParamArray =
      _TWEthereumAbiFunctionAddParamArrayPtr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, bool)>();

  /// Get a uint8 type parameter at the given index
  ///
  /// \param fn A Non-null eth abi function
  /// \param idx index for the parameter (0-based).
  /// \param isOutput determines if the parameter is an input or output
  /// \return the value of the parameter.
  int TWEthereumAbiFunctionGetParamUInt8(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int idx,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionGetParamUInt8(
      fn,
      idx,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionGetParamUInt8Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Uint8 Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
              ffi.Bool)>>('TWEthereumAbiFunctionGetParamUInt8');
  late final _TWEthereumAbiFunctionGetParamUInt8 =
      _TWEthereumAbiFunctionGetParamUInt8Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Get a uint64 type parameter at the given index
  ///
  /// \param fn A Non-null eth abi function
  /// \param idx index for the parameter (0-based).
  /// \param isOutput determines if the parameter is an input or output
  /// \return the value of the parameter.
  int TWEthereumAbiFunctionGetParamUInt64(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int idx,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionGetParamUInt64(
      fn,
      idx,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionGetParamUInt64Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Uint64 Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
              ffi.Bool)>>('TWEthereumAbiFunctionGetParamUInt64');
  late final _TWEthereumAbiFunctionGetParamUInt64 =
      _TWEthereumAbiFunctionGetParamUInt64Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Get a uint256 type parameter at the given index
  ///
  /// \param fn A Non-null eth abi function
  /// \param idx index for the parameter (0-based).
  /// \param isOutput determines if the parameter is an input or output
  /// \return the value of the parameter stored in a block of data.
  ffi.Pointer<TWData> TWEthereumAbiFunctionGetParamUInt256(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int idx,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionGetParamUInt256(
      fn,
      idx,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionGetParamUInt256Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Int, ffi.Bool)>>('TWEthereumAbiFunctionGetParamUInt256');
  late final _TWEthereumAbiFunctionGetParamUInt256 =
      _TWEthereumAbiFunctionGetParamUInt256Ptr.asFunction<
          ffi.Pointer<TWData> Function(
              ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Get a bool type parameter at the given index
  ///
  /// \param fn A Non-null eth abi function
  /// \param idx index for the parameter (0-based).
  /// \param isOutput determines if the parameter is an input or output
  /// \return the value of the parameter.
  bool TWEthereumAbiFunctionGetParamBool(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int idx,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionGetParamBool(
      fn,
      idx,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionGetParamBoolPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
              ffi.Bool)>>('TWEthereumAbiFunctionGetParamBool');
  late final _TWEthereumAbiFunctionGetParamBool =
      _TWEthereumAbiFunctionGetParamBoolPtr.asFunction<
          bool Function(ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Get a string type parameter at the given index
  ///
  /// \param fn A Non-null eth abi function
  /// \param idx index for the parameter (0-based).
  /// \param isOutput determines if the parameter is an input or output
  /// \return the value of the parameter.
  ffi.Pointer<TWString> TWEthereumAbiFunctionGetParamString(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int idx,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionGetParamString(
      fn,
      idx,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionGetParamStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Int, ffi.Bool)>>('TWEthereumAbiFunctionGetParamString');
  late final _TWEthereumAbiFunctionGetParamString =
      _TWEthereumAbiFunctionGetParamStringPtr.asFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Get an address type parameter at the given index
  ///
  /// \param fn A Non-null eth abi function
  /// \param idx index for the parameter (0-based).
  /// \param isOutput determines if the parameter is an input or output
  /// \return the value of the parameter.
  ffi.Pointer<TWData> TWEthereumAbiFunctionGetParamAddress(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int idx,
    bool isOutput,
  ) {
    return _TWEthereumAbiFunctionGetParamAddress(
      fn,
      idx,
      isOutput,
    );
  }

  late final _TWEthereumAbiFunctionGetParamAddressPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWEthereumAbiFunction>,
              ffi.Int, ffi.Bool)>>('TWEthereumAbiFunctionGetParamAddress');
  late final _TWEthereumAbiFunctionGetParamAddress =
      _TWEthereumAbiFunctionGetParamAddressPtr.asFunction<
          ffi.Pointer<TWData> Function(
              ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Adding a uint8 type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamUInt8(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    int val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamUInt8(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamUInt8Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
              ffi.Uint8)>>('TWEthereumAbiFunctionAddInArrayParamUInt8');
  late final _TWEthereumAbiFunctionAddInArrayParamUInt8 =
      _TWEthereumAbiFunctionAddInArrayParamUInt8Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, int)>();

  /// Adding a uint16 type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamUInt16(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    int val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamUInt16(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamUInt16Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
              ffi.Uint16)>>('TWEthereumAbiFunctionAddInArrayParamUInt16');
  late final _TWEthereumAbiFunctionAddInArrayParamUInt16 =
      _TWEthereumAbiFunctionAddInArrayParamUInt16Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, int)>();

  /// Adding a uint32 type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamUInt32(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    int val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamUInt32(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamUInt32Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
              ffi.Uint32)>>('TWEthereumAbiFunctionAddInArrayParamUInt32');
  late final _TWEthereumAbiFunctionAddInArrayParamUInt32 =
      _TWEthereumAbiFunctionAddInArrayParamUInt32Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, int)>();

  /// Adding a uint64 type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamUInt64(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    int val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamUInt64(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamUInt64Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
              ffi.Uint64)>>('TWEthereumAbiFunctionAddInArrayParamUInt64');
  late final _TWEthereumAbiFunctionAddInArrayParamUInt64 =
      _TWEthereumAbiFunctionAddInArrayParamUInt64Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, int)>();

  /// Adding a uint256 type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter stored in a block of data
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamUInt256(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    ffi.Pointer<TWData> val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamUInt256(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamUInt256Ptr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
                  ffi.Pointer<TWData>)>>(
      'TWEthereumAbiFunctionAddInArrayParamUInt256');
  late final _TWEthereumAbiFunctionAddInArrayParamUInt256 =
      _TWEthereumAbiFunctionAddInArrayParamUInt256Ptr.asFunction<
          int Function(
              ffi.Pointer<TWEthereumAbiFunction>, int, ffi.Pointer<TWData>)>();

  /// Adding a uint[N] type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param bits Number of bits of the integer parameter
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter stored in a block of data
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamUIntN(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    int bits,
    ffi.Pointer<TWData> val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamUIntN(
      fn,
      arrayIdx,
      bits,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamUIntNPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
                  ffi.Int, ffi.Pointer<TWData>)>>(
      'TWEthereumAbiFunctionAddInArrayParamUIntN');
  late final _TWEthereumAbiFunctionAddInArrayParamUIntN =
      _TWEthereumAbiFunctionAddInArrayParamUIntNPtr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, int,
              ffi.Pointer<TWData>)>();

  /// Adding a int8 type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamInt8(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    int val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamInt8(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamInt8Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
              ffi.Int8)>>('TWEthereumAbiFunctionAddInArrayParamInt8');
  late final _TWEthereumAbiFunctionAddInArrayParamInt8 =
      _TWEthereumAbiFunctionAddInArrayParamInt8Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, int)>();

  /// Adding a int16 type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamInt16(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    int val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamInt16(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamInt16Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
              ffi.Int16)>>('TWEthereumAbiFunctionAddInArrayParamInt16');
  late final _TWEthereumAbiFunctionAddInArrayParamInt16 =
      _TWEthereumAbiFunctionAddInArrayParamInt16Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, int)>();

  /// Adding a int32 type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamInt32(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    int val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamInt32(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamInt32Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
              ffi.Int32)>>('TWEthereumAbiFunctionAddInArrayParamInt32');
  late final _TWEthereumAbiFunctionAddInArrayParamInt32 =
      _TWEthereumAbiFunctionAddInArrayParamInt32Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, int)>();

  /// Adding a int64 type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamInt64(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    int val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamInt64(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamInt64Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
              ffi.Int64)>>('TWEthereumAbiFunctionAddInArrayParamInt64');
  late final _TWEthereumAbiFunctionAddInArrayParamInt64 =
      _TWEthereumAbiFunctionAddInArrayParamInt64Ptr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, int)>();

  /// Adding a int256 type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter stored in a block of data
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamInt256(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    ffi.Pointer<TWData> val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamInt256(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamInt256Ptr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
                  ffi.Pointer<TWData>)>>(
      'TWEthereumAbiFunctionAddInArrayParamInt256');
  late final _TWEthereumAbiFunctionAddInArrayParamInt256 =
      _TWEthereumAbiFunctionAddInArrayParamInt256Ptr.asFunction<
          int Function(
              ffi.Pointer<TWEthereumAbiFunction>, int, ffi.Pointer<TWData>)>();

  /// Adding a int[N] type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param bits Number of bits of the integer parameter
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter stored in a block of data
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamIntN(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    int bits,
    ffi.Pointer<TWData> val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamIntN(
      fn,
      arrayIdx,
      bits,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamIntNPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
                  ffi.Int, ffi.Pointer<TWData>)>>(
      'TWEthereumAbiFunctionAddInArrayParamIntN');
  late final _TWEthereumAbiFunctionAddInArrayParamIntN =
      _TWEthereumAbiFunctionAddInArrayParamIntNPtr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, int,
              ffi.Pointer<TWData>)>();

  /// Adding a bool type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamBool(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    bool val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamBool(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamBoolPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
              ffi.Bool)>>('TWEthereumAbiFunctionAddInArrayParamBool');
  late final _TWEthereumAbiFunctionAddInArrayParamBool =
      _TWEthereumAbiFunctionAddInArrayParamBoolPtr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, bool)>();

  /// Adding a string type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamString(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    ffi.Pointer<TWString> val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamString(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamStringPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
                  ffi.Pointer<TWString>)>>(
      'TWEthereumAbiFunctionAddInArrayParamString');
  late final _TWEthereumAbiFunctionAddInArrayParamString =
      _TWEthereumAbiFunctionAddInArrayParamStringPtr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int,
              ffi.Pointer<TWString>)>();

  /// Adding an address type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamAddress(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    ffi.Pointer<TWData> val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamAddress(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamAddressPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
                  ffi.Pointer<TWData>)>>(
      'TWEthereumAbiFunctionAddInArrayParamAddress');
  late final _TWEthereumAbiFunctionAddInArrayParamAddress =
      _TWEthereumAbiFunctionAddInArrayParamAddressPtr.asFunction<
          int Function(
              ffi.Pointer<TWEthereumAbiFunction>, int, ffi.Pointer<TWData>)>();

  /// Adding a bytes type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param val the value of the parameter
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamBytes(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    ffi.Pointer<TWData> val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamBytes(
      fn,
      arrayIdx,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamBytesPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
                  ffi.Pointer<TWData>)>>(
      'TWEthereumAbiFunctionAddInArrayParamBytes');
  late final _TWEthereumAbiFunctionAddInArrayParamBytes =
      _TWEthereumAbiFunctionAddInArrayParamBytesPtr.asFunction<
          int Function(
              ffi.Pointer<TWEthereumAbiFunction>, int, ffi.Pointer<TWData>)>();

  /// Adding a int64 type parameter of to the top-level input parameter array
  ///
  /// \param fn A Non-null eth abi function
  /// \param arrayIdx array index for the abi function (0-based).
  /// \param size fixed size of the bytes array parameter (val).
  /// \param val the value of the parameter
  /// \return the index of the added parameter (0-based).
  int TWEthereumAbiFunctionAddInArrayParamBytesFix(
    ffi.Pointer<TWEthereumAbiFunction> fn,
    int arrayIdx,
    int size,
    ffi.Pointer<TWData> val,
  ) {
    return _TWEthereumAbiFunctionAddInArrayParamBytesFix(
      fn,
      arrayIdx,
      size,
      val,
    );
  }

  late final _TWEthereumAbiFunctionAddInArrayParamBytesFixPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(ffi.Pointer<TWEthereumAbiFunction>, ffi.Int,
                  ffi.Size, ffi.Pointer<TWData>)>>(
      'TWEthereumAbiFunctionAddInArrayParamBytesFix');
  late final _TWEthereumAbiFunctionAddInArrayParamBytesFix =
      _TWEthereumAbiFunctionAddInArrayParamBytesFixPtr.asFunction<
          int Function(ffi.Pointer<TWEthereumAbiFunction>, int, int,
              ffi.Pointer<TWData>)>();

  /// Derives a key from a password and a salt using PBKDF2 + Sha256.
  ///
  /// \param password is the master password from which a derived key is generated
  /// \param salt is a sequence of bits, known as a cryptographic salt
  /// \param iterations is the number of iterations desired
  /// \param dkLen is the desired bit-length of the derived key
  /// \return the derived key data.
  ffi.Pointer<TWData> TWPBKDF2HmacSha256(
    ffi.Pointer<TWData> password,
    ffi.Pointer<TWData> salt,
    int iterations,
    int dkLen,
  ) {
    return _TWPBKDF2HmacSha256(
      password,
      salt,
      iterations,
      dkLen,
    );
  }

  late final _TWPBKDF2HmacSha256Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWData>, ffi.Pointer<TWData>,
              ffi.Uint32, ffi.Uint32)>>('TWPBKDF2HmacSha256');
  late final _TWPBKDF2HmacSha256 = _TWPBKDF2HmacSha256Ptr.asFunction<
      ffi.Pointer<TWData> Function(
          ffi.Pointer<TWData>, ffi.Pointer<TWData>, int, int)>();

  /// Derives a key from a password and a salt using PBKDF2 + Sha512.
  ///
  /// \param password is the master password from which a derived key is generated
  /// \param salt is a sequence of bits, known as a cryptographic salt
  /// \param iterations is the number of iterations desired
  /// \param dkLen is the desired bit-length of the derived key
  /// \return the derived key data.
  ffi.Pointer<TWData> TWPBKDF2HmacSha512(
    ffi.Pointer<TWData> password,
    ffi.Pointer<TWData> salt,
    int iterations,
    int dkLen,
  ) {
    return _TWPBKDF2HmacSha512(
      password,
      salt,
      iterations,
      dkLen,
    );
  }

  late final _TWPBKDF2HmacSha512Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWData>, ffi.Pointer<TWData>,
              ffi.Uint32, ffi.Uint32)>>('TWPBKDF2HmacSha512');
  late final _TWPBKDF2HmacSha512 = _TWPBKDF2HmacSha512Ptr.asFunction<
      ffi.Pointer<TWData> Function(
          ffi.Pointer<TWData>, ffi.Pointer<TWData>, int, int)>();

  /// Creates an address from a string representation.
  ///
  /// \param string Non-null pointer to a solana address string
  /// \note Should be deleted with \TWSolanaAddressDelete
  /// \return Non-null pointer to a Solana address data structure
  ffi.Pointer<TWSolanaAddress> TWSolanaAddressCreateWithString(
    ffi.Pointer<TWString1> string,
  ) {
    return _TWSolanaAddressCreateWithString(
      string,
    );
  }

  late final _TWSolanaAddressCreateWithStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWSolanaAddress> Function(
              ffi.Pointer<TWString1>)>>('TWSolanaAddressCreateWithString');
  late final _TWSolanaAddressCreateWithString =
      _TWSolanaAddressCreateWithStringPtr.asFunction<
          ffi.Pointer<TWSolanaAddress> Function(ffi.Pointer<TWString1>)>();

  /// Delete the given Solana address
  ///
  /// \param address Non-null pointer to a Solana Address
  void TWSolanaAddressDelete(
    ffi.Pointer<TWSolanaAddress> address,
  ) {
    return _TWSolanaAddressDelete(
      address,
    );
  }

  late final _TWSolanaAddressDeletePtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWSolanaAddress>)>>(
      'TWSolanaAddressDelete');
  late final _TWSolanaAddressDelete = _TWSolanaAddressDeletePtr.asFunction<
      void Function(ffi.Pointer<TWSolanaAddress>)>();

  /// Derive default token address for token
  ///
  /// \param address Non-null pointer to a Solana Address
  /// \param tokenMintAddress Non-null pointer to a token mint address as a string
  /// \return Null pointer if the Default token address for a token is not found, valid pointer otherwise
  ffi.Pointer<TWString1> TWSolanaAddressDefaultTokenAddress(
    ffi.Pointer<TWSolanaAddress> address,
    ffi.Pointer<TWString1> tokenMintAddress,
  ) {
    return _TWSolanaAddressDefaultTokenAddress(
      address,
      tokenMintAddress,
    );
  }

  late final _TWSolanaAddressDefaultTokenAddressPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWSolanaAddress>,
              ffi.Pointer<TWString1>)>>('TWSolanaAddressDefaultTokenAddress');
  late final _TWSolanaAddressDefaultTokenAddress =
      _TWSolanaAddressDefaultTokenAddressPtr.asFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWSolanaAddress>, ffi.Pointer<TWString1>)>();

  /// Returns the address string representation.
  ///
  /// \param address Non-null pointer to a Solana Address
  /// \return Non-null pointer to the Solana address string representation
  ffi.Pointer<TWString1> TWSolanaAddressDescription(
    ffi.Pointer<TWSolanaAddress> address,
  ) {
    return _TWSolanaAddressDescription(
      address,
    );
  }

  late final _TWSolanaAddressDescriptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWSolanaAddress>)>>('TWSolanaAddressDescription');
  late final _TWSolanaAddressDescription =
      _TWSolanaAddressDescriptionPtr.asFunction<
          ffi.Pointer<TWString1> Function(ffi.Pointer<TWSolanaAddress>)>();

  /// Decode a Base32 input with the given alphabet
  ///
  /// \param string Encoded base32 input to be decoded
  /// \param alphabet Decode with the given alphabet, if nullptr ALPHABET_RFC4648 is used by default
  /// \return The decoded data, can be null.
  /// \note ALPHABET_RFC4648 doesn't support padding in the default alphabet
  ffi.Pointer<TWData> TWBase32DecodeWithAlphabet(
    ffi.Pointer<TWString> string,
    ffi.Pointer<TWString> alphabet,
  ) {
    return _TWBase32DecodeWithAlphabet(
      string,
      alphabet,
    );
  }

  late final _TWBase32DecodeWithAlphabetPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>>('TWBase32DecodeWithAlphabet');
  late final _TWBase32DecodeWithAlphabet =
      _TWBase32DecodeWithAlphabetPtr.asFunction<
          ffi.Pointer<TWData> Function(
              ffi.Pointer<TWString>, ffi.Pointer<TWString>)>();

  /// Decode a Base32 input with the default alphabet (ALPHABET_RFC4648)
  ///
  /// \param string Encoded input to be decoded
  /// \return The decoded data
  /// \note Call TWBase32DecodeWithAlphabet with nullptr.
  ffi.Pointer<TWData> TWBase32Decode(
    ffi.Pointer<TWString> string,
  ) {
    return _TWBase32Decode(
      string,
    );
  }

  late final _TWBase32DecodePtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWString>)>>(
      'TWBase32Decode');
  late final _TWBase32Decode = _TWBase32DecodePtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWString>)>();

  /// Encode an input to Base32 with the given alphabet
  ///
  /// \param data Data to be encoded (raw bytes)
  /// \param alphabet Encode with the given alphabet, if nullptr ALPHABET_RFC4648 is used by default
  /// \return The encoded data
  /// \note ALPHABET_RFC4648 doesn't support padding in the default alphabet
  ffi.Pointer<TWString> TWBase32EncodeWithAlphabet(
    ffi.Pointer<TWData> data,
    ffi.Pointer<TWString> alphabet,
  ) {
    return _TWBase32EncodeWithAlphabet(
      data,
      alphabet,
    );
  }

  late final _TWBase32EncodeWithAlphabetPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWData>,
              ffi.Pointer<TWString>)>>('TWBase32EncodeWithAlphabet');
  late final _TWBase32EncodeWithAlphabet =
      _TWBase32EncodeWithAlphabetPtr.asFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWData>, ffi.Pointer<TWString>)>();

  /// Encode an input to Base32 with the default alphabet (ALPHABET_RFC4648)
  ///
  /// \param data Data to be encoded (raw bytes)
  /// \return The encoded data
  /// \note Call TWBase32EncodeWithAlphabet with nullptr.
  ffi.Pointer<TWString> TWBase32Encode(
    ffi.Pointer<TWData> data,
  ) {
    return _TWBase32Encode(
      data,
    );
  }

  late final _TWBase32EncodePtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWString> Function(ffi.Pointer<TWData>)>>(
      'TWBase32Encode');
  late final _TWBase32Encode = _TWBase32EncodePtr.asFunction<
      ffi.Pointer<TWString> Function(ffi.Pointer<TWData>)>();

  /// Sign a message.
  ///
  /// \param privateKey: the private key used for signing
  /// \param message: A custom hex message which is input to the signing.
  /// \returns the signature, Hex-encoded. On invalid input empty string is returned. Returned object needs to be deleted after use.
  ffi.Pointer<TWString> TWStarkExMessageSignerSignMessage(
    ffi.Pointer<TWPrivateKey> privateKey,
    ffi.Pointer<TWString> message,
  ) {
    return _TWStarkExMessageSignerSignMessage(
      privateKey,
      message,
    );
  }

  late final _TWStarkExMessageSignerSignMessagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWPrivateKey>,
              ffi.Pointer<TWString>)>>('TWStarkExMessageSignerSignMessage');
  late final _TWStarkExMessageSignerSignMessage =
      _TWStarkExMessageSignerSignMessagePtr.asFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWString>)>();

  /// Verify signature for a message.
  ///
  /// \param pubKey: pubKey that will verify and recover the message from the signature
  /// \param message: the message signed (without prefix) in hex
  /// \param signature: in Hex-encoded form.
  /// \returns false on any invalid input (does not throw), true if the message can be recovered from the signature
  bool TWStarkExMessageSignerVerifyMessage(
    ffi.Pointer<TWPublicKey> pubKey,
    ffi.Pointer<TWString> message,
    ffi.Pointer<TWString> signature,
  ) {
    return _TWStarkExMessageSignerVerifyMessage(
      pubKey,
      message,
      signature,
    );
  }

  late final _TWStarkExMessageSignerVerifyMessagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>>('TWStarkExMessageSignerVerifyMessage');
  late final _TWStarkExMessageSignerVerifyMessage =
      _TWStarkExMessageSignerVerifyMessagePtr.asFunction<
          bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>();

  /// Implement format input as described in https://tezostaquito.io/docs/signing/
  ///
  /// \param message message to format e.g: Hello, World
  /// \param dAppUrl the app url, e.g: testUrl
  /// \returns the formatted message as a string
  ffi.Pointer<TWString> TWTezosMessageSignerFormatMessage(
    ffi.Pointer<TWString> message,
    ffi.Pointer<TWString> url,
  ) {
    return _TWTezosMessageSignerFormatMessage(
      message,
      url,
    );
  }

  late final _TWTezosMessageSignerFormatMessagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>>('TWTezosMessageSignerFormatMessage');
  late final _TWTezosMessageSignerFormatMessage =
      _TWTezosMessageSignerFormatMessagePtr.asFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWString>, ffi.Pointer<TWString>)>();

  /// Implement input to payload as described in: https://tezostaquito.io/docs/signing/
  ///
  /// \param message formatted message to be turned into an hex payload
  /// \return the hexpayload of the formated message as a hex string
  ffi.Pointer<TWString> TWTezosMessageSignerInputToPayload(
    ffi.Pointer<TWString> message,
  ) {
    return _TWTezosMessageSignerInputToPayload(
      message,
    );
  }

  late final _TWTezosMessageSignerInputToPayloadPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWString>)>>('TWTezosMessageSignerInputToPayload');
  late final _TWTezosMessageSignerInputToPayload =
      _TWTezosMessageSignerInputToPayloadPtr.asFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWString>)>();

  /// Sign a message as described in https://tezostaquito.io/docs/signing/
  ///
  /// \param privateKey: the private key used for signing
  /// \param message: A custom message payload (hex) which is input to the signing.
  /// \returns the signature, Hex-encoded. On invalid input empty string is returned. Returned object needs to be deleted after use.
  ffi.Pointer<TWString> TWTezosMessageSignerSignMessage(
    ffi.Pointer<TWPrivateKey> privateKey,
    ffi.Pointer<TWString> message,
  ) {
    return _TWTezosMessageSignerSignMessage(
      privateKey,
      message,
    );
  }

  late final _TWTezosMessageSignerSignMessagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString> Function(ffi.Pointer<TWPrivateKey>,
              ffi.Pointer<TWString>)>>('TWTezosMessageSignerSignMessage');
  late final _TWTezosMessageSignerSignMessage =
      _TWTezosMessageSignerSignMessagePtr.asFunction<
          ffi.Pointer<TWString> Function(
              ffi.Pointer<TWPrivateKey>, ffi.Pointer<TWString>)>();

  /// Verify signature for a message as described in https://tezostaquito.io/docs/signing/
  ///
  /// \param pubKey: pubKey that will verify the message from the signature
  /// \param message: the message signed as a payload (hex)
  /// \param signature: in Base58-encoded form.
  /// \returns false on any invalid input (does not throw), true if the message can be verified from the signature
  bool TWTezosMessageSignerVerifyMessage(
    ffi.Pointer<TWPublicKey> pubKey,
    ffi.Pointer<TWString> message,
    ffi.Pointer<TWString> signature,
  ) {
    return _TWTezosMessageSignerVerifyMessage(
      pubKey,
      message,
      signature,
    );
  }

  late final _TWTezosMessageSignerVerifyMessagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>>('TWTezosMessageSignerVerifyMessage');
  late final _TWTezosMessageSignerVerifyMessage =
      _TWTezosMessageSignerVerifyMessagePtr.asFunction<
          bool Function(ffi.Pointer<TWPublicKey>, ffi.Pointer<TWString>,
              ffi.Pointer<TWString>)>();

  /// Encrypts a block of Data using AES in Cipher Block Chaining (CBC) mode.
  ///
  /// \param key encryption key Data, must be 16, 24, or 32 bytes long.
  /// \param data Data to encrypt.
  /// \param iv initialization vector.
  /// \param mode padding mode.
  /// \return encrypted Data.
  ffi.Pointer<TWData> TWAESEncryptCBC(
    ffi.Pointer<TWData> key,
    ffi.Pointer<TWData> data,
    ffi.Pointer<TWData> iv,
    int mode,
  ) {
    return _TWAESEncryptCBC(
      key,
      data,
      iv,
      mode,
    );
  }

  late final _TWAESEncryptCBCPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWData>, ffi.Pointer<TWData>,
              ffi.Pointer<TWData>, ffi.Int32)>>('TWAESEncryptCBC');
  late final _TWAESEncryptCBC = _TWAESEncryptCBCPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>, ffi.Pointer<TWData>,
          ffi.Pointer<TWData>, int)>();

  /// Decrypts a block of data using AES in Cipher Block Chaining (CBC) mode.
  ///
  /// \param key decryption key Data, must be 16, 24, or 32 bytes long.
  /// \param data Data to decrypt.
  /// \param iv initialization vector Data.
  /// \param mode padding mode.
  /// \return decrypted Data.
  ffi.Pointer<TWData> TWAESDecryptCBC(
    ffi.Pointer<TWData> key,
    ffi.Pointer<TWData> data,
    ffi.Pointer<TWData> iv,
    int mode,
  ) {
    return _TWAESDecryptCBC(
      key,
      data,
      iv,
      mode,
    );
  }

  late final _TWAESDecryptCBCPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWData>, ffi.Pointer<TWData>,
              ffi.Pointer<TWData>, ffi.Int32)>>('TWAESDecryptCBC');
  late final _TWAESDecryptCBC = _TWAESDecryptCBCPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWData>, ffi.Pointer<TWData>,
          ffi.Pointer<TWData>, int)>();

  /// Encrypts a block of data using AES in Counter (CTR) mode.
  ///
  /// \param key encryption key Data, must be 16, 24, or 32 bytes long.
  /// \param data Data to encrypt.
  /// \param iv initialization vector Data.
  /// \return encrypted Data.
  ffi.Pointer<TWData> TWAESEncryptCTR(
    ffi.Pointer<TWData> key,
    ffi.Pointer<TWData> data,
    ffi.Pointer<TWData> iv,
  ) {
    return _TWAESEncryptCTR(
      key,
      data,
      iv,
    );
  }

  late final _TWAESEncryptCTRPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWData>, ffi.Pointer<TWData>,
              ffi.Pointer<TWData>)>>('TWAESEncryptCTR');
  late final _TWAESEncryptCTR = _TWAESEncryptCTRPtr.asFunction<
      ffi.Pointer<TWData> Function(
          ffi.Pointer<TWData>, ffi.Pointer<TWData>, ffi.Pointer<TWData>)>();

  /// Decrypts a block of data using AES in Counter (CTR) mode.
  ///
  /// \param key decryption key Data, must be 16, 24, or 32 bytes long.
  /// \param data Data to decrypt.
  /// \param iv initialization vector Data.
  /// \return decrypted Data.
  ffi.Pointer<TWData> TWAESDecryptCTR(
    ffi.Pointer<TWData> key,
    ffi.Pointer<TWData> data,
    ffi.Pointer<TWData> iv,
  ) {
    return _TWAESDecryptCTR(
      key,
      data,
      iv,
    );
  }

  late final _TWAESDecryptCTRPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWData> Function(ffi.Pointer<TWData>, ffi.Pointer<TWData>,
              ffi.Pointer<TWData>)>>('TWAESDecryptCTR');
  late final _TWAESDecryptCTR = _TWAESDecryptCTRPtr.asFunction<
      ffi.Pointer<TWData> Function(
          ffi.Pointer<TWData>, ffi.Pointer<TWData>, ffi.Pointer<TWData>)>();

  /// Create a FIO Account
  ///
  /// \param string Account name
  /// \note Must be deleted with \TWFIOAccountDelete
  /// \return Pointer to a nullable FIO Account
  ffi.Pointer<TWFIOAccount> TWFIOAccountCreateWithString(
    ffi.Pointer<TWString1> string,
  ) {
    return _TWFIOAccountCreateWithString(
      string,
    );
  }

  late final _TWFIOAccountCreateWithStringPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWFIOAccount> Function(
              ffi.Pointer<TWString1>)>>('TWFIOAccountCreateWithString');
  late final _TWFIOAccountCreateWithString = _TWFIOAccountCreateWithStringPtr
      .asFunction<ffi.Pointer<TWFIOAccount> Function(ffi.Pointer<TWString1>)>();

  /// Delete a FIO Account
  ///
  /// \param account Pointer to a non-null FIO Account
  void TWFIOAccountDelete(
    ffi.Pointer<TWFIOAccount> account,
  ) {
    return _TWFIOAccountDelete(
      account,
    );
  }

  late final _TWFIOAccountDeletePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWFIOAccount>)>>(
          'TWFIOAccountDelete');
  late final _TWFIOAccountDelete = _TWFIOAccountDeletePtr.asFunction<
      void Function(ffi.Pointer<TWFIOAccount>)>();

  /// Returns the short account string representation.
  ///
  /// \param account Pointer to a non-null FIO Account
  /// \return Account non-null string representation
  ffi.Pointer<TWString1> TWFIOAccountDescription(
    ffi.Pointer<TWFIOAccount> account,
  ) {
    return _TWFIOAccountDescription(
      account,
    );
  }

  late final _TWFIOAccountDescriptionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWFIOAccount>)>>('TWFIOAccountDescription');
  late final _TWFIOAccountDescription = _TWFIOAccountDescriptionPtr.asFunction<
      ffi.Pointer<TWString1> Function(ffi.Pointer<TWFIOAccount>)>();

  /// Encodes data as a Base58 string, including the checksum.
  ///
  /// \param data The data to encode.
  /// \return the encoded Base58 string with checksum.
  ffi.Pointer<TWString> TWBase58Encode(
    ffi.Pointer<TWData> data,
  ) {
    return _TWBase58Encode(
      data,
    );
  }

  late final _TWBase58EncodePtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWString> Function(ffi.Pointer<TWData>)>>(
      'TWBase58Encode');
  late final _TWBase58Encode = _TWBase58EncodePtr.asFunction<
      ffi.Pointer<TWString> Function(ffi.Pointer<TWData>)>();

  /// Encodes data as a Base58 string, not including the checksum.
  ///
  /// \param data The data to encode.
  /// \return then encoded Base58 string without checksum.
  ffi.Pointer<TWString> TWBase58EncodeNoCheck(
    ffi.Pointer<TWData> data,
  ) {
    return _TWBase58EncodeNoCheck(
      data,
    );
  }

  late final _TWBase58EncodeNoCheckPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWString> Function(ffi.Pointer<TWData>)>>(
      'TWBase58EncodeNoCheck');
  late final _TWBase58EncodeNoCheck = _TWBase58EncodeNoCheckPtr.asFunction<
      ffi.Pointer<TWString> Function(ffi.Pointer<TWData>)>();

  /// Decodes a Base58 string, checking the checksum. Returns null if the string is not a valid Base58 string.
  ///
  /// \param string The Base58 string to decode.
  /// \return the decoded data, empty if the string is not a valid Base58 string with checksum.
  ffi.Pointer<TWData> TWBase58Decode(
    ffi.Pointer<TWString> string,
  ) {
    return _TWBase58Decode(
      string,
    );
  }

  late final _TWBase58DecodePtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWString>)>>(
      'TWBase58Decode');
  late final _TWBase58Decode = _TWBase58DecodePtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWString>)>();

  /// Decodes a Base58 string, w/o checking the checksum. Returns null if the string is not a valid Base58 string.
  ///
  /// \param string The Base58 string to decode.
  /// \return the decoded data, empty if the string is not a valid Base58 string without checksum.
  ffi.Pointer<TWData> TWBase58DecodeNoCheck(
    ffi.Pointer<TWString> string,
  ) {
    return _TWBase58DecodeNoCheck(
      string,
    );
  }

  late final _TWBase58DecodeNoCheckPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<TWData> Function(ffi.Pointer<TWString>)>>(
      'TWBase58DecodeNoCheck');
  late final _TWBase58DecodeNoCheck = _TWBase58DecodeNoCheckPtr.asFunction<
      ffi.Pointer<TWData> Function(ffi.Pointer<TWString>)>();

  /// Creates a new Account with an address, a coin type, derivation enum, derivationPath, publicKey,
  /// and extendedPublicKey. Must be deleted with TWAccountDelete after use.
  ///
  /// \param address The address of the Account.
  /// \param coin The coin type of the Account.
  /// \param derivation The derivation of the Account.
  /// \param derivationPath The derivation path of the Account.
  /// \param publicKey hex encoded public key.
  /// \param extendedPublicKey Base58 encoded extended public key.
  /// \return A new Account.
  ffi.Pointer<TWAccount> TWAccountCreate(
    ffi.Pointer<TWString1> address,
    int coin,
    int derivation,
    ffi.Pointer<TWString1> derivationPath,
    ffi.Pointer<TWString1> publicKey,
    ffi.Pointer<TWString1> extendedPublicKey,
  ) {
    return _TWAccountCreate(
      address,
      coin,
      derivation,
      derivationPath,
      publicKey,
      extendedPublicKey,
    );
  }

  late final _TWAccountCreatePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWAccount> Function(
              ffi.Pointer<TWString1>,
              ffi.Int32,
              ffi.Int32,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>,
              ffi.Pointer<TWString1>)>>('TWAccountCreate');
  late final _TWAccountCreate = _TWAccountCreatePtr.asFunction<
      ffi.Pointer<TWAccount> Function(
          ffi.Pointer<TWString1>,
          int,
          int,
          ffi.Pointer<TWString1>,
          ffi.Pointer<TWString1>,
          ffi.Pointer<TWString1>)>();

  /// Deletes an account.
  ///
  /// \param account Account to delete.
  void TWAccountDelete(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountDelete(
      account,
    );
  }

  late final _TWAccountDeletePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<TWAccount>)>>(
          'TWAccountDelete');
  late final _TWAccountDelete =
      _TWAccountDeletePtr.asFunction<void Function(ffi.Pointer<TWAccount>)>();

  /// Returns the address of an account.
  ///
  /// \param account Account to get the address of.
  ffi.Pointer<TWString1> TWAccountAddress(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountAddress(
      account,
    );
  }

  late final _TWAccountAddressPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWAccount>)>>('TWAccountAddress');
  late final _TWAccountAddress = _TWAccountAddressPtr.asFunction<
      ffi.Pointer<TWString1> Function(ffi.Pointer<TWAccount>)>();

  /// Return CoinType enum of an account.
  ///
  /// \param account Account to get the coin type of.
  int TWAccountCoin(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountCoin(
      account,
    );
  }

  late final _TWAccountCoinPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<TWAccount>)>>(
          'TWAccountCoin');
  late final _TWAccountCoin =
      _TWAccountCoinPtr.asFunction<int Function(ffi.Pointer<TWAccount>)>();

  /// Returns the derivation enum of an account.
  ///
  /// \param account Account to get the derivation enum of.
  int TWAccountDerivation(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountDerivation(
      account,
    );
  }

  late final _TWAccountDerivationPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<TWAccount>)>>(
          'TWAccountDerivation');
  late final _TWAccountDerivation = _TWAccountDerivationPtr.asFunction<
      int Function(ffi.Pointer<TWAccount>)>();

  /// Returns derivationPath of an account.
  ///
  /// \param account Account to get the derivation path of.
  ffi.Pointer<TWString1> TWAccountDerivationPath(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountDerivationPath(
      account,
    );
  }

  late final _TWAccountDerivationPathPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWAccount>)>>('TWAccountDerivationPath');
  late final _TWAccountDerivationPath = _TWAccountDerivationPathPtr.asFunction<
      ffi.Pointer<TWString1> Function(ffi.Pointer<TWAccount>)>();

  /// Returns hex encoded publicKey of an account.
  ///
  /// \param account Account to get the public key of.
  ffi.Pointer<TWString1> TWAccountPublicKey(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountPublicKey(
      account,
    );
  }

  late final _TWAccountPublicKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWAccount>)>>('TWAccountPublicKey');
  late final _TWAccountPublicKey = _TWAccountPublicKeyPtr.asFunction<
      ffi.Pointer<TWString1> Function(ffi.Pointer<TWAccount>)>();

  /// Returns Base58 encoded extendedPublicKey of an account.
  ///
  /// \param account Account to get the extended public key of.
  ffi.Pointer<TWString1> TWAccountExtendedPublicKey(
    ffi.Pointer<TWAccount> account,
  ) {
    return _TWAccountExtendedPublicKey(
      account,
    );
  }

  late final _TWAccountExtendedPublicKeyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWString1> Function(
              ffi.Pointer<TWAccount>)>>('TWAccountExtendedPublicKey');
  late final _TWAccountExtendedPublicKey = _TWAccountExtendedPublicKeyPtr
      .asFunction<ffi.Pointer<TWString1> Function(ffi.Pointer<TWAccount>)>();

  /// Generates the private stark key at the given derivation path from a valid eth signature
  ///
  /// \param derivationPath non-null StarkEx Derivation path
  /// \param signature valid eth signature
  /// \return  The private key for the specified derivation path/signature
  ffi.Pointer<TWPrivateKey> TWStarkWareGetStarkKeyFromSignature(
    ffi.Pointer<TWDerivationPath> derivationPath,
    ffi.Pointer<TWString> signature,
  ) {
    return _TWStarkWareGetStarkKeyFromSignature(
      derivationPath,
      signature,
    );
  }

  late final _TWStarkWareGetStarkKeyFromSignaturePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<TWPrivateKey> Function(ffi.Pointer<TWDerivationPath>,
              ffi.Pointer<TWString>)>>('TWStarkWareGetStarkKeyFromSignature');
  late final _TWStarkWareGetStarkKeyFromSignature =
      _TWStarkWareGetStarkKeyFromSignaturePtr.asFunction<
          ffi.Pointer<TWPrivateKey> Function(
              ffi.Pointer<TWDerivationPath>, ffi.Pointer<TWString>)>();
}

class GeniusArray extends ffi.Struct {
  @ffi.Uint64()
  external int size;

  external ffi.Pointer<ffi.Uint8> ptr;
}

class GeniusMatrix extends ffi.Struct {
  @ffi.Uint64()
  external int size;

  external ffi.Pointer<GeniusArray> ptr;
}

class GeniusAddress extends ffi.Struct {
  /// A string prepended with `0x` followed by 64 hex characters
  @ffi.Array.multi([67])
  external ffi.Array<ffi.Char> address;
}

class GeniusTokenValue extends ffi.Struct {
  /// Represents a Genius token value in fixed-point format as a string
  @ffi.Array.multi([22])
  external ffi.Array<ffi.Char> value;
}

/// Defines a resizable block of data.
///
/// The implementantion of these methods should be language-specific to minimize translation overhead. For instance it
/// should be a `jbyteArray` for Java and an `NSData` for Swift.
typedef TWData = ffi.Void;

/// Defines a resizable string.
///
/// The implementantion of these methods should be language-specific to minimize translation
/// overhead. For instance it should be a `jstring` for Java and an `NSString` for Swift. Create
/// allocates memory, the delete call should be called at the end to release memory.
typedef TWString = ffi.Void;

/// Filecoin-Ethereum address converter.
class TWFilecoinAddressConverter extends ffi.Opaque {}

/// Blockchain enum type
abstract class TWBlockchain {
  static const int TWBlockchainBitcoin = 0;
  static const int TWBlockchainEthereum = 1;
  static const int TWBlockchainVechain = 3;
  static const int TWBlockchainTron = 4;
  static const int TWBlockchainIcon = 5;
  static const int TWBlockchainBinance = 6;
  static const int TWBlockchainRipple = 7;
  static const int TWBlockchainTezos = 8;
  static const int TWBlockchainNimiq = 9;
  static const int TWBlockchainStellar = 10;
  static const int TWBlockchainAion = 11;
  static const int TWBlockchainCosmos = 12;
  static const int TWBlockchainTheta = 13;
  static const int TWBlockchainOntology = 14;
  static const int TWBlockchainZilliqa = 15;
  static const int TWBlockchainIoTeX = 16;
  static const int TWBlockchainEOS = 17;
  static const int TWBlockchainNano = 18;
  static const int TWBlockchainNULS = 19;
  static const int TWBlockchainWaves = 20;
  static const int TWBlockchainAeternity = 21;
  static const int TWBlockchainNebulas = 22;
  static const int TWBlockchainFIO = 23;
  static const int TWBlockchainSolana = 24;
  static const int TWBlockchainHarmony = 25;
  static const int TWBlockchainNEAR = 26;
  static const int TWBlockchainAlgorand = 27;
  static const int TWBlockchainPolkadot = 29;
  static const int TWBlockchainCardano = 30;
  static const int TWBlockchainNEO = 31;
  static const int TWBlockchainFilecoin = 32;
  static const int TWBlockchainMultiversX = 33;
  static const int TWBlockchainOasisNetwork = 34;
  static const int TWBlockchainDecred = 35;
  static const int TWBlockchainZcash = 36;
  static const int TWBlockchainGroestlcoin = 37;
  static const int TWBlockchainThorchain = 38;
  static const int TWBlockchainRonin = 39;
  static const int TWBlockchainKusama = 40;
  static const int TWBlockchainNervos = 41;
  static const int TWBlockchainEverscale = 42;
  static const int TWBlockchainAptos = 43;
  static const int TWBlockchainHedera = 44;
  static const int TWBlockchainTheOpenNetwork = 45;
  static const int TWBlockchainSui = 46;
}

/// Elliptic cruves
abstract class TWCurve {
  static const int TWCurveSECP256k1 = 0;
  static const int TWCurveED25519 = 1;
  static const int TWCurveED25519Blake2bNano = 2;
  static const int TWCurveCurve25519 = 3;
  static const int TWCurveNIST256p1 = 4;
  static const int TWCurveED25519ExtendedCardano = 5;
  static const int TWCurveStarkex = 6;
  static const int TWCurveNone = 7;
}

/// Registered HD version bytes
///
/// \see https://github.com/satoshilabs/slips/blob/master/slip-0132.md
abstract class TWHDVersion {
  static const int TWHDVersionNone = 0;
  static const int TWHDVersionXPUB = 76067358;
  static const int TWHDVersionXPRV = 76066276;
  static const int TWHDVersionYPUB = 77429938;
  static const int TWHDVersionYPRV = 77428856;
  static const int TWHDVersionZPUB = 78792518;
  static const int TWHDVersionZPRV = 78791436;
  static const int TWHDVersionLTUB = 27108450;
  static const int TWHDVersionLTPV = 27106558;
  static const int TWHDVersionMTUB = 28471030;
  static const int TWHDVersionMTPV = 28469138;
  static const int TWHDVersionDPUB = 50178342;
  static const int TWHDVersionDPRV = 50177256;
  static const int TWHDVersionDGUB = 49990397;
  static const int TWHDVersionDGPV = 49988504;
}

/// Registered human-readable parts for BIP-0173
///
/// - SeeAlso: https://github.com/satoshilabs/slips/blob/master/slip-0173.md
abstract class TWHRP {
  static const int TWHRPUnknown = 0;
  static const int TWHRPBitcoin = 1;
  static const int TWHRPLitecoin = 2;
  static const int TWHRPViacoin = 3;
  static const int TWHRPGroestlcoin = 4;
  static const int TWHRPDigiByte = 5;
  static const int TWHRPMonacoin = 6;
  static const int TWHRPCosmos = 7;
  static const int TWHRPBitcoinCash = 8;
  static const int TWHRPBitcoinGold = 9;
  static const int TWHRPIoTeX = 10;
  static const int TWHRPNervos = 11;
  static const int TWHRPZilliqa = 12;
  static const int TWHRPTerra = 13;
  static const int TWHRPCryptoOrg = 14;
  static const int TWHRPKava = 15;
  static const int TWHRPOasis = 16;
  static const int TWHRPBluzelle = 17;
  static const int TWHRPBandChain = 18;
  static const int TWHRPMultiversX = 19;
  static const int TWHRPSecret = 20;
  static const int TWHRPAgoric = 21;
  static const int TWHRPBinance = 22;
  static const int TWHRPECash = 23;
  static const int TWHRPTHORChain = 24;
  static const int TWHRPHarmony = 25;
  static const int TWHRPCardano = 26;
  static const int TWHRPQtum = 27;
  static const int TWHRPNativeInjective = 28;
  static const int TWHRPOsmosis = 29;
  static const int TWHRPTerraV2 = 30;
  static const int TWHRPCoreum = 31;
  static const int TWHRPNativeCanto = 32;
  static const int TWHRPSommelier = 33;
  static const int TWHRPFetchAI = 34;
  static const int TWHRPMars = 35;
  static const int TWHRPUmee = 36;
  static const int TWHRPQuasar = 37;
  static const int TWHRPPersistence = 38;
  static const int TWHRPAkash = 39;
  static const int TWHRPNoble = 40;
  static const int TWHRPStargaze = 41;
  static const int TWHRPNativeEvmos = 42;
  static const int TWHRPJuno = 43;
  static const int TWHRPStride = 44;
  static const int TWHRPAxelar = 45;
  static const int TWHRPCrescent = 46;
  static const int TWHRPKujira = 47;
  static const int TWHRPComdex = 48;
  static const int TWHRPNeutron = 49;
}

/// HD wallet purpose
///
/// \see https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
/// \see https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki
/// \see https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki
abstract class TWPurpose {
  static const int TWPurposeBIP44 = 44;
  static const int TWPurposeBIP49 = 49;
  static const int TWPurposeBIP84 = 84;
  static const int TWPurposeBIP1852 = 1852;
}

/// Non-default coin address derivation names (default, unnamed derivations are not included).
abstract class TWDerivation {
  static const int TWDerivationDefault = 0;
  static const int TWDerivationCustom = 1;
  static const int TWDerivationBitcoinSegwit = 2;
  static const int TWDerivationBitcoinLegacy = 3;
  static const int TWDerivationBitcoinTestnet = 4;
  static const int TWDerivationLitecoinLegacy = 5;
  static const int TWDerivationSolanaSolana = 6;
}

/// Public key types
abstract class TWPublicKeyType {
  static const int TWPublicKeyTypeSECP256k1 = 0;
  static const int TWPublicKeyTypeSECP256k1Extended = 1;
  static const int TWPublicKeyTypeNIST256p1 = 2;
  static const int TWPublicKeyTypeNIST256p1Extended = 3;
  static const int TWPublicKeyTypeED25519 = 4;
  static const int TWPublicKeyTypeED25519Blake2b = 5;
  static const int TWPublicKeyTypeCURVE25519 = 6;
  static const int TWPublicKeyTypeED25519Cardano = 7;
  static const int TWPublicKeyTypeStarkex = 8;
}

/// Represents a private key.
class TWPrivateKey extends ffi.Opaque {}

/// Represents a public key.
class TWPublicKey extends ffi.Opaque {}

/// Coin type for Level 2 of BIP44.
///
/// \see https://github.com/satoshilabs/slips/blob/master/slip-0044.md
abstract class TWCoinType {
  static const int TWCoinTypeAeternity = 457;
  static const int TWCoinTypeAion = 425;
  static const int TWCoinTypeBinance = 714;
  static const int TWCoinTypeBitcoin = 0;
  static const int TWCoinTypeBitcoinCash = 145;
  static const int TWCoinTypeBitcoinGold = 156;
  static const int TWCoinTypeCallisto = 820;
  static const int TWCoinTypeCardano = 1815;
  static const int TWCoinTypeCosmos = 118;
  static const int TWCoinTypeDash = 5;
  static const int TWCoinTypeDecred = 42;
  static const int TWCoinTypeDigiByte = 20;
  static const int TWCoinTypeDogecoin = 3;
  static const int TWCoinTypeEOS = 194;
  static const int TWCoinTypeWAX = 14001;
  static const int TWCoinTypeEthereum = 60;
  static const int TWCoinTypeEthereumClassic = 61;
  static const int TWCoinTypeFIO = 235;
  static const int TWCoinTypeGoChain = 6060;
  static const int TWCoinTypeGroestlcoin = 17;
  static const int TWCoinTypeICON = 74;
  static const int TWCoinTypeIoTeX = 304;
  static const int TWCoinTypeKava = 459;
  static const int TWCoinTypeKin = 2017;
  static const int TWCoinTypeLitecoin = 2;
  static const int TWCoinTypeMonacoin = 22;
  static const int TWCoinTypeNebulas = 2718;
  static const int TWCoinTypeNULS = 8964;
  static const int TWCoinTypeNano = 165;
  static const int TWCoinTypeNEAR = 397;
  static const int TWCoinTypeNimiq = 242;
  static const int TWCoinTypeOntology = 1024;
  static const int TWCoinTypePOANetwork = 178;
  static const int TWCoinTypeQtum = 2301;
  static const int TWCoinTypeXRP = 144;
  static const int TWCoinTypeSolana = 501;
  static const int TWCoinTypeStellar = 148;
  static const int TWCoinTypeTezos = 1729;
  static const int TWCoinTypeTheta = 500;
  static const int TWCoinTypeThunderCore = 1001;
  static const int TWCoinTypeNEO = 888;
  static const int TWCoinTypeTomoChain = 889;
  static const int TWCoinTypeTron = 195;
  static const int TWCoinTypeVeChain = 818;
  static const int TWCoinTypeViacoin = 14;
  static const int TWCoinTypeWanchain = 5718350;
  static const int TWCoinTypeZcash = 133;
  static const int TWCoinTypeFiro = 136;
  static const int TWCoinTypeZilliqa = 313;
  static const int TWCoinTypeZelcash = 19167;
  static const int TWCoinTypeRavencoin = 175;
  static const int TWCoinTypeWaves = 5741564;
  static const int TWCoinTypeTerra = 330;
  static const int TWCoinTypeTerraV2 = 10000330;
  static const int TWCoinTypeHarmony = 1023;
  static const int TWCoinTypeAlgorand = 283;
  static const int TWCoinTypeKusama = 434;
  static const int TWCoinTypePolkadot = 354;
  static const int TWCoinTypeFilecoin = 461;
  static const int TWCoinTypeMultiversX = 508;
  static const int TWCoinTypeBandChain = 494;
  static const int TWCoinTypeSmartChainLegacy = 10000714;
  static const int TWCoinTypeSmartChain = 20000714;
  static const int TWCoinTypeOasis = 474;
  static const int TWCoinTypePolygon = 966;
  static const int TWCoinTypeTHORChain = 931;
  static const int TWCoinTypeBluzelle = 483;
  static const int TWCoinTypeOptimism = 10000070;
  static const int TWCoinTypeZksync = 10000324;
  static const int TWCoinTypeArbitrum = 10042221;
  static const int TWCoinTypeECOChain = 10000553;
  static const int TWCoinTypeAvalancheCChain = 10009000;
  static const int TWCoinTypeXDai = 10000100;
  static const int TWCoinTypeFantom = 10000250;
  static const int TWCoinTypeCryptoOrg = 394;
  static const int TWCoinTypeCelo = 52752;
  static const int TWCoinTypeRonin = 10002020;
  static const int TWCoinTypeOsmosis = 10000118;
  static const int TWCoinTypeECash = 899;
  static const int TWCoinTypeCronosChain = 10000025;
  static const int TWCoinTypeSmartBitcoinCash = 10000145;
  static const int TWCoinTypeKuCoinCommunityChain = 10000321;
  static const int TWCoinTypeBoba = 10000288;
  static const int TWCoinTypeMetis = 1001088;
  static const int TWCoinTypeAurora = 1323161554;
  static const int TWCoinTypeEvmos = 10009001;
  static const int TWCoinTypeNativeEvmos = 20009001;
  static const int TWCoinTypeMoonriver = 10001285;
  static const int TWCoinTypeMoonbeam = 10001284;
  static const int TWCoinTypeKavaEvm = 10002222;
  static const int TWCoinTypeKlaytn = 10008217;
  static const int TWCoinTypeMeter = 18000;
  static const int TWCoinTypeOKXChain = 996;
  static const int TWCoinTypeNervos = 309;
  static const int TWCoinTypeEverscale = 396;
  static const int TWCoinTypeAptos = 637;
  static const int TWCoinTypeHedera = 3030;
  static const int TWCoinTypeSecret = 529;
  static const int TWCoinTypeNativeInjective = 10000060;
  static const int TWCoinTypeAgoric = 564;
  static const int TWCoinTypeTON = 607;
  static const int TWCoinTypeSui = 784;
  static const int TWCoinTypeStargaze = 20000118;
  static const int TWCoinTypePolygonzkEVM = 10001101;
  static const int TWCoinTypeJuno = 30000118;
  static const int TWCoinTypeStride = 40000118;
  static const int TWCoinTypeAxelar = 50000118;
  static const int TWCoinTypeCrescent = 60000118;
  static const int TWCoinTypeKujira = 70000118;
}

/// Defines a resizable string.
///
/// The implementantion of these methods should be language-specific to minimize translation
/// overhead. For instance it should be a `jstring` for Java and an `NSString` for Swift. Create
/// allocates memory, the delete call should be called at the end to release memory.
typedef TWString1 = ffi.Void;

/// Represents a Nervos address.
class TWNervosAddress extends ffi.Opaque {}

/// A vector of TWData byte arrays
class TWDataVector extends ffi.Opaque {}

/// Defines a resizable block of data.
///
/// The implementantion of these methods should be language-specific to minimize translation overhead. For instance it
/// should be a `jbyteArray` for Java and an `NSData` for Swift.
typedef TWData1 = ffi.Void;

/// Non-core transaction utility methods, like building a transaction using an external signature.
class TWTransactionCompiler extends ffi.Opaque {}

/// Private key types, the vast majority of chains use the default, 32-byte key.
abstract class TWPrivateKeyType {
  static const int TWPrivateKeyTypeDefault = 0;
  static const int TWPrivateKeyTypeCardano = 1;
}

/// Represents a signer to sign transactions for any blockchain.
class TWAnySigner extends ffi.Opaque {}

/// Tron message signing and verification.
///
/// Tron and some other wallets support a message signing & verification format, to create a proof (a signature)
/// that someone has access to the private keys of a specific address.
class TWTronMessageSigner extends ffi.Opaque {}

/// Preset encryption parameter with different security strength, for key store
abstract class TWStoredKeyEncryptionLevel {
  /// Default, which is one of the below values, determined by the implementation.
  static const int TWStoredKeyEncryptionLevelDefault = 0;

  /// Minimal sufficient level of encryption strength (scrypt 4096)
  static const int TWStoredKeyEncryptionLevelMinimal = 1;

  /// Weak encryption strength (scrypt 16k)
  static const int TWStoredKeyEncryptionLevelWeak = 2;

  /// Standard level of encryption strength (scrypt 262k)
  static const int TWStoredKeyEncryptionLevelStandard = 3;
}

/// Represents a NEAR Account name
class TWNEARAccount extends ffi.Opaque {}

/// Represents a legacy Bitcoin address in C++.
class TWBitcoinAddress extends ffi.Opaque {}

/// Wrapper class for Ethereum ABI encoding & decoding.
class TWEthereumAbiFunction extends ffi.Opaque {}

class TWEthereumAbi extends ffi.Opaque {}

/// Stellar address version byte.
abstract class TWStellarVersionByte {
  static const int TWStellarVersionByteAccountID = 48;
  static const int TWStellarVersionByteSeed = 192;
  static const int TWStellarVersionBytePreAuthTX = 200;
  static const int TWStellarVersionByteSHA256Hash = 280;
}

/// Stellar memo type.
abstract class TWStellarMemoType {
  static const int TWStellarMemoTypeNone = 0;
  static const int TWStellarMemoTypeText = 1;
  static const int TWStellarMemoTypeId = 2;
  static const int TWStellarMemoTypeHash = 3;
  static const int TWStellarMemoTypeReturn = 4;
}

/// Represents a legacy Groestlcoin address.
class TWGroestlcoinAddress extends ffi.Opaque {}

/// Filecoin address type.
abstract class TWFilecoinAddressType {
  static const int TWFilecoinAddressTypeDefault = 0;
  static const int TWFilecoinAddressTypeDelegated = 1;
}

/// Represents an address in C++ for almost any blockchain.
class TWAnyAddress extends ffi.Opaque {}

/// Represents a BIP 0173 address.
class TWSegwitAddress extends ffi.Opaque {}

/// Represents a BIP44 DerivationPath in C++.
class TWDerivationPath extends ffi.Opaque {}

class TWDerivationPathIndex extends ffi.Opaque {}

/// Hierarchical Deterministic (HD) Wallet
class TWHDWallet extends ffi.Opaque {}

/// Preset encryption kind
abstract class TWStoredKeyEncryption {
  static const int TWStoredKeyEncryptionAes128Ctr = 0;
  static const int TWStoredKeyEncryptionAes128Cbc = 1;
  static const int TWStoredKeyEncryptionAes192Ctr = 2;
  static const int TWStoredKeyEncryptionAes256Ctr = 3;
}

/// Represents a key stored as an encrypted file.
class TWStoredKey extends ffi.Opaque {}

class TWAccount extends ffi.Opaque {}

/// Represents a Ripple X-address.
class TWRippleXAddress extends ffi.Opaque {}

/// Padding mode used in AES encryption.
abstract class TWAESPaddingMode {
  static const int TWAESPaddingModeZero = 0;
  static const int TWAESPaddingModePKCS7 = 1;
}

/// Base64 encode / decode functions
class TWBase64 extends ffi.Opaque {}

/// Mnemonic validate / lookup functions
class TWMnemonic extends ffi.Opaque {}

/// Bitcoin SIGHASH type.
abstract class TWBitcoinSigHashType {
  static const int TWBitcoinSigHashTypeAll = 1;
  static const int TWBitcoinSigHashTypeNone = 2;
  static const int TWBitcoinSigHashTypeSingle = 3;
  static const int TWBitcoinSigHashTypeFork = 64;
  static const int TWBitcoinSigHashTypeForkBTG = 20288;
  static const int TWBitcoinSigHashTypeAnyoneCanPay = 128;
}

/// Bitcoin script manipulating functions
class TWBitcoinScript extends ffi.Opaque {}

/// Ethereum message signing and verification.
///
/// Ethereum and some other wallets support a message signing & verification format, to create a proof (a signature)
/// that someone has access to the private keys of a specific address.
class TWEthereumMessageSigner extends ffi.Opaque {}

/// Bitcoin message signing and verification.
///
/// Bitcoin Core and some other wallets support a message signing & verification format, to create a proof (a signature)
/// that someone has access to the private keys of a specific address.
/// This feature currently works on old legacy addresses only.
class TWBitcoinMessageSigner extends ffi.Opaque {}

/// Hash functions
class TWHash extends ffi.Struct {
  @ffi.Uint8()
  external int unused;
}

/// Represents Ethereum ABI value
class TWEthereumAbiValue extends ffi.Opaque {}

/// THORChain swap functions
class TWTHORChainSwap extends ffi.Opaque {}

class TWEthereum extends ffi.Opaque {}

/// Stellar network passphrase string.
abstract class TWStellarPassphrase {
  static const int TWStellarPassphraseStellar = 0;
  static const int TWStellarPassphraseKin = 1;
}

/// Cardano helper functions
class TWCardano extends ffi.Opaque {}

/// CoinTypeConfiguration functions
class TWCoinTypeConfiguration extends ffi.Struct {
  @ffi.Uint8()
  external int unused;
}

/// Password-Based Key Derivation Function 2
class TWPBKDF2 extends ffi.Opaque {}

/// Solana address helper functions
class TWSolanaAddress extends ffi.Opaque {}

/// Base32 encode / decode functions
class TWBase32 extends ffi.Opaque {}

/// Chain identifiers for Ethereum-based blockchains, for convenience. Recommended to use the dynamic CoinType.ChainId() instead.
/// See also TWChainId.
abstract class TWEthereumChainID {
  static const int TWEthereumChainIDEthereum = 1;
  static const int TWEthereumChainIDClassic = 61;
  static const int TWEthereumChainIDPoa = 99;
  static const int TWEthereumChainIDVechain = 74;
  static const int TWEthereumChainIDCallisto = 820;
  static const int TWEthereumChainIDTomochain = 88;
  static const int TWEthereumChainIDPolygon = 137;
  static const int TWEthereumChainIDOkc = 66;
  static const int TWEthereumChainIDThundertoken = 108;
  static const int TWEthereumChainIDGochain = 60;
  static const int TWEthereumChainIDMeter = 82;
  static const int TWEthereumChainIDCelo = 42220;
  static const int TWEthereumChainIDWanchain = 888;
  static const int TWEthereumChainIDCronos = 25;
  static const int TWEthereumChainIDOptimism = 10;
  static const int TWEthereumChainIDXdai = 100;
  static const int TWEthereumChainIDSmartbch = 10000;
  static const int TWEthereumChainIDFantom = 250;
  static const int TWEthereumChainIDBoba = 288;
  static const int TWEthereumChainIDKcc = 321;
  static const int TWEthereumChainIDZksync = 324;
  static const int TWEthereumChainIDHeco = 128;
  static const int TWEthereumChainIDMetis = 1088;
  static const int TWEthereumChainIDPolygonzkevm = 1101;
  static const int TWEthereumChainIDMoonbeam = 1284;
  static const int TWEthereumChainIDMoonriver = 1285;
  static const int TWEthereumChainIDRonin = 2020;
  static const int TWEthereumChainIDKavaevm = 2222;
  static const int TWEthereumChainIDKlaytn = 8217;
  static const int TWEthereumChainIDAvalanchec = 43114;
  static const int TWEthereumChainIDEvmos = 9001;
  static const int TWEthereumChainIDArbitrum = 42161;
  static const int TWEthereumChainIDSmartchain = 56;
  static const int TWEthereumChainIDAurora = 1313161554;
}

/// StarkEx message signing and verification.
///
/// StarkEx and some other wallets support a message signing & verification format, to create a proof (a signature)
/// that someone has access to the private keys of a specific address.
class TWStarkExMessageSigner extends ffi.Opaque {}

/// Tezos message signing, verification and utilities.
class TWTezosMessageSigner extends ffi.Opaque {}

/// AES encryption/decryption methods.
class TWAES extends ffi.Struct {
  @ffi.Uint8()
  external int unused;
}

/// Represents a FIO Account name
class TWFIOAccount extends ffi.Opaque {}

/// Substrate based chains Address Type
///
/// \see https://github.com/paritytech/substrate/wiki/External-Address-Format-(SS58)#address-type
abstract class TWSS58AddressType {
  static const int TWSS58AddressTypePolkadot = 0;
  static const int TWSS58AddressTypeKusama = 2;
}

/// Base58 encode / decode functions
class TWBase58 extends ffi.Opaque {}

class TWStarkWare extends ffi.Opaque {}
