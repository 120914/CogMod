import SwiftUI

class NineViewModel: ObservableObject {
    
    @Published var model: NineModel
    
    init(){
        model = NineModel()
        self.model.bidString = getBidsString()
        //model.resetModelTrial()
    }
    
    func reset() {
        model.reset()
        resetTrial()
    }
    
    func resetQuit(){
        let chunk = createChunk(model.model, ["isa", "state"], [Value.Text("game-state"), Value.Text("reset")])
        model.model.buffers["action"] = chunk
        model.model.run()
        model.resetModelTrial()
    }

    var flag: Int?
    var playerMNS: Int {model.playerMNS}
    var modelMNS: Int {model.modelMNS}
    var suggestedModelMNS: Double { model.suggestedModelMNS }
    var bid: Int? { model.highlightedBid }
    var highlightedMNS: Int?
    var playerBid: Int?
    var modelBid: Int?
    var bidString: String { model.bidString }
    var selection = "opening1"
    var roundScorePlayer = 0
    var roundScoreModel = 0
    
    func resetTrial() {
        roundScoreModel = 0
        roundScorePlayer = 0
        model.resetModelTrial()
    }
    
    func getTrace() -> String {
        var trace = ""
        var playerO = 0.0
        var modelO = 0.0
        
        if (model.roundPlayerInfo["type"]!.count > 1 && model.roundModelInfo["type"]!.count > 1) {
            for i in 1...model.roundPlayerInfo["type"]!.count-1 {
                if (model.roundPlayerInfo["type"]![i] == "decision") {
                    trace += "😀: I \(model.roundPlayerInfo["bids"]![i]).\n"
                    break
                }
                playerO += Double(model.roundPlayerInfo["bids"]![i]) ?? 0.0
                trace += "😀: I want to have \(Int(playerO)) points.\n"
                if (model.roundModelInfo["type"]![i] != "decision") {
                    modelO += Double(model.roundModelInfo["bids"]![i]) ?? 0.0
                    trace += "🤖: I want to have \(Int(modelO)) points.\n"
                }
                else {
                    trace += "🤖: I \(model.roundModelInfo["bids"]![i]).\n"
                }
            }
        }
        return trace
    }
    
    func getBidsString() -> String {
        var sBid = ""
        if (self.playerBid != nil)
        {
            sBid += "😀 wants: \(self.playerBid!)\n"
        }
        else{
            sBid += "😀 wants: _\n"
        }
        if (self.modelBid != nil)
        {
            sBid += "🤖 wants: \(self.modelBid!)\n"
        }
        else{
            sBid += "🤖 wants: _\n"
        }
        return sBid
    }
    func chooseMNS(_ mns: Int) {
        model.chooseMNS(mns)
    }
    
    func highlightBid(_ bid: Int?) {
        model.highlightedBid = bid
    }
    
    func chooseBid(_ bid: Int, _ f: Bool) {
        self.modelBid = nil
        self.playerBid = bid
        self.flag = model.chooseBid(bid, final: f)
        self.modelBid = self.model.roundModelBids.last
        self.model.bidString = self.getBidsString()
        self.playerBid = nil
        
        if (self.flag == 1) {
            updatePlayerStrategyHistory()
            roundScoreModel = (9 - self.model.roundPlayerBids.last!) - self.model.modelMNS
            roundScorePlayer = self.model.roundPlayerBids.last! - self.model.playerMNS
            self.model.modelScore += (roundScoreModel)
            self.model.playerScore += (roundScorePlayer)
            model.strategies.append(model.mostUsedStratPlayer())
            updateDM()
            model.success = true
            model.totalGames += 1
        }
        else if (self.flag == 2) {
            model.success = false
            updatePlayerStrategyHistory()
            self.model.bidString = "Model rejected your bid"
            
            roundScoreModel = 0
            roundScorePlayer = 0
             
            let chunk = model.model.generateNewChunk()
            chunk.setSlot(slot: "isa", value: "game-state")
            chunk.setSlot(slot: "state", value: "reset")
            
            model.model.buffers["action"] = chunk
            model.model.run()
            
            //resetTrial()
            model.gamesQuit += 1
            model.totalGames += 1
            model.strategies.append(model.mostUsedStratPlayer())
        }
        
        else if (self.flag == 3) {
            updatePlayerStrategyHistory()
            self.model.bidString = "The model wants \(model.roundModelBids.last!) as their final offer"
            model.modelFinal = true
        }
    }
    
    func updatePlayerStrategyHistory(){
        if (model.roundModelInfo["strategy"]!.count - 1 >= 1){
            var modelStrategy = model.roundModelInfo["strategy"]![1...(model.roundModelInfo["strategy"]!.count-1)]
            modelStrategy.append("neutral")
            model.roundPlayerInfo["strategy"] = Array(modelStrategy)
        }
    }
    
    func acceptOffer(){
        model.success = true
        self.model.roundPlayerInfo["type"]!.append("decision")
        self.model.roundPlayerInfo["bids"]!.append("accept")
        roundScoreModel = self.model.roundModelBids.last! - self.model.modelMNS
        roundScorePlayer = (9 - self.model.roundModelBids.last!) - self.model.playerMNS
        self.model.modelScore += (roundScoreModel)
        self.model.playerScore += (roundScorePlayer)
        model.strategies.append(model.mostUsedStratPlayer())
        model.totalGames += 1
        updateDM()
    }
    
    func declineOffer(){
        model.success = false
        self.model.roundPlayerInfo["type"]!.append("decision")
        self.model.roundPlayerInfo["bids"]!.append("decline")
        roundScoreModel = 0
        roundScorePlayer = 0
        model.strategies.append(model.mostUsedStratPlayer())
        model.totalGames += 1
        model.gamesQuit += 1
    }
    
    func updateDM(){
        let chunk = model.model.generateNewChunk()

        if (roundScoreModel == roundScorePlayer) {
            chunk.setSlot(slot: "isa", value: "game-state")
            chunk.setSlot(slot: "state", value: "reset")
            
            model.model.buffers["action"] = chunk
            model.model.run()
        }
        else {
            var winner: [String: Array<String>]?
            var loser: [String: Array<String>]?
            var mns: Int?
            
            if (roundScoreModel > roundScorePlayer) {
                winner = model.roundModelInfo
                loser = model.roundPlayerInfo
                mns = model.modelMNS
            }
            else {
                model.gamesWonPlayer += 1
                winner = model.roundPlayerInfo
                loser = model.roundModelInfo
                mns = model.playerMNS
            }
            
            print(winner!)
            if (winner!["strategy"]!.count-1 > 0){
                for i in 0...(winner!["strategy"]!.count-1) {
                    if (winner!["bids"]!.indices.contains(i) &&
                        winner!["type"]!.indices.contains(i) &&
                        loser!["bids"]!.indices.contains(i)){
                        let chunk = self.model.model.generateNewChunk()
                        chunk.setSlot(slot: "isa", value: "game-state")
                        chunk.setSlot(slot: "state", value: "feedback")
                        chunk.setSlot(slot: "type-move", value: winner!["type"]![i])
                        chunk.setSlot(slot: "strategy", value: winner!["strategy"]![i])
                        chunk.setSlot(slot: "mns", value: String(mns!))
                        
                        if (winner!["type"]![i] == "opening" || (winner!["type"]![i] == "claim")) {
                            chunk.setSlot(slot: "bid-diff", value: "nil")
                        }
                        else{
                            chunk.setSlot(slot: "bid-diff", value: winner!["bids"]![i-1])
                        }
                        if (winner!["type"]![i] == "claim") {
                            chunk.setSlot(slot: "op-move", value: "nil")
                        }
                        else{
                            chunk.setSlot(slot: "op-move", value: loser!["bids"]![i])
                        }
                        chunk.setSlot(slot: "my-move", value: winner!["bids"]![i])
                        
                        self.model.model.buffers["action"] = chunk
                        self.model.model.run()
                    }
                }
            }
        }
        model.collectDM()
    }
    
    func selectionInDM(_ selec: String){
        if (Array(model.dmDict.keys).contains(selec) == false){
            self.selection = "opening1"
        }
    }
}
