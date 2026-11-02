import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Serviço de anúncios (Google AdMob).
///
/// Usa IDs de TESTE do Google por enquanto. Para produção, trocar os IDs
/// abaixo pelos IDs reais criados no AdMob do app "Âncora: Devocional".
///
/// Nos ambientes sem suporte (Linux/desktop), o SDK não existe; nesse caso o
/// serviço entrega o "prêmio" imediatamente para o app continuar funcionando.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;

  // IDs de TESTE oficiais do Google (substituir por produção depois).
  static const String _rewardedTestId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _interstitialTestId = 'ca-app-pub-3940256099942544/1033173712';

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      loadRewardedAd();
      loadInterstitialAd();
    } catch (e) {
      debugPrint('AdService: indisponível nesta plataforma ($e)');
      _initialized = false;
    }
  }

  // -------------------------------------------------------------------------
  // REWARDED (áudio do devocional)
  // -------------------------------------------------------------------------

  void loadRewardedAd() {
    if (!_initialized) return;
    try {
      RewardedAd.load(
        adUnitId: _rewardedTestId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) => _rewardedAd = ad,
          onAdFailedToLoad: (error) {
            debugPrint('Rewarded falhou: ${error.message}');
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('Rewarded load erro: $e');
    }
  }

  /// Exibe o anúncio rewarded. Se não houver anúncio disponível (ou a
  /// plataforma não suportar), chama [onReward] imediatamente.
  Future<void> showRewarded({required VoidCallback onReward}) async {
    final ad = _rewardedAd;
    if (!_initialized || ad == null) {
      onReward();
      loadRewardedAd();
      return;
    }
    _rewardedAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        onReward();
        loadRewardedAd();
      },
    );
    try {
      await ad.show(
        onUserEarnedReward: (ad, reward) => onReward(),
      );
    } catch (e) {
      debugPrint('Rewarded show erro: $e');
      onReward();
      loadRewardedAd();
    }
  }

  // -------------------------------------------------------------------------
  // INTERSTITIAL (1º salvamento de anotação do dia)
  // -------------------------------------------------------------------------

  void loadInterstitialAd() {
    if (!_initialized) return;
    try {
      InterstitialAd.load(
        adUnitId: _interstitialTestId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => _interstitialAd = ad,
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial falhou: ${error.message}');
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('Interstitial load erro: $e');
    }
  }

  Future<void> showInterstitial() async {
    final ad = _interstitialAd;
    if (!_initialized || ad == null) {
      loadInterstitialAd();
      return;
    }
    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitialAd();
      },
    );
    try {
      await ad.show();
    } catch (e) {
      debugPrint('Interstitial show erro: $e');
      loadInterstitialAd();
    }
  }
}
