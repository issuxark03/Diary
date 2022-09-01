//
//  ViewController.swift
//  Diary
//
//  Created by Yongwoo Yoo on 2022/02/24.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var collectionView: UICollectionView!
	//Diary타입 배열
	private var diaryList = [Diary]() {
		//property observer
		didSet{
			self.saveDiaryList()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureCollectionView()
		self.loadDiaryList()
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(editDiaryNotification(_:)),
			name: NSNotification.Name("editDiary"),
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(starDiaryNotification(_:)),
			name: NSNotification.Name("starDiary"),
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(deleteDiaryNotification(_:)),
			name: NSNotification.Name("deleteDiary"),
			object: nil)
	}

	//다이어리들 콜렉션 뷰에 표시
	private func configureCollectionView() {
		self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
		self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) //collection view의 상하좌우간격
		self.collectionView.delegate = self
		self.collectionView.dataSource = self
	}
	
	@objc func editDiaryNotification(_ notification: NSNotification) {
		guard let diary = notification.object as? Diary else { return }
		//find uuidString ..
		guard let index = self.diaryList.firstIndex(where: { $0.uuidString == diary.uuidString }) else { return }
		self.diaryList[index] = diary
		self.diaryList = self.diaryList.sorted(by: {
			$0.date.compare($1.date) == .orderedDescending
		})
		self.collectionView.reloadData()
		print("뷰컨트롤러 옵저버호출됨")
	}
	
	@objc func starDiaryNotification(_ notification: NSNotification){
		guard let starDiary = notification.object as? [String : Any] else { return }
		guard let isStar = starDiary["isStar"] as? Bool else { return }
		guard let uuidString = starDiary["uuidString"] as? String else { return }
		guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
		
		self.diaryList[index].isStar = isStar //update diaryList isStar property
	}
	
	@objc func deleteDiaryNotification(_ notification: NSNotification){
		guard let uuidString = notification.object as? String else { return }
		guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
		
		self.diaryList.remove(at: index)
		self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
	}
	
	//segue로 호출되기때문에
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
			writeDiaryViewController.delegate = self
		}
	}
	
	private func saveDiaryList() {
		let date = self.diaryList.map {
			[
				"uuidString": $0.uuidString,
				"title": $0.title,
				"contents": $0.contents,
				"date": $0.date,
				"isStar": $0.isStar
			]
		}
		let userDefaults = UserDefaults.standard
		userDefaults.set(date, forKey: "diaryList")
	}
	
	private func loadDiaryList() {
		let userDefault = UserDefaults.standard
		guard let data = userDefault.object(forKey: "diaryList") as? [[String: Any]] else { return } //object method는 Any타입으로 return되기때문에 dic+array 형태로 type casting + optional binding
		self.diaryList = data.compactMap {
			guard let uuidString = $0["uuidString"] as? String else { return nil }
			guard let title = $0["title"] as? String else { return nil }
			guard let contents = $0["contents"] as? String else { return nil }
			guard let date = $0["date"] as? Date else { return nil }
			guard let isStar = $0["isStar"] as? Bool else { return nil }
			return Diary(uuidString:uuidString, title: title, contents: contents, date: date, isStar: isStar)
		}
		self.diaryList = self.diaryList.sorted(by: {
			$0.date.compare($1.date) == .orderedDescending //날짜 최신순으로 정렬
		})
	}
	
	//형변환
	private func dateToString(date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
		formatter.locale = Locale(identifier: "ko-KR")
		return formatter.string(from: date)

	}
}


extension ViewController : UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		//print("다이어리 카운트 : \(self.diaryList.count)")
		return self.diaryList.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		//print("cellforItemAt : \(indexPath)")
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
		//print("cell : \(cell)")
		let diary = self.diaryList[indexPath.row]
		cell.titleLabel.text = diary.title
		cell.dateLabel.text = self.dateToString(date: diary.date)
		//print("셀 : \(cell)")
		return cell

	}
}

//레이아웃 구성
extension ViewController : UICollectionViewDelegateFlowLayout {
	//표시할 셀의 사이즈를 설정
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200) //아이폰화면의 너비값을 2로 나눈값 - 20(left right 간격)
	}

}

extension ViewController : WriteDiaryViewDelegate {
	func didSelectRegister(diary: Diary) {
		self.diaryList.append(diary)
		self.diaryList = self.diaryList.sorted(by: {
			$0.date.compare($1.date) == .orderedDescending //날짜 최신순으로 정렬
		})
		self.collectionView.reloadData()
	}
}

extension ViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
		let diary = self.diaryList[indexPath.row]
		viewController.diary = diary
		viewController.indexPath = indexPath
		self.navigationController?.pushViewController(viewController, animated: true)
	}
}
