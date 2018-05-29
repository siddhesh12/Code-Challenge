//
//  HeaderCollectionReusableView.swift
//  Code-Challenge
//
//  Created by Siddhesh Mahadeshwar on 29/05/18.
//  Copyright © 2018 net.siddhesh. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate: class {
  func toggleSection(header: HeaderCollectionReusableView, section: Int)
}

class HeaderCollectionReusableView: UICollectionReusableView {
  @IBOutlet weak var sectionTitle: UILabel!
  weak var delegate: HeaderViewDelegate?
  var section:Int?
  @IBOutlet weak var contentView: UILabel!
  @IBOutlet weak var arrowImageView: UIImageView!
  
  override func awakeFromNib() {
    setCardView()
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))
  }
  
  @objc private func didTapHeader() {
    delegate?.toggleSection(header: self, section: section!)
  }
}

extension HeaderCollectionReusableView {
  
  func setCardView() {
    layer.cornerRadius = 10.0
    layer.borderWidth = 1.0
    layer.borderColor = UIColor.clear.cgColor
    layer.masksToBounds = false;
    
    layer.shadowColor = UIColor.lightGray.cgColor
    layer.shadowOffset = CGSize(width:0,height: 2.0)
    layer.shadowRadius = 2.0
    layer.shadowOpacity = 1.0
    layer.masksToBounds = false
    
  }
  
  func updateCardView(show:Bool) {
    layer.shadowOffset = show ? CGSize(width: 0, height: 2) : CGSize(width: 0, height: -2.5)
    arrowImageView.transform = show ? CGAffineTransform.identity : CGAffineTransform(rotationAngle: CGFloat(Double.pi))
  }
}
