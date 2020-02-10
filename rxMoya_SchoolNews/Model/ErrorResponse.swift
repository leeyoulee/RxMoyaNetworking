//
//  ErrorResponse.swift
//  rxMoya_SchoolNews
//
//  Created by 이유리 on 05/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    var code:        String?
    var message:     String?
    
    enum CodingKeys : String, CodingKey {
        case code        = "CODE"
        case message     = "MESSAGE"
    }
    
    init(from decoder: Decoder) throws {
        let values       = try decoder.container(keyedBy: CodingKeys.self)
        code             = try values.decodeIfPresent(String.self, forKey: .code)
        message          = try values.decodeIfPresent(String.self, forKey: .message)
    }
}
