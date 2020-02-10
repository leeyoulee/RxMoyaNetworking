//
//  NetworkService.swift
//  rxMoya_SchoolNews
//
//  Created by 이유리 on 04/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa

struct NetworkService{
    static let provider = MoyaProvider<SchoolProvider>(plugins:[NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])
    
    static func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data
        }
    }
}

extension NetworkService{
    struct SchoolGet {
        static func getSchool(schoolName: String) -> Single<[School]> {
            return requestArray(.schoolGet(schoolName: schoolName), silent: true)
        }
        
        static func getSchoolFood(educationCode: String, schoolCode: String, startDate: String, endDate: String) -> Single<[SchoolFood]> {
            return requestArray(.schoolFoodGet(educationCode: educationCode, schoolCode: schoolCode, startDate: startDate, endDate: endDate))
        }
    }
}

extension NetworkService{
    static func requestArray<T: Codable>(_ api: SchoolProvider, silent: Bool = false) -> Single<[T]> {
        let request = Single<[T]>.create { single in
            let observable = NetworkService.provider.rx
                .request(api)
                .subscribe{ event in
                    switch event {
                    case .success(let response):
                        do {
                            print("network response : \(String(describing:response.response))")
                            
                            guard let responseData = try? response.data else {
                                single(.error(SchoolProvider.Error.failureResponse(api: api, code: .sc_000)))
                                return
                            }
                            
                            if let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String : Any] {
                                // 검색한 결과가 없거나 기타 에러일 때 내려오는 JSON을 Error로 방출
                                if let result = json?["RESULT"] as? [String : Any] {
                                    if let code = result["CODE"] as? String {
                                        let resultCode = SchoolProvider.ResultCode(rawValue: code) ?? .sc_000
                                        single(.error(SchoolProvider.Error.failureResponse(api: api, code: resultCode)))
                                    }
                                }
                                // 검색한 결과가 있을 때 내려오는 JSON은 Success로 방출
                                else {
                                    if let info = json?[api.path] as? [[String : Any]] {
                                        let row = info[1]
                                        let data = row["row"]
                                        
                                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
                                            single(.error(SchoolProvider.Error.failureResponse(api: api, code: .sc_000)))
                                            return
                                        }
                                        guard let datas = try? JSONDecoder().decode([T].self, from: jsonData) else {
                                            single(.error(SchoolProvider.Error.failureResponse(api: api, code: .sc_000)))
                                            return
                                        }
                                        single(.success(datas))
                                    }
                                }
                            }
                        } catch let error {
                            print("network error :\(error.localizedDescription)")
                            single(.error(error))
                        }
                    case .error(let error):
                        print("network error response :\(error.localizedDescription)")
                        single(.error(error))
                    }
            }
            
            return Disposables.create{
                observable.dispose()
            }
            }.observeOn(MainScheduler.instance)
        
        return silent ? request : request.retryWhen{ $0.flatMap { _retry(api: api, error: $0)}}
    }
    
    static func _retry(api: SchoolProvider, error: Error) -> Single<()> {
        return Single.create { single in
            var resultCode: SchoolProvider.ResultCode = .sc_000
            
            if let apiServerError = error as? SchoolProvider.Error, case .failureResponse(let api, let code) = apiServerError {
                if let errors = api.errors, errors.contains(code) {
                    single(.error(error))
                    return Disposables.create()
                }
                resultCode = code
            }
            
            DispatchQueue.main.async {
                let title = "안내"
                let message = "에러코드 : \(resultCode)\n다시 시도하겠습니까?"
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                alert.addAction(UIAlertAction(title: "재시도", style: .default) { _ in
                    single(.success(()))
                })
                UIApplication.topViewController()?.present(alert, animated: false, completion: nil)
            }
            return Disposables.create()
        }
    }
}

extension PrimitiveSequenceType where TraitType == SingleTrait {
    @discardableResult
    func on() -> Disposable {
        return on(success: { _ in }, error: nil)
    }
    
    @discardableResult
    func on(success: @escaping (Self.ElementType) -> Void) -> Disposable {
        return on(success: success, error: nil)
    }
    
    @discardableResult
    func on(success: @escaping (Self.ElementType) -> Void, error errorHandler: ((SchoolProvider.ResultCode) -> Void)? = nil) -> Disposable {
        return subscribe(
            onSuccess: success,
            onError: { error in
                if let apiServerError = error as? SchoolProvider.Error, case .failureResponse(let api, let code) = apiServerError {
                    if let errors = api.errors, errors.contains(code) {
                        errorHandler?(code)
                    }
                }
        })
    }
}

// 상단에 띄워진 뷰컨트롤러를 가져옴
extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
