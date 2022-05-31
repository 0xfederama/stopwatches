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
    
    // Quit app on Close
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
}

struct AboutView: View {
    var body: some View {
        VStack {
            Image("stopwatch-64")
                .padding()
            Text("Stopwatches (v2.0)")
                .font(.title)
                .fontWeight(.heavy)
                .padding()
            
            Text("Made by Federico Ramacciotti")
            Text("[GitHub](github.com/0xfederama)")
            HStack {
                Spacer()
                Text("Icon made with [Flaticon](https://www.flaticon.com/premium-icon/stopwatch_1321756?term=stopwatch&page=1&position=38&page=1&position=38&related_id=1321756&origin=tag)")
                Spacer()
            }
            
            Text("I know this app is very small, but I made it with love while studying for the University.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top)
            Text("If you would like to donate something it would mean a lot to me! [Tip jar](paypal.me/federicoramacciotti) ❤️")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom)
            
            Text("This app is made just to learn SwiftUI, please note that there may be some errors. If you find them please consider submitting a Github issue.")
                .fontWeight(.light)
                .font(.callout)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(width: 380)
        .fixedSize()
    }
}
