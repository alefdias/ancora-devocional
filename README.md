# Âncora: Devocional

App Flutter de devocional diário com **duas trilhas**: evangélica e católica litúrgica.
Inclui áudio (TTS), anotações pessoais, sequência de dias (streak), plano premium e
onboarding com escolha de afiliação religiosa.

- **Pacote:** `com.ancora.devocional`
- **Versão:** 1.0.0+1
- **Flutter:** SDK `^3.7.0`

---

## ✨ Funcionalidades

| Área | Detalhes |
|---|---|
| Devocional do dia | Versículo, reflexão, oração e propósito/frase de impacto |
| Trilha evangélica | 366 devocionais com plano de leitura bíblica |
| Trilha católica | 366 devocionais litúrgicos: celebração, grau, tempo e cor litúrgica, leituras, Evangelho, santo do dia, propósito e **desafio semanal** (48 obras de misericórdia) |
| Áudio | TTS local; liberado por anúncio rewarded 1x/dia (ou premium) |
| Anotações | Editor por dia, histórico e persistência local |
| Streak | Contador de dias seguidos |
| Onboarding | Escolha entre Evangélico e Católico |
| Ajustes | Troca de trilha a qualquer momento |

A troca de trilha é imediata: o app carrega os dois assets e escolhe pelo
`religionProvider` (`evangelico` ou `catolico`).

---

## 🗂️ Estrutura

```
lib/
├── app/                 # Tema e widget raiz
├── data/
│   └── devotionals.dart # Biblioteca das duas trilhas (assets)
├── features/
│   ├── home/            # Devocional do dia (evangélico/católico)
│   ├── audio/           # Player TTS + rewarded
│   ├── notes/           # Editor e histórico
│   ├── onboarding/      # Escolha da trilha
│   ├── premium/         # Tela de assinatura (fictícia)
│   ├── settings/        # Perfil, trilha, privacidade
│   └── login/           # Firebase Auth / Google
├── services/            # AdMob e TTS
├── models.dart          # Devotional, Challenge, Note...
└── providers.dart       # Riverpod: religião, notas, streak, premium
assets/data/
├── devotionals.json            # 366 evangélicos
└── devotionals_catolico.json   # 366 católicos + desafios
```

---

## 🚀 Rodar

```bash
flutter pub get
flutter run                 # dispositivo/emulador conectado
flutter build apk --debug   # APK de teste
flutter build appbundle     # Play Store (release)
```

### Build automático no GitHub

Todo push na branch `main` dispara o workflow **Build Android (APK + AAB)**
(`.github/workflows/build_apk.yml`), que:

1. compila `app-release.apk`;
2. compila `app-release.aab`;
3. publica os dois arquivos como artifacts do Actions;
4. atualiza a release **`latest`** em <https://github.com/alefdias/ancora-devocional/releases/latest>.

Também pode ser disparado manualmente em **Actions → Build Android (APK + AAB) → Run workflow**.

> O build usa a keystore de **debug** (arquivo `android/app/debug.keystore`). Serve para testes;
> para publicar na Play Store é preciso configurar uma keystore de release.

### Testes e análise

```bash
flutter analyze
flutter test
```

Cobertura atual: carregamento dos 366 dias das duas trilhas, campos litúrgicos,
desafios semanais, seleção por data (incluindo 29/02) e renderização da home católica
sem overflow.

---

## 🔄 Atualizar o conteúdo católico

O asset católico é gerado a partir do livro consolidado:

```bash
# na pasta "../devocional livro catolico"
python3 exportar_app_catolico.py
```

Isso grava `assets/data/devotionals_catolico.json` já limpo de LaTeX.
O asset evangélico é gerado por `../devocional Livro/exportar_app.py`.

---

## ⚠️ Pendências para publicação

1. **AdMob:** `lib/services/ad_service.dart` usa IDs de **teste**. Trocar pelos IDs reais.
2. **iOS:** falta `ios/Runner/GoogleService-Info.plist` (só o Android tem configuração Firebase).
3. **Premium:** a assinatura é simulada localmente (`premiumProvider`); integrar compras (Play Billing/App Store).
4. **Firebase:** revisar regras, provedores de login e remover o acesso de teste do desktop.
5. **Assinatura do app:** configurar keystore de release.
6. **README/loja:** textos, ícone, screenshots e política de privacidade definitivos.
