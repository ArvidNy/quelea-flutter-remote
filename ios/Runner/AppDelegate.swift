import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var keyCommands: [UIKeyCommand]? {
        var list = [
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [UIKeyModifierFlags.control], action: #selector(nextItem)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [UIKeyModifierFlags.command], action: #selector(nextItem)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(nextSlide)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [UIKeyModifierFlags.control], action: #selector(previousItem)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [UIKeyModifierFlags.command], action: #selector(previousItem)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(previousSlide)),
            UIKeyCommand(input: UIKeyCommand.inputPageDown, modifierFlags: [UIKeyModifierFlags.control], action: #selector(nextItem)),
            UIKeyCommand(input: UIKeyCommand.inputPageDown, modifierFlags: [UIKeyModifierFlags.command], action: #selector(nextItem)),
            UIKeyCommand(input: UIKeyCommand.inputPageDown, modifierFlags: [], action: #selector(nextSlide)),
            UIKeyCommand(input: UIKeyCommand.inputPageUp, modifierFlags: [UIKeyModifierFlags.control], action: #selector(previousItem)),
            UIKeyCommand(input: UIKeyCommand.inputPageUp, modifierFlags: [UIKeyModifierFlags.command], action: #selector(previousItem)),
            UIKeyCommand(input: UIKeyCommand.inputPageUp, modifierFlags: [], action: #selector(previousSlide)),
            UIKeyCommand(input: "r", modifierFlags: [UIKeyModifierFlags.control], action: #selector(record)),
            UIKeyCommand(input: "r", modifierFlags: [UIKeyModifierFlags.command], action: #selector(record)),
            UIKeyCommand(input: "d", modifierFlags: [UIKeyModifierFlags.control], action: #selector(openSchedule)),
            UIKeyCommand(input: "d", modifierFlags: [UIKeyModifierFlags.command], action: #selector(openSchedule)),
            UIKeyCommand(input: "t", modifierFlags: [UIKeyModifierFlags.control], action: #selector(openSettings)),
            UIKeyCommand(input: "t", modifierFlags: [UIKeyModifierFlags.command], action: #selector(openSettings)),
            UIKeyCommand(input: "1", modifierFlags: [UIKeyModifierFlags.control], action: #selector(goto1)),
            UIKeyCommand(input: "2", modifierFlags: [UIKeyModifierFlags.control], action: #selector(goto2)),
            UIKeyCommand(input: "3", modifierFlags: [UIKeyModifierFlags.control], action: #selector(goto3)),
            UIKeyCommand(input: "4", modifierFlags: [UIKeyModifierFlags.control], action: #selector(goto4)),
            UIKeyCommand(input: "5", modifierFlags: [UIKeyModifierFlags.control], action: #selector(goto5)),
            UIKeyCommand(input: "6", modifierFlags: [UIKeyModifierFlags.control], action: #selector(goto6)),
            UIKeyCommand(input: "7", modifierFlags: [UIKeyModifierFlags.control], action: #selector(goto7)),
            UIKeyCommand(input: "8", modifierFlags: [UIKeyModifierFlags.control], action: #selector(goto8)),
            UIKeyCommand(input: "9", modifierFlags: [UIKeyModifierFlags.control], action: #selector(goto9)),
        ]
        if #available(iOS 13.4, *) {
            list.append(UIKeyCommand(input: UIKeyCommand.f5, modifierFlags: [], action: #selector(logo)))
            list.append(UIKeyCommand(input: UIKeyCommand.f6, modifierFlags: [], action: #selector(black)))
            list.append(UIKeyCommand(input: UIKeyCommand.f7, modifierFlags: [], action: #selector(clear)))
        }
        return list
    }
    
     @objc func nextItem() {
        sendUrl(s: "nextitem")
    }
    
    @objc func nextSlide() {
        sendUrl(s: "next")
    }
    
    @objc func previousItem() {
        sendUrl(s: "previtem")
    }
    
    @objc func previousSlide() {
        sendUrl(s: "prev")
    }

    @objc func logo() {
        sendUrl(s: "tlogo")
    }

    @objc func clear() {
        sendUrl(s: "clear")
    }
    
    @objc func black() {
        sendUrl(s: "black")
    }
    
    @objc func record() {
        sendUrl(s: "record")
    }
    
    @objc func goto1() {
        sendUrl(s: "section0")
    }
    
    @objc func goto2() {
        sendUrl(s: "section1")
    }
    
    @objc func goto3() {
        sendUrl(s: "section2")
    }
    
    @objc func goto4() {
        sendUrl(s: "section3")
    }
    
    @objc func goto5() {
        sendUrl(s: "section4")
    }
    
    @objc func goto6() {
        sendUrl(s: "section5")
    }
    
    @objc func goto7() {
        sendUrl(s: "section6")
    }
    
    @objc func goto8() {
        sendUrl(s: "section7")
    }
    
    @objc func goto9() {
        sendUrl(s: "section8")
    }
    
    @objc func slideNumber() {
        print("slideNumber")
    }
    
    @objc func openSettings() {
        // Not supported yet
    }
    
    @objc func openSearch() {
        // Not supported
    }
    
    @objc func openSchedule() {
        // Not supported
    }
    
    @objc func sectionTitles() {
        // Not supported
    }
    
    func sendUrl(s: String) {
        let defaults = UserDefaults.standard
        let u = defaults.string(forKey: "flutter.pref_server_url") ?? "http://192.168.0.1:1112"
        let url = URL(string: u + "/" + s)!
        print(url.absoluteString)
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard data != nil else { return }
        }
        task.resume()
    }
}
