//
//  School.swift
//  rxMoya_SchoolNews
//
//  Created by 이유리 on 04/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation

struct School: Codable {
    var educationCode:     String? //시도교육청코드
    var schoolCode:        String? //표준학교코드
    var schoolName:        String? //학교명
    var schoolCategory:    String? //학교종류명
    var schoolAddress:     String? //도로명주소
    var schoolFoundation:  String? //설립명
    
    enum CodingKeys : String, CodingKey {
        case educationCode      = "ATPT_OFCDC_SC_CODE"  //시도교육청코드
        case schoolCode         = "SD_SCHUL_CODE"       //표준학교코드
        case schoolName         = "SCHUL_NM"            //학교명
        case schoolCategory     = "SCHUL_KND_SC_NM"     //학교종류명
        case schoolAddress      = "ORG_RDNMA"           //도로명주소
        case schoolFoundation   = "FOND_SC_NM"          //설립명
    }
    
    init(from decoder: Decoder) throws {
        let values          = try decoder.container(keyedBy: CodingKeys.self)
        educationCode       = try values.decodeIfPresent(String.self, forKey: .educationCode)
        schoolCode          = try values.decodeIfPresent(String.self, forKey: .schoolCode)
        schoolName          = try values.decodeIfPresent(String.self, forKey: .schoolName)
        schoolCategory      = try values.decodeIfPresent(String.self, forKey: .schoolCategory)
        schoolAddress       = try values.decodeIfPresent(String.self, forKey: .schoolAddress)
        schoolFoundation    = try values.decodeIfPresent(String.self, forKey: .schoolFoundation)
    }
}
