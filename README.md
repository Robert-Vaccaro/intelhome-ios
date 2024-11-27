
# IntelHome

Welcome to **IntelHome**, an iOS application that integrates object detection and smart device management to streamline your home automation experience. This project leverages CoreML, Vision, AVFoundation, and Swift to deliver a powerful and intuitive user interface for detecting and interacting with devices in real-time.

## Features

- **Object Detection**  
  Use your device's camera to detect and identify objects or devices in real time. Hover over any supported object, and the app will display bounding boxes with relevant labels.

- **Device Management**  
  Seamlessly manage smart devices such as TVs, laptops, keyboards, and more. Add, edit, and organize devices with ease.

- **User Profiles**  
  Customize and manage user profiles for a personalized experience.

- **Smart Location Tabs**  
  Organize devices by location for quick access and improved usability.

- **Modern UI/UX**  
  Sleek design with responsive animations and intuitive navigation.


## Tech Stack

- **Programming Language**: Swift

- **Frameworks**:
 - **Vision & CoreML**: For real-time object detection using YOLOv3 model variants.
 - **AVFoundation**: For camera integration and live video capture.
 - **UIKit**: For creating a modern and user-friendly interface.

- **Backend**: Node.js with Express for managing user data, devices, and locations.
- **Database**: MongoDB for persistent storage.

## Getting Started

### Prerequisites

- **Xcode**: Version 14.0 or later
- **iOS Deployment Target**: iOS 15.0 or later
- **Swift**: Version 5.5 or later

---

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-repo/intelhome.git
   cd intelhome` 

2.  **Open the project in Xcode:**
       ```bash
       open IntelHome.xcodeproj` 

    
3.  **Build and run the app on a simulator or physical device:**
    
    -   Select the desired scheme in Xcode.
    -   Click the "Run" button.

#### CoreML Model

IntelHome uses the YOLOv3 model for object detection. To replace or add optimized models:

-   Download `.mlmodel` files (can download here: [YOLOv3](https://ml-assets.apple.com/coreml/models/Image/ObjectDetection/YOLOv3/YOLOv3.mlmodel))
-   Add the model to the Xcode project.


## Usage

#### Object Detection

-   Navigate to the "Detection" tab.
-   Point your camera at a supported device.
-   Tap the bounding box to interact with the detected object.

#### Device Management

-   Add new devices via the "Add Device" button.
-   Edit or delete existing devices.

#### Location Tabs

-   View and manage devices grouped by location.



## Testing

#### Test Environment

The app is available on TestFlight for beta testing.

#### What to Test

-   Object detection accuracy and responsiveness.
-   Device management workflows.
-   Navigation and UI interactions.


## License

This project is licensed under the MIT License.
