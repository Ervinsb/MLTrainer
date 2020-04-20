//
//  ContentView.swift
//  ML Trainer
//
//  Created by Ervīns Balodis on 07/11/2019.
//  Copyright © 2019 Ervīns Balodis. All rights reserved.
//

import SwiftUI
import CoreML
import Vision
import ImageIO
import PencilKit
struct ContentView: View {
    
    @State var isShowingImagePicker = false
    @State var showingActionSheet = false
    @State var photoSourceType: UIImagePickerController.SourceType = .camera
    @State var classLabel: String = "Dog"
    @EnvironmentObject var imageCModel: Classifier
    let tempImage = UIImage(systemName: "umbrella")
    
    func classify(){
        self.imageCModel.updateClassifications()
    }
    
    func updateModel(){
        self.imageCModel.updateModel(outputLabel: classLabel)
    }
    
    func compileModel(){
        self.imageCModel.compileDownloadedModel()
    }
    
    var body: some View {
        VStack {
            
            // Comment out stuff with imageCModel or canvas will show that the app has crashed
            Text(imageCModel.classificationText)

            Image(uiImage: self.imageCModel.theImage!)
                .resizable()
                .scaledToFill()
                .frame(width: 224, height: 224)
                .border(Color.red, width: 2)
                .clipped()
            
            
            Button(action: {
                FirebaseController.downloadModel()
            }) {
                Text("Download model").font(.title)
            }
            
            Button(action: {
                FirebaseController.downloadUpdatedModelData()
            }) {
                Text("Download updated model data").font(.title)
            }
            
            Button(action: {
                self.compileModel()
            }) {
                Text("Compile model").font(.title)
            }
            
            Button(action: {
                FirebaseController.uploadUpdatedModelData()
            }) {
                Text("Upload updated model data").font(.title)
            }
            
            Button(action: {
                 self.showingActionSheet.toggle()
             }) {
                 Text("Select an image").font(.title)
             }.actionSheet(isPresented: $showingActionSheet, content: {
                 ActionSheet(title: Text("Take a picture or pick an existing one"), message: nil, buttons: [
                     //1st action sheet button
                     .default(Text("Take a photo"), action: {
                         self.photoSourceType = .camera
                         self.isShowingImagePicker.toggle()
                     }),
                     //2nd action sheet button
                     .default(Text("Pick a photo from library"), action: {
                         self.photoSourceType = .photoLibrary
                         self.isShowingImagePicker.toggle()
                     }),
                     //3nd action sheet button
                     .destructive(Text("Cancel"), action: {
                         self.showingActionSheet.toggle()
                     })
                 ])
             }).sheet(isPresented: $isShowingImagePicker, content: {
                 MyImagePickerView(isPresented: self.$isShowingImagePicker, selectedImage: self.$imageCModel.theImage, photoSourceType: self.$photoSourceType)
            })
            
            Button(action: {
               self.classify()
            }) {
                Text("Classify").font(.title)
            }
            
            Button(action: {
                self.updateModel()
            }) {
                Text("Update model").font(.title)
            }
            
            TextField("Enter the class: ", text: $classLabel)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center )
                .padding()
            
        }
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
