//
//  ContentView.swift
//  Stopwatches
//
//  Created by Federico Ramacciotti on 15/01/22.
//

import SwiftUI

struct Watch: Hashable, Codable {
    let name: String
    var minutes: Int
}

class ReadData: ObservableObject {
    @Published var watches = [Watch]()

    init() {
        // If file doesn't exist, create it
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: "Library/Application Support/Stopwatches/watches.json") {
            print("File does not exist")
            try? fileManager.createDirectory(atPath: "Library/Application Support/Stopwatches", withIntermediateDirectories: true, attributes: nil)
            fileManager.createFile(atPath: "Library/Application Support/Stopwatches/watches.json", contents: try? Data(contentsOf: Bundle.main.url(forResource: "watches", withExtension: "json")!))
        }
        let fileURL = URL(fileURLWithPath: "Library/Application Support/Stopwatches/watches.json")
        loadData(url: fileURL)
    }

    func loadData(url: URL) {
        let data = try! Data(contentsOf: url)
        @State var watches = try? JSONDecoder().decode([Watch].self, from: data)
        self.watches = watches!
    }
}

class WriteData: ObservableObject {
    @Published var watches = [Watch]()

    init(watches: [Watch]) {
        writeData(watches: watches)
    }

    func writeData(watches: [Watch]) {
        let url = URL(fileURLWithPath: "Library/Application Support/Stopwatches/watches.json")
        let encoded = try? JSONEncoder().encode(watches)
        do {
            try encoded!.write(to: url)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }
}

//Content view
struct ContentView: View {
    @State var currentView = 0
    @State var currentWatch: String = ""
    var watches: [Watch] {
        get {
            return ReadData().watches
        }
    }

    var body: some View {

        switch currentView {
        case 1:
            ContinueWatch(currentView: $currentView, watches: watches, currentWatch: currentWatch)
                .frame(minWidth: 400, maxWidth: 400)
        case 2:
            CreateWatch(currentView: $currentView, watches: watches)
                .frame(minWidth: 400, maxWidth: 400)
        default:
            TimersView(currentView: $currentView, watches: watches, currentWatch: $currentWatch)
                .frame(minWidth: 400)
        }
    }
}

// Homepage
struct TimersView: View {
    @Binding var currentView: Int
    @State private var alert = false
    @State var watches: [Watch]
    @Binding var currentWatch: String

    var body: some View {
        Text("Your stopwatches")
            .font(.title)
            .fontWeight(.heavy)
            .padding()

        if watches.isEmpty {
            Text("No stopwatches created")
                .padding()
        } else {
            VStack {
                ForEach(watches, id: \.self) { watch in
                    HStack {
                        Text(watch.name)
                        Spacer()
                        let hours = Int(watch.minutes / 60)
                        let minutes = Int(watch.minutes % 60)
                        Text(String(hours) + "h " + String(minutes) + "m")
                        Text("")
                        Button("Start") {
                            self.currentWatch = watch.name
                            self.currentView = 1
                        }
                        Button("Delete") {
                            //Delete stopwatch from watches
                            self.currentWatch = watch.name
                            let index = getIndex(watches: watches, name: currentWatch)
                            print("Index " + String(index))
                            if index != -1 {
                                watches.remove(at: index)
                                _ = WriteData(watches: watches)
                            }
                            self.currentView = 0
                        }
                    }
                }
            }
                .padding()
        }

        Button("New stopwatch") {
            self.currentView = 2
        }
            .padding()
            .padding(.top, 24)
    }
}

// Create a new stopwatch
struct CreateWatch: View {
    @Binding var currentView: Int
    @State var watchName: String = ""
    @State var watches: [Watch]

    var body: some View {
        Text("")
        Text("Create a new stopwatch")
            .font(.title)
            .fontWeight(.heavy)

        VStack {
            TextField("Enter stopwatch name...", text: $watchName, onCommit: {
                //Check if another stopwatch with the same name already exists
                if exists(watches: watches, name: watchName) {
                    print("Stopwatch already exists")
                } else {
                    //Create the new stopwatch
                    let newWatch = Watch(name: watchName, minutes: 0)
                    watches.append(newWatch)
                    _ = WriteData(watches: watches)
                }
                self.currentView = 0
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Text("Hint: you cannot create a stopwatch that already exists")
                .italic()
            Text("")
        }

        HStack {
            Button("Cancel") {
                self.currentView = 0
            }
            Button("Create") {
                //Check if another stopwatch with the same name already exists
                if exists(watches: watches, name: watchName) {
                    print("Stopwatch already exists")
                } else {
                    //Create the new stopwatch
                    let newWatch = Watch(name: watchName, minutes: 0)
                    watches.append(newWatch)
                    _ = WriteData(watches: watches)
                }
                self.currentView = 0
            }
        }
            .padding()
    }
}

// Continue an existing stopwatch
struct ContinueWatch: View {
    @Binding var currentView: Int
    @State var watches: [Watch]
    let currentWatch: String

    @State private var progressTime = 0
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            progressTime += 1
        }
    }
    var hours: Int {
        progressTime / 3600
    }
    var minutes: Int {
        (progressTime % 3600) / 60
    }
    var seconds: Int {
        progressTime % 60
    }

    var body: some View {
        Text("Stopwatch " + currentWatch + " started")
            .font(.title)
            .fontWeight(.heavy)
            .padding()

        Spacer()
        Text(currentWatch + " started with " + String(getMinutes(watches: watches, name: currentWatch)) + " minutes")
            .fontWeight(.bold)

        HStack(spacing: 2) {
            StopwatchUnitView(timeUnit: hours)
            Text(":")
            StopwatchUnitView(timeUnit: minutes)
            Text(":")
            StopwatchUnitView(timeUnit: seconds)
        }
            .onAppear(perform: { _ = timer })
            .padding()

        Spacer()
        Button("Stop") {
            //Write minutes to json
            let minutes = progressTime / 60
            sumMinutes(watches: &watches, name: currentWatch, minutes: minutes)
            _ = WriteData(watches: watches)
            self.currentView = 0
        }
        Text("")
    }
}

struct StopwatchUnitView: View {
    var timeUnit: Int
    var timeUnitStr: String {
        let timeUnitStr = String(timeUnit)
        return timeUnit < 10 ? "0" + timeUnitStr : timeUnitStr
    }

    var body: some View {
        HStack (spacing: 2) {
            Text(timeUnitStr.substring(index: 0)).frame(width: 8)
            Text(timeUnitStr.substring(index: 1)).frame(width: 8)
        }
    }
}

extension String {
    func substring(index: Int) -> String {
        let arrayString = Array(self)
        return String(arrayString[index])
    }
}

func sumMinutes(watches: inout [Watch], name: String, minutes: Int) {
    for i in 0..<watches.count {
        if watches[i].name == name {
            print("Total minutes " + String(watches[i].minutes + minutes))
            watches[i].minutes += minutes
        }
    }
}

func getMinutes(watches: [Watch], name: String) -> Int {
    for watch in watches {
        if watch.name == name {
            return watch.minutes;
        }
    }
    return 0;
}

func getIndex(watches: [Watch], name: String) -> Int {
    print("Name " + name)
    for i in 0..<watches.count {
        if watches[i].name == name {
            return i;
        }
    }
    return -1;
}

func exists(watches: [Watch], name: String) -> Bool {
    for watch in watches {
        if watch.name == name {
            return true;
        }
    }
    return false;
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
