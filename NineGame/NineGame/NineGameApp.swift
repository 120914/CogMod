import SwiftUI

 @main
struct TestApp: App {
    var modelView = NineViewModel()
    
    var body: some Scene {
        WindowGroup {
            viewSelector(model : modelView).environmentObject(PresentedView())
        }
    }
}
