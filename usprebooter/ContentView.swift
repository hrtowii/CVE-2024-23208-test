import SwiftUI

struct ContentView: View {
    @State var LogItems: [String.SubSequence] = [""]
    @State private var username: String = ""
    @AppStorage("headroom") var staticHeadroomMB: Double = 384.0
    @AppStorage("pages") var pUaFPages: Double = 3072.0
    @Binding var useNewUI: Bool
    var body: some View {
        // thx haxi0
        VStack {
            TextField(
                    "a",
                    text: $username
                )
                .onSubmit {
                }
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .border(.secondary)


                Text(username)
                    .foregroundColor(.blue)
            HStack {
                Button("do the thing!") {
                    DispatchQueue.global(qos: .background).async {
                        troll()
                    }
                }
            }
            
            ScrollView {
                ScrollViewReader { scroll in
                    VStack(alignment: .leading) {
                        ForEach(0 ..< LogItems.count, id: \.self) { LogItem in
                            Text("\(String(LogItems[LogItem]))")
                                .textSelection(.enabled)
                                .font(.custom("Menlo", size: 10))
                                .foregroundColor(.white)
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: LogStream.shared.reloadNotification)) { _ in
                        DispatchQueue.global(qos: .utility).async {
                            FetchLog()
                            scroll.scrollTo(LogItems.count - 1)
                        }
                    }
                }
            }
            .frame(height: 230)
        }
        .padding(20)
        .background {
            Color(.black)
                .cornerRadius(20)
                .opacity(0.5)
        }
    }
    private func FetchLog() {
        guard let AttributedText = LogStream.shared.outputString.copy() as? NSAttributedString else {
            LogItems = ["Error Getting Log!"]
            return
        }
        LogItems = AttributedText.string.split(separator: "\n")
    }
}

// #Preview {
//    ContentView()
// }
