import SwiftUI

struct HomeView: View {
    @EnvironmentObject var presentedView: PresentedView
    @ObservedObject var model: NineViewModel
    @State var reqView: Int = 0
    var body: some View {
        VStack {
            Text("The Game of Nine")

            Button("Play a Game") {
                model.resetTrial()
                presentedView.currentView = .MNSView
            }
            
            Button("Reset Model") {
                model.reset()
            }
            .foregroundColor(.red)

        }
    }
}
