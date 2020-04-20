import SwiftUI
import Vision
import CoreML
import ImageIO
import UIKit

final class Classifier: ObservableObject{
    
    @Published var theImage: UIImage? = UIImage(systemName: "umbrella")
    @Published var classificationText: String = "Select or take a photo!"
    let localModelURL = FirebaseController.URLToModel
    let documentsURL = try! FileManager().url(for: .documentDirectory,
    in: .userDomainMask,
    appropriateFor: nil,
    create: true)
    let fileManager = FileManager.default
    var globalCompiledModelURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true).appendingPathComponent("compiledModel.mlmodelc")
    var imageConstraint: MLImageConstraint!
    
    //METHODS
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func compileDownloadedModel(){
        print("Compiling model")
        let fileManager = FileManager.default
        let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
        let pathOfFile = documentDirectory.appendingPathComponent("compiledModel.mlmodelc")
        globalCompiledModelURL = try! MLModel.compileModel(at: localModelURL!)
        _ = try! fileManager.replaceItemAt(pathOfFile, withItemAt: globalCompiledModelURL)
        //try! fileManager.removeItem(at: documentDirectory.appendingPathComponent("(A Document Being Saved By ML Trainer)"))
        print("The URL of the compiled model after compilation: ")
        globalCompiledModelURL = pathOfFile
        print(pathOfFile)
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func updateClassifications() {
        let classificationRequest: VNCoreMLRequest = {
            do {
                let model = try VNCoreMLModel(for: try! MLModel(contentsOf: globalCompiledModelURL))
                let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                    self?.processClassifications(for: request, error: error)
                })
                request.imageCropAndScaleOption = .centerCrop
                return request
            } catch {
                fatalError("Failed to load Vision ML model: \(error)")
            }
        }()
        self.classificationText = "Classifying..."
        
        //let orientation = CGImagePropertyOrientation(image.imageOrientation)
        //Should fix this so that the orientation is correct
        let orientation = CGImagePropertyOrientation.right
        guard let ciImage = CIImage(image: self.theImage!) else { fatalError("Unable to create \(CIImage.self) from \(String(describing: theImage)).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([classificationRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationText = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            
            let classifications = results as! [VNClassificationObservation]
        
            if classifications.isEmpty {
                self.classificationText = "Nothing recognized."
            } else {
                print(classifications)
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                   return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                self.classificationText = "Classification:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func getImageConstraint(model: MLModel) -> MLImageConstraint {
      return model.modelDescription.inputDescriptionsByName["image"]!.imageConstraint!
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private func batchProvider(outputLabel: String) -> MLArrayBatchProvider
    {
        var batchInputs: [MLFeatureProvider] = []
        let imageOptions: [MLFeatureValue.ImageOption: Any] = [
          .cropAndScale: VNImageCropAndScaleOption.scaleFill.rawValue
        ]
        var trainingImages = [UIImage]() //
        trainingImages.append(theImage!) //
        imageConstraint = self.getImageConstraint(model: catanddog_updateable().model)
        for image in trainingImages {
            do{
                let inputValue = try MLFeatureValue(cgImage: image.cgImage!, constraint: imageConstraint, options: imageOptions)
                
                if let pixelBuffer = inputValue.imageBufferValue{
                    let x = catanddog_updateableTrainingInput(image: pixelBuffer, classLabel: outputLabel)
                    batchInputs.append(x)
                }
            }
            catch(let error){
                print("error description is \(error.localizedDescription)")
            }
        }
     return MLArrayBatchProvider(array: batchInputs)
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private func loadModel(url: URL) -> MLModel? {
      do {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        return try MLModel(contentsOf: url, configuration: config)
      } catch {
        print("Error loading model: \(error)")
        return nil
      }
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func updateModel(outputLabel: String){
        //Configuration for when update is performed
        let modelConfig = MLModelConfiguration()
        modelConfig.computeUnits = .cpuAndGPU
        do {
            let updateTask = try MLUpdateTask(forModelAt: globalCompiledModelURL, trainingData: batchProvider(outputLabel: outputLabel), configuration: modelConfig,
                             progressHandlers: MLUpdateProgressHandlers(forEvents: [.trainingBegin,.epochEnd],
                              progressHandler: { (contextProgress) in
                                print(contextProgress.event)
                                // you can check the progress here, after each epoch
                             }) { (finalContext) in
                                    do {
                                        try finalContext.model.write(to: self.globalCompiledModelURL)
                                    } catch(let error) {
                                        print("Error: \(error.localizedDescription)")
                                    }
            })
            updateTask.resume()
        } catch {
            print("Error while updating: \(error.localizedDescription)")
        }
    }
}
