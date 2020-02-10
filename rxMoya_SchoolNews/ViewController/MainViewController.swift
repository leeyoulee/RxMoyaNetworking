//
//  ViewController.swift
//  rxMoya_SchoolNews
//
//  Created by 이유리 on 04/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController, SchoolRegistDataDelegate {
    
    @IBOutlet weak var schoolNewsTableView: UITableView!
    @IBOutlet weak var emptyEnrolledSchoolView: UIView!
    @IBOutlet weak var nonSchoolFoodDataView: UIView!
    @IBOutlet weak var moveToMonthFoodVCButton: UIButton!
    
    /// 등록된 학교있는지 없는지
    var isEnrolledSchool = BehaviorRelay<Bool>(value: false)
    /// 등록된 학교있을때 해당 학교 데이터 저장
    var registedSchoolData = BehaviorRelay<School?>(value: nil)
    var foodRelayData = BehaviorRelay<[SchoolFood]>(value: [])
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeUI()
        self.setTableView()
        
        if let data = UserDefaults.standard.value(forKey:"SchoolDataKey") as? Data {
            let songs2 = try? PropertyListDecoder().decode(School.self, from: data)
            self.registedSchoolData.accept(songs2)
            self.isEnrolledSchool.accept(true)
            self.schoolNewsTableView.reloadData()
        }
    }
    
    deinit {
        print("MainViewController ----> Deinit")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.enrollSchool {
            if let schoolSearchVC = segue.destination as? SchoolSearchViewController {
                schoolSearchVC.delegate = self
            }
        } else if segue.identifier == Segue.monthFoodList {
            if let monthFoodListVC = segue.destination as? MonthFoodListViewController {
                // 한달치 급식화면으로 이동하면, 등록된 학교 데이터를 넘겨줌
                monthFoodListVC.registedSchool = self.registedSchoolData
            }
        }
    }
    
    
    @IBAction func schoolEnrollButtonAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segue.enrollSchool, sender: self)
    }
    
    @IBAction func schoolDeleteButtonActioin(_ sender: UIBarButtonItem) {
        self.registedSchoolData.accept(nil)
        self.isEnrolledSchool.accept(false)
        UserDefaults.standard.removeObject(forKey: "SchoolDataKey")
    }
    
    @IBAction func moveToMonthFoodListVC(_ sender: UIButton) {
        if let schoolData = self.registedSchoolData.value {
            self.performSegue(withIdentifier: Segue.monthFoodList, sender: self)
        }
    }
    
}


extension MainViewController {
    struct Segue {
        static let enrollSchool     = "enrollSchoolSegue"
        static let monthFoodList    = "monthFoodListSegue"
    }
    
    // SchoolRegistDataDelegate 함수 오버라이딩
    func registData(data: School) {
        // 받아온 데이터를 테이블뷰에 로드하기위해 accept해주고, 등록된 학교 있는걸로 변경
        self.registedSchoolData.accept(data)
        self.isEnrolledSchool.accept(true)
        print("registedSchoolData : \(self.registedSchoolData.value)")
    }
}

// MARK: UI Binding
extension MainViewController {
    func initializeUI() {
        isEnrolledSchool.subscribe(onNext: { [weak self] value in
            guard let `self` = self else { return }
            // 등록된 학교있으면 해당학교에 대한 소식띄움
            if value {
                self.title = self.registedSchoolData.value?.schoolName
                self.navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.emptyEnrolledSchoolView.isHidden = true
                self.schoolNewsTableView.isHidden = false
                self.nonSchoolFoodDataView.isHidden = false
                self.requestData()
            }
                // 등록된 학교없으면 등록하라는 화면띄움
            else {
                self.title = "학교 소식"
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                self.emptyEnrolledSchoolView.isHidden = false
                self.schoolNewsTableView.isHidden = true
                self.nonSchoolFoodDataView.isHidden = true
            }
        }).disposed(by: disposeBag)
    }
    
    func setTableView() {
        schoolNewsTableView.estimatedRowHeight = 100.0
        schoolNewsTableView.rowHeight = UITableView.automaticDimension
        schoolNewsTableView.register(UINib(nibName: SchoolFoodListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SchoolFoodListTableViewCell.identifier)
        
        // food값이 변경되면 테이블뷰 재구성
        self.foodRelayData.asDriver(onErrorJustReturn: []).drive(self.schoolNewsTableView.rx.items(cellIdentifier: SchoolFoodListTableViewCell.identifier, cellType: SchoolFoodListTableViewCell.self)) { [weak self] _, element, cell in
            guard let _ = self else { return }
            cell.foodServiceDateLabel?.text = element.foodDate
            cell.foodCategoryLabel?.text = element.foodCategory
            // 문자열에 <br/>로 되어있는 부분을 줄바꿈처리
            let foodString = element.foodName?.replacingOccurrences(of: "<br/>", with: "\n")
            cell.foodNameLabel?.text = foodString
            }.disposed(by: self.disposeBag)
        
        
        
        
        self.schoolNewsTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                if let schoolData = self.registedSchoolData.value {
                    self.performSegue(withIdentifier: Segue.monthFoodList, sender: self)
                }
            }).disposed(by: self.disposeBag)
    }
}


// MARK: Data Requset
extension MainViewController {
    /// 등록한 학교에 대한 급식 정보를 요청
    func requestData() {
        // 현재 날짜를 yyyymmdd 형식으로 포맷함
        let now = Date()
        let formatDate = DateFormatter()
        formatDate.locale = Locale(identifier: "ko_kr")
        formatDate.timeZone = TimeZone(abbreviation: "KST")
        formatDate.dateFormat = "yyyyMMdd"
        let date = formatDate.string(from: now)
        print("Maindate ===== \(date)")
        
        if let data = self.registedSchoolData.value {
            NetworkService.SchoolGet.getSchoolFood(educationCode: data.educationCode ?? "", schoolCode: data.schoolCode ?? "", startDate: date, endDate: date).on(success: { [weak self] result in
                guard let `self` = self else { return }
                print("result : \(result)")
                DispatchQueue.main.async {
                    self.nonSchoolFoodDataView.isHidden = true
                    self.schoolNewsTableView.isHidden = false
                    self.foodRelayData.accept(result)
                }
                }, error: { error in
                    print("**error** : \(error)")
                    if error == .sc_200 {
                        DispatchQueue.main.async {
                            self.nonSchoolFoodDataView.isHidden = false
                            self.schoolNewsTableView.isHidden = true
                        }
                    }
            }).disposed(by: disposeBag)
        }
    }
}
