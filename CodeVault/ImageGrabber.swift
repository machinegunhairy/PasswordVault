//
//  ImageGrabber.swift
//  CodeVault
//
//  Created by William McGreaham on 1/7/21.
//

import UIKit

class ImageGrabber {
    static func getImage(siteName: String) -> String {
        switch siteName.lowercased() {
        case let str where str.contains("blizzard"),
             let str where str.contains("battlenet"):
            return "blizzardIcon"
        case let str where str.contains("aol"):
            return "aolIcon"
        case let str where str.contains("gmail"):
            return "gmailIcon"
        case let str where str.contains("yahoo"):
            return "yahooIcon"
        case let str where str.contains("hotmail"):
            return "hotmailIcon"
        case let str where str.contains("facebook"):
            return "facebookIcon"
        case let str where str.contains("twitter"):
            return "twitterIcon"
        case let str where str.contains("instagram"):
            return "instagramIcon"
        case let str where str.contains("steam"):
            return "steamIcon"
        case let str where str.contains("minecraft"):
            return "minecraftIcon"
        case let str where str.contains("windows"),
             let str where str.contains("microsoft"):
            return "windowsIcon"
        case let str where str.contains("apple"):
            return "appleIcon"
        case let str where str.contains("swtor"):
            return "swtorIcon"
        case let str where str.contains("netflix"):
            return "netflixIcon"
        case let str where str.contains("hbo"):
            return "hbomaxIcon"
        case let str where str.contains("movies"):
            return "moviesIcon"
        case let str where str.contains("vudu"):
            return "vuduIcon"
        case let str where str.contains("amazon"):
            return "amazonIcon"
        case let str where str.contains("oculus"):
            return "oculusIcon"
        case let str where str.contains("pintrist"):
            return "pintristIcon"
        default:
            return ""
        }
    }
}
