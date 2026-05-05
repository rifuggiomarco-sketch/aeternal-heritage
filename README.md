# Aeterna Protocol — Flutter App

Eredità Digitale Dinamica. Vault cifrato AES-256 + Dead Man's Switch + Moral Compass AI.

---

## COME OTTENERE L'APK IN 3 METODI

---

### METODO 1 — GitHub Actions (consigliato, nessuna installazione)

1. Crea un account GitHub su https://github.com
2. Crea un nuovo repository (New → Repository)
3. Carica questa cartella nel repository:
   ```
   git init
   git add .
   git commit -m "first commit"
   git remote add origin https://github.com/TUO-USERNAME/aeterna-protocol.git
   git push -u origin main
   ```
4. Vai su GitHub → tab **Actions**
5. Trovi il workflow **"Build Aeterna Protocol APK"** già in esecuzione
6. Attendi ~10 minuti → clicca sul job → **Artifacts** → scarica `aeterna-protocol-release-apk.zip`
7. Estrai lo zip → trovi `app-release.apk` pronto da installare

Per le versioni future, crea un tag:
```
git tag v1.0.1 && git push origin v1.0.1
```
GitHub creerà una Release con l'APK allegato automaticamente.

---

### METODO 2 — Compilazione locale (se hai Flutter installato)

**Requisiti:**
- Flutter SDK 3.24+ → https://docs.flutter.dev/get-started/install
- Android Studio + Android SDK (API 23+)
- Java 17

**Comandi:**
```bash
# Installa dipendenze
flutter pub get

# Verifica ambiente
flutter doctor

# Build APK debug (per test rapido)
flutter build apk --debug

# Build APK release (per distribuzione)
flutter build apk --release

# L'APK si trova in:
# build/app/outputs/flutter-apk/app-release.apk
```

**Installa su dispositivo Android connesso:**
```bash
flutter install
```

---

### METODO 3 — Build su Codemagic (CI/CD cloud gratuito)

1. Vai su https://codemagic.io → Sign up con GitHub
2. Connetti il repository
3. Seleziona **Flutter App** come tipo di progetto
4. Clicca **Start first build**
5. L'APK viene scaricabile al termine

---

## STRUTTURA DEL PROGETTO

```
lib/
├── main.dart                      ← Entry point + Firebase init
├── core/
│   ├── theme/app_theme.dart       ← Palette Deep Navy + Gold
│   ├── router/app_router.dart     ← GoRouter navigazione
│   └── encryption/
│       └── encryption_service.dart ← AES-256-GCM Zero-Knowledge
├── features/
│   ├── auth/auth_screen.dart      ← Login + biometria
│   ├── home/home_screen.dart      ← Dashboard principale
│   ├── vault/
│   │   ├── vault_screen.dart      ← Lista documenti cifrati
│   │   └── vault_provider.dart    ← State management (Riverpod)
│   ├── switch/
│   │   ├── switch_screen.dart     ← Configura Dead Man's Switch
│   │   └── switch_provider.dart   ← Timer e check-in logic
│   ├── heirs/
│   │   ├── heirs_screen.dart      ← Gestione eredi
│   │   └── heirs_provider.dart    ← State management eredi
│   └── settings/
│       └── settings_screen.dart   ← Impostazioni + IAP
└── shared/
    └── models/
        ├── vault_doc.dart         ← Modello documento cifrato
        └── heir.dart              ← Modello erede
```

---

## CONFIGURAZIONE FIREBASE (per notifiche push)

1. Vai su https://console.firebase.google.com
2. Crea progetto → Aggiungi app Android
3. Package name: `com.aeterna.protocol`
4. Scarica `google-services.json`
5. Posizionalo in: `android/app/google-services.json`

Senza Firebase, l'app funziona in modalità offline (vault + switch locale).

---

## SCHERMATE

| Schermata        | File                              | Funzione                          |
|------------------|-----------------------------------|-----------------------------------|
| Auth             | `features/auth/auth_screen.dart`  | Login, biometria, setup password  |
| Home             | `features/home/home_screen.dart`  | Dashboard, switch status, azioni  |
| Vault            | `features/vault/vault_screen.dart`| Upload/gestione documenti cifrati |
| Dead Man's Switch| `features/switch/switch_screen.dart`| Configura timer e check-in      |
| Eredi            | `features/heirs/heirs_screen.dart`| Aggiungi/rimuovi eredi            |
| Impostazioni     | `features/settings/settings_screen.dart`| Piano, backup, sicurezza   |

---

## IN-APP PURCHASE — SKU da configurare

| SKU                           | Prezzo  | Sblocca                                    |
|-------------------------------|---------|---------------------------------------------|
| `aeterna_gold_monthly`        | €29,90  | Vault 100GB, eredi illimitati, notarile     |
| `aeterna_gold_annual`         | €249,00 | Come mensile, sconto 30%                    |
| `aeterna_legacy_monthly`      | €99,90  | Tutto Gold + consulente + API B2B           |
| `aeterna_legacy_annual`       | €899,00 | Come mensile, sconto 25%                    |

Implementa con il package `in_app_purchase: ^3.2.0` e RevenueCat SDK.

---

## ASO (App Store Optimization)

**Nome app:** Aeterna Protocol  
**Sottotitolo:** Il tuo vault digitale dopo.  
**Categoria:** Produttività / Lifestyle  

**Keyword principali:**
digital legacy, vault cifrato, eredità digitale, testamento digitale,
password eredi, documenti famiglia, lascito digitale, custodia documenti,
privacy documenti, sicurezza eredità

**Descrizione breve (Google Play):**
Proteggi i tuoi dati più sensibili. Lasciali alle persone giuste. Sempre.

---

## PALETTE COLORI

| Variabile         | Hex       | Uso                          |
|-------------------|-----------|------------------------------|
| Navy              | `#0A1628` | Background principale        |
| Navy Light        | `#1A2B44` | Card, bottom sheet           |
| Navy Deep         | `#060E1A` | Code blocks, overlay         |
| Gold              | `#C9A458` | Accent, CTA, highlight       |
| Gold Light        | `#E8C57A` | Hover, selezioni             |
| Off White         | `#FAFAF8` | Testo principale             |
| Muted             | `#4A5568` | Testo secondario             |
| Label             | `#A0AEC0` | Label, mono, caption         |
| Border            | `#2D3748` | Bordi card                   |
| Success           | `#48BB78` | Switch attivo, verificato    |
| Warning           | `#ED8936` | Avvisi scadenza              |
| Danger            | `#FC8181` | Errori, eliminazione         |

---

## PROMPT AI PER ASSETS STORE

### Icona app (1024x1024):
```
Minimalist app icon for a premium digital legacy vault app.
Deep navy blue background #0A1628. A geometric gold lock symbol
#C9A458 with subtle infinity/eternity motif. Clean, authoritative,
luxury fintech aesthetic. No text. No gradients. Sharp edges.
Square format, rounded corners treatment.
```

### Splash Screen:
```
Full-screen splash for iOS/Android. Deep navy #0A1628 background.
Centered gold geometric logo mark. Below: "Aeterna Protocol" in
Inter Black white. Below: "Eredità Digitale" in DM Mono gold,
small caps. Elegant, minimal, luxury feel. 9:19.5 ratio.
```

### Screenshot 1 — Dashboard:
```
iPhone 15 Pro mockup, dark app UI. Dashboard screen showing
"Dead Man's Switch: Attivo — 28 giorni". Deep navy background,
gold accents. Three quick action buttons below. Premium fintech
look. Italian language UI.
```

### Screenshot 2 — Vault:
```
iPhone 15 Pro mockup showing encrypted document vault UI.
List of locked files with gold lock icons. "Cifrato AES-256"
label visible. Dark navy theme. FAB button in gold "Carica".
```

### Screenshot 3 — Heirs:
```
iPhone 15 Pro mockup showing heirs management screen.
Three heir cards with avatar initials, relationship tags.
"Verified" badge in green. Dark navy background, elegant
typography. "Eredi Designati" header.
```
