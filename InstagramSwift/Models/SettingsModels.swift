//
//  SettingsModels.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 11.06.2022.
//

import Foundation
import UIKit

struct SettingsSection {
    let title: String
    let options: [SettingOption]
}

struct SettingOption {
    let title: String
    let image: UIImage?
    let color: UIColor
    let handler: (() -> Void)
}
