// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import '../lib.dart';
import '../utils/error.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'uri.dart';

// These types are ignored because they are not used by any `pub` functions: `FfiRequestContextV1`, `FfiRequestContextV2`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `clone`, `clone`, `from`, `from`, `from`, `from`, `from`, `from`, `from`, `from`

class FfiContextV1 {
  final ArcContextV1 field0;

  const FfiContextV1({
    required this.field0,
  });

  Future<String> processResponse({required List<int> response}) => core
      .instance.api
      .crateApiSendFfiContextV1ProcessResponse(that: this, response: response);

  @override
  int get hashCode => field0.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FfiContextV1 &&
          runtimeType == other.runtimeType &&
          field0 == other.field0;
}

class FfiContextV2 {
  final ArcContextV2 field0;

  const FfiContextV2({
    required this.field0,
  });

  Future<String?> processResponse({required List<int> response}) => core
      .instance.api
      .crateApiSendFfiContextV2ProcessResponse(that: this, response: response);

  @override
  int get hashCode => field0.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FfiContextV2 &&
          runtimeType == other.runtimeType &&
          field0 == other.field0;
}

class FfiRequest {
  final FfiUrl ffiUrl;
  final Uint8List body;

  const FfiRequest({
    required this.ffiUrl,
    required this.body,
  });

  @override
  int get hashCode => ffiUrl.hashCode ^ body.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FfiRequest &&
          runtimeType == other.runtimeType &&
          ffiUrl == other.ffiUrl &&
          body == other.body;
}

class FfiRequestBuilder {
  final RequestBuilder field0;

  const FfiRequestBuilder({
    required this.field0,
  });

  Future<FfiRequestBuilder> alwaysDisableOutputSubstitution(
          {required bool disable}) =>
      core.instance.api
          .crateApiSendFfiRequestBuilderAlwaysDisableOutputSubstitution(
              that: this, disable: disable);

  Future<FfiRequestContext> buildNonIncentivizing(
          {required BigInt minFeeRate}) =>
      core.instance.api.crateApiSendFfiRequestBuilderBuildNonIncentivizing(
          that: this, minFeeRate: minFeeRate);

  Future<FfiRequestContext> buildRecommended({required BigInt minFeeRate}) =>
      core.instance.api.crateApiSendFfiRequestBuilderBuildRecommended(
          that: this, minFeeRate: minFeeRate);

  Future<FfiRequestContext> buildWithAdditionalFee(
          {required BigInt maxFeeContribution,
          int? changeIndex,
          required BigInt minFeeRate,
          required bool clampFeeContribution}) =>
      core.instance.api.crateApiSendFfiRequestBuilderBuildWithAdditionalFee(
          that: this,
          maxFeeContribution: maxFeeContribution,
          changeIndex: changeIndex,
          minFeeRate: minFeeRate,
          clampFeeContribution: clampFeeContribution);

  static Future<FfiRequestBuilder> fromPsbtAndUri(
          {required String psbtBase64, required FfiPjUri pjUri}) =>
      core.instance.api.crateApiSendFfiRequestBuilderFromPsbtAndUri(
          psbtBase64: psbtBase64, pjUri: pjUri);

  @override
  int get hashCode => field0.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FfiRequestBuilder &&
          runtimeType == other.runtimeType &&
          field0 == other.field0;
}

class FfiRequestContext {
  final RequestContext field0;

  const FfiRequestContext({
    required this.field0,
  });

  Future<(FfiRequest, FfiContextV1)> extractV1() =>
      core.instance.api.crateApiSendFfiRequestContextExtractV1(
        that: this,
      );

  Future<(FfiRequest, FfiContextV2)> extractV2(
          {required FfiUrl ohttpProxyUrl}) =>
      core.instance.api.crateApiSendFfiRequestContextExtractV2(
          that: this, ohttpProxyUrl: ohttpProxyUrl);

  @override
  int get hashCode => field0.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FfiRequestContext &&
          runtimeType == other.runtimeType &&
          field0 == other.field0;
}
