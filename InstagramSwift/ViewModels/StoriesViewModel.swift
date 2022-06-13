//
//  StoriesViewModel.swift
//  InstagramSwift
//
//  Created by Ivan Potapenko on 13.06.2022.
//

import UIKit

struct StoriesViewModel {
    let stories: [Story]
}

struct Story {
    let username: String
    let image: UIImage?
}
