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
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var mkMapView: MKMapView!
    @IBOutlet weak var scheduleTableView: UITableView!
    var titleLabelText = String()
    var durationLabelText = String()
    let planVM = PlanViewModel()
    let disposeBag = DisposeBag()
    let datePicker = UIDatePicker()
    // TimelinePoint, Timeline back color, title, description, lineInfo, thumbnails, illustration
    var timelines = [(TimelinePoint?, UIColor?, String?, String?, String?, [String]?, String?)]()
    var selectedDate: Date?
    var polylineCoordinates = [CLLocationCoordinate2D]()
    var polylines = [MKPolyline]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        mkMapView.rx.setDelegate(self).disposed(by: disposeBag)
        scheduleTableView.delegate = self
        titleLabel.text = titleLabelText
        durationLabel.text = durationLabelText
    }
    
    func setupTableView() {
        // Do any additional setup after loading the view.
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle(for: TimelineTableViewCell.self))
        self.scheduleTableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableCell")
        let addButtonTableViewCellNib = UINib(nibName: "AddButtonTableViewCell", bundle: Bundle(for: AddButtonTableViewCell.self))
        self.scheduleTableView.register(addButtonTableViewCellNib, forCellReuseIdentifier: "AddButtonTableCell")
        let dataSource = MyDataSource()
        dataSource.addPlaceButtonAction = { [weak self] indexNum in
            let tabbar = UIStoryboard.init(name: "PlanTab", bundle: nil)
            guard let tabBarController = tabbar.instantiateViewController(withIdentifier: "SearchPlanController")as? SearchPlanController else {return}
            tabBarController.delegate = self
            tabBarController.planIndex = indexNum
            self?.navigationController?.pushViewController(tabBarController, animated: true)
        }
        planVM.data.bind(to: scheduleTableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        // 변경된 날짜를 사용하거나 특정 작업 수행
        let date = sender.date
        selectedDate = date
        print("Selected date: \(selectedDate)")
    }
    
    func displayDatePickerPopup(_ section: Int, _ row: Int) {
            let alertController = UIAlertController(title: "Select Date", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
            
            alertController.view.addSubview(datePicker)
            
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 50).isActive = true
            datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 8).isActive = true
            datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -8).isActive = true
            
            let doneAction = UIAlertAction(title: "Done", style: .default) { (_) in
                var timeline = self.timelines[row]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                timeline = (timeline.0, timeline.1, dateFormatter.string(from: self.selectedDate!), nil, nil, [], nil)
                self.timelines[row] = timeline
                self.planVM.data.accept([section : self.timelines])
            }
            alertController.addAction(doneAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
}

final class MyDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
    typealias Element = [Int: [(TimelinePoint?, UIColor?, String?, String?, String?, [String]?, String?)]]
    var _itemModels: [Int: [(TimelinePoint?, UIColor?, String?, String?, String?, [String]?, String?)]] = [:]
    var addPlaceButtonAction: ((Int) -> Void)?
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
                self?.addPlaceButtonAction?(indexPath.section)
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

extension PlanTabViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? AddButtonTableViewCell {
            return
        }
        let region = MKCoordinateRegion( center: self.polylineCoordinates[indexPath.row], latitudinalMeters: CLLocationDistance(exactly: 5000)!, longitudinalMeters: CLLocationDistance(exactly: 5000)!)
        self.mkMapView.setRegion(self.mkMapView.regionThatFits(region), animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if let cell = tableView.cellForRow(at: indexPath) as? AddButtonTableViewCell {
            return nil
        }
        
        let delete = UIContextualAction(style: .normal, title: "") { (_, _, success: @escaping (Bool) -> Void) in
            self.timelines.remove(at: indexPath.row)
            self.planVM.data.accept([indexPath.section : self.timelines])
            let coorinate = self.polylineCoordinates[indexPath.row]
            let overlays = self.mkMapView.overlays
            self.mkMapView.removeOverlays(overlays)
            self.polylineCoordinates.remove(at: indexPath.row)
            let polyLine = MKPolyline(coordinates: self.polylineCoordinates, count: self.polylineCoordinates.count)
            self.mkMapView.addOverlay(polyLine)

            let annotations = self.mkMapView.annotations
            for annotation in annotations {
                if annotation.coordinate.latitude == coorinate.latitude &&
                    annotation.coordinate.longitude == coorinate.longitude {
                    self.mkMapView.removeAnnotation(annotation)
                }
            }
            success(true)
        }

        let addTime = UIContextualAction(style: .normal, title: "") { (_, _, success: @escaping (Bool) -> Void) in
            // 원하는 액션 추가
            self.datePicker.datePickerMode = .countDownTimer
            self.displayDatePickerPopup(indexPath.section, indexPath.row)
            self.datePicker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
            success(true)
        }

        // 각 ContextualAction 대한 설정
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash.fill")

        addTime.backgroundColor = .systemGreen
        addTime.image = UIImage(systemName: "clock.fill")
        // UISwipeActionsConfiguration에 action을 추가하여 리턴
        let configuration = UISwipeActionsConfiguration(actions: [delete,addTime])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

extension PlanTabViewController: SearchPlanDataBackDelegate {
    
    func searchPlanDataBack(_ index: Int, _ plans: [SearchPlanModelForTabView]) {
        for item in plans{
            let coordinate = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
            var annotation = CustomAnnotation(
                orderNo: String(item.orderNo),
                coordinate: coordinate,
                title: item.title,
                subtitle: item.descriptionLabel
            )
            mkMapView.addAnnotation(annotation)
            polylineCoordinates.append(coordinate)
            timelines.append((TimelinePoint(), UIColor.black, nil, item.title, nil, nil, nil))
        }
        let polyLine = MKPolyline(coordinates: polylineCoordinates, count: polylineCoordinates.count)
        mkMapView.addOverlay(polyLine)
        let region = MKCoordinateRegion( center: polylineCoordinates[0], latitudinalMeters: CLLocationDistance(exactly: 5000)!, longitudinalMeters: CLLocationDistance(exactly: 5000)!)
        self.mkMapView.setRegion(mkMapView.regionThatFits(region), animated: true)
        planVM.data.accept([index : timelines])
    }
}

extension PlanTabViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
                let polylineRenderer = MKPolylineRenderer(polyline: polyline)
                polylineRenderer.strokeColor = .red
                polylineRenderer.lineWidth = 3.0
                return polylineRenderer
        }
            return MKOverlayRenderer()
    }
    
}

class CustomAnnotation: NSObject, MKAnnotation {
    var orderNo: String
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(orderNo: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.orderNo = orderNo
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

class CustomAnnotationView: MKAnnotationView {
    static let identifier = "CustomAnnotationView"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        // 초기화 시 설정할 내용이 있다면 여기에 추가할 수 있습니다.
        self.canShowCallout = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



