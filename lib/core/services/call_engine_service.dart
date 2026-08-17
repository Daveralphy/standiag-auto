// Thin wrapper around the Agora RTC engine for StanDiag Auto's in-app voice
// calls. One instance belongs to one call screen and is disposed when that
// screen closes — Agora only supports one RtcEngine per App ID running at a
// time, so this is deliberately not a shared/singleton provider.

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/agora_config.dart';

class CallEngineService {
  RtcEngine? _engine;

  /// Requests the microphone permission, initializes the engine, and joins
  /// [channelId] — the job's own id, so both parties land in the same room
  /// without needing any separate room-code exchange.
  ///
  /// [onRemoteJoined] fires once the other party actually connects.
  /// [onRemoteLeft] fires when they leave the channel — the most reliable
  /// signal a call screen has for "the other side hung up," since it comes
  /// straight from the live connection rather than a value either side has
  /// to remember to write somewhere first.
  Future<void> join({
    required String channelId,
    required void Function() onRemoteJoined,
    required void Function() onRemoteLeft,
  }) async {
    if (!AgoraConfig.isConfigured) {
      throw StateError('agora-not-configured');
    }
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw StateError('microphone-permission-denied');
    }

    final engine = createAgoraRtcEngine();
    _engine = engine;
    await engine.initialize(RtcEngineContext(appId: AgoraConfig.appId));
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (connection, remoteUid, elapsed) => onRemoteJoined(),
        onUserOffline: (connection, remoteUid, reason) => onRemoteLeft(),
      ),
    );
    await engine.enableAudio();
    await engine.joinChannel(
      // Empty token: only valid while the Agora project's App Certificate
      // is disabled (testing mode). See AgoraConfig.
      token: '',
      channelId: channelId,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
      ),
    );
  }

  Future<void> setMuted(bool muted) async {
    await _engine?.muteLocalAudioStream(muted);
  }

  Future<void> setSpeakerphoneOn(bool enabled) async {
    await _engine?.setEnableSpeakerphone(enabled);
  }

  /// Leaves the channel and releases the engine. Safe to call more than
  /// once (e.g. once from an explicit "end call" tap and again from
  /// dispose()) — a second call is a no-op.
  Future<void> leave() async {
    final engine = _engine;
    _engine = null;
    if (engine == null) return;
    await engine.leaveChannel();
    await engine.release();
  }
}
