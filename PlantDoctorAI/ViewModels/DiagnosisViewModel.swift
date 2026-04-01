//
//  DiagnosisViewModel.swift
//  PlantDoctorAI
//
//  Created by Baran on 1.04.2026.
//

// ViewModel, View ile services arasındaki köprüdür
// View'dan aksiyon alır -> Service'e iş yaptırır
// -> Sonucu @Published değişkenlere yazar -> View güncellenir.
import SwiftUI
import Combine

// Teşhis Durumu
// Enum: teşhis sürecinin hangi aşamada olduğunu tutar
// Her aşamada UI farklı bir şey gösterir

enum DiagnosisState{
    case idle // Başlangıç - fotograf yok
    case loading // CoreML çalışıyor
    case success(DiagnosisResult) // sonuç hazır
    case error(String) // Hata mesajı
}

// @MainActor: tüm UI güncellemeleri main thread'de yapılır
// ObservableObject: SwiftUI bu class'ı izler
// @Published değişken değişince View otomatik yeniden çizilir

@MainActor
final class DiagnosisViewModel: ObservableObject {
    
    // @Published Değişkenler
    // Bu değişkenler değişince bağlı View yeniden çizilir
    
    // Seçilen fotoğraf - nil ise henüz seçilmemiş
    @Published var selectedImage: UIImage?
    
    // Teşhis sürecinin durumu
    @Published var diagnosisState : DiagnosisState = .idle
    
    // Teşhis sürecinin durumu
    @Published var showImagePicker = false
    
    // Kamera gösterilsin mi?
    @Published var showCamera = false
    
    // Hata alert'i
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    
    // Private Bağımlılık
    // Service'i private tutar - Viewdoğrudan erişemez
    private let service = PlantDiagnosisService()
    
    // Hesaplanan Özellikler
    
    // Yükleme var mı? Buton bu değere göre aktif/pasif olur
    var isLoading: Bool{
        if case .loading = diagnosisState {return true}
        return false
    }
    
    // Fotoğraf seçilmiş mi? Teşhis butonu için
    var canDiagnose: Bool{
        selectedImage != nil && !isLoading
    }
    
    // Kullanıcı Aksiyonları
    
    // Galeride fotoğraf seçme
    func selectPhoto(){
        showImagePicker = true
    }
    
    // Kamera açma
    func openCamera(){
        showCamera = true
    }
    
    // Fotoğraf seçildikten sonra çağrılır
    func imageSelected(_ image: UIImage) {
        selectedImage = image
        diagnosisState = .idle
        showImagePicker = false
        showCamera = false
    }
    
    // Teşhizi sıfırla - Yeni Teşhis butonu için
    func reset(){
        selectedImage = nil
        diagnosisState = .idle
    }
    
    // Task: async kodu sync bağlamdan başlatır
    // MainActor sayesinde sonuç otomatik thread'e döner
    
    func diagnose(){
        
        // Fotoğraf seçili değilse çık
        guard let image = selectedImage else{
            errorMessage = "Lütfen önce bir fotoğraf seçin"
            showErrorAlert = true
            return
        }
        
        // Loading durumuna geç - UI spinner gösterir
        diagnosisState = .loading
        
        // Task: async fonksiyonu çağırmak için gerekli
        Task{
            do{
                // await: servis tamamlanana kadar bekle
                // UI bu sürededonmaz - kullanıcı ekranı görür
                let result = try await service.diagnose(image: image)
                
                
                // Başarılı - state güncelle, View otomatik yenilenir
                diagnosisState = .success(result)
            } catch{
                // Hata - kullanıcıya mesaj gönder
                diagnosisState = .error(error.localizedDescription)
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
        
    }
        
}
