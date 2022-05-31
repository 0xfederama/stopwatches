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

var watches: [Watch] = []

func saveWatches() {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(watches) {
        UserDefaults.standard.set(encoded, forKey: "Stopwatches")
    }
}

func loadWatches() {
    if let savedWatches = UserDefaults.standard.object(forKey: "Stopwatches") as? Data {
        let decoder = JSONDecoder()
        watches = try! decoder.decode([Watch].self, from: savedWatches)
    }
}

//Content view
struct ContentView: View {
    @State var currentView = 0
    @State var currentWatch: String = ""
    
    init() {
        loadWatches()
    }
    
    var body: some View {
        
        switch currentView {
        case 1:
            ContinueWatchView(currentView: $currentView, currentWatch: currentWatch)
                .frame(minWidth: 400, maxWidth: 400)
        case 2:
            NewWatchView(currentView: $currentView)
                .frame(minWidth: 400, maxWidth: 400)
        default:
            TimersView(currentView: $currentView, currentWatch: $currentWatch)
                .frame(minWidth: 400, maxWidth: 400)
        }
    }
}

// Homepage
struct TimersView: View {
    @Binding var currentView: Int
    @Binding var currentWatch: String
    @State var refreshView: Bool = false
    
    var body: some View {
        Text("Your stopwatches")
            .font(.title)
            .fontWeight(.heavy)
            .padding()
            .background(Color.clear.disabled(refreshView))
        
        if watches.isEmpty {
            Text("No stopwatches created")
                .padding()
        } else {
            VStack {
                ForEach(watches, id: \.self) { watch in
                    HStack {
                        Text(watch.name)
                            .help(Text(watch.name))
                        Spacer()
                        let hours = Int(watch.minutes / 60)
                        let minutes = Int(watch.minutes % 60)
                        Text(String(hours) + "h " + String(minutes) + "m")
                        Text("")
                        Button("Start") {
                            currentWatch = watch.name
                            currentView = 1
                        }
                        Button("Delete") {
                            //Delete stopwatch from watches
                            currentWatch = watch.name
                            let index = getIndex(watches: watches, name: currentWatch)
                            print("Delete at index " + String(index))
                            if index != -1 {
                                watches.remove(at: index)
                                saveWatches()
                            }
                            currentView = 0
                            refreshView.toggle()
                        }
                    }
                }
            }
            .padding()
        }
        
        Button("New stopwatch") {
            currentView = 2
        }
        .padding()
        .padding(.top, 24)
    }
}

// Create a new stopwatch
struct NewWatchView: View {
    @Binding var currentView: Int
    @State var watchName: String = ""
    @State private var duplicatedAlert: Bool = false
    @FocusState private var inputFieldFocused: Bool
    
    var body: some View {
        Text("New stopwatch")
            .font(.title)
            .fontWeight(.heavy)
            .padding()
        
        VStack {
            Text("")
            TextField("Enter stopwatch name...", text: $watchName, onCommit: {
                //Check if another stopwatch with the same name already exists
                if watchName != "" {
                    if exists(watches: watches, name: watchName) {
                        print("Stopwatch already exists")
                        duplicatedAlert = true
                    } else {
                        //Create the new stopwatch
                        let newWatch = Watch(name: watchName, minutes: 0)
                        watches.append(newWatch)
                        saveWatches()
                        currentView = 0
                    }
                }
            })
            .onAppear() {
                inputFieldFocused = true
            }
            .focused($inputFieldFocused)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 240)
            .padding()
            
            if duplicatedAlert == true {
                Text("A stopwatch with that name already exists!")
            }
            Text("")
        }
        
        HStack {
            Button("Cancel") {
                currentView = 0
            }
            .keyboardShortcut(.cancelAction)
            Button("Create") {
                //Check if another stopwatch with the same name already exists
                if watchName != "" {
                    if exists(watches: watches, name: watchName) {
                        print("Stopwatch already exists")
                        duplicatedAlert = true
                    } else {
                        //Create the new stopwatch
                        let newWatch = Watch(name: watchName, minutes: 0)
                        watches.append(newWatch)
                        saveWatches()
                        currentView = 0
                    }
                }
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding()
    }
}

// Continue an existing stopwatch
struct ContinueWatchView: View {
    @Binding var currentView: Int
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
        Text(currentWatch)
            .font(.title)
            .fontWeight(.heavy)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding()
        
        Spacer()
        let totMinutes = getMinutes(watches: watches, name: currentWatch)
        let currHours = Int(totMinutes / 60)
        let currMinutes = Int(totMinutes % 60)
        Text("Started with " + String(currHours) + "h " + String(currMinutes) + "m")
        Text("")
        
        HStack(spacing: 2) {
            StopwatchUnitView(timeUnit: hours)
            Text(":")
            StopwatchUnitView(timeUnit: minutes)
            Text(":")
            StopwatchUnitView(timeUnit: seconds)
        }
        .font(.title2)
        .onAppear(perform: { _ = timer })
        .padding()
        
        Spacer()
        Button("Stop") {
            //Write minutes to json
            let minutes = progressTime / 60
            sumMinutes(watches: &watches, name: currentWatch, minutes: minutes)
            saveWatches()
            currentView = 0
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
            Text(timeUnitStr.substring(index: 0)).frame(width: 10)
            Text(timeUnitStr.substring(index: 1)).frame(width: 10)
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
