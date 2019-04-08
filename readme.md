<h1 align="center">ActivityClassifier by <a href="https://skafos.ai">Skafos</a></h1>

ActivityClassifier is an example app that uses the Skafos platform for CoreML model integration and delivery on an iPhone. It's a good starting point for diving in, or a good reference for integrating Skafos in to your own app. Skafos is a platform that streamlines CoreML model updates (assets) without needing to submit a new version to the app store everytime a new model is ready for use.

Checkout our [blog series](https://medium.com/skafosai/activity-classification-for-watchos-part-3-b5a60ac6707f) where we talk more about data collection, model training, and detail the design of this simple example!

This ActivityClassifier example app specifically integrates and deploys an Activity Classifier machine learning model. [Activity Classification](https://docs.metismachine.io/docs/activity-classification) is a type of machine learning that can identify human activities from device sensor data. The example model provided in this app will try to identify walking, sitting, versus standing. For more details about how to use and customize this model, please navigate to the [Skafos Turi Activity Classifier repo on github](https://github.com/skafos/TuriActivityClassifier). 

<br>

## Getting Started

Before diving in to this example application, make sure you have setup an account at [Skafos](https://skafos.ai) and run through the [quickstart](https://dashboard.skafos.ai/quickstart/project).

## Project Setup

1. Clone or fork this repository.
2. In the project directory, run `pod install` or `pod update`
3. Open the project workspace (`.xcworkspace`)
4. In your project's settings under `General` change the following:
* Display Name
* Bundle Identifier
* Team
* Any other settings specific to your app.

## Skafos Framework Setup

1.  Inside `AppDelegate.swift` make sure to use your Skafos **publishable key** in: `Skafos.initialize`
2.  Inside `ViewController.swift` make sure the assetName you use matches the names you assign to assets delivered through Skafos.

## Now What?

Now take a moment to click on `ActivityClassifier.mlmodel` and under *Model Class* section click the arrow next 
to `ActivityClassifier` and have a peek at the class that Xcode generates from the CoreML Model. Now, inside of 
`ViewController.swift` (around line 95) take a look at the `reloadModel` function to see an example of
how to load an asset using the *Skafos* framework. While in `ViewController.swift` also look (around line 86)
for how to setup `NSNotificationCenter` to listen for Skafos notifications that the asset has been updated.

## License

Skafos swift framework uses the Apache2 license, located in the LICENSE file.

## Questions? Need Help? 

[**Signup for our Slack Channel**](https://skafosai.slack.com/)

[**Find us on Reddit**](https://reddit.com/r/skafos) 

**Contact us by email** <a href="mailto:..">dev@metismachine.com</a>

