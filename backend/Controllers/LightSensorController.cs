using System;
using System.IO.Ports;
using System.Linq;
using System.Runtime.InteropServices;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

[Route("api/[controller]")]
[ApiController]
public class LightSensorController : ControllerBase
{
    private static SerialPort? _serialPort;
    private static readonly object _lock = new object();
    private readonly IConfiguration _configuration;
    private readonly ILogger<LightSensorController> _logger;

    public LightSensorController(IConfiguration configuration, ILogger<LightSensorController> logger)
    {
        _configuration = configuration;
        _logger = logger;

        lock (_lock)
        {
            if (_serialPort == null || !_serialPort.IsOpen)
            {
                InitializeSerialPort();
            }
        }
    }

    private void InitializeSerialPort()
    {
        try
        {
            // Try to get port from configuration first
            string? portName = _configuration["SerialPort:PortName"];
            int baudRate = _configuration.GetValue<int>("SerialPort:BaudRate", 9600);

            // If not configured, try to auto-detect
            if (string.IsNullOrEmpty(portName))
            {
                portName = AutoDetectSerialPort();
            }

            if (!string.IsNullOrEmpty(portName))
            {
                _serialPort = new SerialPort(portName, baudRate)
                {
                    ReadTimeout = 1000,
                    WriteTimeout = 1000
                };
                _serialPort.Open();
                _logger.LogInformation($"Serial port {portName} opened successfully at {baudRate} baud.");
            }
            else
            {
                _logger.LogWarning("No serial port configured or detected. Sensor features will be unavailable.");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError($"Failed to initialize serial port: {ex.Message}");
            _serialPort = null;
        }
    }

    private string? AutoDetectSerialPort()
    {
        try
        {
            var availablePorts = SerialPort.GetPortNames();
            
            if (availablePorts.Length == 0)
            {
                _logger.LogWarning("No serial ports detected on this system.");
                return null;
            }

            // Try to intelligently select a port based on platform
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                // On Windows, prefer COM3 or the first available COM port
                var preferredPort = availablePorts.FirstOrDefault(p => p == "COM3") 
                                 ?? availablePorts.First();
                _logger.LogInformation($"Auto-detected Windows serial port: {preferredPort}");
                return preferredPort;
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux) || 
                     RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
            {
                // On Linux/Mac, prefer USB serial ports (ttyUSB*, ttyACM*)
                var preferredPort = availablePorts.FirstOrDefault(p => p.Contains("ttyUSB") || p.Contains("ttyACM"))
                                 ?? availablePorts.First();
                _logger.LogInformation($"Auto-detected Unix serial port: {preferredPort}");
                return preferredPort;
            }

            // Default to first available port
            var defaultPort = availablePorts.First();
            _logger.LogInformation($"Auto-detected serial port: {defaultPort}");
            return defaultPort;
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error during serial port auto-detection: {ex.Message}");
            return null;
        }
    }

    [HttpGet("read")]
    public IActionResult ReadSensor()
    {
        if (_serialPort == null)
        {
            return StatusCode(503, new { error = "Serial port not initialized. Sensor hardware may not be connected." });
        }

        if (!_serialPort.IsOpen)
        {
            // Try to reopen the port
            try
            {
                _serialPort.Open();
            }
            catch (Exception ex)
            {
                return StatusCode(503, new { error = $"Serial port is closed and could not be reopened: {ex.Message}" });
            }
        }

        try
        {
            // Clear any existing data in buffer
            _serialPort.DiscardInBuffer();
            
            // Read a line from the sensor
            string data = _serialPort.ReadLine().Trim();
            
            // Validate that we got numeric data
            if (int.TryParse(data, out int lightLevel))
            {
                return Ok(new { lightLevel = lightLevel, timestamp = DateTime.UtcNow });
            }
            else
            {
                return BadRequest(new { error = "Invalid sensor data received", rawData = data });
            }
        }
        catch (TimeoutException)
        {
            return StatusCode(408, new { error = "Timeout reading from serial port. Sensor may not be responding." });
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error reading from serial port: {ex.Message}");
            return StatusCode(500, new { error = $"Error reading from serial port: {ex.Message}" });
        }
    }

    [HttpGet("status")]
    public IActionResult GetStatus()
    {
        if (_serialPort == null)
        {
            return Ok(new 
            { 
                connected = false, 
                message = "Serial port not initialized",
                availablePorts = SerialPort.GetPortNames()
            });
        }

        return Ok(new 
        { 
            connected = _serialPort.IsOpen,
            portName = _serialPort.PortName,
            baudRate = _serialPort.BaudRate,
            availablePorts = SerialPort.GetPortNames()
        });
    }
}
