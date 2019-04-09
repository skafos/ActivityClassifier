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


class ViewController: UIViewController {
    
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
    
    // Initialize the activity modeling class and asset name from Skafos
    lazy var activity = Activity(label: label)
    let assetName:String = "ActivityClassifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.title = "Activity Classifier"
        
        // Make sure nothing is running through the model yet
        activity.stopDeviceMotion()
        
        // Skafos load cached asset
        // If you pass in a tag, Skafos will make a network request to fetch the asset with that tag
        Skafos.load(asset: assetName, tag: "latest") { (error, asset) in
            // Log the asset in the console
            console.info(asset)
            guard error == nil, let model = asset.model else {
                console.error("Skafos load asset error: \(error?.localizedDescription ?? "No model available in the asset")")
                return
            }
            // Assign model to the classifier class
            self.activity.classifier.model = model
            
            // Start running the app
            self.activity.startDeviceMotion()
        }

        /***
         Listen for changes in an asset with the given name. A notification is triggered anytime an
         asset is downloaded from the servers. This can happen in response to a push notification
         or when you manually call Skafos.load with a tag like above.
         ***/
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.reloadModel(_:)), name: Skafos.Notifications.assetUpdateNotification(assetName), object: nil)
    }

    override func viewDidLayoutSubviews() {
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(180)
            make.right.left.equalToSuperview()
            make.height.equalTo(100)
        }
    
        super.viewDidLayoutSubviews()
    }
    
    @objc func reloadModel(_ notification:Notification) {
        // Stop device motion briefly
        activity.stopDeviceMotion()
       
        // Load new asset
        Skafos.load(asset: assetName) { (error, asset) in
            // Log the asset in the console
            console.info(asset)
            guard error == nil else {
                console.error("Skafos load asset error: \(String(describing: error))")
                return
            }
            guard let model = asset.model else {
                console.info("No model available in the asset")
                return
            }
            // Assign model to the classifier class
            self.activity.classifier.model = model
            
            // Start running the app
            self.activity.startDeviceMotion()
        }
    }
}



