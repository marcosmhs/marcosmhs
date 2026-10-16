import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

enum SitePublishState { idle, waiting, publishing, done, error }

/// Regera o HTML estático do site público chamando a Cloud Function `publishSite`.
///
/// Os formulários chamam [requestPublish] depois de salvar; vários salvamentos seguidos
/// viram uma única publicação (espera [_debounce] sem novas alterações).
class SitePublisher extends ChangeNotifier {
  SitePublisher._();
  static final SitePublisher instance = SitePublisher._();

  static const _debounce = Duration(seconds: 3);

  Timer? _timer;
  bool _pendingAfterCurrent = false;

  SitePublishState state = SitePublishState.idle;
  DateTime? lastPublishedAt;
  String lastError = '';

  bool get busy => state == SitePublishState.waiting || state == SitePublishState.publishing;

  void requestPublish() {
    _timer?.cancel();
    if (state == SitePublishState.publishing) {
      _pendingAfterCurrent = true;
      return;
    }
    _setState(SitePublishState.waiting);
    _timer = Timer(_debounce, publishNow);
  }

  Future<void> publishNow() async {
    _timer?.cancel();
    if (state == SitePublishState.publishing) {
      _pendingAfterCurrent = true;
      return;
    }
    _setState(SitePublishState.publishing);
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1').httpsCallable(
        'publishSite',
        options: HttpsCallableOptions(timeout: const Duration(minutes: 2)),
      );
      await callable.call();
      lastPublishedAt = DateTime.now();
      lastError = '';
      _setState(SitePublishState.done);
    } on FirebaseFunctionsException catch (e) {
      lastError = e.message ?? e.code;
      _setState(SitePublishState.error);
    } catch (e) {
      lastError = e.toString();
      _setState(SitePublishState.error);
    }

    if (_pendingAfterCurrent) {
      _pendingAfterCurrent = false;
      requestPublish();
    }
  }

  String get statusText {
    switch (state) {
      case SitePublishState.idle:
        return 'Site publicado';
      case SitePublishState.waiting:
        return 'Alterações pendentes...';
      case SitePublishState.publishing:
        return 'Publicando o site...';
      case SitePublishState.done:
        final t = lastPublishedAt;
        return t == null
            ? 'Site publicado'
            : 'Publicado às ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      case SitePublishState.error:
        return 'Falha ao publicar: $lastError';
    }
  }

  void _setState(SitePublishState value) {
    state = value;
    notifyListeners();
  }
}
