import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup method channel for CarPlay
    if let controller = window?.rootViewController as? FlutterViewController {
      methodChannel = FlutterMethodChannel(name: "com.dawatime/carplay", binaryMessenger: controller.binaryMessenger)
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Make method channel accessible to CarPlaySceneDelegate
  static func getMethodChannel() -> FlutterMethodChannel? {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      return appDelegate.methodChannel
    }
    return nil
  }
}
