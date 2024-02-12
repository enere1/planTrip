//
//  AddTripViewController.swift
//  tripPlan
//
//  Created by 이순곤 on 2024/01/07.
//

import Foundation
import UIKit
import TimelineTableViewCell
import RxCocoa
import RxSwift

class AddTripViewController: UIViewController {
    var delegate: SearchPlanDataBackDelegate?
    @IBOutlet weak var tableView: UITableView!
    var planIndex: Int?
    let tripVM = TripViewModel()
    let disposeBag = DisposeBag()
    var selectedItemStack = [Int]()
    var scrollView = UIScrollView()
    var contentView = UIView()
    var stackView = UIStackView()
    var selectButton = UIButton()
    var viewBottomConstraint: NSLayoutConstraint?
    var viewTopConstraint: NSLayoutConstraint?
    var tagIndex = 0
    var selectPlaceList = [String]()
    var textLabel = UILabel()
    var selectedSearchPlan = [TripModel]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        selectButton = UIButton()
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        selectButton.setTitle("選択完了", for: .normal)
        selectButton.titleLabel!.textAlignment = .center
        selectButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        selectButton.backgroundColor = UIColor(hue: 0.5917, saturation: 0.79, brightness: 1, alpha: 1.0)
        selectButton.tintColor = .clear //.white
        self.view.addSubview(selectButton)
        NSLayoutConstraint.activate([
            selectButton.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 10),
            selectButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            selectButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            selectButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
        //setupTableView()
        let searchPlanTableViewCellNib = UINib(nibName: "SearchPlanTableViewCell", bundle: Bundle(for: SearchPlanTableViewCell.self))
        self.tableView.register(searchPlanTableViewCellNib, forCellReuseIdentifier: "SearchPlanTableCell")
        let addTripDataSource = AddTripDataSource()
            
        tripVM.tripList.bind(to: tableView.rx.items(dataSource: addTripDataSource)).disposed(by: disposeBag)
        addTripDataSource.updateConstraintClosure = { [weak self] sectionIdex, rowIndex, button  in
            guard let self = self else { return }
            var newTrip = tripVM.tripList.value
            let sortedCategories = Set(newTrip.map { $0.category }).sorted { (category1, category2) in
                return category1.localizedStandardCompare(category2) == .orderedAscending
            }
            let category = Array(sortedCategories)[sectionIdex]
            let categoryItems = newTrip.filter { $0.category == category }
            var tripModel = categoryItems[rowIndex]
            if let index = newTrip.firstIndex(where: { $0.orderNo == tripModel.orderNo }) {
                // 찾은 요소의 buttonIsEnabled 속성을 false로 설정
                newTrip[index].buttonIsEnabled = false
                selectedSearchPlan.append(tripModel)
     
                // 변경된 배열을 다시 BehaviorRelay에 반영
                tripVM.tripList.accept(newTrip)
            }
            
            if stackView.arrangedSubviews.count == 0 {
                // 기존 코드 유지
                viewBottomConstraint?.isActive = false
                viewTopConstraint?.isActive = false
                
                viewTopConstraint = self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 80)
                viewTopConstraint?.isActive = true
                
                scrollView = UIScrollView()
                scrollView.translatesAutoresizingMaskIntoConstraints = false
                scrollView.showsHorizontalScrollIndicator = true
                scrollView.showsVerticalScrollIndicator = false
                self.view.addSubview(scrollView)
                
                NSLayoutConstraint.activate([
                    scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
                    scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                    scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
                    scrollView.bottomAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 0)
                ])
                scrollView.contentSize = CGSize(width: 1000, height: 80)
                contentView = UIView()
                contentView.translatesAutoresizingMaskIntoConstraints = false
                
                contentView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.98, alpha: 1.0) /* #fbfbfb */
                self.scrollView.addSubview(contentView)
                
                NSLayoutConstraint.activate([
                    contentView.topAnchor.constraint(equalTo: scrollView.frameLayoutGuide.topAnchor, constant: 0),
                    contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 0),
                    contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: 0),
                    contentView.bottomAnchor.constraint(equalTo: scrollView.frameLayoutGuide.bottomAnchor, constant: 0)
                ])
                
                selectButton = UIButton()
                selectButton.translatesAutoresizingMaskIntoConstraints = false
                selectButton.setTitle("選択完了", for: .normal)
                selectButton.titleLabel!.textAlignment = .center
                selectButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
                
                selectButton.backgroundColor = UIColor(hue: 0.5917, saturation: 0.79, brightness: 1, alpha: 1.0)
                selectButton.tintColor = .white
                selectButton.addTarget(self, action: #selector(tabSelectButton), for: .touchUpInside)
                self.view.addSubview(selectButton)
                NSLayoutConstraint.activate([
                    selectButton.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 10),
                    selectButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                    selectButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
                    selectButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
                ])
                self.view.layoutIfNeeded()
                
                viewBottomConstraint = self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
                viewBottomConstraint?.isActive = true
                
                setupMainStackView()
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            }
            
            
            
            
            let label = UILabel()
            let view = UIView()
            let button = tableSelectButton(viewIndex: tagIndex, tableIndex: rowIndex)
            view.tag = tagIndex
            tagIndex += 1
            
            view.translatesAutoresizingMaskIntoConstraints = false
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 13)
            label.widthAnchor.constraint(equalToConstant: 60).isActive = true
            label.lineBreakMode = .byTruncatingTail
            label.textAlignment = .center
            button.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
            button.imageView?.tintColor = .white
            button.backgroundColor = .clear
            button.layer.cornerRadius = button.layer.frame.size.width / 2
            
            var imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            let selectPlace = Observable.of(selectedSearchPlan.last!)
            selectPlace.map({ searchPlan in
                searchPlan.placeImage
            }).bind(to: imageView.rx.image)
                .disposed(by: disposeBag)
            view.addSubview(imageView)

            selectPlace.map({ searchPlan in
                searchPlan.title
            }).bind(to: label.rx.text)
                .disposed(by: disposeBag)
            view.addSubview(label)
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            label.widthAnchor.constraint(equalTo: imageView.widthAnchor, constant: 0).isActive = true
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4).isActive = true
            
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            button.addTarget(self, action: #selector(click), for: .touchUpInside)
            NSLayoutConstraint.activate(
                [
                    button.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -3),
                    button.heightAnchor.constraint(equalToConstant: 25),
                    button.widthAnchor.constraint(equalToConstant: 25),
                    button.rightAnchor.constraint(equalTo: imageView.rightAnchor,constant: 3)
                ]
            )
            
            
            view.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(view)
            self.view.layoutIfNeeded()
            
            self.tableView.reloadData()
            
        }
    }
    
    private func setupMainStackView(){
        //self.stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.backgroundColor = .green
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.spacing = 13
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.5),
        ])
        
    }
    
    @objc func click(_ sender: tableSelectButton) {
        let viewIndex = sender.viewIndex // 해당 버튼의 tag 값이 클릭된 인덱스가 됨
        let tableIndex = sender.tableIndex
        if let viewToRemove = stackView.arrangedSubviews.first(where: { $0.tag == viewIndex }) {
            // If a view with a matching tag is found, remove it from the stackView
            stackView.removeArrangedSubview(viewToRemove)
            viewToRemove.removeFromSuperview()
            
            let tripModel = selectedSearchPlan[viewIndex]
            var newTrip = tripVM.tripList.value
            if let index = newTrip.firstIndex(where: { $0.orderNo == tripModel.orderNo }) {
                // 찾은 요소의 buttonIsEnabled 속성을 false로 설정
                newTrip[index].buttonIsEnabled = true
                tripVM.tripList.accept(newTrip)
            }
        }
        
        if stackView.arrangedSubviews.count == 0 {
            self.scrollView.removeFromSuperview()
            self.stackView.removeFromSuperview()
            self.contentView.removeFromSuperview()
            self.selectButton.removeFromSuperview()
            viewBottomConstraint?.isActive = false
            viewTopConstraint?.isActive = false
            
            viewBottomConstraint = self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
            viewTopConstraint = self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)

            viewBottomConstraint?.isActive = true
            viewTopConstraint?.isActive = true

            // 변경 사항 반영
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            
            tagIndex = 0
            
            
        }
        selectedSearchPlan.remove(at: viewIndex)
        tableView.reloadData()
    }
    
    @objc func tabSelectButton(_ sender: tableSelectButton) {
        let homeTab = UIStoryboard.init(name: "HomeTab", bundle: nil)
        guard let tabBarController = homeTab.instantiateViewController(withIdentifier: "CalanderViewController")as? CalanderViewController else {return}
        self.navigationController?.pushViewController(tabBarController, animated: true)

    }
    
}

final class AddTripDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
   
    typealias Element = [TripModel]
    var _itemModels: [TripModel] = []
    var categories: [String] {
        let sortedCategories = Set(_itemModels.map { $0.category }).sorted { (category1, category2) in
            return category1.localizedStandardCompare(category2) == .orderedAscending
        }
        return sortedCategories
    }
    
    var updateConstraintClosure: ((Int, Int, UIButton) -> Void)?
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = categories.count
        return count
    }

    func tableView(_ tableView: UITableView, observedEvent: RxSwift.Event<[TripModel]>) {
        Binder(self) { dataSource, element in
            dataSource._itemModels = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = Array(categories)[section]
        let count = _itemModels.filter { $0.category == category }.count
        
        return count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(categories)[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlanTableCell", for: indexPath) as! SearchPlanTableViewCell
        let category = Array(categories)[indexPath.section]
        let categoryItems = _itemModels.filter { $0.category == category }
        let tripModel = categoryItems[indexPath.row]
        cell.sectionIndex = indexPath.section
        cell.rowIndex = indexPath.row
        cell.descriptionLabel.text = tripModel.descriptionLabel
        cell.placeImageView.image = tripModel.placeImage
        cell.placeImageView.layer.cornerRadius = cell.placeImageView.frame.height / 2
        cell.placeImageView.clipsToBounds = true
        cell.placeImageView.layer.borderWidth = 5
        cell.placeImageView.layer.borderColor = UIColor.white.cgColor

        cell.titleLabel.text = tripModel.title
        cell.tapSelectButtonAction = updateConstraintClosure
        cell.selectButton.isEnabled = tripModel.buttonIsEnabled

        return cell
    }
    
    
}
