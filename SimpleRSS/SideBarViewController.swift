//
//  SideBarViewController.swift
//  SimpleRSS
//
//  Created by shuntaro on 2022/10/16.
//

import Cocoa
import Alamofire
import SwiftyJSON

class SidebarViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.rowHeight = 60
        }
    }
    
    var newsController: NewsViewController!
    var feed: Feed! {
        didSet {
            self.refresh(false)
        }
    }
    
    var news = [News]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SidebarView"), owner: self) as? SidebarCellView
        result?.title.stringValue = news[row].title
        var description = news[row].description
        if description.isEmpty {
            description = "説明はありません。"
        }
        result?.descriptionLabel.stringValue = description
        return result
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        print("Selected Row: \(row)")
        if row >= 0 && row < news.count {
            newsController.url = news[row].link
            newsController.load()
        }
    }
    
    func refresh(_ webView: Bool = true) {
        AF.request(feed.getJsonURL())
            .validate().response() { response in
                var isOK = false
                
                switch response.result {
                case .success(let values):
                    let json = JSON(values as Any)
                    print("Feed from \(json["feed"]["title"])")
                    self.view.window?.title = json["feed"]["title"].stringValue
                    print("--------------------------------------------------")
                    self.news.removeAll()
                    json["items"].forEach { i, value in
                        self.news.append(News(value["title"].string!, link: value["link"].string!, description: value["content"].string!))
                        print("Title: \(value["title"].string!)")
                        print("  URL: \(value["link"].string!)")
                        print("--------------------------------------------------")
                        isOK = true
                    }
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error")
                    print(error)
                    print(error.localizedDescription)
                    print("--------------------------------------------------")
                    isOK = true
                }
                
                print("------------------------Feed----------------------")
                if !isOK {
                    print("Unknown Error")
                    print("--------------------------------------------------")
                }
            }
        
        newsController.webView.reload()
    }
    
}
