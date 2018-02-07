//
//  FriendCollectionViewCell.swift
//  Butter
//
//  Created by RaviSharma on 15/11/17.
//  Copyright © 2017 Ravi Sharma. All rights reserved.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgVw_friend:        UIImageView!

    @IBOutlet weak var lbl_Name:            UILabel!
    @IBOutlet weak var imgVw_selected:      UIImageView!
    @IBOutlet weak var lbl_selected:        UILabel!

    let cell_width = Double((Int(UIScreen.main.bounds.width)-46)/3)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
        
        imgVw_friend.frame = CGRect(x: 0 , y: 0, width: cell_width, height: cell_width);

        lbl_Name.frame = CGRect(x: 0, y:cell_width, width: cell_width, height: 40)
        lbl_Name.backgroundColor = .white
        lbl_Name.textAlignment = NSTextAlignment.center;

        lbl_selected.frame = CGRect(x: 0, y:0, width: cell_width, height: cell_width);
        lbl_selected.clipsToBounds = true
        lbl_selected.layer.cornerRadius = 5
        
        imgVw_selected.frame = CGRect(x: (cell_width-60)/2, y:(cell_width-78)/2, width: cell_width, height:65)
    }
}
