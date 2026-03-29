//
//  Feed.swift
//  SimpleRSS
//
//  Created by shuntaro on 2022/10/17.
//

import Cocoa
import Alamofire
import SwiftyJSON

/// RSSフィード。
class Feed: NSObject, NSCoding, NSSecureCoding {
    static let supportsSecureCoding: Bool = true
    
    /// RSS の URL。
    let url: String
    /// RSS のタイトル。
    var title: String
    
    init(_ aURL: String, title aTitle: String) {
        url = aURL
        title = aTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        url = aDecoder.decodeObject(forKey: "url") as! String
        title = aDecoder.decodeObject(forKey: "title") as! String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(url, forKey: "url")
        coder.encode(title, forKey: "title")
    }
    
    /// RSS を Json に変換する API の URL を取得します。
    func getJsonURL() -> String {
        return "https://api.rss2json.com/v1/api.json?rss_url=\(url)"
    }
}

extension UserDefaults {
    func feed(forKey key: String) -> Feed? {
        if let storedData = self.object(forKey: key) as? Data {
            if let unarchivedObject = try! NSKeyedUnarchiver.unarchivedObject(ofClass: Feed.self, from: storedData) {
                return unarchivedObject
            }
        }
        return nil
    }
    
    func feedArray(forKey key: String) -> [Feed]? {
        if let storedData = self.array(forKey: key) {
            var unarchivedFeeds = [Feed]()
            for feedData in storedData {
                if let unarchivedObject = try! NSKeyedUnarchiver.unarchivedObject(ofClass: Feed.self, from: feedData as! Data) {
                    unarchivedFeeds.append(unarchivedObject)
                }
            }
            return unarchivedFeeds
        }
        return nil
    }

    func setFeed(_ feed: Feed, forKey key: String) {
        var data: Data!
        if #available(macOS 10.13, *) {
            data = try! NSKeyedArchiver.archivedData(withRootObject: feed, requiringSecureCoding: false)
        } else {
            data = NSKeyedArchiver.archivedData(withRootObject: feed)
        }
        self.set(data, forKey: key)
    }
    
    func setFeedArray(_ feeds: [Feed], forKey key: String) {
        var data: Data!
        if #available(macOS 10.13, *) {
            data = try! NSKeyedArchiver.archivedData(withRootObject: feeds, requiringSecureCoding: false)
        } else {
            data = NSKeyedArchiver.archivedData(withRootObject: feeds)
        }
        self.set(data, forKey: key)
    }
}
