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
import MapKit
import CoreLocation


protocol SearchPlanDataBackDelegate {
    func searchPlanDataBack(_ index: Int, _ plans: [SearchPlanModelForTabView])
}

enum LookaroundError: Error {
    case unableToCreateScene
}

class SearchPlanController: UIViewController {
    
    var delegate: SearchPlanDataBackDelegate?
    @IBOutlet weak var tableView: UITableView!
    var planIndex: Int?
    let searchVM = SearchViewModel()
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
    let searchCompleter = MKLocalSearchCompleter()
    let geocoder = CLGeocoder()
    var newSearchPlanModels = [SearchPlanModel]()
    var selectedSearchPlan = [SearchPlanModel]()
    let searchPlanSubject = PublishSubject<[SearchPlanModel]>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var bounds = UIScreen.main.bounds
        var width = bounds.size.width //화면 너비
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: width - 28, height: 40))
        textField.placeholder = "タイプしてください。"
        textField.backgroundColor = UIColor.clear
        
        // 네비게이션 바 아래에 테두리 추가
        let borderBottom = CALayer()
        let borderWidth: CGFloat = 1
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        borderBottom.frame = CGRect(x: 0, y: navigationBarHeight, width: UIScreen.main.bounds.width, height: borderWidth)
        borderBottom.backgroundColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.addSublayer(borderBottom)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: textField)
        
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

        textField
            .rx
            .controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: {
                   if let text = textField.text {
                       self.searchCompleter.queryFragment = text
                   }
               })
               .disposed(by: disposeBag)
        
        let searchPlanTableViewCellNib = UINib(nibName: "SearchPlanTableViewCell", bundle: Bundle(for: SearchPlanTableViewCell.self))
        self.tableView.register(searchPlanTableViewCellNib, forCellReuseIdentifier: "SearchPlanTableCell")
        let searchPlanDataSource = SearchPlanDataSource()

        searchCompleter
            .rx
            .didUpdateResults
            .flatMap {
                let results = $0
                self.newSearchPlanModels = [SearchPlanModel]()
                for result in results {
                    let request = MKLocalSearch.Request()
                    let coordinate = CLLocationCoordinate2DMake(21.029429272433653, 105.83730702275895)
                    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
                    request.region = region
                    request.naturalLanguageQuery = result.title
                    MKLocalSearch(request: request).start { (response, error) in
                        guard let response = response else {
                            return
                        }

                        let mapItems = response.mapItems
                        for item in mapItems {
                            let sceneRequest = MKLookAroundSceneRequest(mapItem: item)
                            sceneRequest.getSceneWithCompletionHandler { scene, error in
                                guard error == nil, let scene = scene else {
                                    return
                                }
                                
                                let lookAroundSnapshotter = MKLookAroundSnapshotter(scene: scene, options: .init())
                                lookAroundSnapshotter.getSnapshotWithCompletionHandler { snapshot, error in
                                    guard error == nil, let snapshot = snapshot else {
                                        return
                                    }
                                    let coordinate = item.placemark.coordinate
                                    let model = SearchPlanModel(placeImage: snapshot.image, title: result.title, descriptionLabel: result.subtitle, buttonIsEnabled: true, longitude: coordinate.longitude, latitude: coordinate.latitude)
                                    self.newSearchPlanModels.append(model)
                                    self.searchPlanSubject.onNext(self.newSearchPlanModels)
                                }
                            }
                        }
                    }
                }
                return self.searchPlanSubject.asObservable()

            }.bind(to: tableView.rx.items(dataSource: searchPlanDataSource))
            .disposed(by: disposeBag)

        searchPlanDataSource.updateConstraintClosure = { [weak self] sectionIndex, rowindex, button  in
            guard let self = self else { return }
            newSearchPlanModels[rowindex].buttonIsEnabled = false
            selectedSearchPlan.append(newSearchPlanModels[rowindex])
            searchPlanSubject.onNext(newSearchPlanModels)
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
            let button = tableSelectButton(viewIndex: tagIndex, tableIndex: rowindex)
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
            let selectPlace = Observable.of(newSearchPlanModels[rowindex])
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
            let indexPath = IndexPath(row: tableIndex, section: 0)
            newSearchPlanModels[tableIndex].buttonIsEnabled = true
            self.searchPlanSubject.onNext(self.newSearchPlanModels)
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
    
    @objc func tabSelectButton(_ sender: UIButton) {
        print("tabSelectButton")
        let plans = selectedSearchPlan
            .enumerated() // 배열의 요소와 인덱스를 함께 가져옵니다.
            .map { index, searchPlan in
                let searchPlanModelForTabView = SearchPlanModelForTabView(
                    orderNo: index,
                    placeImage: searchPlan.placeImage,
                    title: searchPlan.title,
                    descriptionLabel: searchPlan.descriptionLabel,
                    buttonIsEnabled: searchPlan.buttonIsEnabled,
                    longitude: searchPlan.longitude,
                    latitude: searchPlan.latitude)
                return searchPlanModelForTabView
            }
        delegate?.searchPlanDataBack(planIndex!, plans)
        navigationController?.popViewController(animated: true)
    }
}

final class SearchPlanDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
   
    typealias Element = [SearchPlanModel]
    var _itemModels: [SearchPlanModel] = []
    var updateConstraintClosure: ((Int, Int, UIButton) -> Void)?
    
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
        cell.rowIndex = indexPath.row
        cell.sectionIndex = indexPath.section
        cell.descriptionLabel.text = item.descriptionLabel
        cell.placeImageView.image = item.placeImage
        cell.titleLabel.text = item.title
        cell.tapSelectButtonAction = updateConstraintClosure
        cell.selectButton.isEnabled = item.buttonIsEnabled

        return cell
    }
    
    
}

class tableSelectButton: UIButton {
    var viewIndex: Int
    var tableIndex: Int
    
    init(viewIndex: Int, tableIndex: Int) {
        self.viewIndex = viewIndex
        self.tableIndex = tableIndex
        
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
