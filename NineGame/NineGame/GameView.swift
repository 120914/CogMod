//
//  ContentView.swift
//  Negotiation
//
//  Created by J.N. Bikowski on 2/24/23.
//
//
import SwiftUI

struct GameView: View {
    @ObservedObject var model: NineViewModel
    @EnvironmentObject var presentedView: PresentedView
    @State var finalOffer: Bool = false
    @State var playerAction: Int = 0
    @State var playerMNS: Int = 0
    @State var modelMNS: Int = 1
    @State var playerScore: Int = 0
    @State var modelScore: Int = 0
    @State private var GameViewSwitch: Int = 0
    var body: some View {

        VStack {
            // Clock
            //HStack {
                //Text("⏱")
                //Text(String(model.time)) // TODO: start keeping track of game time here
            // }
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
                        Text("Model score: \(Int(model.model.modelScore))")
                        //Text("Player score: \(Int(model.model.playerScore))")// TODO: add score value here
                        Text("Model MNS: \(Int(model.suggestedModelMNS))")  // TODO: add model given MNS
                    }
                }
                ZStack {
                    Rectangle()
                        .fill()
                        .foregroundColor(.white)
                    Rectangle()
                        .stroke(lineWidth: 3)
                    Text(model.bidString) // TODO: add previous bids info
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
                    Text("I want:")
                    HStack {  // TODO: value of var "playerAction" knows which value pressed button is
                        GameButtonView(playerMNS: model.playerMNS, buttonNr: 1, playerAction: $playerAction)
                        GameButtonView(playerMNS: model.playerMNS, buttonNr: 2, playerAction: $playerAction)
                        GameButtonView(playerMNS: model.playerMNS, buttonNr: 3, playerAction: $playerAction)
                        GameButtonView(playerMNS: model.playerMNS, buttonNr: 4, playerAction: $playerAction)
                        GameButtonView(playerMNS: model.playerMNS, buttonNr: 5, playerAction: $playerAction)
                        GameButtonView(playerMNS: model.playerMNS, buttonNr: 6, playerAction: $playerAction)
                        GameButtonView(playerMNS: model.playerMNS, buttonNr: 7, playerAction: $playerAction)
                        GameButtonView(playerMNS: model.playerMNS, buttonNr: 8, playerAction: $playerAction)
                        GameButtonView(playerMNS: model.playerMNS, buttonNr: 9, playerAction: $playerAction)
                    }
                    FinalOfferToggle(finalOffer: $finalOffer)
                }
            }
            .padding()
            
            // Buttons
            VStack {  // TODO: add actions
                HStack {
                    Button("Submit Offer") {
                        if (model.model.modelFinal == false) {
                            if (playerAction > 0)
                            {
                                model.chooseBid(playerAction, finalOffer)
                                if (model.flag == 1 || model.flag == 2){
                                    presentedView.currentView = .FeedbackView
                                }
                                playerAction = 0
                            }
                            else{
                                print("Please pick a bid for this round!")
                            }
                        } else
                        {
                            print("you cannot counter bid on a final offer!")
                        }
                    }
                    .padding()
                    Button("Accept Offer") {
                        if (model.model.roundModelInfo["strategy"]!.count > 1){
                            model.acceptOffer()
                            presentedView.currentView = .FeedbackView
                        }
                
                    }
                    .padding()
                    Button("Decline Offer") {
                        if (model.model.roundModelInfo["strategy"]!.count > 1){
                            model.declineOffer()
                            presentedView.currentView = .FeedbackView
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                Button("Quit Round") {
                    model.model.success = false
                    presentedView.currentView = .FeedbackView
                    //model.model.resetModelTrial()
                }
                .foregroundColor(.red)
                .padding()
            }

            // Scores
            HStack { // TODO: add in these values
                Text("MNS Value: " + String(model.playerMNS))
                    .padding([.bottom, .trailing], 30.0)
                Text("Score: " + String(model.model.playerScore))
                    .padding([.leading, .bottom], 30.0)
            }
            .padding()
        }
        .padding()
    }
}

struct FinalOfferToggle: View {
    @Binding var finalOffer: Bool
    // TODO: make sure that can click square as well as text
    var body: some View {
        if (finalOffer) {
            HStack {
                Rectangle()
                    .foregroundColor(.black)
                    .frame(width: 10.0, height: 10.0)
                
                Button(action: { withAnimation {
                        self.finalOffer.toggle()
                } }) {
                    Text("This is my final offer")
                }
            }
        } else {
            HStack {
                Rectangle()
                    .stroke()
                    .frame(width: 10.0, height: 10.0)
                Button(action: { withAnimation {
                        self.finalOffer.toggle()
                } }) {
                    Text("This is my final offer")
                }
            }
        }
    }
}

struct GameButtonView: View {
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
                        .frame(width: 25.0, height: 25.0)
                } else {
                    Circle()
                        .strokeBorder(.pink, lineWidth: 2)
                        .background(Circle().foregroundColor(.white))
                        .frame(width: 25.0, height: 25.0)
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
                        .frame(width: 25.0, height: 25.0)
                } else {
                    Circle()
                        .strokeBorder(.black, lineWidth: 2)
                        .background(Circle().foregroundColor(.white))
                        .frame(width: 25.0, height: 25.0)
                }
                Button(String(buttonNr)) { playerAction = buttonNr }
                    .frame(width: 20.0, height: 20.0)
            }
        }
    }
}

