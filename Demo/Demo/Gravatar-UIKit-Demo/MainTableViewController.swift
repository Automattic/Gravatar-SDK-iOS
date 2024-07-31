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
        case uiImageViewExtension
        case fetchProfile
        case imageUpload
        case profileCard
        case configuration
        case profileViewController
        #if DEBUG
        case displayRemoteSVG
        #endif
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
        case .uiImageViewExtension:
            content.text = "UIImageView Extension"
        case .fetchProfile:
            content.text = "Fetch Profile"
        case .imageUpload:
            content.text = "Image Upload"
        case .profileCard:
            content.text = "Profile Card"
        case .configuration:
            content.text = "Profile Card Configuration"
        case .profileViewController:
            content.text = "Profile View Controller"
        #if DEBUG
        case .displayRemoteSVG:
            content.text = "Display remote SVG"
        #endif
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
        case .uiImageViewExtension:
            let vc = DemoUIImageViewExtensionViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .fetchProfile:
            let vc = DemoFetchProfileViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .imageUpload:
            navigationController?.pushViewController(DemoUploadImageViewController(), animated: true)
        case .profileCard:
            navigationController?.pushViewController(DemoProfileViewsViewController(), animated: true)
        case .configuration:
            show(DemoProfileConfigurationViewController(style: .insetGrouped), sender: nil)
        case .profileViewController:
            navigationController?.pushViewController(DemoProfilePresentationStylesViewController(), animated: true)
        #if DEBUG
        case .displayRemoteSVG:
            navigationController?.pushViewController(DemoRemoteSVGViewController(), animated: true)
        #endif
        }
    }
}
