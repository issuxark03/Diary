//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by Yongwoo Yoo on 2022/02/25.
//

import UIKit

enum DiaryEditorMode {
	case new
	case edit(IndexPath, Diary)
}

protocol WriteDiaryViewDelegate: AnyObject {
	func didSelectRegister(diary: Diary)
}

class WriteDiaryViewController: UIViewController {

	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var contentsTextView: UITextView!
	@IBOutlet weak var dateTextField: UITextField!
	@IBOutlet weak var confirmButton: UIBarButtonItem!
	
	private let datePicker = UIDatePicker()
	private var diaryDate: Date? //데이트피커에서 선택된 데이트를 저장하는 프로퍼티
	weak var delegate: WriteDiaryViewDelegate?
	var diaryEditorMode: DiaryEditorMode = .new //초기값 new
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.configureContentsTextView()
		self.configureDatePicker()
		self.configureInputField()
		self.configureEditMode()
		self.confirmButton.isEnabled = false //등록버튼 비활성화
    }
	
	private func configureEditMode() {
		switch self.diaryEditorMode {
			case let .edit(_, diary):
				self.titleTextField.text = diary.title
				self.contentsTextView.text = diary.contents
				self.dateTextField.text = self.dateToString(date: diary.date)
				self.diaryDate = diary.date
				self.confirmButton.title = "수정"
			
			default:
				break
		}
	}
	
	//형변환
	private func dateToString(date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
		formatter.locale = Locale(identifier: "ko-KR")
		return formatter.string(from: date)

	}
	
	//내용 textView 레이어 설정
	private func configureContentsTextView() {
		let borderColor = UIColor(red: 220/225, green: 220/255, blue: 220/255, alpha: 1.0)
		self.contentsTextView.layer.borderColor = borderColor.cgColor //레이어관련된 색상설정시에는 uicolor가아닌 cgcolor로
		self.contentsTextView.layer.borderWidth = 0.5
		self.contentsTextView.layer.cornerRadius = 5.0
	}
	
	private func configureDatePicker(){
		self.datePicker.datePickerMode = .date
		self.datePicker.preferredDatePickerStyle = .wheels
		self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged) //uicontroller가 이벤트에 응답하는 방식을 설정
		self.datePicker.locale = Locale(identifier: "ko-KR") //언어 한국어로
		self.dateTextField.inputView = self.datePicker //dateTextField의 입력창을 데이트피커로 변경
	}
	
	@objc private func datePickerValueDidChange(_ datePicker: UIDatePicker){
		let formmater = DateFormatter() //DateFormatter : 날짜와 텍스트를 변환. 데이트타입을 문자열로 변환, 날짜형에서 데이트타입으로 변환 등
		formmater.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
		formmater.locale = Locale(identifier: "ko_KR")
		self.diaryDate = datePicker.date
		self.dateTextField.text = formmater.string(from: datePicker.date)
		self.dateTextField.sendActions(for: .editingChanged)// editingChanged를 강제로 발생해서 configureInputField의 addTarget이 호출되도록 함. 이게없으면 날짜를변경해도 editing changed 이벤트가 발생하지 않기때문
	}
	private func configureInputField() {
		self.contentsTextView.delegate = self
		self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged) //제목 text가 입력될때마다 호출
		self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged) //날짜가 변경될때 호출
	}
	
	//제목 텍스트필드가 변할때 호출되는 selector
	@objc private func titleTextFieldDidChange(_ textField: UITextField) {
		self.validateInputField()
	}
	
	//날짜가 변경될때 호출되는 selector
	@objc private func dateTextFieldDidChange(_ textField: UITextField) {
		self.validateInputField()
	}
	
	//빈화면 누를때 실행됨
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true) //편집모드 종료
	}
	
	//등록버튼
	@IBAction func tabConfirmButton(_ sender: UIBarButtonItem) {
		guard let title = self.titleTextField.text else { return }
		guard let contents = self.contentsTextView.text else { return }
		guard let date = self.diaryDate else { return }
		
		switch self.diaryEditorMode {
			case .new: //새로생성
				let diary = Diary(uuidString: UUID().uuidString, title: title, contents: contents, date: date, isStar: false)
				self.delegate?.didSelectRegister(diary: diary)
				
			case let .edit(_, diary):
				let diary = Diary(uuidString: diary.uuidString, title: title, contents: contents, date: date, isStar: diary.isStar)
				NotificationCenter.default.post(
					name: NSNotification.Name("editDiary"),
					object: diary,
					userInfo: nil)

		}
		
		//self.delegate?.didSelectRegister(diary: diary)
		self.navigationController?.popViewController(animated: true)
	}
	
	//등록버튼 활성화여부 판단
	private func validateInputField() {
		self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty //모든 inputfield가 비어있지 않으면 enable
	}
	
}

extension WriteDiaryViewController: UITextViewDelegate {
	//textview의 text가 입력될때마다 호출되는 delegate
	func textViewDidChange(_ textView: UITextView) {
		self.validateInputField()
	}
}
