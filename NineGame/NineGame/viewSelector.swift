import SwiftUI


class PresentedView: ObservableObject {
    enum AvailableViews {
        case HomeView, MNSView, GameView, FeedbackView
    }
    
    @Published var currentView: AvailableViews = .HomeView
}

struct viewSelector: View{
    @ObservedObject var model: NineViewModel
    @EnvironmentObject var presentedView: PresentedView
    
    var body: some View {
        TabView {
            switch presentedView.currentView {
            case .HomeView: HomeView(model:model).tabItem{Label("Game", systemImage: "house")}
            case .MNSView: MNSView(model:model).tabItem{Label("Game", systemImage: "house")}
            case .GameView: GameView(model:model).tabItem{Label("Game", systemImage: "house")}
            case .FeedbackView: FeedbackView(model:model).tabItem{Label("Game", systemImage: "house")}
            }
            StatisticsView(model:model).tabItem{Label("Stats", systemImage: "wrench")}
            DMview(model:model).tabItem{Label("DM", systemImage: "brain")}
        }
    }
}


