//
//  UserDashboardViewController.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/10.
//

import UIKit
import CoinMasterInfoKit

class UserDashboardViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userUIDLabel: UILabel!
    @IBOutlet weak var activeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activeButton.layer.cornerRadius = 5
        self.activeButton.layer.shadowColor = UIColor.black.cgColor
        self.activeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.activeButton.layer.shadowOpacity = 0.15
        self.activeButton.layer.shadowRadius = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CoinbaseService.shared.getApiResponse(api: .profile,
                                              authRequired: true,
                                              requestPath: .profile) { (profiles: [Profile]) in
            guard let profile = profiles.first else { return }
            DispatchQueue.main.async {
                self.userNameLabel.text = profile.name
                self.userUIDLabel.text = "UID: \(profile.userId)"
                let active = profile.active
                if active {
                    self.activeButton.setTitle("身份認證成功", for: .normal)
                } else {
                    self.activeButton.setTitle("身份認證失敗", for: .normal)
                }
            }
        }
    }
}
