//
//  AlertUtils.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/10.
//

import Foundation
import UIKit

class AlertUtils {
    static func alert(title: String, message: String, from viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
