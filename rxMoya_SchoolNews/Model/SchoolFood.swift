//
//  SchoolFood.swift
//  rxMoya_SchoolNews
//
//  Created by 이유리 on 04/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation

struct SchoolFood: Codable {
    var educationCode:     String? //시도교육청코드
    var schoolCode:        String? //표준학교코드
    var schoolName:        String? //학교명
    var schoolCategory:    String? //학교종류명
    var foodCode:          String? //식사코드
    var foodCategory:      String? //식사명
    var foodDate:          String? //급식일자
    var foodName:          String? //요리명
    var foodInfo:          String? //원산지정보
    
    enum CodingKeys : String, CodingKey {
        case educationCode      = "ATPT_OFCDC_SC_CODE"  //시도교육청코드
        case schoolCode         = "SD_SCHUL_CODE"       //표준학교코드
        case schoolName         = "SCHUL_NM"            //학교명
        case schoolCategory     = "SCHUL_KND_SC_NM"     //학교종류명
        case foodCode           = "MMEAL_SC_CODE"       //식사코드
        case foodCategory       = "MMEAL_SC_NM"         //식사명
        case foodDate           = "MLSV_YMD"            //급식일자
        case foodName           = "DDISH_NM"            //요리명
        case foodInfo           = "ORPLC_INFO"          //원산지정보
    }
    
    init(from decoder: Decoder) throws {
        let values      = try decoder.container(keyedBy: CodingKeys.self)
        educationCode   = try values.decodeIfPresent(String.self, forKey: .educationCode)
        schoolCode      = try values.decodeIfPresent(String.self, forKey: .schoolCode)
        schoolName      = try values.decodeIfPresent(String.self, forKey: .schoolName)
        schoolCategory  = try values.decodeIfPresent(String.self, forKey: .schoolCategory)
        foodCode        = try values.decodeIfPresent(String.self, forKey: .foodCode)
        foodCategory    = try values.decodeIfPresent(String.self, forKey: .foodCategory)
        foodDate        = try values.decodeIfPresent(String.self, forKey: .foodDate)
        foodName        = try values.decodeIfPresent(String.self, forKey: .foodName)
        foodInfo        = try values.decodeIfPresent(String.self, forKey: .foodInfo)
    }
}
