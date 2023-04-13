//
//  FeedbackView.swift
//  Test
//
//  Created by J.N. Bikowski on 3/21/23.
//

import SwiftUI


struct FeedbackView: View {
    @ObservedObject var model: NineViewModel
    @EnvironmentObject var presentedView: PresentedView
    
    // TODO: get these from the model based on game that was just played
    @State var trace: String = ""
    @State var playerStrategy: String = "aggressive"
    @State var modelStrategy: String = "cooperative"
    
    @State var time: String = "3:14"
    @State var playerMNS: Int = 4
    @State var playerPoints: Int = 3
    @State var modelMNS: Int = 2
    @State var modelPoints: Int = 0
    
    var body: some View {
        VStack {
            //Text("The round took " + String(time) + " minutes")
            //   .padding()
            //    .font(.footnote)
            
            let playerInfo: String = "Your MNS was " + String(model.playerMNS) + " and you gained "
            let modelInfo: String = "The model's MNS was " + String(model.modelMNS) + " and it gained "
            VStack {
                if (model.model.success) {
                    Text("The negotiation was a success").foregroundColor(.green).bold().font(.body)
                }
                else {
                    Text("The negotiation failed").foregroundColor(.red).bold().font(.body)
                }
                if (model.roundScorePlayer > 0) {
                    Text(playerInfo)
                    + Text(String(model.roundScorePlayer)).foregroundColor(.green).bold().font(.body)
                    + Text(" points.")
                } else if (model.roundScorePlayer < 0) {
                    Text(playerInfo)
                    + Text(String(model.roundScorePlayer)).foregroundColor(.red).bold().font(.body)
                    + Text(" points.")
                } else {
                    Text(playerInfo)
                    + Text(String(model.roundScorePlayer)).font(.body)
                    + Text(" points")
                }
                
                if (model.roundScoreModel > 0) {
                    Text(modelInfo)
                    + Text(String(model.roundScoreModel)).foregroundColor(.green).bold().font(.body)
                    + Text(" points.")
                } else if (model.roundScoreModel < 0) {
                    Text(modelInfo)
                    + Text(String(model.roundScoreModel)).foregroundColor(.red).bold().font(.body)
                    + Text(" points.")
                } else {
                    Text(modelInfo)
                    + Text(String(model.roundScoreModel)).font(.body)
                    + Text(" points")
                }
            }
            .font(.footnote)

            ZStack {
                Rectangle()
                    .fill()
                    .foregroundColor(.white)
                Rectangle()
                    .stroke(lineWidth: 3)
                VStack {
                    Text("Trace of bids in the round:")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(model.getTrace()).multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .padding(.horizontal, 10.0)
            .padding(.vertical)

            VStack {
//                let range = (modelStrategy as NSString).range(of: modelStrategy)
//                let attrModelStrat = NSMutableAttributedString.init(string: modelStrategy)
//                attrModelStrat.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
//                var attributedString = AttributedString(modelStrategy)//.foregroundColor(.red)
//                modelStrategy.foregroundColor(.red)
                if (model.model.mostUsedStratModel() == "aggressive") {
                    Text("The model used the ")
                    + Text(model.model.mostUsedStratModel() + " strategy").foregroundColor(.orange).font(.body)
                } else if (model.model.mostUsedStratModel() == "cooperative") {
                    Text("The model used the ")
                    + Text(model.model.mostUsedStratModel() + " strategy").foregroundColor(.cyan).font(.body)
                } else {
                    Text("The model used the " + model.model.mostUsedStratModel() + " strategy")
                }
                
                if (model.model.strategies.last! == "aggressive") {
                    Text("It thinks you used the ")
                    + Text(model.model.strategies.last! + " strategy").foregroundColor(.orange).font(.body)
                } else if (model.model.strategies.last! == "cooperative") {
                    Text("It thinks you used the ")
                    + Text(model.model.strategies.last! + " strategy").foregroundColor(.cyan).font(.body)
                } else {
                    Text("It thinks you used the " + model.model.strategies.last! + " strategy")
                }
            }
            .font(/*@START_MENU_TOKEN@*/.footnote/*@END_MENU_TOKEN@*/)

            // buttons
            HStack {
                Button("Next Round") {
                    model.resetTrial()
                    presentedView.currentView = .MNSView
                }
                .padding()
                Button("Quit Game") {
                    //model.resetTrial()
                    presentedView.currentView = .HomeView
                }.foregroundColor(.pink)
                .padding()
            }
            .padding()
        }
    }
}
