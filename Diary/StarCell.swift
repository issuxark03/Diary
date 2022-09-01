//
//  StarCell.swift
//  Diary
//
//  Created by Yongwoo Yoo on 2022/02/24.
//

import UIKit

class StarCell: UICollectionViewCell {
    
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	//initializer
	//UIView가 storyboard에서 생성될때 실행
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.contentView.layer.cornerRadius = 3.0
		self.contentView.layer.borderWidth = 1.0
		self.contentView.layer.borderColor = UIColor.black.cgColor
	}
	
}
