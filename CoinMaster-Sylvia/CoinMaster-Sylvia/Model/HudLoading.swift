//
//  HudLoading.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/11.
//

import Foundation
import JGProgressHUD

class HudLoading {
    static let shared = HudLoading()
    
    private let hud = JGProgressHUD()
    
    private init() {}
    
    func setHud(view: UIView) {
        DispatchQueue.main.async {
            self.hud.textLabel.text = "Loading"
            self.hud.show(in: view)
        }
    }
    
    func dismissHud() {
        DispatchQueue.main.async {
            self.hud.dismiss()
        }
    }
}
