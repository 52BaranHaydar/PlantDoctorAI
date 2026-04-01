//
//  PlantDisease.swift
//  PlantDoctorAI
//
//  Created by Baran on 31.03.2026.
//

import Foundation
import SwiftUI
// Struct kullanıyoruz çünkü
// - Valur type: kopyaladığında bağımsız kopya oluşur
// - Identifiable: SwiftUI List'te her satırı ayırt eder
// - Codable: JSON'a dönüştürebilir (geleckte API için)

struct PlantDisease: Identifiable, Codable{
    // Her hastalığa benzersiz kimlil - SwiftUI List için zorunlu
    let id: UUID
    
    // CoreMl modelinin ürettiği ham sınıf adı
    // Örnek: "Tomato__Late_blight"
    let className: String
    
    // Kullanıcıya gösterilecek Türkçe isim
    let displayName: String
    
    // Hastalık açıklaması
    let description: String
    
    // Tedavi önerileri listesi - birden fazla öneri olabilir
    let treatments: [String]
    
    // Ciddiyet seviyesi: 1 (hafif) -> 5 (kritik)
    let severityLevel: Int
    
    // CoreML güven skoru: 0.0 ile 1.0 arası
    // var kullanıyoruz çünkü tahmin sonrası atanacak
    var confidence: Double
    
    // Hesaplanan Özellikler
    // "var" + süslü parantez = computed property
    // Deger saklmaz, her seferinde hesaplanır
    
    
    // 0.876 -> %87.6 formatında çevirir
    var confidencePercentage: String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: confidence)) ?? "%0"
    }
    
    // Ciddiyet seviyesine göre SwiftUI rengi döner
    // switch-case: her ihtimali tek tek kontrol eder
    var severityColor: Color{
        switch severityLevel{
        case 1: return .green // Hafif
        case 2: return .yellow // Orta
        case 3: return .orange // Ciddi
        case 4,5 : return .red // Kritik
        default: return .gray // Bilinmiyor
        }
    }
    
    // Sayısal seviyesi Türkçe metne çevirir
    var severityText: String{
        switch severityLevel{
        case 1: return "Hafif"
        case 2: return "Orta"
        case 3: return "Ciddi"
        case 4: return "Ağır"
        case 5: return "Kritik"
        default: return "Bilinmiyor"
        }
    }
    
    // Kurucu Fonksiyon (Inıtializer)
    // id parametresi varsayılan UUID() alır
    // Yani çoğu zaman id vermene gerek olmaz
    init(
        id: UUID = UUID(),
        className: String,
        displayName: String,
        description: String,
        treatments: [String],
        severityLevel: Int,
        confidence: Double = 0.0
    ){
        self.id = id
        self.className = className
        self.displayName = displayName
        self.description = description
        self.treatments = treatments
        self.severityLevel = severityLevel
        self.confidence = confidence
    }
}


// Bir teşhis oturumun tüm sonuçlarını bir arada tutar
// ViewModel bu struct'ı üretir, View bu struct'ı gösterir
struct DiagnosisResult: Identifiable {
    
    // Her sonuca benzersiz id-let: değişmez
    let id: UUID = UUID()
    
    // Kullanıcının çektiği orijinal fotoğraf
    let image: UIImage
    
    // En yüksek güvenlikli hasta tahmini
    let topDisease: PlantDisease
    
    // İlk 3 tahmn - Diğer İhtimaller için
    let topPredictions: [PlantDisease]
    
    // Teşhis tarihi ve saati
    let diagnosedAt: Date
    
    // Güven %60'ın üstünde true
    let isReliable: Bool
    
    // Güvenirlik mesajı - computed property
    
    var reliabilityMessage: String{
        isReliable ? "Yüksek güvenirlilik" : "Düşük güvenirlilik - uzman görüşü alın"
    }
}

//  PlantDiseaseDatabase
// "enum" kullanıyoruz çünkü bu sadece bir veri deposu
// — hiç örneklenmemeli (new PlantDiseaseDatabase() olmaz)
// static: sınıf adıyla direkt erişilir, nesne gerekmez
enum PlantDiseaseDatabase {

    // Tüm hastalıklar: CoreML sınıf adı → PlantDisease nesnesi
    // Key: "Tomato___Late_blight" gibi model çıktısı
    // Value: Zengin bilgi içeren PlantDisease struct'ı
    static let diseases: [String: PlantDisease] = [

        "Tomato___Late_blight": PlantDisease(
            className: "Tomato___Late_blight",
            displayName: "Domates — Geç Yanıklık",
            description: "Phytophthora infestans mantarı neden olur. Yapraklarda kahverengi-siyah lekeler görülür. Çok hızlı yayılır.",
            treatments: [
                "Hasta yaprakları hemen kopar ve uzaklaştır",
                "Bakır bazlı fungisit uygula (haftalık)",
                "Sabah sulaması yap — yaprakları ıslak bırakma"
            ],
            severityLevel: 4
        ),

        "Tomato___healthy": PlantDisease(
            className: "Tomato___healthy",
            displayName: "Domates — Sağlıklı",
            description: "Bitkide hastalık belirtisi tespit edilmedi.",
            treatments: [
                "Düzenli sulama ve gübrelemeye devam et",
                "Haftalık kontrol alışkanlığı edin"
            ],
            severityLevel: 1
        ),

        "Potato___Late_blight": PlantDisease(
            className: "Potato___Late_blight",
            displayName: "Patates — Geç Yanıklık",
            description: "1840'larda İrlanda'da büyük kıtlığa yol açan P. infestans mantarıdır.",
            treatments: [
                "Etkilenen bitkileri hemen söküp yak",
                "Ridomil Gold veya bakır fungisit uygula",
                "3-4 yıllık ekim nöbeti uygula"
            ],
            severityLevel: 5
        ),

        "Apple___Apple_scab": PlantDisease(
            className: "Apple___Apple_scab",
            displayName: "Elma — Karaleke",
            description: "Venturia inaequalis mantarı. Yaprak ve meyvelerde koyu lekeler oluşur.",
            treatments: [
                "İlkbaharda fungisit uygula",
                "Düşen yaprakları topla ve yok et"
            ],
            severityLevel: 3
        )
    ]

    // Bilinmeyen hastalık gelirse varsayılan yanıt döner
    // "??" nil-coalescing: sol taraf nil ise sağ tarafı kullan
    static func disease(for className: String) -> PlantDisease {
        diseases[className] ?? PlantDisease(
            className: className,
            displayName: "Bilinmeyen Hastalık",
            description: "Veritabanında bulunamadı. Uzmanla görüşün.",
            treatments: ["Bitki uzmanına danışın"],
            severityLevel: 3
        )
    }
}

