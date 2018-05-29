//
//  CountryCollectionViewCell.swift
//  Code-Challenge
//
//  Created by Siddhesh Mahadeshwar on 29/05/18.
//  Copyright © 2018 net.siddhesh. All rights reserved.
//

import UIKit

class CountryCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var nodeLabel: UILabel!
  @IBOutlet weak var premiumLabel: UILabel!

  func setCardView(){
    contentView.layer.cornerRadius = 2.0
    contentView.layer.borderWidth = 1.0
    contentView.layer.borderColor = UIColor.clear.cgColor
    contentView.layer.masksToBounds = false;
    
    layer.shadowColor = UIColor.lightGray.cgColor
    layer.shadowOffset = CGSize(width:0,height: 2.0)
    layer.shadowRadius = 2.0
    layer.shadowOpacity = 1.0
    layer.masksToBounds = false;
  }
  
  override func awakeFromNib() {
    setCardView()
  }
}
