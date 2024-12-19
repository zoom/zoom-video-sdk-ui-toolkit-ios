# Zoom Video SDK UI toolkit

The [Zoom Video SDK UI toolkit](https://developers.zoom.us/docs/video-sdk/ios/ui-toolkit/) is a prebuilt video chat user interface powered by the Zoom Video SDK.

The UI toolkit enables you to instantly start using a core set of Video SDK features in your app, including:
- Feature configuration
- Join and leave sessions
- Video on or off
- Front or back camera
- Mute and unmute
- Session chat (group and private)
- Active speaker and gallery view
- Participant management (with host and manager role)
- Virtual background
- Portrait and landscape support
- Screen sharing (full-screen)
- Cloud Recording (Additional license required)
- Live Streaming Support
- CRC Info and Invite (Additional license required)

These features are available in both the default and components UI.

The use of this UI Toolkit is subject to the [Video SDK terms of service](https://www.zoom.com/en/trust/video-sdk-terms/). Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

## Sample App

Visit the [Zoom Video SDK UI toolkit Sample Project](https://github.com/zoom/videosdk-ui-toolkit-ios-sample). 

## Prerequisites

- Xcode
- A physical 64-bit iOS device (iPhone or iPad) with iOS version 13.0+
- A validated provisioning profile certificate
- A [Video SDK developer account](https://developers.zoom.us/docs/video-sdk/developer-accounts/) with credentials

## Installation

The Zoom Video SDK UI toolkit is available in both the Swift Package Manager (SPM) and Cocoapod.

For SPM, there are 2 branches available:
- main: SPM with all features
- essential: SPM with all features except for Virtual Background and Screen Share.

The current branch you are viewing right now is the *essential* branch and we do have another branch named *main* that consists of all 5 xcframeworks (ZoomVideoSDK, ZoomVideoSDKUIToolkit, ZoomVideoSDKScreenShare, CptShare, and zoomcml) with all the UI toolkit features listed earlier. However, if you do not need the virtual background and screen sharing feature, you can continue using this *essential* branch instead of the *main* branch.

For Cocoapod:

```
// All features
pod 'ZoomVSDKUIToolkitiOS/ZoomVideoSDK'
pod 'ZoomVSDKUIToolkitiOS/ZoomVideoSDKUIToolkit'
pod 'ZoomVSDKUIToolkitiOS/CptShare'
pod 'ZoomVSDKUIToolkitiOS/zoomcml'
    
// Essential features without Virtual Background and Screen Share
pod 'ZoomVSDKUIToolkitiOS/ZoomVideoSDK'
pod 'ZoomVSDKUIToolkitiOS/ZoomVideoSDKUIToolkitEssential'
```

For screen sharing to works, you will need to follow closely on our documentation on [Screen Sharing's Broadcast the device screen](https://developers.zoom.us/docs/video-sdk/ios/share/#broadcast-the-device-screen). Do take note that the CptShare.xcframework is already in the ZoomVideoSDKUIToolkit-iOS library so you do not need to add it separately as it has already been taken care of but you do still need to add the ZoomVideoSDKScreenShare library to your Broadcast Extension target.

## Required App Permissions

For the camera and mic to work during the session, add the following:

| Permission Required | Optional | Permission Key | Description |
| :------------------ | :------- | :------------- | :---------- |
| Camera              | Required | NSCameraUsageDescription | Required for Video |
| Microphone          | Required | NSMicrophoneUsageDescription | Required for Audio |
| Bluetooth           | Required | NSBluetoothPeripheralUsageDescription | Required for Bluetooth audio devices |

## Authorize

Learn how to use your credentials to [authenticate](https://developers.zoom.us/docs/video-sdk/auth/#generate-a-video-sdk-jwt) so you can connect.

See the [Video SDK Auth Endpoint Sample](https://github.com/zoom/videosdk-sample-signature-node.js) for a sample app that shows how to quickly, easily, and securely generate a Video SDK JWT.

## Usage

After understanding the authorization process, we can simply add the Zoom Video SDK UI toolkit to your View Controller by following the 3 steps below.

### Step 1. Create the SessionContext and InitParams

Create the **SessionContext** that takes in the required parameters such as JWT, session name and username (display name). If your session requires a password, you can use the password parameter.

```Swift
let sessionContext = SessionContext(jwt: String, sessionName: String, username: String)

// OR if password is required
let sessionContext = SessionContext(jwt: String, sessionName: String, sessionPassword: String?, username: String)

/*
 Under the InitParams, all parameters are optional:
 1. If your session allows screen sharing, you will need to add the App Group ID parameter,
 2. By default the UI Toolkits comes with all available features (with some features require additional license). If you will like to only use some of these features, you will need to add the features you want under the features parameter.
 3. If your session allows and can perform cloud recording, you can add in a customized consent message.
 4. If your session allows and can perform live streaming, you can add in a customized consent message.
 */
let sessionContext  = SessionContext(jwt: String, sessionName: String, username: String), initParams: InitParams(appGroupId: String?, features: [UIToolkitFeature]?, recordingConsentMessage: String?, liveStreamConsentMessage: liveStreamingConsentMessage))
```

### Step 2A. (Default UI) Create the Zoom Video View Controller and present it

Create the **UIToolkitVC** that takes in the **sessionContext** and present it.

```Swift
let vc = UIToolkitVC(sessionContext: sessionContext)
vc.delegate = self
vc.modalPresentationStyle = .fullScreen
present(toolkitVC, animated: true)
```

### Step 2B. (Component UI) 

Refer to our [documentation](https://developers.zoom.us/docs/video-sdk/ios/ui-toolkit/).

### Step 3. Delegate

There is a delegate class **UIToolkitDelegate** which consists of important callbacks such as error, view is loaded and dismissed.

```Swift
extension YourViewController: UIToolkitDelegate {
    func onError(_ errorType: UIToolkitError) {
        print("Sample VC onError Callback: \(errorType.rawValue) -> \(errorType.description)")
    }
    
    /*
     Default UI
     */
    func onViewLoaded() {
        print("Sample VC onViewLoaded")
    }
    
    func onViewDismissed() {
        print("Sample VC onViewDismissed")
    }
    
    /*
     Component UI
     */
    func startJoinSessionSuccessed() {
        print("Sample VC Start/Join Session Successfully")
        performSegue(withIdentifier: "goCustomVC", sender: nil)
    }
    
    func leaveSession(reason: ZoomVideoSDKSessionLeaveReason) {
        print("Sample VC Left Session, reason: \(reason)")
    }
}
```

See the [Zoom Video SDK UI toolkit](https://developers.zoom.us/docs/video-sdk/ios/ui-toolkit/) documentation for more.

## Need help?

If you're looking for help, try [Developer Support](https://devsupport.zoom.us/hc/en-us) or our [Developer Forum](https://devforum.zoom.us/). Priority support is also available with [Premier Developer Support](https://explore.zoom.us/docs/en-us/developer-support-plans.html) plans.

<br> 

---

Copyright 2024 Zoom Video Communications, Inc. All rights reserved.
