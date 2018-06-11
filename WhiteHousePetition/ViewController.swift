//
//  ViewController.swift
//  WhiteHousePetition
//
//  Created by Daniel Aditya Istyana on 6/5/18.
//  Copyright © 2018 Daniel Aditya Istyana. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var petitions = [[String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Parsing JSON"
        
//        let urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        DispatchQueue.global(qos: .userInitiated) .async {
            [unowned self] in
            if let url = URL(string: urlString) {
                if let data = try? String(contentsOf: url) {
                    let json = JSON(parseJSON: data)
                    if json["metadata"]["responseInfo"]["status"].intValue == 200 {
                        self.parseJson(json: json)
                        return
                    }
                }
            }
            self.showError()
        }
        
//        if let url  = URL(string: urlString) {
//            if let data =  try? String(contentsOf: url) {
//                let json = JSON(parseJSON: data)
//                if json["metadata"]["responseInfo"]["status"].intValue == 200 {
//                    parseJson(json: json)
//                    return
//                }
//            }
//        }
//        showError()
    }
    
    func parseJson(json: JSON) {
        for result in json["results"].arrayValue {
            let title = result["title"].stringValue
            let body = result["body"].stringValue
            let sigs = result["signatureCount"].stringValue
            let obj = ["title": title, "body": body, "sigs": sigs]
            petitions.append(obj)
        }
        print(petitions)
        DispatchQueue.main.async {
            [unowned self] in self.tableView.reloadData()
        }
    }
    
    func showError() {
        DispatchQueue.main.async {
            [unowned self] in
            let ac = UIAlertController(title: "Loading Error", message: "Please check your internet connection", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(ac, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition["title"]
        cell.detailTextLabel?.text = petition["body"]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

