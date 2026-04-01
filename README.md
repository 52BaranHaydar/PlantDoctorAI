# 🌿 PlantDoctorAI

> CoreML + SwiftUI ile yapay zeka destekli bitki hastalığı teşhis uygulaması

![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![iOS](https://img.shields.io/badge/iOS-16%2B-blue?logo=apple)
![CoreML](https://img.shields.io/badge/CoreML-Vision-green?logo=apple)

---

## 📱 Uygulama Hakkında

**PlantDoctorAI**, bitkinin fotoğrafını çekmen yeterli — yapay zeka saniyeler içinde hastalığı tespit edip tedavi önerisi sunar. İnternet bağlantısı gerekmez, tüm analiz cihazın üzerinde çalışır.

---

## ✨ Özellikler

| Özellik | Açıklama |
|---|---|
| 📷 Kamera ve Galeri | Canlı kamera veya galeriden fotoğraf seçimi |
| 🤖 CoreML Teşhis | Cihaz üzerinde çalışan ML, internet gerekmez |
| 🌿 Hastalık Veritabanı | Domates, patates, elma hastalıkları |
| 💊 Tedavi Önerileri | Her hastalık için somut müdahale adımları |
| 📊 Güven Skoru | Teşhis güvenilirliğini görsel olarak gösterir |
| 🌙 Dark Mode | iOS tema değişimine tam uyumlu |

---

## 🏗 Mimari — MVVM
```
PlantDoctorAI/
├── Models/
│   └── PlantDisease.swift          # Veri yapıları, hastalık veritabanı
├── ViewModels/
│   └── DiagnosisViewModel.swift    # İş mantığı, @Published state
├── Views/
│   ├── ContentView.swift           # Ana ekran
│   └── CameraAndPickerViews.swift  # UIKit bridge
└── Services/
    └── PlantDiagnosisService.swift # CoreML/Vision entegrasyonu
```

### Veri Akışı
```
Kullanıcı → View → ViewModel → Service → CoreML
                                              ↓
Kullanıcı ← View ← ViewModel ← DiagnosisResult
```

---

## 🚀 Kurulum
```bash
git clone https://github.com/52BaranHaydar/PlantDoctorAI.git
cd PlantDoctorAI
open PlantDoctorAI.xcodeproj
```

Xcode açılınca **Cmd + R** ile çalıştır.

### Gereksinimler

- Xcode 15+
- iOS 16+
- Swift 5.9+

---

## 🌿 Desteklenen Hastalıklar

| Bitki | Hastalık | Ciddiyet |
|---|---|---|
| Domates | Geç Yanıklık | 🔴 Ağır |
| Domates | Sağlıklı | 🟢 İyi |
| Patates | Geç Yanıklık | 🔴 Kritik |
| Elma | Karaleke | 🟠 Ciddi |

---

## 🔀 Git Branch Stratejisi
```
main              ← kararlı dal, korumalı
└── feature/xyz   ← her özellik ayrı branch
    PR açılır → review → merge
```

### Commit Kuralları
```
feat:      Yeni özellik
fix:       Hata düzeltmesi
refactor:  Kod iyileştirmesi
docs:      Dokümantasyon
test:      Test ekleme
```

---

## 🤖 CoreML Modeli

Demo modunda simüle edilmiş sonuçlar döner.
Gerçek model eklemek için:

1. `.mlmodel` dosyasını `Resources/` klasörüne sürükle
2. Xcode'da "Add to target" seç
3. `PlantDiagnosisService.swift` içindeki TODO satırını güncelle

---

## 👨‍💻 Geliştirici

**Baran Haydar** — [@52BaranHaydar](https://github.com/52BaranHaydar)

---

## 📄 Lisans

MIT License

---

*🌿 Tarım teknolojisi, yapay zeka ile daha erişilebilir olabilir.*
