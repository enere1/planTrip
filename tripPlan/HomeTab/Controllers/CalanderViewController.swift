//
//  ViewController.swift
//  tripPlan
//
//  Created by 이순곤 on 2024/01/16.
//

import UIKit
import FSCalendar
import RxCocoa
import RxSwift
import Foundation

class CalanderViewController: UIViewController  {

    @IBOutlet weak var calender: FSCalendar!
    let disposeBag = DisposeBag()
    var selectedDates: Set<Date> = []
    var selectButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calender.allowsMultipleSelection = true
        calender.swipeToChooseGesture.isEnabled = true
        calender.delegate = self
        calender.dataSource = self
        
       
    }
    
}

extension CalanderViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        
        return appearance.selectionColor
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            selectedDates.insert(date)
            if selectedDates.count > 1 {
                let sortedDates = selectedDates.sorted { $0 < $1 }
                let firstDay = sortedDates[0]
                let lastDay = sortedDates[sortedDates.count - 1]
                let dateRange = DateInterval(start: firstDay, end: lastDay)
                let dayInterval: TimeInterval = 24 * 60 * 60
                for day in stride(from: dateRange.start, through: dateRange.end, by: dayInterval) {
                    let calendar = Calendar.current
                    let selectDate = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: day))
                    calender.select(selectDate)
                    selectedDates.insert(day)
                }
                
                selectButton = UIButton()
                selectButton.addTarget(self, action: #selector(tabSelectButton), for: .touchUpInside)
                selectButton.translatesAutoresizingMaskIntoConstraints = false
                let dateFormatterForOutput = DateFormatter()
                dateFormatterForOutput.dateFormat = "MM月dd日"
                let stringStartDay = dateFormatterForOutput.string(from: firstDay)
                let stringLastDay = dateFormatterForOutput.string(from: lastDay)
                selectButton.setTitle("\(stringStartDay)から\(stringLastDay)まで選択", for: .normal)
                selectButton.titleLabel!.textAlignment = .center
                selectButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                
                selectButton.backgroundColor = UIColor(hue: 0.5917, saturation: 0.79, brightness: 1, alpha: 1.0)
                selectButton.tintColor = .clear //.white
                self.view.addSubview(selectButton)
                NSLayoutConstraint.activate([
                    selectButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                    selectButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                    selectButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
                ])
                
            }
            
            // Assuming calender is a UIView subclass
            calendar.reloadData()
    }

    
    @objc func tabSelectButton(_ sender: tableSelectButton) {
        let planTab = UIStoryboard.init(name: "PlanTab", bundle: nil)
        if let tabBarController = planTab.instantiateViewController(withIdentifier: "PlanTabViewController") as? PlanTabViewController {
            self.navigationController?.pushViewController(tabBarController, animated: true)
            tabBarController.titleLabelText = "東京"
            tabBarController.durationLabelText = "2023年2月12日~2023年2月16日"

        } else {
            print("Failed to instantiate PlanTabViewController from storyboard.")
        }

    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDates.remove(date)
        if selectedDates.count > 1 {
            let sortedDates = selectedDates.sorted { $0 < $1 }
            let firstDay = sortedDates[0]
            let lastDay = sortedDates[sortedDates.count - 1]
            let dateFormatterForOutput = DateFormatter()
            dateFormatterForOutput.dateFormat = "MM月dd日"
            let stringStartDay = dateFormatterForOutput.string(from: firstDay)
            let stringLastDay = dateFormatterForOutput.string(from: lastDay)
            selectButton.setTitle("\(stringStartDay)から\(stringLastDay)まで選択", for: .normal)
        }
            
        if selectedDates.count == 1{
            selectButton.removeFromSuperview()
            self.viewDidLoad()
        }
    }
}

