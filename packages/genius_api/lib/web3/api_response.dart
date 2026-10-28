class ApiResponse<T> {
  final T? data;
  final String? errorMessage;
  final bool isSuccess;

  /// Set only by [ApiResponse.reverted]: the failure is settled on chain.
  final bool reverted;

  ApiResponse._({
    this.data,
    this.errorMessage,
    required this.isSuccess,
    this.reverted = false,
  });

  /// Factory for a successful response
  factory ApiResponse.success(T data) {
    return ApiResponse._(data: data, isSuccess: true);
  }

  /// Factory for an error response
  factory ApiResponse.error(String errorMessage) {
    return ApiResponse._(errorMessage: errorMessage, isSuccess: false);
  }

  /// A failure that still carries [data]: a signed transaction whose
  /// broadcast got no answer, so it may be on the network under that hash.
  factory ApiResponse.unconfirmed(T data, String errorMessage) {
    return ApiResponse._(
      data: data,
      errorMessage: errorMessage,
      isSuccess: false,
    );
  }

  /// A transaction that was mined and reverted, under [data]'s hash. Unlike
  /// [ApiResponse.unconfirmed] it is final: it can never land.
  factory ApiResponse.reverted(T data, String errorMessage) {
    return ApiResponse._(
      data: data,
      errorMessage: errorMessage,
      isSuccess: false,
      reverted: true,
    );
  }
}
