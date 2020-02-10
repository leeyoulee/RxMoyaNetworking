//
//  MonthFoodListViewController.swift
//  rxMoya_SchoolNews
//
//  Created by 이유리 on 06/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MonthFoodListViewController: UIViewController {
    
    @IBOutlet weak var monthFoodListTableView: UITableView!
    @IBOutlet weak var nonSchoolFoodDataView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    
    var monthFoodRelayData = BehaviorRelay<[SchoolFood]>(value: [])
    var registedSchool = BehaviorRelay<School?>(value: nil)
    var currentDate = BehaviorRelay<Date>(value: Date())
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeUI()
        self.setTableView()
    }
    
    @IBAction func previousMonthButtonAction(_ sender: UIButton) {
        self.currentDate.accept(self.currentDate.value.previousMonth)
    }
    
    @IBAction func nextMonthButtonAction(_ sender: UIButton) {
        self.currentDate.accept(self.currentDate.value.nextMonth)
    }
    
}

// MARK: UI Binding
extension MonthFoodListViewController {
    func initializeUI() {
        if let schoolName = self.registedSchool.value?.schoolName {
            self.title = schoolName + " 한달치 급식"
        }
        
        self.currentDate.accept(Date())
        // 상단 날짜 변경되면 문구 변경
        self.currentDate.subscribe({ [weak self] data in
            guard let `self` = self else { return }
            // 상단에 보여지는 달의 첫날과 마지막날을 구함
            let sdate = self.formatDate(format: "yyyyMMdd", date: self.currentDate.value.startOfMonth)
            let edate = self.formatDate(format: "yyyyMMdd", date: self.currentDate.value.endOfMonth)
            
            self.monthLabel?.text = self.formatDate(format: "yyyy년 M월", date: self.currentDate.value)
            self.requestData(sDate: sdate, eDate: edate)
        }).disposed(by: disposeBag)
    }
    
    func setTableView() {
        self.monthFoodListTableView.isHidden = true
        self.nonSchoolFoodDataView.isHidden = false
        
        monthFoodListTableView.estimatedRowHeight = 100.0
        monthFoodListTableView.rowHeight = UITableView.automaticDimension
        monthFoodListTableView.register(UINib(nibName: SchoolFoodListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SchoolFoodListTableViewCell.identifier)
        
        // food값이 변경되면 테이블뷰 재구성
        self.monthFoodRelayData.asDriver(onErrorJustReturn: []).drive(self.monthFoodListTableView.rx.items(cellIdentifier: SchoolFoodListTableViewCell.identifier, cellType: SchoolFoodListTableViewCell.self)) { [weak self] _, element, cell in
            guard let `self` = self else { return }
            cell.foodServiceDateLabel?.text = element.foodDate
            cell.foodCategoryLabel?.text = element.foodCategory
            // 문자열에 <br/>로 되어있는 부분을 줄바꿈처리
            let foodString = element.foodName?.replacingOccurrences(of: "<br/>", with: "\n")
            cell.foodNameLabel?.text = foodString
            }.disposed(by: self.disposeBag)
    }
    /// 날짜는 원하는 형식으로 포맷하는 함수
    func formatDate(format formatString: String, date: Date) -> String {
        let format = DateFormatter()
        format.locale = Locale(identifier: "ko_kr")
        format.timeZone = TimeZone(abbreviation: "KST")
        format.dateFormat = formatString
        
        return format.string(from: date)
    }
}

// MARK: Data Requset
extension MonthFoodListViewController {
    /// 등록한 학교에 대한 급식 정보를 요청
    func requestData(sDate: String, eDate: String) {
        if let data = self.registedSchool.value {
            
            NetworkService.SchoolGet.getSchoolFood(educationCode: data.educationCode ?? "", schoolCode: data.schoolCode ?? "", startDate: sDate, endDate: eDate).on(success: { [weak self] result in
                guard let `self` = self else { return }
                print("result : \(result)")
                DispatchQueue.main.async {
                    self.monthFoodRelayData.accept(result)
                    self.nonSchoolFoodDataView.isHidden = true
                    self.monthFoodListTableView.isHidden = false
                }
                }, error: { error in
                    print("**error** : \(error)")
                    if error == .sc_200 {
                        DispatchQueue.main.async {
                            self.monthFoodListTableView.isHidden = true
                            self.nonSchoolFoodDataView.isHidden = false
                        }
                    }
            }).disposed(by: disposeBag)
        }
    }
}
