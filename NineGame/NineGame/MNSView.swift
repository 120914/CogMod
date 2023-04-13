import SwiftUI

struct MNS_Previews: PreviewProvider {
    static var previews: some View {
        MNSView(model: NineViewModel())
    }
}

struct MNSView: View {
    @ObservedObject var model: NineViewModel
    @State var playerAction: Int = 0
    @EnvironmentObject var presentedView: PresentedView
    var body: some View {

        VStack {
            // Clock
//            HStack {
//                Text("⏱")
//                Text("time") // TODO: start keeping track of game time here
//            }
            // Info View
            HStack {
                ZStack {
                    Rectangle()
                        .fill()
                        .foregroundColor(.white)
                    Rectangle()
                        .stroke(lineWidth: 3)
                    VStack {
                        Text("🤖")
                            .font(.largeTitle)
                        Text("Model score: \(model.model.modelScore)") // TODO: add score value here
                        Text("Model MNS: \(Int(model.suggestedModelMNS))")
                    }
                }
                ZStack {
                    Rectangle()
                        .fill()
                        .foregroundColor(.white)
                    Rectangle()
                        .stroke(lineWidth: 3)
                    Text("Exchange the MNS")
                }
            }
            .padding()
            
            // Submission field
            ZStack {
                Rectangle()
                    .fill()
                    .foregroundColor(.white)
                Rectangle()
                    .stroke(lineWidth: 3)
                VStack {
                    Text("My MNS is:")
                    HStack {  // TODO: get clicked MNS value from variable "playerAction"
                        MNSButtonView(playerMNS: model.playerMNS, buttonNr: 1, playerAction: $playerAction)
                        MNSButtonView(playerMNS: model.playerMNS, buttonNr: 2, playerAction: $playerAction)
                        MNSButtonView(playerMNS: model.playerMNS, buttonNr: 3, playerAction: $playerAction)
                        MNSButtonView(playerMNS: model.playerMNS, buttonNr: 4, playerAction: $playerAction)
                        MNSButtonView(playerMNS: model.playerMNS, buttonNr: 5, playerAction: $playerAction)
                        MNSButtonView(playerMNS: model.playerMNS, buttonNr: 6, playerAction: $playerAction)
                        MNSButtonView(playerMNS: model.playerMNS, buttonNr: 7, playerAction: $playerAction)
                        MNSButtonView(playerMNS: model.playerMNS, buttonNr: 8, playerAction: $playerAction)
                        MNSButtonView(playerMNS: model.playerMNS, buttonNr: 9, playerAction: $playerAction)
                    }
                }
            }
            .padding()
            
            // Buttons
            HStack {  // TODO: add actions
                Button("Submit MNS") {
                    if (playerAction > 0) {
                        model.chooseMNS(playerAction)
                        presentedView.currentView = .GameView
                    }
                    else {
                        print("Please make a claim first!")
                    }
                }
                .padding()
                Button("Quit Game") {
                    presentedView.currentView = .HomeView
                }
                .foregroundColor(.red)
                .padding()
            }
            .padding(.horizontal)

            // Scores
            HStack { // TODO: add in these values
                Text("MNS Value: " + "\(model.model.playerMNS)")
                    .padding([.bottom, .trailing], 30.0)
                Text("Score: " + "\(model.model.playerScore)")
                    .padding([.leading, .bottom], 30.0)
            }
            .padding()
        }
        .padding()
    }
}


struct MNSButtonView: View {
    var playerMNS: Int
    @State var buttonNr: Int
    @Binding var playerAction: Int
    var body: some View {
//        let _ = print(playerAction, buttonNr)
        if (buttonNr < playerMNS) {
            ZStack {
                if (playerAction == buttonNr) {
                    Circle()
                        .strokeBorder(.pink, lineWidth: 2)
                        .background(Circle().foregroundColor(Color(red:1.0, green:0.84, blue:0.46)))
                        .frame(width: 27.0, height: 27.0)
                } else {
                    Circle()
                        .strokeBorder(.pink, lineWidth: 2)
                        .background(Circle().foregroundColor(.white))
                        .frame(width: 27.0, height: 27.0)
                }
                Button(String(buttonNr)) { playerAction = buttonNr }
                    .frame(width: 20.0, height: 20.0)
                    .foregroundColor(.pink)
            }
        } else {
            ZStack {
                if (playerAction == buttonNr) {
                    Circle()
                        .strokeBorder(.black, lineWidth: 2)
                        .background(Circle().foregroundColor(Color(red:0.4627, green:0.8392, blue:1.0)))
                        .frame(width: 27.0, height: 27.0)
                } else {
                    Circle()
                        .strokeBorder(.black, lineWidth: 2)
                        .background(Circle().foregroundColor(.white))
                        .frame(width: 27.0, height: 27.0)
                }
                Button(String(buttonNr)) { playerAction = buttonNr }
                    .frame(width: 20.0, height: 20.0)
            }
        }
    }
}
