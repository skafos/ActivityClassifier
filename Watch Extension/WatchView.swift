//
//  WatchView.swift
//  Watch Extension
//
//  Created by Skafos.ai on 4/9/19.
//  Copyright © 2019 Skafos.ai. All rights reserved.
//

import WatchKit
import Foundation
import Skafos


class WatchView: WKInterfaceController {

    @IBOutlet var activityLabel: WKInterfaceLabel!
    lazy var activity = WatchActivity(activityLabel: activityLabel)
    let assetName:String = "ActivityClassifier"
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(WatchView.reloadModel(_:)), name: Skafos.Notifications.assetUpdateNotification(assetName), object: nil)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
