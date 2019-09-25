//
//  ViewController.swift
//  ActivityClassifier
//
//  Created by Skafos.ai on 4/4/19.
//  Copyright © 2019 Skafos.ai. All rights reserved.
//

import UIKit
import Skafos
import CoreML
import SnapKit
import CoreMotion

class ViewController: UIViewController {
    
    // Define some ML Model constants for the recurrent network
    struct ModelConstants {
        static let numOfFeatures = 6
        // Must be the same value you used while training
        static let predictionWindowSize = 30
        // Must be the same value you used while training
        static let sensorsUpdateFrequency = 1.0 / 10.0
        static let hiddenInLength = 200
        static let hiddenCellInLength = 200
    }
    
    // Initialize the model, layers, and prediction window
    private let classifier = ActivityClassifier()
    private let modelName:String = "ActivityClassifier"
    var currentIndexInPredictionWindow = 0
    let predictionWindowDataArray = try? MLMultiArray(shape: [1, ModelConstants.predictionWindowSize, ModelConstants.numOfFeatures] as [NSNumber], dataType: MLMultiArrayDataType.double)
    var lastHiddenOutput = try? MLMultiArray(shape: [ModelConstants.hiddenInLength as NSNumber], dataType: MLMultiArrayDataType.double)
    var lastHiddenCellOutput = try? MLMultiArray(shape: [ModelConstants.hiddenCellInLength as NSNumber], dataType: MLMultiArrayDataType.double)
    
    // Initialize CoreMotion Manager
    let motionManager = CMMotionManager()

    // Initialize the label that will get updated
    private lazy var label:UILabel = {
        let label           = UILabel()
        label.text          = ""
        label.font          = label.font.withSize(35)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        
        self.view.addSubview(label)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.title = "Activity Classifier"
        
        // Make sure nothing is running through the model yet
        stopDeviceMotion()
        
        // Skafos load cached asset
        // If you pass in a tag, Skafos will make a network request to fetch the asset with that tag
        Skafos.load(asset: modelName) { (error, asset) in
            // Log the asset in the console
            console.info(asset)
            guard error == nil, let model = asset.model else {
                console.error("Skafos load asset error: \(error?.localizedDescription ?? "No model available in the asset")")
                return
            }
            // Assign model to the classifier class
            self.classifier.model = model
        }
      
        // Start running the app
        self.startDeviceMotion()
    }
    
    func stopDeviceMotion() {
        guard motionManager.isDeviceMotionAvailable else {
            debugPrint("Core Motion Data Unavailable!")
            return
        }
        // Stop streaming device data
        motionManager.stopDeviceMotionUpdates()
        // Reset some parameters
        currentIndexInPredictionWindow = 0
        lastHiddenOutput = try? MLMultiArray(shape: [ModelConstants.hiddenInLength as NSNumber], dataType: MLMultiArrayDataType.double)
        lastHiddenCellOutput = try? MLMultiArray(shape: [ModelConstants.hiddenCellInLength as NSNumber], dataType: MLMultiArrayDataType.double)
        
    }
    
    func startDeviceMotion() {
        guard motionManager.isDeviceMotionAvailable else {
            debugPrint("Core Motion Data Unavailable!")
            return
        }
        motionManager.deviceMotionUpdateInterval = ModelConstants.sensorsUpdateFrequency
        motionManager.showsDeviceMovementDisplay = true
        motionManager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
            guard let motionData = motionData else { return }
            // Add motion data sample to array
            self.addMotionDataSampleToArray(motionSample: motionData)
        }
    }
    
    func addMotionDataSampleToArray(motionSample: CMDeviceMotion) {
        // Add the current motion data reading to the data array
        guard let dataArray = predictionWindowDataArray else { return }
        
        // Using global queue for building prediction array
        DispatchQueue.global().async {
            dataArray[[0, self.currentIndexInPredictionWindow, 0] as [NSNumber]] = motionSample.rotationRate.x as NSNumber
            dataArray[[0, self.currentIndexInPredictionWindow, 1] as [NSNumber]] = motionSample.rotationRate.y as NSNumber
            dataArray[[0, self.currentIndexInPredictionWindow, 2] as [NSNumber]] = motionSample.rotationRate.z as NSNumber
            dataArray[[0, self.currentIndexInPredictionWindow, 3] as [NSNumber]] = motionSample.userAcceleration.x as NSNumber
            dataArray[[0, self.currentIndexInPredictionWindow, 4] as [NSNumber]] = motionSample.userAcceleration.y as NSNumber
            dataArray[[0, self.currentIndexInPredictionWindow, 5] as [NSNumber]] = motionSample.userAcceleration.z as NSNumber
            
            // Update prediction array index
            self.currentIndexInPredictionWindow += 1
            
            // If data array is full - execute a prediction
            if (self.currentIndexInPredictionWindow == ModelConstants.predictionWindowSize) {
                // Move to main thread to update the UI
                DispatchQueue.main.async {
                    // Use the predicted activity
                    self.label.text = self.activityPrediction() ?? "N/A"
                }
                // Start a new prediction window from scratch
                self.currentIndexInPredictionWindow = 0
            }
        }
    }
    
    func activityPrediction() -> String? {
        guard let dataArray = predictionWindowDataArray else { return "Error!" }
        
        // Perform prediction
        let modelPrediction = try? classifier.prediction(features: dataArray, hiddenIn: lastHiddenOutput, cellIn: lastHiddenCellOutput)
        
        // Update the state vectors
        lastHiddenOutput = modelPrediction?.hiddenOut
        lastHiddenCellOutput = modelPrediction?.cellOut
        
        // Return the predicted activity
        return modelPrediction?.activity
    }
    
    override func viewDidLayoutSubviews() {
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(180)
            make.right.left.equalToSuperview()
            make.height.equalTo(100)
        }
    
        super.viewDidLayoutSubviews()
    }
}
