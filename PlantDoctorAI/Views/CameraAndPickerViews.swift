//
//  CameraAndPickerViews.swift
//  PlantDoctorAI
//
//  Created by Baran on 1.04.2026.
//

// Galeri Seçici
// SwitUI View'a dönüştüren protokol
// SwiftUI'ın kendi galeri API'SI OLMADIĞI İÇİN
// UIKit'in PHPPickerViewCotroller'ını kullanıyoruz
import SwiftUI
import PhotosUI
// MARK: - Galeri Seçici
// UIViewControllerRepresentable: UIKit ViewController'ı
// SwiftUI View'a dönüştüren protokol.
// SwiftUI'ın kendi galeri API'si olmadığı için
// UIKit'in PHPickerViewController'ını kullanıyoruz.
struct ImagePickerView: UIViewControllerRepresentable {

    // Fotoğraf seçilince ViewModel'e haber ver
    // @escaping: closure bu fonksiyondan sonra da yaşar
    let onImageSelected: (UIImage) -> Void

    // Xcode bu iki fonksiyonu zorunlu tutar:
    // 1. makeUIViewController: VC'yi oluştur
    // 2. updateUIViewController: güncellemeleri uygula

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images      // Sadece fotoğraf
        config.selectionLimit = 1    // Tek seçim

        let picker = PHPickerViewController(configuration: config)
        // Seçim yapılınca Coordinator haberdar olur
        picker.delegate = context.coordinator
        return picker
    }

    // Galeri için güncelleme gerekmez — boş bırakıyoruz
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    // Coordinator: UIKit delegate'ini SwiftUI'a bağlar
    func makeCoordinator() -> Coordinator {
        Coordinator(onImageSelected: onImageSelected)
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, PHPickerViewControllerDelegate {

        let onImageSelected: (UIImage) -> Void

        init(onImageSelected: @escaping (UIImage) -> Void) {
            self.onImageSelected = onImageSelected
        }

        // Kullanıcı fotoğraf seçince çağrılır
        func picker(_ picker: PHPickerViewController,
                    didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            // Seçim yoksa (iptal) çık
            guard let result = results.first else { return }

            // UIImage olarak yüklenebilir mi?
            guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { return }

            // Asenkron fotoğraf yükle
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                guard let image = object as? UIImage else { return }

                // UI güncellemesi main thread'de olmalı!
                DispatchQueue.main.async {
                    self.onImageSelected(image)
                }
            }
        }
    }
}

// MARK: - Kamera View
// UIImagePickerController: kameraya erişim sağlar
// iOS'un yerleşik kamera arayüzünü kullanır
struct CameraView: UIViewControllerRepresentable {

    let onImageCaptured: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera      // Kamerayı aç (galeri değil)
        picker.mediaTypes = ["public.image"]  // Sadece fotoğraf
        picker.allowsEditing = false     // Kırpma yok
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured)
    }

    // MARK: - Coordinator
    // İki protokol birden uygulanıyor — UIKit zorunluluğu
    class Coordinator: NSObject,
                       UIImagePickerControllerDelegate,
                       UINavigationControllerDelegate {

        let onImageCaptured: (UIImage) -> Void

        init(onImageCaptured: @escaping (UIImage) -> Void) {
            self.onImageCaptured = onImageCaptured
        }

        // Fotoğraf çekilince çağrılır
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            picker.dismiss(animated: true)

            // info sözlüğünden fotoğrafı çıkar
            guard let image = info[.originalImage] as? UIImage else { return }

            // Kamera fotoğrafı bazen ters gelir — düzelt
            let fixed = image.fixedOrientation()

            DispatchQueue.main.async {
                self.onImageCaptured(fixed)
            }
        }

        // Kullanıcı iptal ettiyse
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - UIImage Extension
// Extension: var olan tipe yeni fonksiyon ekler
// Apple'ın UIImage tipini değiştirmeden genişletiyoruz
extension UIImage {

    // Kamera EXIF yön verisinden kaynaklanan ters görüntüyü düzeltir
    // CoreML düz görüntü beklediği için bu adım önemli
    func fixedOrientation() -> UIImage {

        // Zaten doğru yöndeyse dokunma
        guard imageOrientation != .up else { return self }

        // CGContext ile yeniden çiz — bu sefer .up yönünde
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
