//
//  MainWindowController.swift
//  SimpleRSS
//
//  Created by shuntaro on 2022/10/17.
//
//  BBC: http://feeds.bbci.co.uk/news/rss.xml
//  Yahoo: https://news.yahoo.co.jp/rss/topics/top-picks.xml
//
//  Clear User Defaults:
//  let appDomain = Bundle.main.bundleIdentifier
//  UserDefaults.standard.removePersistentDomain(forName: appDomain!)
//

import Cocoa
import Alamofire
import SwiftyJSON

class MainWindowController: NSWindowController {
    
    @IBOutlet weak var popupMenu: NSPopUpButton!
    
    var feeds = [Feed]()
    var feed: Feed! {
        didSet {
            self.setFeed()
        }
    }
    var user = UserDefaultsController()
    var sideBar: SidebarViewController!

    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        // let appDomain = Bundle.main.bundleIdentifier
        // UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        
        let splitController = contentViewController as? NSSplitViewController
        sideBar = splitController?.splitViewItems[0].viewController as? SidebarViewController
        sideBar.newsController = splitController?.splitViewItems[1].viewController as? NewsViewController
        if let feeds = user.get(.feeds) as? [Feed] {
            self.feeds = feeds
            if feeds.count > 0 {
                popupMenu.itemArray[0].title = feeds[0].title
                if feeds.count > 1 {
                    for i in 1..<feeds.count {
                        popupMenu.addItem(withTitle: feeds[i].title)
                    }
                }
            }
        } else {
            performSegue(withIdentifier: "showPanel", sender: self)
        }
        if let lastFeed = user.get(.lastFeed) as? Feed {
            feed = lastFeed
            sideBar.feed = feed
            var index = 0
            for i in 0..<feeds.count {
                if feeds[i].url == feed.url {
                    index = i
                    continue
                }
            }
            popupMenu.select(popupMenu.itemArray[index])
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showPanel" {
            let nextVC = segue.destinationController as! PanelViewController
            nextVC.previousVC = self
        }
    }
    
    @IBAction func popupDidChange(_ sender: Any) {
        if popupMenu.indexOfSelectedItem >= 0 && popupMenu.indexOfSelectedItem < feeds.count {
            feed = feeds[popupMenu.indexOfSelectedItem]
            sideBar.feed = feed
            window?.title = feed.title
            user.set(feed!, key: .lastFeed)
        }
    }
    
    @IBAction func removeFeed(_ sender: Any) {
        popupMenu.removeItem(at: popupMenu.indexOfSelectedItem)
        feeds.remove(at: popupMenu.indexOfSelectedItem)
        user.set(feeds, key: .feeds)
    }
    
    @IBAction func refresh(_ sender: Any) {
        sideBar.refresh()
    }
    
    func setFeed(_ isInsert: Bool = false) {
        if isInsert {
            self.feeds.insert(self.feed, at: 0)
            self.popupMenu.insertItem(withTitle: self.feed.title, at: 0)
            self.popupMenu.select(self.popupMenu.itemArray[0])
            self.user.set(self.feeds, key: .feeds)
        }
        self.user.set(self.feed!, key: .lastFeed)
        self.sideBar.feed = self.feed
        self.sideBar.tableView.reloadData()
    }
    
    func addFeed(_ url: String) {
        if url == "canceled" {
            if feeds.count < 1 {
                exit(0)
            }
        } else {
            var contains = false
            var containFeed: String?
            feeds.forEach {
                containFeed = $0.title
                if $0.url == url {
                    contains = true
                    return
                }
            }
            if !contains {
                let jsonURL = "https://api.rss2json.com/v1/api.json?rss_url=\(url)"
                AF.request(jsonURL).responseData { response in
                    switch response.result {
                    case .success(let values):
                        let title = JSON(values)["feed"]["title"].stringValue
                        if self.feeds.count < 1 {
                            self.popupMenu.removeItem(at: 0)
                        }
                        self.feed = Feed(url, title: title)
                        self.setFeed(true)
                    case .failure(let error):
                        break
                    }
                }
            } else {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = """
                    Feed "\(containFeed ?? "")" was already added.
                    """
                    alert.addButton(withTitle: "OK")
                    _ = alert.runModal()
                }
            }
        }
    }

}
