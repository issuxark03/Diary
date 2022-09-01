//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by Yongwoo Yoo on 2022/02/25.
//

import UIKit

class DiaryDetailViewController: UIViewController {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var contentsTextView: UITextView!
	@IBOutlet weak var dateLabel: UILabel!
	var starButton: UIBarButtonItem?
	
	var diary: Diary?
	var indexPath: IndexPath?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.configureView()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(starDiaryNotification(_:)),
			name: NSNotification.Name("starDiary"),
			object: nil)

    }
	
	//화면 표시
	private func configureView() {
		guard let diary = self.diary else { return } //optional binding
		self.titleLabel.text = diary.title
		self.contentsTextView.text = diary.contents
		self.dateLabel.text = self.dateToString(date: diary.date)
		
		//starButton attribute definition (UIBarButtonItem)
		self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tabStarButton))
		self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") /*true*/ : UIImage(systemName: "star")/*false*/
		self.starButton?.tintColor = .orange
		self.navigationItem.rightBarButtonItem = self.starButton //navigation bar top-right button add (created starButton)
	}
	
	//형변환
	private func dateToString(date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
		formatter.locale = Locale(identifier: "ko-KR")
		return formatter.string(from: date)
	}
	
	@objc func editDiaryNotification(_ notification: NSNotification){
		guard let diary = notification.object as? Diary else { return } //post에서 보낸 object를 Diary로 down Casting
		self.diary = diary
		self.configureView()
		print("디테일뷰 옵저버호출됨")
	}
	
	@objc func starDiaryNotification(_ notification: NSNotification){
		guard let starDiary = notification.object as? [String : Any] else { return }
		guard let isStar = starDiary["isStar"] as? Bool else { return }
		guard let uuidString = starDiary["uuidString"] as? String else { return }
		guard let diary = self.diary else { return }
		
		if diary.uuidString == uuidString {
			self.diary?.isStar = isStar
			self.configureView()
		}
	}
    
	@IBAction func tabEditButton(_ sender: UIButton) {
		guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return	}
		guard let indexPath = self.indexPath else {	return }
		guard let diary = self.diary else {	return }
		viewController.diaryEditorMode = .edit(indexPath, diary)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(editDiaryNotification(_:)),
			name: NSNotification.Name("editDiary"),
			object: nil)
		
		self.navigationController?.pushViewController(viewController, animated: true)
	}
	
	@IBAction func tabDeleteButton(_ sender: UIButton) {
		guard let uuidString = diary?.uuidString else { return }
		NotificationCenter.default.post(name: NSNotification.Name("deleteDiary"), object: uuidString, userInfo: nil)
		self.navigationController?.popViewController(animated: true)
	}
	
	//when star button touch up inside call
	@objc func tabStarButton() {
		guard let isStar = self.diary?.isStar else { return }
		

		if isStar {
			self.starButton?.image = UIImage(systemName: "star") //1>0
		} else {
			self.starButton?.image = UIImage(systemName: "star.fill") //0>1
		}
		
		self.diary?.isStar = !isStar //input opposite value 1>0 0>1
		//self.delegate?.didSelectStar(indexPath: indexPath, isStar: self.diary?.isStar ?? false)
		NotificationCenter.default.post(
			name: NSNotification.Name("starDiary"),
			object: [
				"diary": self.diary,
				"isStar": self.diary?.isStar ?? false,
				"uuidString" : self.diary?.uuidString
			], userInfo: nil)
	}
	
	//when Instance Deinit
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
