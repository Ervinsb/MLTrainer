//
//  FirebaseController.swift
//  ML Trainer
//
//  Created by Ervīns Balodis on 15/11/2019.
//  Copyright © 2019 Ervīns Balodis. All rights reserved.
//

import Foundation
import Firebase
import SwiftUI
import CoreML
import Vision

struct FirebaseController {
    static let modelName = "CatDogUpdatable.mlmodel"
    static let storage = Storage.storage()
    static let storageRef = storage.reference()
    static let modelInStorage = storageRef.child(modelName)
    static let documentsURL = try! FileManager().url(for: .documentDirectory,
                                              in: .userDomainMask,
                                              appropriateFor: nil,
                                              create: true)
    static let docstr = documentsURL.absoluteString
    static let URLToModel = URL(string: docstr + "/" + modelName)
    static let fileWeightsInStorage = storageRef.child("model.espresso.weights")
    static let fileShapeInStorage = storageRef.child("model.espresso.shape")
    static let fileNetInStorage = storageRef.child("model.espresso.net")
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static func uploadUpdatedModelData(){
        let fileManager = FileManager.default
        let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
        let fileWeights = documentDirectory.appendingPathComponent("compiledModel.mlmodelc/model.espresso.weights")
        let fileShape = documentDirectory.appendingPathComponent("compiledModel.mlmodelc/model.espresso.shape")
        let fileNet = documentDirectory.appendingPathComponent("compiledModel.mlmodelc/model.espresso.net")
        
        let uploadTask = fileWeightsInStorage.putFile(from: fileWeights, metadata: nil) { metadata, error in
            if let error = error{
                 print("Error uploading weights to firebase! \n \(error)")
            } else {
                print("Weights successfuly uploaded to firebase! \n")
            }
        }
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print("Done: \(percentComplete)%")
        }
        let uploadTask2 = fileShapeInStorage.putFile(from: fileShape, metadata: nil) { metadata, error in
            if let error = error{
                 print("Error uploading shape to firebase! \n \(error)")
            } else {
                print("Shape successfuly uploaded to firebase! \n")
            }
        }
        uploadTask2.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print("Done: \(percentComplete)%")
        }
        let uploadTask3 = fileNetInStorage.putFile(from: fileNet, metadata: nil) { metadata, error in
            if let error = error{
                 print("Error uploading net to firebase! \n \(error)")
            } else {
                print("Net successfuly uploaded to firebase! \n")
            }
        }
        uploadTask3.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print("Done: \(percentComplete)%")
        }
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static func downloadModel() {
        let downloadTask = modelInStorage.write(toFile: URLToModel!){ url, error in
            if let error = error{
                 print("Error downloading model from firebase! \n \(error)")
            } else {
                print("Model successfuly downloaded from firebase! \n")
                print("Saved model URL: ")
                print(URLToModel?.absoluteString ?? "No URL to print") // For debugging
            }
        }
        downloadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print("Done: \(percentComplete)%")
        }

        downloadTask.observe(.success) { snapshot in
            print("Downloaded successfully")
        }
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static func downloadUpdatedModelData() {
        let fileManager = FileManager.default
        let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
        let fileWeights = documentDirectory.appendingPathComponent("compiledModel.mlmodelc/model.espresso.weights")
        let fileShape = documentDirectory.appendingPathComponent("compiledModel.mlmodelc/model.espresso.shape")
        let fileNet = documentDirectory.appendingPathComponent("compiledModel.mlmodelc/model.espresso.net")
        
        let downloadTask = fileWeightsInStorage.write(toFile: fileWeights){ url, error in
            if let error = error{
                 print("Error downloading weights from firebase! \n \(error)")
            } else {
                print("Weights successfuly downloaded from firebase! \n")
            }
        }
        // Add a progress observer to a download task
        downloadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print("Done: \(percentComplete)%")
        }
        downloadTask.observe(.success) { snapshot in
            print("Weights downloaded successfully")
        }
        
        let downloadTask2 = fileShapeInStorage.write(toFile: fileShape){ url, error in
            if let error = error{
                 print("Error downloading shape from firebase! \n \(error)")
            } else {
                print("Shape successfuly downloaded from firebase! \n")
            }
        }
        downloadTask2.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print("Done: \(percentComplete)%")
        }
        downloadTask2.observe(.success) { snapshot in
            print("Shape downloaded successfully")
        }
        
        let downloadTask3 = fileNetInStorage.write(toFile: fileNet){ url, error in
            if let error = error{
                 print("Error downloading net from firebase! \n \(error)")
            } else {
                print("Net successfuly downloaded from firebase! \n")
            }
        }
        downloadTask3.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print("Done: \(percentComplete)%")
        }
        downloadTask3.observe(.success) { snapshot in
            print("Net downloaded successfully")
        }
    }
}
