# ⏳ CHRONOS • Titan of Time — iOS Pomodoro Uygulaması

![Platform](https://img.shields.io/badge/Platform-iOS%2017.0%2B-D4AF37?style=flat-square&logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9%20%7C%206.0-F05138?style=flat-square&logo=swift)
![Framework](https://img.shields.io/badge/UI-SwiftUI-0A84FF?style=flat-square)
![Audio](https://img.shields.io/badge/Audio-AVAudioEngine-10B981?style=flat-square)

**CHRONOS • Titan of Time**, **Hades II — Chronos (Zamanın Titanı)** estetiğinden ilham alınarak **Swift** ve **SwiftUI** ile sıfırdan geliştirilmiş yerel (native) bir iOS Pomodoro ve odaklanma uygulamasıdır. Antik altın çarklar, gerçek zamanlı kum saati fiziği, prosedürel ses sentezleyici (`AVAudioEngine`) ve obsidyen-altın arayüz detaylarıyla zaman yönetimini atmosferik bir deneyime dönüştürür.

---

## ✨ Öne Çıkan Özellikler

### ⚙️ Dönen Zaman Çarkları & Usturlap Kadranı (`TimerRingView`)
- **Çift Yönlü Mekanik Çarklar**: Saat yönünde dönen 36 dişli dış bronz/altın çark ve ters yönde dönen 24 dişli iç usturlap halkası.
- **Romen Rakamlı Dişli Rozetleri**: Kadran etrafında 12 adet mini dişli rozet (`XII, I, II ... XI`) ve 60 dakikalık altın kadran çentikleri.
- **Chronos Tırpan İbresi**: Merkezdeki obsidyen sunak etrafında geçen süreyi takip eden altın ibre ve parlak ilerleme yayı.
- **Duyarlı (Responsive) Ölçeklendirme**: Tüm iPhone ekran boyutlarına otomatik uyum sağlayan dinamik kadran çapı.

### ⏳ Antik Altın Kum Saati & Atmosfer (`PomodoroLogoAndBubblesView`)
- **Gerçek Zamanlı Kum Akışı (`ChronosHourglassView`)**: Üst hazneden alt hazneye kalan süreyle orantılı akan kum animasyonu ve ışıltı parçacıkları.
- **Yüzen Altın Tozları (`AmbientBubblesBackgroundView`)**: Arka planda süzülen altın kum taneleri, rün halkaları ve derin Tartarus parıltıları.
- **Sinematik Açılış Ekranı (`ChronosSplashScreenView`)**: Dönen rün çemberleri ve ışıldayan Chronos mührü ile uygulama açılışı.

### 🎵 Prosedürel Ses Sentezleyici & Ortam Sesleri (`ChronosSoundEngine`)
Harici ses dosyalarına ihtiyaç duymadan `AVAudioEngine` üzerinde gerçek zamanlı üretilen sesler:
- **Ortam Sesleri (Ambient)**:
  - *Zaman Çarkları*: Mekanik saat tıkırtısı ve rezonans tınısı
  - *Yağmur*: Yumuşak filtrelenmiş yağmur dokusu
  - *Akarsu*: Dinlendirici su akışı modülasyonu
  - *Kafe*: Sıcak arka plan uğultusu
- **Bitiş Çanları**: *Titan Çanı (Chronos Zili)*, *Zen Çanı (Gong)*, *Tibet Kasesi*, *Dijital Çan*, *Akustik Marimba*.

### 📜 Zamanın Görevleri (`TasksSheetView`)
- **Görev Yönetimi**: Yeni görev oluşturma, tahmini kum saati (`⏳ 1–10`) hedefi belirleme ve tamamlanan görevleri mühürleme.
- **Filtreleme**: *Tümü*, *Aktif* ve *Tamamlanan* görev görünümleri.
- **Aktif Odak Bağlantısı**: Seçilen görevi ana ekrandaki zaman çarkına bağlama ve her odak seansı sonunda otomatik ilerleme kaydetme.

### 📊 Zamanın Kayıtları — İstatistikler (`StatsSheetView`)
- **4 Ana Metrik Kartı**: *Toplam Süre*, *Tamamlanan Seanslar*, *Günlük Seri (🔥)* ve *Bugünkü Seanslar*.
- **Son 7 Günlük Zaman Akışı**: Haftalık odaklanma performansını gösteren altın sütun grafiği.
- **Mühürlenen Seanslar**: Tamamlanan son çalışmaların görev adı, tarih ve süre geçmişi.

### 🎨 Görünüm, Temalar & Otomasyon (`SettingsSheetView`)
- **Özelleştirilebilir Süreler**: Odaklanma (`1–120 dk`), Kısa Mola (`1–60 dk`), Uzun Mola (`1–90 dk`) ve Uzun Mola Döngü Sıklığı (`2–12 döngü`).
- **Otomatik Geçişler**: Odaklanma bitince molayı veya mola bitince yeni odak seansını otomatik başlatma.
- **6 Farklı Tema**:
  - `CHRONOS • Zamanın Titanı` *(Önerilen)*
  - `Obsidyen (Karanlık)`
  - `Kızıl Akşam`
  - `Zümrüt Doğa`
  - `Zen Kağıt`
  - `Sistem`

---

## 🗂️ Proje Mimarisi

Proje, temiz ve modüler **MVVM (Model-View-ViewModel)** mimarisiyle yapılandırılmıştır:

```text
ChronosPomodoro/
├── Pomodoro.xcodeproj
└── Pomodoro/
    ├── App/
    │   └── PomodoroApp.swift                 # Uygulama giriş noktası
    ├── Models/
    │   └── PomodoroModels.swift              # Fazlar, görev/seans modelleri, ayarlar ve Chronos renk paleti
    ├── ViewModels/
    │   └── PomodoroViewModel.swift           # Zamanlayıcı döngüsü, kalıcı veri (UserDefaults) ve ses motoru
    ├── Views/
    │   ├── ContentView.swift                 # Ana ekran, üst/alt barlar, kontrol düğmeleri ve açılış ekranı
    │   ├── TimerRingView.swift               # Dönen çarklar, Romen rakamları ve geri sayım kadranı
    │   ├── PomodoroLogoAndBubblesView.swift  # Antik kum saati ve arka plan altın parçacık efektleri
    │   └── SheetsAndSubviews.swift           # Görevler, İstatistikler ve Ayarlar pencereleri
    └── Resources/
        └── Assets.xcassets                   # Uygulama ikonu ve görsel varlıklar
```

---

## 🚀 Kurulum ve Çalıştırma

1. Depoyu bilgisayarınıza klonlayın:
   ```bash
   git clone https://github.com/AidenVanya/Ios-chronos-Pomodoro.git
   cd Ios-chronos-Pomodoro
   ```
2. Projeyi **Xcode** ile açın:
   ```bash
   open Pomodoro.xcodeproj
   ```
3. Üst araç çubuğundan bir iOS Simülatörü (örn. *iPhone 16 Pro*) veya fiziksel cihazınızı seçin.
4. `Cmd + R` kısayoluyla uygulamayı derleyip çalıştırın.

---

## 🛠️ Gereksinimler

- **Xcode**: 15.0 veya üzeri
- **iOS**: 17.0 veya üzeri
- **Dil**: Swift 5.9 / Swift 6 uyumlu eşzamanlılık (`@MainActor` & arka plan ses kuyruğu)

---

<p align="center">
  <i>"Zaman akıp gider; onu yalnızca irade sahibi olanlar mühürleyebilir." — Chronos</i>
</p>
