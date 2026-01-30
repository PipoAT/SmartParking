// Platform-specific implementation for web
String getDefaultApiUrl() {
  // For web, use relative URL or current host
  // This assumes the API is served from the same origin
  // Or use window.location.origin if needed
  return 'http://localhost:8080/api';
}
