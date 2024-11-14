// import 'dart:async';
// import 'dart:typed_data';

// import 'package:flutter/cupertino.dart';
// import 'package:payjoin_flutter/common.dart' as common;
// import 'package:payjoin_flutter/receive.dart' as receive;
// import 'package:payjoin_flutter/send.dart' as send;
// import 'package:payjoin_flutter/uri.dart' as pj_uri;

// class PayJoinLibrary {
//   static const pjUrl = "https://localhost:8088";
//   static const ohRelay = "https://localhost:8088";
//   static const localCertFile = "localhost.der";
//   Future<String> buildPjUri(double amount, String address, {String? pj}) async {
//     try {
//       final pjUri = "bitcoin:$address?amount=$amount&pj=${pj ?? pjUrl}";
//       await pj_uri.Uri.fromStr(pjUri);
//       return pjUri;
//     } catch (e) {
//       debugPrint(e.toString());
//       rethrow;
//     }
//   }

//   Future<(receive.WantsOutputs, send.V2PostContext)> handlePjRequest(
//       String psbtBase64,
//       String uriStr,
//       Future<bool> Function(Uint8List) isOwned) async {
//     final uri = await pj_uri.Uri.fromStr(uriStr);
//     final (req, cxt) = await (await (await send.SenderBuilder.fromPsbtAndUri(
//                 psbtBase64: psbtBase64, pjUri: uri.checkPjSupported()))
//             .buildWithAdditionalFee(
//                 maxFeeContribution: BigInt.from(10000),
//                 minFeeRate: BigInt.zero,
//                 clampFeeContribution: false))
//         .extractV1();
//     // TODO get unchecked proposal
//     final unchecked = await receive.UncheckedProposal.fromRequest(
//         body: req.body.toList(), query: (req.url.query())!, headers: headers);
//     final wantsOutputs = await checkProposal(unchecked, isOwned);
//     return (wantsOutputs, cxt);
//   }

//   Future<receive.WantsOutputs> checkProposal(
//       receive.UncheckedProposal uncheckedProposal,
//       Future<bool> Function(Uint8List) isOwned) async {
//     // in a payment processor where the sender could go offline, this is where you schedule to broadcast the original_tx
//     var _ = await uncheckedProposal.extractTxToScheduleBroadcast();
//     final maybeInputsOwned =
//         await uncheckedProposal.assumeInteractiveReceiver();
//     // Receive Check 2: receiver can't sign for proposal inputs
//     final maybeInputsSeen =
//         await maybeInputsOwned.checkInputsNotOwned(isOwned: isOwned);

//     // Receive Check 3: receiver can't fall for probing attacks
//     final outputsUnknown =
//         await maybeInputsSeen.checkNoInputsSeenBefore(isKnown: (e) async {
//       return false;
//     });

//     // Receive Check 4: identify receiver outputs
//     final wantsOutputs = await outputsUnknown.identifyReceiverOutputs(
//         isReceiverOutput: (e) async {
//       // TODO
//       return false;
//     });

//     return wantsOutputs;
//   }
// }
