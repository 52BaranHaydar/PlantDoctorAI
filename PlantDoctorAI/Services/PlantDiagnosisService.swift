//
//  PlantDiagnosisService.swift
//  PlantDoctorAI
//
//  Created by Baran on 31.03.2026.
//

// Bu dosya CoreML modeliyle konuşur
// ViewModel bu servisi çağırır - View hiç bilmez.
// Tek sorumluluğu: fotograf al, tahmin döndür.

// PlantDiagnosisService.swift
// PlantDoctorAI
//
// CoreML modeliyle konuşan servis katmanı.
// Create ML ile eğittiğimiz PlantDiseaseClassifier modelini
// Vision framework üzerinden çalıştırır.
// PlantDiagnosisService.swift
// PlantDoctorAI
//
// CoreML modeliyle konuşan servis katmanı.
// Simulator'da otomatik demo modu devreye girer.
// Gerçek iPhone'da CoreML modeli çalışır.

import CoreML
import Vision
import UIKit

// MARK: - Hata Tipleri
enum PlantDiagnosisError: LocalizedError {
    case modelNotFound
    case imageProcessingFailed
    case predictionFailed
    case lowConfidence(Double)

    var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "Model yüklenemedi."
        case .imageProcessingFailed:
            return "Fotoğraf işlenemedi."
        case .predictionFailed:
            return "Teşhis yapılamadı."
        case .lowConfidence(let score):
            return "Güven skoru çok düşük (%\(Int(score * 100)))."
        }
    }
}

// MARK: - PlantDiagnosisService
final class PlantDiagnosisService {

    // Minimum güven eşiği
    private let minimumConfidence: Float = 0.30

    // MARK: - CoreML Modeli
    // #if targetEnvironment(simulator): derleme zamanı koşulu
    // Simulator'da ANE/GPU yok — model çalışmaz
    // Gerçek iPhone'da otomatik aktif olur
    private lazy var visionModel: VNCoreMLModel? = {
        #if targetEnvironment(simulator)
        print("⚠️ Simulator — demo modu aktif")
        return nil
        #else
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all
            let model = try PlantDiseaseClassifier(configuration: config)
            print("✅ PlantDiseaseClassifier yüklendi")
            return try VNCoreMLModel(for: model.model)
        } catch {
            print("❌ Model yükleme hatası: \(error)")
            return nil
        }
        #endif
    }()

    // MARK: - Ana Teşhis Fonksiyonu
    func diagnose(image: UIImage) async throws -> DiagnosisResult {

        // Fotoğraf yönünü düzelt
        let fixedImage = image.fixedOrientation()

        // Model yoksa (simulator) demo modu
        guard let model = visionModel else {
            print("🔧 Demo modu: simüle sonuç")
            return makeDemoResult(for: image)
        }

        // UIImage → CGImage
        guard let cgImage = fixedImage.cgImage else {
            throw PlantDiagnosisError.imageProcessingFailed
        }

        // Continuation: callback → async/await köprüsü
        return try await withCheckedThrowingContinuation { continuation in

            // Çift resume önleme
            var resumed = false

            let request = VNCoreMLRequest(model: model) { request, error in

                guard !resumed else { return }
                resumed = true

                if let error = error {
                    print("❌ Vision hatası: \(error)")
                    continuation.resume(throwing: PlantDiagnosisError.predictionFailed)
                    return
                }

                guard let results = request.results as? [VNClassificationObservation],
                      !results.isEmpty else {
                    continuation.resume(throwing: PlantDiagnosisError.predictionFailed)
                    return
                }

                // Güven skoruna göre sırala
                let sorted = results.sorted { $0.confidence > $1.confidence }

                guard let top = sorted.first else {
                    continuation.resume(throwing: PlantDiagnosisError.predictionFailed)
                    return
                }

                print("🌿 Top tahmin: \(top.identifier) — %\(Int(top.confidence * 100))")

                // Güven eşiği kontrolü
                if top.confidence < self.minimumConfidence {
                    continuation.resume(
                        throwing: PlantDiagnosisError.lowConfidence(Double(top.confidence))
                    )
                    return
                }

                // İlk 3 tahmini dönüştür
                let predictions = sorted.prefix(3).map { obs -> PlantDisease in
                    var disease = PlantDiseaseDatabase.disease(for: obs.identifier)
                    disease.confidence = Double(obs.confidence)
                    return disease
                }

                let result = DiagnosisResult(
                    image: image,
                    topDisease: predictions[0],
                    topPredictions: Array(predictions),
                    diagnosedAt: Date(),
                    isReliable: top.confidence >= self.minimumConfidence
                )

                continuation.resume(returning: result)
            }

            // Görüntüyü işle
            let handler = VNImageRequestHandler(
                cgImage: cgImage,
                orientation: .up,
                options: [:]
            )

            do {
                try handler.perform([request])
            } catch {
                if !resumed {
                    resumed = true
                    continuation.resume(throwing: PlantDiagnosisError.predictionFailed)
                }
            }
        }
    }

    // MARK: - Demo Modu
    // Simulator'da gerçekçi simüle sonuç döner
    private func makeDemoResult(for image: UIImage) -> DiagnosisResult {

        // Rastgele farklı sonuçlar üret — demo daha gerçekçi görünür
        let demoScenarios: [(String, Double)] = [
            ("Tomato_Late_blight", Double.random(in: 0.78...0.94)),
            ("Tomato_Early_blight", Double.random(in: 0.72...0.88)),
            ("Tomato_healthy", Double.random(in: 0.80...0.95)),
            ("Potato___Late_blight", Double.random(in: 0.75...0.90)),
            ("Pepper__bell___healthy", Double.random(in: 0.82...0.96))
        ]

        let picked = demoScenarios.randomElement()!
        var top = PlantDiseaseDatabase.disease(for: picked.0)
        top.confidence = picked.1

        var second = PlantDiseaseDatabase.disease(for: "Tomato_Early_blight")
        second.confidence = Double.random(in: 0.03...0.15)

        var third = PlantDiseaseDatabase.disease(for: "Potato___healthy")
        third.confidence = Double.random(in: 0.01...0.08)

        return DiagnosisResult(
            image: image,
            topDisease: top,
            topPredictions: [top, second, third],
            diagnosedAt: Date(),
            isReliable: true
        )
    }
}
