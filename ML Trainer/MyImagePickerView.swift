//
//  MyImagePickerView.swift
//  ML Trainer
//
//  Created by Ervīns Balodis on 11/11/2019.
//  Copyright © 2019 Ervīns Balodis. All rights reserved.
//

import SwiftUI

struct MyImagePickerView: UIViewControllerRepresentable{
    
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    @Binding var photoSourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MyImagePickerView>) -> UIViewController {
        let controller = UIImagePickerController()
        controller.sourceType = photoSourceType
        controller.delegate = context.coordinator
        return controller
    }
    
    func makeCoordinator() -> MyImagePickerView.Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        
        let parent: MyImagePickerView
        
        init(parent: MyImagePickerView){
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImageFromPicker = info[.originalImage] as? UIImage{
                self.parent.selectedImage = selectedImageFromPicker
            }
            self.parent.isPresented = false
        }
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<MyImagePickerView>) {
    }
}
