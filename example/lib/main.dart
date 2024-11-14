// import 'dart:convert';

// import 'package:bdk_flutter/bdk_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:payjoin_flutter/bitcoin_ffi.dart';
// import 'package:payjoin_flutter/common.dart' as common;
// import 'package:payjoin_flutter/receive.dart';
// import 'package:payjoin_flutter/uri.dart' as pay_join_uri;
// import 'package:payjoin_flutter_example/bdk_client.dart';
// import 'package:payjoin_flutter_example/payjoin_library.dart';

// void main() async {
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//         debugShowCheckedModeBanner: false, home: PayJoin());
//   }
// }

// class PayJoin extends StatefulWidget {
//   const PayJoin({super.key});

//   @override
//   State<PayJoin> createState() => _PayJoinState();
// }

// class _PayJoinState extends State<PayJoin> {
//   static const primaryColor = 0xffC71585;
//   PayJoinLibrary payJoinLibrary = PayJoinLibrary();
//   final sender = BdkClient(
//       "wpkh(tprv8ZgxMBicQKsPdgsqhkRVYkBBULxG3HvyXtwhWKEgfH4bsU8bmaqhdbZvxq4Z7BLFtUrT58ynRDrBcfG3vNpNHsKTV5xCEgRoKaNNzcVW3HW/84'/1'/0'/0/*)#ln3hfgcf",
//       Network.signet);
//   final receiver = BdkClient(
//       "wpkh(tprv8ZgxMBicQKsPfKJjrApLfm2BhWhV1JpL3StS8UPagm91Y215JGZktQKTtvErD92RKxEDYD9Sfc9eGZVkuH94NgEHPhz7rpgzhiNm2UPs1G1/84'/1'/0'/0/*)#h8uywf09",
//       Network.signet);

//   String displayText = "";
//   String pjUri = "";
//   late PartiallySignedTransaction senderPsbt;
//   late PartiallySignedTransaction processedAndFinalizedPsbt;
//   @override
//   void initState() {
//     sender.restoreWallet();
//     receiver.restoreWallet();
//     setState(() {
//       displayText = "sender & receiver restored";
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(primaryColor),
//         elevation: 0,
//         centerTitle: false,
//         title: Text('PayJoin App',
//             style: GoogleFonts.ibmPlexMono(
//                 fontWeight: FontWeight.w900,
//                 fontSize: 18,
//                 color: Colors.white)), // Set this heigh
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               margin: const EdgeInsets.only(bottom: 50),
//               padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
//               color: const Color(primaryColor),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Response: ",
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.manrope(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700)),
//                   Expanded(
//                     child: SelectableText(
//                       displayText,
//                       maxLines: 3,
//                       textAlign: TextAlign.start,
//                       style: GoogleFonts.ibmPlexMono(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             TextButton(
//                 onPressed: () async {
//                   await sender.syncWallet();
//                   await receiver.syncWallet();
//                   setState(() {
//                     displayText = "sync complete";
//                   });
//                   debugPrint(
//                       "sender balance: ${(sender.getBalance()).toString()}");
//                 },
//                 child: Text(
//                   "Sync wallets",
//                   style: GoogleFonts.manrope(
//                       color: Colors.black,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800),
//                 )),
//             TextButton(
//                 onPressed: () async {
//                   final address = (receiver.getNewAddress()).address;
//                   final res = await payJoinLibrary.buildPjUri(
//                       0.0083285, address.toQrUri());
//                   setState(() {
//                     pjUri = res;
//                     displayText = res;
//                   });
//                 },
//                 child: Text(
//                   "Build Receiver pj Uri",
//                   style: GoogleFonts.manrope(
//                       color: Colors.black,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800),
//                 )),
//             TextButton(
//                 onPressed: () async {
//                   final balance = sender.getBalance();
//                   debugPrint("Sender Balance: ${balance.toString()}");
//                   final uri = await pay_join_uri.Uri.fromStr(pjUri);
//                   final address = uri.address();
//                   int amount = (((uri.amount()) ?? 0) * 100000000).toInt();
//                   final psbt = (await sender.createPsbt(address, amount, 2000));
//                   debugPrint(
//                     "\nOriginal sender psbt: ${psbt.toString()}",
//                   );
//                   setState(() {
//                     senderPsbt = psbt;
//                   });
//                 },
//                 child: Text(
//                   "Create Sender psbt using receiver pjUri",
//                   style: GoogleFonts.manrope(
//                       color: Colors.black,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800),
//                 )),
//             TextButton(
//                 onPressed: () async {
//                   final (wantsOutputs, contextV1) = await payJoinLibrary
//                       .handlePjRequest(senderPsbt.toString(), pjUri, (e) async {
//                     final script = ScriptBuf(bytes: e);

//                     return (receiver.getAddressInfo(script));
//                   });
//                   var wantsInputs = await wantsOutputs.commitOutputs();

//                   final unspent = receiver.listUnspent();
//                   // Select receiver payjoin inputs.
//                   List<InputPair> candidateInputs = [];
//                   for (var input in unspent) {
//                     final txout = common.TxOut(
//                       value: input.txout.value,
//                       scriptPubkey: input.txout.scriptPubkey.bytes,
//                     );
//                     final psbtin = common.PsbtInput(
//                         witnessUtxo: txout,
//                         redeemScript: null,
//                         witnessScript: null);
//                     final previousOutput = common.OutPoint(
//                         txid: input.outpoint.txid.toString(),
//                         vout: input.outpoint.vout);
//                     final txin = common.TxIn(
//                         previousOutput: previousOutput,
//                         scriptSig:
//                             await Script.newInstance(rawOutputScript: []),
//                         witness: [],
//                         sequence: 0);
//                     final ip = await InputPair.newInstance(txin, psbtin);
//                     candidateInputs.add(ip);
//                   }
//                   final selectedOutpoint = await wantsInputs
//                       .tryPreservingPrivacy(candidateInputs: candidateInputs);

//                   var wantedInputs = await wantsInputs
//                       .contributeInputs(replacementInputs: [selectedOutpoint]);
//                   final provisionalProposal = await wantedInputs.commitInputs();

//                   final payJoinProposal =
//                       await provisionalProposal.finalizeProposal(
//                           processPsbt: (e) async {
//                             debugPrint(
//                                 "\n Original receiver unsigned psbt: $e");
//                             return (await receiver.signPsbt(
//                                     await PartiallySignedTransaction.fromString(
//                                         e)))
//                                 .toString();
//                           },
//                           maxFeeRateSatPerVb: BigInt.from(10000));
//                   final receiverPsbt = await payJoinProposal.psbt();
//                   debugPrint("\n Original receiver psbt: $receiverPsbt");
//                   final receiverProcessedPsbt = await contextV1.processResponse(
//                       response: utf8.encode(receiverPsbt));
//                   final senderProcessedPsbt = (await sender.signPsbt(
//                       await PartiallySignedTransaction.fromString(
//                           receiverProcessedPsbt)));
//                   setState(() {
//                     processedAndFinalizedPsbt = senderProcessedPsbt;
//                   });
//                 },
//                 child: Text(
//                   "Process and finalize receiver Pj request",
//                   style: GoogleFonts.manrope(
//                       color: Colors.black,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800),
//                 )),
//             TextButton(
//                 onPressed: () async {
//                   final res =
//                       await sender.broadcastPsbt(processedAndFinalizedPsbt);
//                   debugPrint("Broadcast success: $res");
//                 },
//                 child: Text(
//                   "Broadcast processed psbt",
//                   style: GoogleFonts.manrope(
//                       color: Colors.black,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800),
//                 ))
//           ],
//         ),
//       ),
//     );
//   }
// }
