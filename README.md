# Zoom's Video SDK UI Toolkit

The Zoom Video SDK UI Toolkit is a prebuilt video chat user interface powered by the Zoom Video SDK.

The use of this UI Took Kit is subject to the [Video SDK terms of use](https://explore.zoom.us/en/video-sdk-terms/). Copyright 2023 Zoom Video Communications, Inc. All rights reserved.

<br>

## Prerequisites

- Xcode
- A physical 64-bit iOS device (iPhone or iPad) with iOS version 11.0+
- A Zoom account with Video SDK credentials
- A validated provisioning profile certificate

<br>

## Installation

Currently, the Zoom Video SDK UI Toolkit is available through Swift Package Manager and will also be available in Cocoapod soon.

```
https://github.com/zoom/zoom-video-sdk-ui-toolkit-ios.git
```

<br>

## Usage

Simply add Zoom Video SDK UI Toolkit into your View Controller by simply follow a quick 2 steps process.

### Step 1. Create the Connection Data

Create the ZoomConnectionData that takes in required parameters such as JWT, session name and username (display name). Refer to our authorization link [here](https://developers.zoom.us/docs/video-sdk/auth/#generate-a-video-sdk-jwt) for more information.

```Swift
let connectionData = ZoomConnectionData(jwtToken: String, sessionName: String, userName: String)

// OR if password is required - you can add the optional sessionPassword parameter
let connectionData = ZoomConnectionData(jwtToken:String, sessionName: String, sessionPassword: String, userName: String)
```

<br>

### Step 2. Create the Zoom Video View Controller and present it

Create the ZoomVideoVC that takes in the **connectionData** created earlier.

```Swift
let zoomVideoToolkitVC = ZoomVideoVC(connectionData: zoomConnectionData)
zoomVideoToolkitVC.modalPresentationStyle = .fullScreen
present(zoomVideoToolkitVC, animated: true)
```

<br>

## Need help?

If you're looking for help, try [Developer Support](https://devsupport.zoom.us/hc/en-us) or our [Developer Forum](https://devforum.zoom.us/). Priority support is also available with [Premier Developer Support](https://explore.zoom.us/docs/en-us/developer-support-plans.html) plans.

<br>

---

Copyright 2023 Zoom Video Communications, Inc. All rights reserved.
