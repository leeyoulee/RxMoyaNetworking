//
//  Response.swift
//  rxMoya_SchoolNews
//
//  Created by 이유리 on 05/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation

struct ResultResponse: Codable {
    var header:     String?
    var result:     String?
    
    enum CodingKeys : String, CodingKey {
        case header      = "head"
        case result      = "row"
    }
    
    init(from decoder: Decoder) throws {
        let values       = try decoder.container(keyedBy: CodingKeys.self)
        header           = try values.decodeIfPresent(String.self, forKey: .header)
        result           = try values.decodeIfPresent(String.self, forKey: .result)
    }
}
