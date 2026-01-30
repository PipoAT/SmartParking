# Hardware Setup Guide

## Arduino Setup

### Hardware Requirements
- Arduino board (Uno, Nano, or compatible)
- Light sensor (photoresistor)
- LED
- USB cable for Arduino connection
- Breadboard and jumper wires (optional)

### Circuit Connections
1. **Light Sensor**: Connect to analog pin A0
2. **LED**: Connect to PWM pin 9 (with appropriate resistor)
3. **Power & Ground**: Connect as needed

### Software Setup

1. Install [Arduino IDE](https://www.arduino.cc/en/software)

2. Open the sketch:
   ```
   arduino-code/Circuit_06/Circuit_06.ino
   ```

3. Select your Arduino board:
   - Tools → Board → Select your board type

4. Select the correct port:
   - Tools → Port → Select your Arduino's port
   - Windows: COMx (e.g., COM3, COM4)
   - Mac: /dev/cu.usbserial* or /dev/cu.usbmodem*
   - Linux: /dev/ttyUSB* or /dev/ttyACM*

5. Upload the sketch to your Arduino:
   - Click the Upload button (→) or press Ctrl+U

6. Open Serial Monitor (Tools → Serial Monitor) to verify data transmission
   - Set baud rate to 9600
   - You should see light level values being printed

## Backend Serial Port Configuration

The backend automatically detects Arduino serial ports, but you can manually configure it:

### Option 1: Automatic Detection (Recommended)
The backend will automatically find and use the first available Arduino port.

### Option 2: Manual Configuration
Edit `backend/appsettings.json` or set environment variables:

```json
{
  "SerialPort": {
    "PortName": "COM3",  // Your Arduino port
    "BaudRate": 9600
  }
}
```

Or use environment variables:
```bash
export SERIAL_PORT_NAME=COM3
export SERIAL_PORT_BAUD_RATE=9600
```

### Troubleshooting

#### Port Access Issues on Linux
If you get permission denied errors:
```bash
sudo usermod -a -G dialout $USER
sudo chmod 666 /dev/ttyUSB0  # or your specific port
```
Then log out and log back in.

#### Port Already in Use
Close any other applications using the port (Arduino IDE Serial Monitor, PuTTY, screen, etc.)

#### No Ports Detected
- Ensure Arduino is connected via USB
- Install Arduino drivers if needed
- Check Device Manager (Windows) or `ls /dev/tty*` (Linux/Mac)

## Testing the Integration

1. **Start the backend server**:
   ```bash
   cd backend
   dotnet run
   ```

2. **Check sensor status**:
   ```bash
   curl http://localhost:8080/api/LightSensor/status
   ```

3. **Read sensor data**:
   ```bash
   curl http://localhost:8080/api/LightSensor/read
   ```

4. **Run the mobile app**:
   ```bash
   cd mobile-ui
   flutter run
   ```

## Platform-Specific Notes

### Windows
- Ports are named COM1, COM2, COM3, etc.
- No special permissions usually needed
- Check Device Manager to find Arduino port

### macOS
- Ports are typically /dev/cu.usbserial* or /dev/cu.usbmodem*
- May need to approve USB device access
- Use `ls /dev/cu.*` to list ports

### Linux
- Ports are typically /dev/ttyUSB* or /dev/ttyACM*
- Requires user permissions (see troubleshooting above)
- Use `ls /dev/tty*` to list ports

## Development Without Hardware

The application gracefully handles missing hardware:
- Backend returns HTTP 503 when sensor is unavailable
- Mobile app continues to function without sensor data
- Use mock data for testing if needed
