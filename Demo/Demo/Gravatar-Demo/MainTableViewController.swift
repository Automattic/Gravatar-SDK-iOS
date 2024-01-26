//
//  MainTableViewController.swift
//  Gravatar-Demo
//
//  Created by Pinar Olguc on 24.01.2024.
//

import Foundation
import UIKit

class MainTableViewController: UITableViewController {

    enum Row: Int, CaseIterable {
        case imageDownloadNetworking
    }
    
    private static let reuseID =  "DefaultCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.reuseID)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = Row(rawValue: indexPath.row) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.reuseID, for: indexPath)
        var content = cell.defaultContentConfiguration()

        switch row {
        case .imageDownloadNetworking:
            content.text = "Image download - Networking"
            break
        }
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = Row(rawValue: indexPath.row) else { return }
        
        switch row {
        case .imageDownloadNetworking:
            let vc = DemoAvatarDownloadViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
