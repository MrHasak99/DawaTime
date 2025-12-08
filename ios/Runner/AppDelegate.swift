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
    
    // Setup method channel after a delay to ensure window is ready
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
      if let controller = self?.window?.rootViewController as? FlutterViewController {
        self?.methodChannel = FlutterMethodChannel(name: "com.dawatime/carplay", binaryMessenger: controller.binaryMessenger)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  static func getMethodChannel() -> FlutterMethodChannel? {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      return appDelegate.methodChannel
    }
    return nil
  }
}
