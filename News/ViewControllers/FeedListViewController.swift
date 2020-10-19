//
//  FeedListViewController.swift
//  News
//
//  Created by Егор Меняйло on 14.10.2020.
//

//
//  FeedListViewController.swift
//  News
//
//  Created by Егор Меняйло on 11.10.2020.
//

import UIKit

final class FeedListViewController: UIViewController, XMLParserDelegate {
//MARK: - PropertyDeclaration
    private let tableView = UITableView()
    private let resourcePicker = ResourcePicker()
    private let defaults = UserDefaults.standard
    private var resourceToParse = "https://www.banki.ru/xml/news.rss"
    private var readNew: [String] = []
    private var myFeed : NSArray = []
    private var readNews: [Int] = []
    private var url: URL!
    private var safeArea: UILayoutGuide!
    private let refreshControl = UIRefreshControl()
    private enum Locals {
        static let cellID = "cell"
        static let cellHeight: CGFloat = 140
        static let numberOfSections: Int = 1
    }
//MARK: - ViewControllerLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Список новостей"
        
        tableView.delegate = self
        tableView.dataSource = self
        resourcePicker.delegate = self
        tableView.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        
        self.navigationItem.rightBarButtonItem = setupButton()
        setupTableView()
        loadData()
    }
//MARK: - LoadDataSetup
    @objc private func loadData() {
        url = URL(string: resourceToParse)!
        loadRss(url)
    }
    
    private func loadRss(_ data: URL) {
        let myParser : XmlParserManager = XmlParserManager().initWithURL(data) as! XmlParserManager
        
        myFeed = myParser.feeds
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
        self.refreshControl.endRefreshing()
        }
    }
//MARK: - UIAndActionSetup
    private func setupButton() -> UIBarButtonItem{
        let choiceButton = UIBarButtonItem.init(title: "Источник", style: .plain, target: self, action: #selector(self.handleButtonPress))
        return choiceButton
    }
    
    @objc private func handleButtonPress() {
       self.navigationController?.pushViewController(resourcePicker,animated: true)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Locals.cellID)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Обновляем данные ...")
    }
}
//MARK: - TableViewConfiguration
extension FeedListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Locals.cellID)
        
        if self.defaults.object(forKey: self.resourceToParse) == nil{
            readNew = []
        }else{
            readNew = self.defaults.object(forKey: self.resourceToParse) as! [String]
        }
        let str = (myFeed.object(at: indexPath.row) as AnyObject).object(forKey: "pubDate") as? String

        if self.readNew.contains(str!){
            cell?.textLabel?.backgroundColor = .gray
        }else{
            cell?.textLabel?.backgroundColor = .clear
        }
        
        let str1 = (myFeed.object(at: indexPath.row) as AnyObject).object(forKey: "title") as? String
        
        cell?.textLabel?.text = str1! + "\n" + str!
        cell?.textLabel?.textColor = UIColor.darkGray
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.lineBreakMode = .byWordWrapping
        cell?.textLabel?.textAlignment = .center
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Locals.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Locals.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController: FeedItemWebViewController = FeedItemWebViewController()
        let dict: NSDictionary = self.myFeed[indexPath.row] as! NSDictionary
        let str = (myFeed.object(at: indexPath.row) as AnyObject).object(forKey: "pubDate") as? String
        
        viewController.selectedFeedURL = (dict["link"] as! String)
        
        if self.readNew.contains(str!){
        }else{
            self.readNew.append(str!)
        }
        
        self.defaults.set(self.readNew, forKey: self.resourceToParse)
        self.navigationController?.pushViewController(viewController,animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
}

//MARK: - ProtocolImplementation
extension FeedListViewController: TransferResource{
    
    func transferResource(resourceToParse: String){
        self.defaults.set(self.readNew, forKey: self.resourceToParse)
        guard let value = self.defaults.object(forKey: resourceToParse) else {
            self.readNew = []
            self.defaults.set(self.readNew, forKey: resourceToParse)
            self.resourceToParse = resourceToParse
            self.loadData()
            return
        }
        self.resourceToParse = resourceToParse
        self.readNew = value as! [String]
        self.loadData()
    }
}


