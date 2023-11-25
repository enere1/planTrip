//
//  SearchPlanController.swift
//  tripPlan
//
//  Created by 이순곤 on 2023/11/23.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class SearchPlanController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    let searchVM = SearchViewModel()
    let disposeBag = DisposeBag()
    var selectedItemStack = [Int]()
    let stackView =  UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var bounds = UIScreen.main.bounds
        var width = bounds.size.width //화면 너비
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: width - 28, height: 40))
        textField.placeholder = "띄어쓰기로 복수 입력이 가능해요"
        textField.backgroundColor = UIColor.clear
        
        // 네비게이션 바 아래에 테두리 추가
        let borderBottom = CALayer()
        let borderWidth: CGFloat = 1
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        borderBottom.frame = CGRect(x: 0, y: navigationBarHeight, width: UIScreen.main.bounds.width, height: borderWidth)
        borderBottom.backgroundColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.addSublayer(borderBottom)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: textField)
        self.view.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.backgroundColor = .orange
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: self.tableView.topAnchor, constant: -10)
        ])
        setupTableView()


    }
    
    func setupTableView() {
        // Do any additional setup after loading the view.
        let searchPlanTableViewCellNib = UINib(nibName: "SearchPlanTableViewCell", bundle: Bundle(for: SearchPlanTableViewCell.self))
        self.tableView.register(searchPlanTableViewCellNib, forCellReuseIdentifier: "SearchPlanTableCell")
        let searchPlanDataSource = SearchPlanDataSource()
        searchVM.recommendList.bind(to: tableView.rx.items(dataSource: searchPlanDataSource)).disposed(by: disposeBag)
        
        searchPlanDataSource.updateConstraintClosure = { [weak self] index in
            guard let self = self else { return }
            
        // 기존 코드 유지
        self.tableView.backgroundColor = .blue
        self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 80).isActive = true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .cyan
        
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.searchVM.recommendList
            .map { $0[index] }
            .compactMap { UIImage(named: $0.placeImage) }
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        stackView.addArrangedSubview(view)
            
        }
    }
}

final class SearchPlanDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
   
    typealias Element = [SearchPlanModel]
    var _itemModels: [SearchPlanModel] = []
    var updateConstraintClosure: ((Int) -> Void)?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, observedEvent: RxSwift.Event<[SearchPlanModel]>) {
        Binder(self) { dataSource, element in
            dataSource._itemModels = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return _itemModels.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "Day " + String(describing: section + 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlanTableCell", for: indexPath) as! SearchPlanTableViewCell
        let item = _itemModels[indexPath.row]
        cell.index = indexPath.row
        cell.descriptionLabel.text = item.descriptionLabel
        cell.placeImageView.image = UIImage(named: item.placeImage)
        cell.titleLabel.text = item.title
        cell.tapSelectButtonAction = updateConstraintClosure
        return cell
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
