//
//  PlanTabViewController.swift
//  tripPlan
//
//  Created by 이순곤 on 2023/11/19.
//

import UIKit
import MapKit
import TimelineTableViewCell
import RxCocoa
import RxSwift

class PlanTabViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var withFriendsButton: UIButton!
    @IBOutlet weak var addFlightButton: UIButton!
    @IBOutlet weak var addHotelButton: UIButton!
    @IBOutlet weak var mkMapView: MKMapView!
    @IBOutlet weak var scheduleTableView: UITableView!
    let planVM = PlanViewModel()
    let disposeBag = DisposeBag()
    // TimelinePoint, Timeline back color, title, description, lineInfo, thumbnails, illustration
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        withFriendsButton.layer.cornerRadius = 15 // 적당한 값을 넣어보세요
        withFriendsButton.clipsToBounds = true
        withFriendsButton.titleLabel?.text = "+ 仲間とスケジュールを立てる"
        addFlightButton.titleLabel?.text = "+ フライト追加"
        addHotelButton.titleLabel?.text = "+ ホテル追加"
    }
    
    func setupTableView() {
        // Do any additional setup after loading the view.
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle(for: TimelineTableViewCell.self))
        self.scheduleTableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableCell")
        
        let addButtonTableViewCellNib = UINib(nibName: "AddButtonTableViewCell", bundle: Bundle(for: AddButtonTableViewCell.self))
        self.scheduleTableView.register(addButtonTableViewCellNib, forCellReuseIdentifier: "AddButtonTableCell")
        
        let dataSource = MyDataSource()
        dataSource.addPlaceButtonAction = { [weak self] in
            let tabbar = UIStoryboard.init(name: "PlanTab", bundle: nil)
            guard let tabBarController = tabbar.instantiateViewController(withIdentifier: "SearchPlanController")as? SearchPlanController else {return}
            self?.navigationController?.pushViewController(tabBarController, animated: true)
        }
        planVM.data.bind(to: scheduleTableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
}

final class MyDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
    typealias Element = [Int: [(TimelinePoint?, UIColor?, String?, String?, String?, [String]?, String?)]]
    var _itemModels: [Int: [(TimelinePoint?, UIColor?, String?, String?, String?, [String]?, String?)]] = [:]
    var addPlaceButtonAction: (() -> Void)?
    func numberOfSections(in tableView: UITableView) -> Int {
        return _itemModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionData = _itemModels[section] else {
            return 1
        }
        return sectionData.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < _itemModels[indexPath.section]!.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableCell", for: indexPath) as! TimelineTableViewCell
            //Configure the cell...
            guard let sectionData = _itemModels[indexPath.section] else {
                return cell
            }
            
            let (timelinePoint, timelineBackColor, title, description, lineInfo, thumbnails, illustration) = sectionData[indexPath.row]
            var timelineFrontColor = UIColor.clear
            if (indexPath.row > 0) {
                if let uiColor = sectionData[indexPath.row - 1].1 {
                    timelineFrontColor = uiColor
                }
            }
            
            if let timelinePoint = timelinePoint {
                cell.timelinePoint = timelinePoint
            }
            
            cell.timeline.frontColor = timelineFrontColor
            
            if let timelineBackColor = timelineBackColor {
                cell.timeline.backColor = timelineBackColor
            }
            
            if let title = title {
                cell.titleLabel.text = title
            }
            
            if let description = description {
                cell.descriptionLabel.text = description
            }
            if let lineInfo = lineInfo {
                cell.lineInfoLabel.text = lineInfo
            }

            if let thumbnails = thumbnails {
                cell.viewsInStackView = thumbnails.map { thumbnail in
                    return UIImageView(image: UIImage(named: thumbnail))
                }
            }
            else {
                cell.viewsInStackView = []
            }

            if let illustration = illustration {
                cell.illustrationImageView.image = UIImage(named: illustration)
            }
            else {
                cell.illustrationImageView.image = nil
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddButtonTableCell", for: indexPath) as! AddButtonTableViewCell
            cell.addPlaceButtonAction = { [weak self] in
                            self?.addPlaceButtonAction?()
            }
            return cell
        }

           
    }

    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        Binder(self) { dataSource, element in
            dataSource._itemModels = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "Day " + String(describing: section + 1)
    }
}
