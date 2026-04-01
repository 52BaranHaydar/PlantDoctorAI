//
//  ContentView.swift
//  PlantDoctorAI
//
//  Created by Baran on 31.03.2026.
//

// Ana Ekran - MVVM'de sadece gösterim yapar
// ViewModel'den veri okur, kullanıcı aksiyonlarını
// ViewModel'e iletir. İş mantığı içermez

import SwiftUI

struct ContentView: View {
    
    // @StateObject: BU View ViewModel'in sahibidir
    // View yeniden çizilse bile ViewModel yok edilemez
    @StateObject private var viewModel = DiagnosisViewModel()
    
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing: 24){
                    
                    // ----- Photo seçim alanı -----
                    PhotoSelectionView(viewModel: viewModel)
                    
                    // --- Teşhis butonu ---
                    DiagnosisButton(viewModel: viewModel)
                    
                    // --- State'e göre doğru view seç ----
                    // switch: her durumda farklı UI göster
                    switch viewModel.diagnosisState {
                    case .idle:
                        HintCard()
                    case .loading:
                        LoadingCard()
                    case .success(let diagnosisResult):
                        ResultCard(result: diagnosisResult)
                    case .error(let message):
                        ErrorCard(message: message)
                    }
                    Spacer(minLength: 32)
                }
                .padding(.horizontal,16)
                .padding(.top,8)
            }
            .navigationTitle("🌿 Bitki Doktoru")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Sağ üst köse - sonuç varsa "Yeni Teşhis" Butonu
                ToolbarItem(placement: .navigationBarTrailing){
                    if case .success = viewModel.diagnosisState {
                        Button("Yeni Teşhis") {
                            withAnimation{
                                viewModel.reset()
                            }
                        }
                        .tint(.green)
                    }
                }
            }
        }
        // Galeri picker
        .sheet(isPresented: $viewModel.showImagePicker){
            ImagePickerView(onImageSelected: viewModel.imageSelected)
        }
        // Kaemra
        .sheet(isPresented: $viewModel.showCamera){
            CameraView(onImageCaptured: viewModel.imageSelected)
        }
        // Hata alerti
        .alert("Hata", isPresented: $viewModel.showErrorAlert){
            Button("Tamam", role: .cancel){}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
}
// Fotoğraf seçim alanı
struct PhotoSelectionView:View {
    
    // @ObservedObject: ViewModel dışarıdan gelir, sadece izler
    @ObservedObject var viewModel: DiagnosisViewModel
    
    var body: some View {
        ZStack{
            if let image = viewModel.selectedImage {
                // Fotoğraf seçilmişse göster
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280)
                    .clipped()
                    .cornerRadius(16)
            } else{
                // Fotoğraf yok - placeholder göster
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(height: 280)
                    .overlay(
                        VStack(spacing: 16){
                            Image(systemName: "leaf.circle.fill")
                                .resizable()
                                .frame(width: 64, height: 64)
                                .foregroundStyle(.green.opacity(0.6))
                            
                            Text("Bitkini fotoğrafını ekle")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            
                            // İki buton yan yana
                            HStack(spacing: 12){
                                Button{
                                    viewModel.selectPhoto()
                                } label: {
                                    Label("Galeri", systemImage: "photo")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.green)
                                        .padding(.horizontal,20)
                                        .padding(.vertical,10)
                                        .background(Color.green.opacity(0.12))
                                        .cornerRadius(10)
                                }
                                
                                Button{
                                    viewModel.openCamera()
                                } label: {
                                    Label("Kamera", systemImage: "camera.fill")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.green)
                                        .padding(.horizontal,20)
                                        .padding(.vertical,10)
                                        .background(Color.green.opacity(0.12))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    )
            }
        }
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct DiagnosisButton: View{
    @ObservedObject var viewModel: DiagnosisViewModel
    
    var body: some View {
        Button(action: viewModel.diagnose){
            HStack{
                
                // Yükleniyorsa spinner, değilse ikon göster
                if viewModel.isLoading{
                    ProgressView()
                        .tint(.white)
                } else{
                    Image(systemName: "waveform.path.ecg")
                }
                
                Text(viewModel.isLoading ? "Analiz ediliyor..." : "Hastalık Teşhisi Yap")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(viewModel.canDiagnose ? Color.green : Color.gray.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(14)
        }
        
        // canDiagnose false is buton tıklanamaz
        .disabled(!viewModel.canDiagnose)
    }
}

struct HintCard: View {
    var body: some View{
        HStack(spacing: 14){
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Nasıl Kullanılır")
                    .font(.subheadline.weight(.semibold))
                
                Text("Hasta görünen yaprak veya bitkinin fotoğrafını çek. Yapay zeka hastalığını tespit edecek")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.yellow.opacity(0.08))
        .cornerRadius(12)
    }
}

struct LoadingCard: View {
    // @State: sadece bu View'a özel animasyon durumu
    @State private var isAnimating = true

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
                // Sürekli dönen animasyon
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating
                )

            Text("Bitki analiz ediliyor")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        // View ekrana gelince animasyon başlat
        .onAppear { isAnimating = true }
    }
}

struct ResultCard: View {
    let result: DiagnosisResult
    
    var body: some View{
        VStack(alignment: .leading, spacing: 12){
            
            
            // Başlık
            Label("Teşhis Sonucu", systemImage: "stethoscope")
                .font(.headline)
            
            // Hastalık adı
            Text(result.topDisease.displayName)
                .font(.title2.weight(.bold))
                .foregroundColor(result.topDisease.severityColor)
            
            // Güven skoru
            HStack{
                Text("Güven")
                    .foregroundStyle(.secondary)
                Text(result.topDisease.confidencePercentage)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
            }
            .font(.subheadline)
            
            Divider()
            
            // Tedaviler
            Text("Tedavi Öneriler")
                .font(.subheadline.weight(.semibold))
            
            ForEach(Array(result.topDisease.treatments.enumerated()), id: \.offset) { index, treatment in
                HStack(alignment: .top, spacing: 10){
                    // Numara balonu
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Color.green)
                        .clipShape(Circle())
                    Text(treatment)
                        .font(.subheadline)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06),radius: 10, x:0, y:4)
    }
}

struct ErrorCard: View {
    let message: String
    var body: some View {
        
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .font(.subheadline)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.08))
        .cornerRadius(12)
    }
    
    struct ImagePickerView: View {
        var onImageSelected: (UIImage) -> Void
        var body: some View {
            Text("Image Picker Placeholder")
                .onAppear { /* Implement real picker elsewhere */ }
        }
    }
    
}

#Preview {
    ContentView()
}
