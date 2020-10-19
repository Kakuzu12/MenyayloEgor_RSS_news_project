//
//  PickerView.swift
//  News
//
//  Created by Егор Меняйло on 12.10.2020.
//

import UIKit
//MARK: - ProtocolDeclaration
protocol TransferResource: NSObjectProtocol {
    func transferResource(resourceToParse: String)
}

final class ResourcePicker: UIViewController{
//MARK: - PropertyDeclaration
    private let tableView = UITableView()
    private var safeArea: UILayoutGuide!
    private let defaults = UserDefaults.standard
    private var resources: [String] = ["https://www.banki.ru/xml/news.rss"]
    weak var delegate: TransferResource?
    private enum Locals {
        static let cellID = "cell"
        static let cellHeight: CGFloat = 100
        static let numberOfSections: Int = 1
    }
//MARK: - ViewControllerLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Источники"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        setupTableView()
        self.navigationItem.rightBarButtonItem = setupButton()
    }
//MARK: - UIAndActionSetup
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
    }
    
    private func setupButton() -> UIBarButtonItem{
        let plusCircleButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle"), style: .done, target: self, action: #selector(handleAddButton))
        plusCircleButton.accessibilityIdentifier = "plusCircleButton"
        return plusCircleButton
    }
    
    @objc private func handleAddButton(){
        let alertController = UIAlertController(title: "Новый источник", message: "Введите свой источник", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Название источника"
        }
        let saveAction = UIAlertAction(title: "Enter", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            guard let name = firstTextField.text else { return }
            guard let url = URL(string: name) else {return}
            
            let parserToCheck : XmlParserManager = XmlParserManager().initWithURL(url) as! XmlParserManager
            
            guard parserToCheck.feeds.count != 0 else{
                DispatchQueue.main.async{
                    let alertController = UIAlertController(title: "Ошибка", message: "Некорректно введен адрес!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: { (action : UIAlertAction!) -> Void in
                    })
                    
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            
            if self.defaults.object(forKey: "array") == nil{
                self.resources.append(name)
                self.defaults.set(self.resources, forKey: "array")
            }else{
                self.resources = self.defaults.object(forKey: "array") as! [String]
                if self.resources.contains(name){
                }else{
                    self.resources.append(name)
                    self.defaults.set(self.resources, forKey: "array")
                }
            }
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action : UIAlertAction!) -> Void in
        })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
//MARK: - TableViewConfiguration
extension ResourcePicker: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.defaults.object(forKey: "array") == nil{
            self.defaults.set(self.resources, forKey: "array")
        }
        let finalResources = self.defaults.object(forKey: "array") as! [String]
        return finalResources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Locals.cellID)
        if self.defaults.object(forKey: "array") == nil{
            self.defaults.set(self.resources, forKey: "array")
        }
        
        let finalResources = self.defaults.object(forKey: "array") as! [String]
        
        cell?.textLabel?.text = finalResources[indexPath.row]
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
        let finalResources = self.defaults.object(forKey: "array") as! [String]
        self.delegate!.transferResource(resourceToParse: finalResources[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
}

