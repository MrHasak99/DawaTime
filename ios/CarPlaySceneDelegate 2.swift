import CarPlay
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                   didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        
        // Create list items for medication reminders
        let listItem1 = CPListItem(text: "Morning Medication", detailText: "8:00 AM")
        let listItem2 = CPListItem(text: "Afternoon Medication", detailText: "2:00 PM")
        let listItem3 = CPListItem(text: "Evening Medication", detailText: "8:00 PM")
        
        // Create a list section
        let section = CPListSection(items: [listItem1, listItem2, listItem3])
        
        // Create a list template
        let listTemplate = CPListTemplate(title: "DawaTime Reminders", sections: [section])
        
        // Set the root template
        interfaceController.setRootTemplate(listTemplate, animated: true, completion: nil)
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                   didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
}
