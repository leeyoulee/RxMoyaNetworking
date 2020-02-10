//
//  SchoolProvider.swift
//  rxMoya_SchoolNews
//
//  Created by 이유리 on 04/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//


import Moya

enum SchoolProvider {
    case schoolGet(schoolName: String)
    case schoolFoodGet(educationCode: String, schoolCode: String, startDate: String, endDate: String)
}

extension SchoolProvider: TargetType {
    var headers: [String : String]? {
        return [:]
    }
    
    var baseURL: URL {
        return URL(string: "https://open.neis.go.kr/hub/")!
    }
    
    var path: String {
        switch self {
        case .schoolGet:
            return "schoolInfo"
        case .schoolFoodGet:
            return "mealServiceDietInfo"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .schoolGet, .schoolFoodGet:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        var param:[String : Any] = [:]
        
        switch self {
        case let .schoolGet(schoolName):
            param["KEY"] = "496305ea8af744c7ab2f3ff184078da8"
            param["Type"] = "json"
            param["pIndex"] = 1
            param["pSize"] = 100
            param["SCHUL_NM"] = schoolName
        case let .schoolFoodGet(value):
            param["KEY"] = "496305ea8af744c7ab2f3ff184078da8"
            param["Type"] = "json"
            param["pIndex"] = 1
            param["pSize"] = 100
            param["ATPT_OFCDC_SC_CODE"] = value.educationCode
            param["SD_SCHUL_CODE"] = value.schoolCode
            param["MLSV_FROM_YMD"] = value.startDate
            param["MLSV_TO_YMD"] = value.endDate
        default: return .requestPlain
        }
        
        return .requestParameters(parameters: param, encoding: URLEncoding.default)
    }
    
    var errors: Set<SchoolProvider.ResultCode>? {
        switch self {
        case .schoolGet, .schoolFoodGet:
            return [.sc_200]
        default: return nil
        }
    }
}

extension SchoolProvider {
    enum Error: Swift.Error {
        case serverMaintenance(message: String)
        // 비정상 응답 (오류코드)
        case failureResponse(api: SchoolProvider, code: SchoolProvider.ResultCode)
        // 잘못된 응답 데이터 (발생시 서버 문의)
        case invalidResponseData(api: SchoolProvider)
    }
    
    enum ResultCode: String {
        case sc_000 = "000"
        case sc_200 = "INFO-200"
    }
}
