import CarPlay
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                   didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        
        // Request medications from Flutter
        if let methodChannel = AppDelegate.getMethodChannel() {
            methodChannel.invokeMethod("getMedications", arguments: nil) { [weak self] result in
                guard let self = self else { return }
                
                if let medications = result as? [[String: Any]] {
                    self.displayMedications(medications, on: interfaceController)
                } else {
                    // Fallback to empty list if no medications
                    self.displayEmptyState(on: interfaceController)
                }
            }
        } else {
            // Fallback if method channel not available
            self.displayEmptyState(on: interfaceController)
        }
    }
    
    func displayMedications(_ medications: [[String: Any]], on interfaceController: CPInterfaceController) {
        var listItems: [CPListItem] = []
        
        for med in medications {
            let name = med["name"] as? String ?? "Unknown"
            let time = med["notifyTime"] as? String ?? "No time set"
            let dosage = med["dosage"] as? Double ?? 0.0
            let type = med["typeOfMedication"] as? String ?? ""
            
            let detailText = "\(time) - \(dosage) \(type)"
            let listItem = CPListItem(text: name, detailText: detailText)
            listItems.append(listItem)
        }
        
        if listItems.isEmpty {
            displayEmptyState(on: interfaceController)
        } else {
            let section = CPListSection(items: listItems)
            let listTemplate = CPListTemplate(title: "DawaTime Reminders", sections: [section])
            interfaceController.setRootTemplate(listTemplate, animated: true, completion: nil)
        }
    }
    
    func displayEmptyState(on interfaceController: CPInterfaceController) {
        let emptyItem = CPListItem(text: "No medications added", detailText: "Add medications in the app")
        let section = CPListSection(items: [emptyItem])
        let listTemplate = CPListTemplate(title: "DawaTime Reminders", sections: [section])
        interfaceController.setRootTemplate(listTemplate, animated: true, completion: nil)
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                   didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
}
