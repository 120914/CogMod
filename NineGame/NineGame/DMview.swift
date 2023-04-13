import SwiftUI

struct DMview: View {
    @ObservedObject var model: NineViewModel
    @State var selection: String = ""
    var body: some View {
        VStack{
            Text("Total # of rules: \(model.model.dmDict.keys.count) in DM.\n")
            Text("# of learned rules: \(model.model.dmDict.keys.count - 28).\n")
            Picker("Select DM chunk to inspect", selection: $selection) {
                Text("").tag("")
                ForEach(Array(model.model.dmDict.keys), id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.menu)
            if (Array(model.model.dmDict.keys).contains(selection)){
                Text(model.model.dmDict[selection]!.description)
              //  Text("Activation: \(model.model.dmDict[selection]!.activation())")
            }
        }
    }
}

