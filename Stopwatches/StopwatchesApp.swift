//
//  StopwatchesApp.swift
//  Stopwatches
//
//  Created by Federico Ramacciotti on 15/01/22.
//

import SwiftUI

@main
struct StopwatchesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    //Disable tabbing
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }
        .commands {
            // Disable new window option
            CommandGroup(replacing: .newItem, addition: { })
            // Modify about view
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button(action: {
                    appDelegate.showAboutPanel()
                }) {
                    Text("About Stopwatches")
                }
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var aboutBoxWindowController: NSWindowController?

    func showAboutPanel() {
        if aboutBoxWindowController == nil {
            let styleMask: NSWindow.StyleMask = [.closable, .titled]
            let window = NSWindow()
            window.styleMask = styleMask
            window.title = "About Stopwatches"
            window.contentView = NSHostingView(rootView: AboutView())
            aboutBoxWindowController = NSWindowController(window: window)
        }

        aboutBoxWindowController?.showWindow(aboutBoxWindowController?.window)
    }
}

struct AboutView: View {
    var body: some View {
        VStack {
            Text("")
            Image("stopwatch-64")
                .padding()
            Text("Stopwatches (v1.0)")
                .font(.title)
                .fontWeight(.heavy)
            Text("")
            Text("Made by Federico Ramacciotti")
            Link("GitHub", destination: URL(string: "https://github.com/0xfederama")!)
            HStack {
                Spacer()
                Text("Icon made by")
                Link("Flaticon", destination: URL(string: "https://www.flaticon.com/premium-icon/stopwatch_1321756?term=stopwatch&page=1&position=38&page=1&position=38&related_id=1321756&origin=tag")!)
                Spacer()
            }
            Text("This app is made just to learn SwiftUI, please note that there may be some errors")
                .fontWeight(.ultraLight)
                .font(.callout)
                .foregroundColor(.gray)
                .frame(width: 280, height: 40, alignment: .center)
                .multilineTextAlignment(.center)
                .padding()
            Text("")
        }
        .frame(idealWidth: 300, idealHeight: 300)
        .fixedSize()
    }
}
