//
// Playground Template developed by Apple Developer Academy | PUC-Rio
// Version 1.0
//
// This template playground is built based on the 10th Submission Requirement of
// the Swift Student Challenge WWDC26: "Your app playground must either [...] or
// be based on a Swift Playground template modified entirely by you as an individual."
//

import UIKit

@MainActor
class FontLoader {
    static func loadCustomFonts(_ fontNames: [String]) {
        var fontURLArray = [URL]()
        for fontName in fontNames {
            guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: nil) else {
                continue
            }
            fontURLArray.append(fontURL)
        }
        CTFontManagerRegisterFontURLs(fontURLArray as CFArray, .process, true, nil)
    }
}

