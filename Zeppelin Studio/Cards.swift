//
//  Cards.swift
//  Zeppelin Studio
//
//  Created by Matt on 29/04/2019.
//  Copyright © 2019 mindelicious. All rights reserved.
//

import Foundation

struct Card: Decodable {
    let name: String
    let ownerName: String
    let phone: String
    let mail: String
    let bio: String
   
}
