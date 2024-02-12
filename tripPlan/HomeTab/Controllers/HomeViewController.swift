//
//  HomeViewController.swift
//  tripPlan
//
//  Created by 이순곤 on 2023/11/19.
//

import UIKit

class HomeViewController: UITableViewController {

    let items = ["ニューヨーク🗽", "韓国🇰🇷"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
            cell.textLabel?.text = items[indexPath.row]
            return cell
    }
    
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        let tabbar = UIStoryboard.init(name: "HomeTab", bundle: nil)
        guard let tabBarController = tabbar.instantiateViewController(withIdentifier: "AddTripViewController")as? AddTripViewController else {return}
        self.navigationController?.pushViewController(tabBarController, animated: true)
    }
}
