import 'dart:convert';

import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:payjoin_flutter/payjoin_flutter.dart' as common;
import 'package:payjoin_flutter/receive/v1.dart' as v1;
import 'package:payjoin_flutter/send.dart' as send;
import 'package:payjoin_flutter/uri.dart' as pay_join_uri;
import 'package:payjoin_flutter_example/bdk_client.dart';
import 'package:payjoin_flutter_example/btc_client.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('v1_to_v1', () {
    setUp(() async {});
    testWidgets('full_cycle', (WidgetTester tester) async {
      final btcClient = BtcClient("sender");
      await btcClient.loadWallet();
      final sender = BdkClient(
          "wpkh(tprv8ZgxMBicQKsPemPN83fE95XY5PRnDJZ6YcTHbFACvme5Rwi2RRoivdksZzrP3M61Vz13pva5LjaY1TA9JezqgzLoaNG5SXpCAcyY5w2ursV)",
          Network.regtest);
      final receiver = BdkClient(
          "wpkh(tprv8ZgxMBicQKsPdD2rdKcJCtGop4vqW3cmvikhzVy42iCev4E9JpeJgnHXdMKLnmAyXatvhXPi8KomgWMa316mwyirBiLXi3MMPhRV1ikfNTJ)",
          Network.regtest);
      await sender.restoreWallet();
      await receiver.restoreWallet();
      // Receiver creates the payjoin URI
      final pjReceiverAddress = receiver.getNewAddress().address;
      final pjSenderAddress = sender.getNewAddress().address;
      await btcClient.sendToAddress(pjSenderAddress.toString(), 1);
      await btcClient.sendToAddress(pjReceiverAddress.toString(), 1);
      await btcClient.generate(11, pjSenderAddress.toString());
      await receiver.syncWallet();
      await sender.syncWallet();
      // Sender create a funded PSBT (not broadcast) to address with amount given in the pjUri
      debugPrint("Sender Balance: ${sender.getBalance().toString()}");
      final uri = await pay_join_uri.Uri.fromStr(
          "${pjReceiverAddress.toQrUri()}?amount=${0.0083285}&pj=https://example.com");
      final address = uri.address();
      int amount = (((uri.amount()) ?? 0) * 100000000).toInt();

      final senderPsbt = (await sender.createPsbt(address, amount, 2000));
      final senderPsbtBase64 = senderPsbt.toString();
      debugPrint(
        "\nOriginal sender psbt: $senderPsbtBase64",
      );

      // Receiver part
      final (req, ctx) = await (await (await send.RequestBuilder.fromPsbtAndUri(
                  psbtBase64: senderPsbtBase64, pjUri: uri.checkPjSupported()))
              .buildWithAdditionalFee(
                  maxFeeContribution: BigInt.from(10000),
                  minFeeRate: BigInt.zero,
                  clampFeeContribution: false))
          .extractV1();
      final headers = common.Headers(map: {
        'content-type': 'text/plain',
        'content-length': req.body.length.toString(),
      });
      final uncheckedProposal = await v1.UncheckedProposal.fromRequest(
          body: req.body.toList(), query: (req.url.query())!, headers: headers);
      // in a payment processor where the sender could go offline, this is where you schedule to broadcast the original_tx
      var _ = await uncheckedProposal.extractTxToScheduleBroadcast();
      final inputsOwned = await uncheckedProposal.checkBroadcastSuitability(
          canBroadcast: (e) async {
        return true;
      });
      // Receive Check 2: receiver can't sign for proposal inputs
      final mixedInputScripts =
          await inputsOwned.checkInputsNotOwned(isOwned: (e) async {
        return receiver.getAddressInfo(ScriptBuf(bytes: e));
      });

      // Receive Check 3: receiver can't sign for proposal inputs
      final seenInputs = await mixedInputScripts.checkNoMixedInputScripts();
      // Receive Check 4: have we seen this input before? More of a check for non-interactive i.e. payment processor receivers.
      final provisionalProposal =
          await (await seenInputs.checkNoInputsSeenBefore(isKnown: (e) async {
        return false;
      }))
              .identifyReceiverOutputs(isReceiverOutput: (e) async {
        return receiver.getAddressInfo(ScriptBuf(bytes: e));
      });
      final unspent = receiver.listUnspent();
      // Select receiver payjoin inputs.
      Map<BigInt, common.OutPoint> candidateInputs = {
        for (var input in unspent)
          input.txout.value: common.OutPoint(
              txid: input.outpoint.txid.toString(), vout: input.outpoint.vout)
      };
      final selectedOutpoint = await provisionalProposal.tryPreservingPrivacy(
          candidateInputs: candidateInputs);
      var selectedUtxo = unspent.firstWhere(
          (i) =>
              i.outpoint.txid.toString() == selectedOutpoint.txid &&
              i.outpoint.vout == selectedOutpoint.vout,
          orElse: () => throw Exception('UTXO not found'));
      var txoToContribute = common.TxOut(
        value: selectedUtxo.txout.value,
        scriptPubkey: selectedUtxo.txout.scriptPubkey.bytes,
      );

      var outpointToContribute = common.OutPoint(
        txid: selectedUtxo.outpoint.txid.toString(),
        vout: selectedUtxo.outpoint.vout,
      );
      await provisionalProposal.contributeWitnessInput(
          txo: txoToContribute, outpoint: outpointToContribute);

      final payJoinProposal =
          await provisionalProposal.finalizeProposal(processPsbt: (e) async {
        debugPrint("\n Original receiver unsigned psbt: $e");
        return (await receiver
                .signPsbt(await PartiallySignedTransaction.fromString(e)))
            .toString();
      });
      final receiverPsbt = await payJoinProposal.psbt();
      debugPrint("\n Original receiver psbt: $receiverPsbt");
      final receiverProcessedPsbt =
          await ctx.processResponse(response: utf8.encode(receiverPsbt));
      final senderProcessedPsbt = (await sender.signPsbt(
          await PartiallySignedTransaction.fromString(receiverProcessedPsbt)));

      final txid = await sender.broadcastPsbt(senderProcessedPsbt);
      debugPrint("Broadcast success: $txid");
    });
  });
}
