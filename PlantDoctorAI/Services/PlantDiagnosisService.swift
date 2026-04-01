//
//  PlantDiagnosisService.swift
//  PlantDoctorAI
//
//  Created by Baran on 31.03.2026.
//

// Bu dosya CoreML modeliyle konuşur
// ViewModel bu servisi çağırır - View hiç bilmez.
// Tek sorumluluğu: fotograf al, tahmin döndür.

import CoreML // Apple'ın makine öğrenmesi framewörk'ü
import Vision // Görüntü analiz + CoreMl entegrasyonu
import UIKit // UIImage tipi İçin

enum PlantDiagnosisError: LocalizedError {
    
    case modelNotFound //.mlmodel dosyası bulunamadı
    case imageProcessingFailed // Görüntü işlenemedi
    case predictionFailed // CoreML tahmini hata verdi
    case lowConfidence(Double) // Güven skoru çok düşük
    
    // Her hata için Türkçe mesaj
    var errorDescription: String? {
        switch self{
        case .modelNotFound:
            return "Model yüklenemedi. Uygulamayı yeniden başlatın"
        case .imageProcessingFailed:
            return "Fotoğraf işlenemedi. Farklı bir fotoğraf deneyin"
        case .predictionFailed:
            return "Teşhis yapılamadı. Lütfen tekrar deneyin. "
        case .lowConfidence(let score):
            return "Güven skoru çok düşük (%\(Int(score * 100)). Daha net fotoğraf çekin."
        }
    }
    
}
// "final class": bu class'tan miras alınamaz (performans için)
// @MainActor: UI guncellemeleri otomatik main thread'de yapılır
final class PlantDiagnosisService{
    // Minimum güven eşiği - %60 altı reddedilir
    private let minimumConfidence: Float = 0.60
    
    // Gerçek model olmadan geliştirme için simule edilmiş sonuc
    // Model dosyası eklenince bu fonksiyon kullanılmaz
    func makeDemoResult(for image: UIImage) -> DiagnosisResult{
        
        // Rastgele gücen skoru üret (gerçekçi demo için)
        var topDisease = PlantDiseaseDatabase.disease(for: "Tomato___Late_blight")
        topDisease.confidence = Double.random(in: 0.72...0.94)
        
        var second = PlantDiseaseDatabase.disease(for: "Tomato___healthy")
        second.confidence = Double.random(in: 0.04...0.18)
        
        return DiagnosisResult(
            image: image, topDisease: topDisease, topPredictions: [topDisease,second], diagnosedAt: Date(), isReliable: true
        )
    }
    
    // async throws: asenkron + hata fırlatabilir
    // await ile çağrılır, UI donmaz
    func diagnose(image: UIImage) async throws -> DiagnosisResult {
        
        // UIImage -> CGImage dönüşümü (Vision bunu ister)
        guard let cgImage = image.cgImage else{
            throw PlantDiagnosisError.imageProcessingFailed
        }
        
        // Gerçek model yoksa demo sonuç döndür
        // Todo: Buraya gerçek .mlmodel eklenince kaldır
        return makeDemoResult(for: image)
        
    }
    
    
}
