# BEACN - Disaster Detection iOS App

BEACN is an iOS application that uses AI-powered image analysis to detect and classify various types of disasters and emergencies from photos.

## Features

- Real-time disaster detection from camera or photo library
- AI-powered classification of 19 different disaster types
- Local Ollama integration for privacy-focused AI processing
- Offline-capable disaster analysis

## Supported Disaster Types

The app can detect and classify the following disasters:
- Gas leak or explosion
- Traffic jam
- Protest
- Heavy storm
- Landslide
- Crime nearby
- Heavy rain
- Flood
- Fallen tree
- Accident
- Earthquake
- Fire in nearby building
- Power outage
- No water supply
- Construction
- Building collapse
- Mobile or internet down
- Broken traffic light
- Road closed

## Prerequisites

- Xcode 14.0 or later
- iOS 15.0 or later
- macOS computer for running Ollama server
- Network connection between iOS device and Ollama server

## Setup Instructions

### 1. iOS App Setup

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd beacn
   ```

2. **Open the project in Xcode:**
   ```bash
   open BEACN.xcodeproj
   ```

3. **Configure your development team:**
   - Select your project in Xcode
   - Go to "Signing & Capabilities"
   - Select your development team
   - Ensure a valid provisioning profile is selected

4. **Update the Ollama server IP address** (see [Network Configuration](#network-configuration) below)

5. **Build and run the app on your device or simulator**

### 2. Local Ollama Setup

#### Installation

**On macOS:**
```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Alternative: Install via Homebrew
brew install ollama
```

**On Linux:**
```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

**On Windows:**
Download the installer from [ollama.ai](https://ollama.ai/download)

#### Model Setup

1. **Start Ollama server:**
   ```bash
   ollama serve
   ```

2. **Pull the required model:**
   ```bash
   ollama pull gemma3:4b
   ```

3. **Verify the model is available:**
   ```bash
   ollama list
   ```

#### Configure Ollama for Network Access

By default, Ollama only accepts connections from localhost. To allow your iOS device to connect:

1. **Set environment variable to allow external connections:**
   ```bash
   export OLLAMA_HOST=0.0.0.0:11434
   ollama serve
   ```

2. **Or create a systemd service (Linux) / launchd service (macOS) with the environment variable**

3. **For permanent setup on macOS:**
   ```bash
   # Create a launch daemon
   sudo nano /Library/LaunchDaemons/com.ollama.server.plist
   ```

   Add the following content:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>Label</key>
       <string>com.ollama.server</string>
       <key>ProgramArguments</key>
       <array>
           <string>/usr/local/bin/ollama</string>
           <string>serve</string>
       </array>
       <key>EnvironmentVariables</key>
       <dict>
           <key>OLLAMA_HOST</key>
           <string>0.0.0.0:11434</string>
       </dict>
       <key>RunAtLoad</key>
       <true/>
       <key>KeepAlive</key>
       <true/>
   </dict>
   </plist>
   ```

   Load the service:
   ```bash
   sudo launchctl load /Library/LaunchDaemons/com.ollama.server.plist
   ```

## Network Configuration

### Finding Your Computer's IP Address

#### On macOS:
```bash
# Method 1: Using ifconfig
ifconfig | grep "inet " | grep -v 127.0.0.1

# Method 2: Using networksetup
networksetup -getinfo "Wi-Fi" | grep "IP address"

# Method 3: System Preferences
# Go to System Preferences > Network > Select your connection > Advanced > TCP/IP
```

#### On Linux:
```bash
# Method 1: Using ip command
ip addr show | grep "inet " | grep -v 127.0.0.1

# Method 2: Using hostname command
hostname -I

# Method 3: Using ifconfig
ifconfig | grep "inet " | grep -v 127.0.0.1
```

#### On Windows:
```cmd
# Command Prompt
ipconfig | findstr "IPv4"

# PowerShell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"}
```

### Updating the IP Address in Your iOS App

1. **Open `OllamaResponse.swift`**

2. **Find this line:**
   ```swift
   guard let url = URL(string: "http://192.168.1.8:11434/api/generate"),
   ```

3. **Replace `192.168.1.8` with your computer's IP address:**
   ```swift
   guard let url = URL(string: "http://YOUR_IP_ADDRESS:11434/api/generate"),
   ```

4. **Rebuild and run the app**

### Network Troubleshooting

1. **Ensure both devices are on the same network**
2. **Check firewall settings on your computer**
3. **Verify Ollama is running and accessible:**
   ```bash
   curl http://YOUR_IP_ADDRESS:11434/api/tags
   ```

4. **Test from your iOS device's browser:**
   Navigate to `http://YOUR_IP_ADDRESS:11434` - you should see the Ollama API documentation

## Usage

1. Launch the BEACN app on your iOS device
2. Grant camera and photo library permissions when prompted
3. Take a photo or select one from your library
4. The app will automatically analyze the image and classify any disasters detected
5. View the results and take appropriate action based on the detected disaster type

## Troubleshooting

### Common Issues

**"Failed to encode photo" Error:**
- Ensure the selected image is valid
- Try reducing image size or quality

**Network Connection Issues:**
- Verify your IP address is correct in the code
- Ensure Ollama server is running on your computer
- Check that both devices are on the same network
- Verify firewall isn't blocking port 11434

**Model Loading Issues:**
- Ensure `gemma3:4b` model is properly downloaded
- Check Ollama logs for any errors
- Try restarting the Ollama service

**App Crashes:**
- Check Xcode console for detailed error messages
- Ensure proper iOS permissions are granted
- Verify the app has network access permissions

## Configuration Options

### Changing the AI Model

To use a different Ollama model, update the model name in `OllamaResponse.swift`:

```swift
let payload: [String: Any] = [
    "model": "your-preferred-model", // Change this line
    // ... rest of payload
]
```

Available models can be found at [Ollama Models](https://ollama.ai/library).

### Adjusting Image Quality

Modify the JPEG compression quality in `OllamaResponse.swift`:

```swift
guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
    // Change 0.8 to your preferred quality (0.1 - 1.0)
}
```

Lower values = smaller file size, faster processing, lower quality
Higher values = larger file size, slower processing, higher quality

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

[Add your license information here]

## Support

For issues and questions:
- Check the troubleshooting section above
- Review Ollama documentation at [ollama.ai](https://ollama.ai)
- Open an issue in this repository