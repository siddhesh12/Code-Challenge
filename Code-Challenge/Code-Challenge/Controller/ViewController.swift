//
//  ViewController.swift
//  Code-Challenge
//
//  Created by Siddhesh Mahadeshwar on 23/05/18.
//  Copyright © 2018 net.siddhesh. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD

fileprivate let reuseIdentifierSection = "countrySection"
fileprivate let reuseIdentifier = "nodeCell"
fileprivate let padding:CGFloat = 20.0

class ViewController: UIViewController {
  @IBOutlet weak var constraintCollectionViewHeight: NSLayoutConstraint!
  @IBOutlet weak var constraintSelectedCountryTop: NSLayoutConstraint!
  @IBOutlet weak var constraintTopSelectedCountryView: NSLayoutConstraint!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var selectedCountryView: UIView!
  @IBOutlet weak var switchVpn: UISwitch!
  @IBOutlet weak var labelSecure: UILabel!
  @IBOutlet weak var imageDownArrow: UIImageView!
  @IBOutlet weak var labelSelectedCountry: UILabel!
  
  var coreDataStack: DataStack!
  var countryService:CountryService!
  var countries:[Country] = []
  var selectedCountry: String?
  fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: padding, right: 0)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    reload()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    collectionView.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: 0, right: padding)
    VPNHandler.shared.checkConnection()
    NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: nil, queue: OperationQueue.main, using: { notification in
      switch VPNHandler.shared.vpnManager.connection.status {
      case .connecting:
        self.showLoading(view: self.view)
      case .connected:
        self.isConnected(connected: true)
        self.hideLoading(view: self.view)
      case .disconnected:
        self.isConnected(connected: false)
        self.hideLoading(view: self.view)
      default:
        self.hideLoading(view: self.view)
      }
    })
    NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: nil, queue: OperationQueue.main, using: { notification in
      self.hideLoading(view: self.view)
      self.getCountries()
    })
    
    moveUpSelectedCountryView(false, animate: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
  }
  
  func initCoreDataStack(_ coreDataStack: DataStack) {
    self.coreDataStack = coreDataStack
    self.countryService = CountryService(managedObjectContext: coreDataStack.mainContext,coreDataStack:coreDataStack)
  }
  
  func reload() {
    showLoading(view: view)
    NetworkManager.shared.getCountries { result in
      
      switch result {
      case .success(let result):
        self.countryService.insertAll(rawArray: result, completion: { result in
          switch result {
          case .success(_):
            self.hideLoading(view: self.view)
            self.getCountries()
          case .failure(let error):
            self.hideLoading(view: self.view)
            print(error)
          }
        })
      case .failure(let error):
        self.hideLoading(view: self.view)
        print(error)
      }
    }
  }
  
  func moveUpSelectedCountryView(_ up: Bool, animate: Bool) {
    if up {
      constraintTopSelectedCountryView.constant = -(view.frame.height - selectedCountryView.frame.height)
      constraintCollectionViewHeight.constant = view.frame.height - selectedCountryView.frame.height
      imageDownArrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    } else {
      constraintTopSelectedCountryView.constant = -70
      imageDownArrow.transform = CGAffineTransform.identity
    }
    
    UIView.animate(withDuration: animate ? 0.24 : 0) {
        self.view.layoutIfNeeded()
    }
  }
  
  @IBAction func currentCountryClicked(_ sender: UIButton) {
    if constraintTopSelectedCountryView.constant == -70 {
      moveUpSelectedCountryView(true, animate: true)
    } else {
      moveUpSelectedCountryView(false, animate: true)
    }
  }
  
  @IBAction func valueChanged(_ sender: UISwitch) {
    if sender.isOn {
      moveUpSelectedCountryView(true, animate: true)
    } else {
      VPNHandler.shared.disconnect()
    }
  }
}

// MARK: - Helper methods
extension ViewController {
  
  func isConnected(connected: Bool) {
    switchVpn.isOn = connected
    labelSecure.text = connected ? "Secured" : "Secure your WIFI"
    labelSelectedCountry.text = connected ? selectedCountry ?? "Select country" : "Select country"
  }
  
  func checkVPNConnection () {
    isConnected(connected: VPNHandler.shared.vpnManager.isEnabled)
  }

}
extension ViewController {
  
  func getCountries() {
    guard let countries = countryService?.getCountries() else { return }
    self.countries = countries
    collectionView.reloadData()
  }
}

extension ViewController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return countries.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let country = countries[section]
    if country.expand {
      return country.nodes?.count ?? 0
    } else {
      return 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      let country = countries[indexPath.section]
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifierSection, for: indexPath) as! HeaderCollectionReusableView
      headerView.sectionTitle.text = country.name
      if country.expand {
        headerView.arrowImageView.transform =  CGAffineTransform(rotationAngle: CGFloat(Double.pi))
      } else {
          headerView.arrowImageView.transform = CGAffineTransform.identity
      }
      headerView.section = indexPath.section
      headerView.delegate = self
      return headerView
    default:
      assert(false, "Unexpected element kind")
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let node = countries[indexPath.section].nodes?[indexPath.row] as! Node
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: reuseIdentifier, for: indexPath) as! CountryCollectionViewCell
    cell.nodeLabel.text = node.group
    cell.premiumLabel.text = countries[indexPath.section].isPremium ? "premium" : "non premium"
    cell.setCardView()
    cell.layoutIfNeeded()
    return cell
  }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: view.frame.width, height: 40)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width - 40, height: 50)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let node = countries[indexPath.section].nodes?[indexPath.row] as! Node
    selectedCountry = countries[indexPath.section].name
    moveUpSelectedCountryView(false, animate: true)
    VPNHandler.shared.configureProtocol(serverName: node.hostName, remoteID: countries[indexPath.section].dnsHostname) { result in
      switch result {
        case .success( _): break
        case .failure(let error):
          self.hideLoading(view: self.view)
          print(error)
      }
    }
  }
}

extension ViewController {
  func showLoading(view:UIView)
  {
    DispatchQueue.main.async {
      let hud = MBProgressHUD.showAdded(to: view, animated: true)
      hud.label.text = "Loading"
    }
  }
  
  func hideLoading(view:UIView)
  {
    DispatchQueue.main.async {
      MBProgressHUD.hide(for: view, animated: true)
    }
  }
}

extension ViewController: HeaderViewDelegate {
  
  func toggleSection(header: HeaderCollectionReusableView, section: Int) {
    
    countries[section].expand = !countries[section].expand
    collectionView.performBatchUpdates({
      self.collectionView.reloadSections(IndexSet(integer: section))
      header.updateCardView(show: countries[section].expand)
    })
  }
}

