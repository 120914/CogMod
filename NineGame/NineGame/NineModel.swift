import Foundation

func createChunk(_ m: Model, _ s: Array<String>, _ v: Array<Value>) -> Chunk
{
    let chunk = m.generateNewChunk()
    for (slot, value) in zip(s, v)
    {
        chunk.setSlot(slot: slot, value: value)
    }
    return chunk
}


struct NineModel {
    var dmDict: [String: Chunk] = [:]
    var totalGames = 0
    var strategies:Array<String> = []
    var overallStrats: Array<String> = []
    var mnsPairs: Array<Array<Int>> = [[1,1], [2,2], [3,3], [4,4], [1,3], [3,1], [1,5], [5,1], [2,6], [6,2], [4,5], [5,4]]
    var model = Model()
    var success = false
    let numbers: Set<Character> = ["1","2","3","4","5","6","7","8","9","0"]
    var modelFinal: Bool = false
    var playerMNS: Int = 0
    var tmer = 0
    var trialNr = 0
    var modelMNS: Int = 0
    var gamesWonPlayer = 0
    var gamesQuit = 0
    var suggestedPlayerMNS: Double = -1.0
    var suggestedModelMNS: Double = -1.0
    var roundPlayerInfo: [String: Array<String>] = ["strategy": [],
                                                    "bids" : [],
                                                    "type" : []]
    var roundModelInfo: [String: Array<String>] = ["strategy": [],
                                                    "bids" : [],
                                                    "type" : []]
    var roundPlayerBids: Array<Int> = [0]
    var roundModelBids: Array<Int> = [0]
    var highlightedBid: Int?
    var playerScore: Int = 0
    var modelScore: Int = 0
    var bidString: String = ""
    
    
    init() {
        model.loadModel(fileName: "nine")
        model.run()
        collectDM()
    }
    
    mutating func collectDM()
    {
        dmDict = [:]
        for (n, ch) in model.dm.chunks {
            if (n.contains("opening") || n.contains("final-offer") || n.contains("claim") || n.contains("bid") || n.contains("imaginal")) {
                dmDict[n] = ch
            }
        }
    }
    
    mutating func reset(){
        strategies = []
        overallStrats = []
        roundModelInfo = ["strategy": [],
                          "bids" : [],
                          "type" : []]
        roundPlayerInfo = ["strategy": [],
                           "bids" : [],
                           "type" : []]
        model.reset()
        collectDM()
        gamesQuit = 0
        gamesWonPlayer = 0
        totalGames = 0
        suggestedPlayerMNS = -1.0
        suggestedModelMNS = -1.0
        roundPlayerBids = [0]
        roundModelBids = [0]
        highlightedBid = nil
        playerScore = 0
        modelScore = 0
        bidString = ""
        trialNr = 0
    }
    
    mutating func resetModelTrial(){
        trialNr += 1
        
        let ac = createChunk(model, ["isa", "state"], [Value.Text("game-state"), Value.Text("reset")])
        
        //reset trial specific variables
        roundModelInfo = ["strategy": [],
                          "bids" : [],
                          "type" : []]
        roundPlayerInfo = ["strategy": [],
                           "bids" : [],
                           "type" : []]
        self.bidString = ""
        roundPlayerBids = [0]
        roundModelBids = [0]
        modelFinal = false
        self.setMNS()

        //create claim chunk
        let chunk = createChunk(model, ["isa", "my-mns"], [Value.Text("game-state"), Value.Number(Double(modelMNS))])
        
        model.buffers["action"] = ac
        model.run()
        
        //put claim chunk in the action buffer and run the model
        model.buffers["action"] = chunk
        model.run()
        
        modelMNSClaim()
    }

    mutating func modelMNSClaim(){
        //record action response of model
        let modelAction = model.lastAction(slot: "my-move")
      
        //Action retrieval buffer check
        if (modelAction != nil) {
            //log model claim move
            self.roundModelInfo["type"]!.append("claim")
            self.roundModelInfo["strategy"]!.append(model.lastAction(slot: "strategy")!)
            self.roundModelInfo["bids"]!.append(modelAction!.description)
            
            //calculate the resulting claimed model MNS
            self.suggestedModelMNS = Double(self.modelMNS) + (Double(modelAction!.description) ?? 0)
        }
        else {
            print("No action returned.")
        }
    }
    //functionality for saving MNS claim of player
    mutating func chooseMNS(_ mns: Int) {
        //log player claim move
        self.roundPlayerInfo["type"]!.append("claim")
        self.roundPlayerInfo["bids"]!.append(String(Double(mns - playerMNS)))
        self.suggestedPlayerMNS = Double(mns)
    }
    
    mutating func chooseBid(_ bid: Int, final f: Bool) -> Int{
        //set constant chunk values
        let isa = Value.Text("game-state")
        let state = Value.Text("game")
        let opFinal = f ? Value.Text("yes") : Value.Text("no")
        let opMove: Value?
        let myBidDiff = (roundModelBids.count == 1) ? Value.Empty : Value.Number(Double(modelMNS) - (Double(self.roundModelInfo["bids"]!.last!) ?? 0.0))
        
        //check for opening move
        if (roundModelBids.count == 1)
        {
            //log model and player opening move
            self.roundPlayerInfo["type"]!.append("opening")
            
            //for opening moves, format the move accordingly
            opMove = Value.Number(Double(bid - roundPlayerBids.last!))
        }
        else{
            //for bid moves (non-opening moves), opponent move will be the difference between
            //the previous two moves
            self.roundPlayerInfo["type"]!.append("bid")
            //self.roundModelInfo["type"]!.append("bid")
            opMove = Value.Number(Double(bid - roundPlayerBids.last!))
        }
        
        //create the action chunk that is passed to the model to act on
        let chunk = createChunk(model, ["isa", "state", "my-bid-diff", "op-move", "op-final"],
                                [isa, state, myBidDiff, opMove!, opFinal])
        
        model.buffers["action"] = chunk
        model.buffers["retrieval"] = nil

        model.run()
        
        //record model response
        let modelAction = model.lastAction(slot: "my-move")
        
        //check the name of the retrieved chunk
        self.roundPlayerInfo["bids"]!.append(String(Double(bid - roundPlayerBids.last!)))
        self.roundPlayerBids.append(bid)
        
        if (modelAction != nil) {
            var bidName = model.buffers["partial"]!.name
            bidName.removeAll(where: {numbers.contains($0)})
            
            //log model bids
            self.roundModelInfo["strategy"]!.append(model.lastAction(slot: "strategy")!)

            switch (modelAction!.description) {
              //if the model rejects the final offer of the player, go to new trial without getting score.
              case "reject":
                self.roundModelInfo["bids"]!.append(model.lastAction(slot: "my-move")!)
                //log model type to be a decision
                self.roundModelInfo["type"]!.append("decision")
                return 2
            
              //if the model accepts the final offer of the player, go to new trial with recalculating scores
              //based on how the 9 points a split.
              case "accept":
                
                self.roundModelInfo["bids"]!.append(model.lastAction(slot: "my-move")!)
                //log model type to be decision
                self.roundModelInfo["type"]!.append("decision")
                return 1
                
              //on quit, go to new trial without recalculating scores
              case "quit":
                
                self.roundModelInfo["bids"]!.append(model.lastAction(slot: "my-move")!)
                self.roundModelInfo["type"]!.append("quit")
                return 2
                
              //if none of the above cases is triggered, the response of the model if not empty is a
              //regular bid
              case let response:
                
                var modelBid = Int(Double(response) ?? 0) + self.roundModelBids.last!
                if modelBid < 1 {
                    modelBid = 1
                }

                
                if (modelBid + bid <= 9)
                {
                    self.roundModelInfo["type"]!.append("decision")
                    self.roundModelInfo["bids"]!.append("accept")
                    self.roundPlayerBids.append(bid)
                    return 1
                }
                else {
                    //logic for responding to final-offers from the model
                    if bidName.contains("final-offer") {
                        self.roundModelInfo["bids"]!.append(model.lastAction(slot: "my-move")!)
                        //log type decision for player
                        if (self.roundModelBids.count > 1){
                            self.roundModelInfo["type"]!.append("bid")
                        }
                        
                        let response = Int(Double(modelAction!.description) ?? 0)
                        var modelBid = response + self.roundModelBids.last!
                        if modelBid < 1 {
                            modelBid = 1
                        }
                        self.roundModelBids.append(modelBid)
                        return 3
                    } else{
                        if self.roundModelBids.count > 1{
                            self.roundModelInfo["type"]!.append("bid")
                        }
                        else{
                            self.roundModelInfo["type"]!.append("opening")
                        }
                        self.roundModelInfo["bids"]!.append(model.lastAction(slot: "my-move")!)
                        self.roundModelBids.append(modelBid)
                        updateStrategy()
                    }
                }
                return 0
            }
        }
        else {
            print("where")
            //nothing returned by model
            return 2
        }
    }
    
    mutating func updateStrategy(){
        let lastTwoBids = Array(self.roundPlayerBids.suffix(2))
        let lastTwoBidsModel = Array(self.roundModelBids.suffix(2))
        
        let chunk = createChunk(model, ["isa", "state", "op-mns", "op-bid-diff", "op-move", "my-move"],
                                [Value.Text("game-state"), Value.Text("game"),
                                 Value.Number(suggestedPlayerMNS),
                                 Value.Number(Double(lastTwoBids[0]-Int(suggestedPlayerMNS))),
                                 Value.Number(Double(lastTwoBids[1] - lastTwoBids[0])),
                                 Value.Number(Double(lastTwoBidsModel[1] - lastTwoBidsModel[0]))])
        
        model.buffers["action"] = chunk
        model.run()
        
    }
    mutating func setMNS(){
        let pair = mnsPairs[Int.random(in: 0...11)]
        self.playerMNS = pair[0]
        self.modelMNS = pair[1]
    }
    
    func mostUsedStratPlayer() -> String{
        var coop = 0
        var agg = 0
        for strat in roundPlayerInfo["strategy"]!{
            if (strat == "coop")
            {
                coop += 1
            }
            else if(strat == "agg")
            {
                agg += 1
            }
        }
        
        if (coop > agg) {
            return "cooperative"
        }
        else if (coop < agg) {
            return "aggressive"
        }
        return "neutral"
    }
    
    func mostUsedStratModel() -> String{
        var coop = 0
        var agg = 0
        for strat in roundModelInfo["strategy"]!{
            if (strat == "coop")
            {
                coop += 1
            }
            else if(strat == "agg")
            {
                agg += 1
            }
        }
        
        if (coop > agg) {
            return "cooperative"
        }
        return "aggressive"
    }
}
