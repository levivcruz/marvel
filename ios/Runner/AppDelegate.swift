import Flutter
import UIKit
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()
    
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup Method Channel for Analytics
    setupAnalyticsMethodChannel()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func setupAnalyticsMethodChannel() {
    let controller = window?.rootViewController as! FlutterViewController
    let analyticsChannel = FlutterMethodChannel(
      name: "com.marvel.analytics",
      binaryMessenger: controller.binaryMessenger
    )
    
    analyticsChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "initialize":
        // Firebase já inicializado
        result(nil)
        
      case "trackEvent":
        self?.handleTrackEvent(call: call, result: result)
        
      case "setUserProperty":
        self?.handleSetUserProperty(call: call, result: result)
        
      case "trackScreen":
        self?.handleTrackScreen(call: call, result: result)
        
      case "trackError":
        self?.handleTrackError(call: call, result: result)
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  private func handleTrackEvent(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let eventName = args["eventName"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Event name is required", details: nil))
      return
    }
    
    let parameters = args["parameters"] as? [String: Any] ?? [:]
    
    // Convert parameters to Analytics-compatible format
    var analyticsParameters: [String: Any] = [:]
    for (key, value) in parameters {
      if let stringValue = value as? String {
        analyticsParameters[key] = stringValue
      } else if let intValue = value as? Int {
        analyticsParameters[key] = NSNumber(value: intValue)
      } else if let doubleValue = value as? Double {
        analyticsParameters[key] = NSNumber(value: doubleValue)
      } else if let boolValue = value as? Bool {
        analyticsParameters[key] = NSNumber(value: boolValue)
      } else {
        analyticsParameters[key] = String(describing: value)
      }
    }
    
    Analytics.logEvent(eventName, parameters: analyticsParameters)
    result(nil)
  }
  
  private func handleSetUserProperty(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let name = args["name"] as? String,
          let value = args["value"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Name and value are required", details: nil))
      return
    }
    
    Analytics.setUserProperty(value, forName: name)
    result(nil)
  }
  
  private func handleTrackScreen(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let screenName = args["screenName"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Screen name is required", details: nil))
      return
    }
    
    Analytics.logEvent(AnalyticsEventScreenView, parameters: [
      AnalyticsParameterScreenName: screenName,
      AnalyticsParameterScreenClass: "Flutter"
    ])
    result(nil)
  }
  
  private func handleTrackError(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let error = args["error"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Error message is required", details: nil))
      return
    }
    
    let stackTrace = args["stackTrace"] as? String
    let fatal = args["fatal"] as? Bool ?? false
    
    var parameters: [String: Any] = [
      "error_message": error,
      "fatal": fatal ? "true" : "false"
    ]
    
    if let stackTrace = stackTrace {
      parameters["stack_trace"] = stackTrace
    }
    
    Analytics.logEvent("app_exception", parameters: parameters)
    result(nil)
  }
}