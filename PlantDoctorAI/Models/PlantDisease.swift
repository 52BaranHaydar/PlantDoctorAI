//
//  PlantDisease.swift
//  PlantDoctorAI
//
//  Created by Baran on 31.03.2026.
//
// PlantDisease.swift
// PlantDoctorAI
//
// Temel veri modelleri ve hastalık veritabanı.
// Model sınıf adları Create ML'in ürettiği
// label isimlerle birebir eşleşiyor.

import SwiftUI

// MARK: - PlantDisease Modeli
struct PlantDisease: Identifiable, Codable {

    let id: UUID
    let className: String
    let displayName: String
    let description: String
    let treatments: [String]
    let severityLevel: Int
    var confidence: Double

    // 0.876 → "%87.6"
    var confidencePercentage: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: confidence)) ?? "%0"
    }

    // Ciddiyet seviyesine göre renk
    var severityColor: Color {
        switch severityLevel {
        case 1:    return .green
        case 2:    return .yellow
        case 3:    return .orange
        case 4, 5: return .red
        default:   return .gray
        }
    }

    // Ciddiyet metni
    var severityText: String {
        switch severityLevel {
        case 1: return "Hafif"
        case 2: return "Orta"
        case 3: return "Ciddi"
        case 4: return "Ağır"
        case 5: return "Kritik"
        default: return "Bilinmiyor"
        }
    }

    init(
        id: UUID = UUID(),
        className: String,
        displayName: String,
        description: String,
        treatments: [String],
        severityLevel: Int,
        confidence: Double = 0.0
    ) {
        self.id = id
        self.className = className
        self.displayName = displayName
        self.description = description
        self.treatments = treatments
        self.severityLevel = severityLevel
        self.confidence = confidence
    }
}

// MARK: - DiagnosisResult
struct DiagnosisResult: Identifiable {
    let id: UUID = UUID()
    let image: UIImage
    let topDisease: PlantDisease
    let topPredictions: [PlantDisease]
    let diagnosedAt: Date
    let isReliable: Bool

    var reliabilityMessage: String {
        isReliable
            ? "Yüksek güvenilirlik"
            : "Düşük güvenilirlik — uzman görüşü alın"
    }
}

// MARK: - PlantDiseaseDatabase
// ⚠️ className değerleri Create ML'in ürettiği
// label isimleriyle BIREBIR eşleşmeli!
enum PlantDiseaseDatabase {

    static let diseases: [String: PlantDisease] = [

        // --- DOMATES ---
        "Tomato_Late_blight": PlantDisease(
            className: "Tomato_Late_blight",
            displayName: "Domates — Geç Yanıklık",
            description: "Phytophthora infestans mantarı neden olur. Yapraklarda kahverengi-siyah lekeler görülür. Çok hızlı yayılır.",
            treatments: [
                "Hasta yaprakları hemen kopar ve uzaklaştır",
                "Bakır bazlı fungisit uygula (haftalık)",
                "Sabah sulaması yap — yaprakları ıslak bırakma"
            ],
            severityLevel: 4
        ),

        "Tomato_Early_blight": PlantDisease(
            className: "Tomato_Early_blight",
            displayName: "Domates — Erken Yanıklık",
            description: "Alternaria solani mantarı. Alt yapraklardan başlar, halkalı koyu lekeler oluşur.",
            treatments: [
                "Etkilenen yaprakları temizle",
                "Fungisit spreyi uygula",
                "Mulch kullanarak toprak sıçramasını engelle"
            ],
            severityLevel: 3
        ),

        "Tomato_healthy": PlantDisease(
            className: "Tomato_healthy",
            displayName: "Domates — Sağlıklı",
            description: "Bitkide hastalık belirtisi tespit edilmedi. Yapraklar normal renk ve dokusunda.",
            treatments: [
                "Düzenli sulama ve gübrelemeye devam et",
                "Haftalık kontrol alışkanlığı edin"
            ],
            severityLevel: 1
        ),

        "Tomato_Leaf_Mold": PlantDisease(
            className: "Tomato_Leaf_Mold",
            displayName: "Domates — Yaprak Küfü",
            description: "Passalora fulva mantarı, nemli ortamlarda gelişir. Yaprak altında sarı-yeşil küf oluşur.",
            treatments: [
                "Serada nem oranını düşür (%85 altı)",
                "Hava sirkülasyonunu artır",
                "Biyofungisit uygula"
            ],
            severityLevel: 2
        ),

        "Tomato_Bacterial_spot": PlantDisease(
            className: "Tomato_Bacterial_spot",
            displayName: "Domates — Bakteriyel Leke",
            description: "Xanthomonas bakterisi neden olur. Yaprak ve meyvelerde küçük koyu lekeler oluşur.",
            treatments: [
                "Bakır bazlı bakterisit uygula",
                "Hasta bitkileri uzaklaştır",
                "Sulama suyunu yapraklara değdirme"
            ],
            severityLevel: 3
        ),

        "Tomato__Target_Spot": PlantDisease(
            className: "Tomato__Target_Spot",
            displayName: "Domates — Hedef Leke",
            description: "Corynespora cassiicola mantarı. Yapraklarda halka halka lekeler oluşur.",
            treatments: [
                "Fungisit uygula",
                "Hasta yaprakları temizle",
                "Bitki sıklığını azalt"
            ],
            severityLevel: 3
        ),

        "Tomato__Tomato_mosaic_virus": PlantDisease(
            className: "Tomato__Tomato_mosaic_virus",
            displayName: "Domates — Mozaik Virüsü",
            description: "Yapraklarda mozaik desenli sararmalar oluşur. Virüs temas ve böcekle yayılır.",
            treatments: [
                "Hasta bitkileri hemen söküp yak",
                "Yaprak bitleriyle mücadele et",
                "Dayanıklı çeşit kullan"
            ],
            severityLevel: 4
        ),

        "Tomato__Tomato_YellowLeaf__Curl_Virus": PlantDisease(
            className: "Tomato__Tomato_YellowLeaf__Curl_Virus",
            displayName: "Domates — Sarı Yaprak Kıvırcıklık Virüsü",
            description: "Beyaz sinek tarafından taşınan virüs. Yapraklar sararır ve kıvrılır.",
            treatments: [
                "Beyaz sinekle mücadele et (sarı yapışkan tuzak)",
                "Hasta bitkileri söküp yak",
                "Dayanıklı çeşit tercih et"
            ],
            severityLevel: 5
        ),

        "Tomato_Septoria_leaf_spot": PlantDisease(
            className: "Tomato_Septoria_leaf_spot",
            displayName: "Domates — Septoria Yaprak Lekesi",
            description: "Septoria lycopersici mantarı. Alt yapraklarda küçük koyu lekeler oluşur.",
            treatments: [
                "Alt yaprakları temizle",
                "Fungisit uygula",
                "Bitkileri ıslak bırakma"
            ],
            severityLevel: 3
        ),

        "Tomato_Spider_mites_Two_spotted_spider_mite": PlantDisease(
            className: "Tomato_Spider_mites_Two_spotted_spider_mite",
            displayName: "Domates — Kırmızı Örümcek",
            description: "Tetranychus urticae akarı. Yapraklarda sararmalar ve ince ağlar oluşur.",
            treatments: [
                "Akarisit uygula",
                "Yaprakları suyla yıka",
                "Nem oranını artır"
            ],
            severityLevel: 3
        ),

        // --- PATATES ---
        "Potato___Late_blight": PlantDisease(
            className: "Potato___Late_blight",
            displayName: "Patates — Geç Yanıklık",
            description: "P. infestans mantarı. 1840'larda İrlanda'da büyük kıtlığa yol açtı. Çok tehlikeli.",
            treatments: [
                "Etkilenen bitkileri hemen söküp yak",
                "Ridomil Gold veya bakır fungisit uygula",
                "3-4 yıllık ekim nöbeti uygula"
            ],
            severityLevel: 5
        ),

        "Potato___Early_blight": PlantDisease(
            className: "Potato___Early_blight",
            displayName: "Patates — Erken Yanıklık",
            description: "Alternaria solani mantarı. Yapraklarda koyu halkalı lekeler oluşur.",
            treatments: [
                "Etkilenen yaprakları temizle",
                "Fungisit uygula",
                "Nöbetleşe ekim uygula"
            ],
            severityLevel: 3
        ),

        "Potato___healthy": PlantDisease(
            className: "Potato___healthy",
            displayName: "Patates — Sağlıklı",
            description: "Bitkide hastalık belirtisi yok. Büyüme normal seyrediyor.",
            treatments: [
                "Potasyum açısından zengin gübre kullan",
                "Toprak pH'ını 5.5-6.0 arasında tut"
            ],
            severityLevel: 1
        ),

        // --- BİBER ---
        "Pepper__bell___Bacterial_spot": PlantDisease(
            className: "Pepper__bell___Bacterial_spot",
            displayName: "Biber — Bakteriyel Leke",
            description: "Xanthomonas bakterisi neden olur. Yaprak ve meyvelerde lekeler oluşur.",
            treatments: [
                "Bakır bazlı bakterisit uygula",
                "Hasta yaprakları uzaklaştır",
                "Sulama suyunu yapraklara değdirme"
            ],
            severityLevel: 3
        ),

        "Pepper__bell___healthy": PlantDisease(
            className: "Pepper__bell___healthy",
            displayName: "Biber — Sağlıklı",
            description: "Bitkide hastalık belirtisi tespit edilmedi.",
            treatments: [
                "Düzenli sulama ve gübrelemeye devam et",
                "Haftalık kontrol alışkanlığı edin"
            ],
            severityLevel: 1
        )
    ]

    // MARK: - Hastalık Arama
    // Bilinmeyen sınıf gelirse varsayılan yanıt döner
    static func disease(for className: String) -> PlantDisease {
        diseases[className] ?? PlantDisease(
            className: className,
            displayName: "Bilinmeyen: \(className)",
            description: "Bu hastalık veritabanında bulunamadı. Uzmanla görüşün.",
            treatments: ["Bitki uzmanına danışın"],
            severityLevel: 3
        )
    }
}
