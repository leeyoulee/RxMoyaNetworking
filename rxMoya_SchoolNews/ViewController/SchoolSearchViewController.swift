//
//  SchoolSearchViewController.swift
//  rxMoya_SchoolNews
//
//  Created by 이유리 on 06/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol SchoolRegistDataDelegate: class {
    func registData(data: School)
}

class SchoolSearchViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var schoolListTableView: UITableView!
    @IBOutlet weak var nonSearchDataView: UIView!
    @IBOutlet weak var searchCountLabel: UILabel!
    @IBOutlet weak var searchCountView: UIView!
    
    var schoolRelayData = BehaviorRelay<[School]>(value: [])
    
    var searchText: String?
    weak var delegate: SchoolRegistDataDelegate?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeUI()
        self.setTableView()
        self.searchAction()
    }
    
    deinit {
        print("SchoolSearchViewController ----> Deinit")
    }
    
}

extension SchoolSearchViewController {
    func initializeUI() {
        self.title = "학교 검색"
        self.schoolRelayData.subscribe({ [weak self] value in
            guard let `self` = self else { return }
            if let element = value.element {
                let count = String(describing: element.count)
                self.searchCountLabel?.text = "검색결과" + count + "개"
            }
        }).disposed(by: disposeBag)
    }
    
    func setTableView() {
        self.nonSearchDataView.isHidden = false
        self.schoolListTableView.isHidden = true
        
        schoolListTableView.register(UINib(nibName: SchoolListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SchoolListTableViewCell.identifier)
        
        // school값이 변경되면 테이블뷰 재구성
        self.schoolRelayData.asDriver(onErrorJustReturn: []).drive(self.schoolListTableView.rx.items(cellIdentifier: SchoolListTableViewCell.identifier, cellType: SchoolListTableViewCell.self)) { [weak self] _, element, cell in
            guard let _ = self else { return }
            cell.schoolNameLabel?.text = element.schoolName
            cell.schoolAddressLabel?.text = element.schoolAddress
            
            cell.buttonActionHandler = { [weak self] in
                guard let `self` = self else { return }
                // 등록 버튼을 클릭하면 클릭한 학교를 MainViewController로 넘겨주고, 화면 닫음
                self.delegate?.registData(data: element)
                UserDefaults.standard.set(try? PropertyListEncoder().encode(element), forKey:"SchoolDataKey")
                self.navigationController?.popViewController(animated: true)
            }
            }.disposed(by: self.disposeBag)
    }
    
    func searchAction() {
        //text 값을 옵셔널 타입(String?)이 아닌 String으로 받아오기 위해 orEmpty 사용
        searchTextField.rx.text.orEmpty.subscribe(onNext: { [weak self] text in
            guard let `self` = self else { return }
            self.searchText = text
            self.requestData()
        }).disposed(by: disposeBag)
        
        searchButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if let text = self.searchText {
                self.requestData()
            }
        }).disposed(by: disposeBag)
    }
}

// MARK: Data Request
extension SchoolSearchViewController {
    func requestData() {
        //school 값을 받아와서 schoolRelayData에 넣어주면 테이블뷰 리로드됨
        NetworkService.SchoolGet.getSchool(schoolName: self.searchText!).on(success: {[weak self] result in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.nonSearchDataView.isHidden = true
                self.schoolListTableView.isHidden = false
                self.searchCountView.isHidden = false
                self.searchCountLabel.isHidden = false
            }
            self.schoolRelayData.accept(result)
            }, error: {  error in
                print("**error** : \(error)")
                if error == .sc_200 {
                    DispatchQueue.main.async {
                        self.nonSearchDataView.isHidden = false
                        self.schoolListTableView.isHidden = true
                        self.searchCountView.isHidden = true
                        self.searchCountLabel.isHidden = true
                    }
                }
        }).disposed(by: disposeBag)
    }
}
