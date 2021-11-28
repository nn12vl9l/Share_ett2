//
//  CreateViewController.swift
//  Share_ett
//
//  Created by 小倉瑞希 on 2021/11/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess
import SwiftUI

class CreateViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextField: UITextField!
    @IBOutlet weak var limitDataField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var postImage: UIImage?
    
    var toolBar:UIToolbar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        limitDataField.delegate = self
        setupToolbar()
        
        // Do any additional setup after loading the view.
    }
    
    func setupToolbar() {
        toolBar = UIToolbar()
        toolBar.sizeToFit()
        let toolBarBtn = UIBarButtonItem(title: "DONE", style: .plain, target: self, action: #selector(doneBtn))
        toolBar.items = [toolBarBtn]
        limitDataField.inputAccessoryView = toolBar
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        textField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "yyyy/MM/dd";
        limitDataField.text = dateFormatter.string(from: sender.date)
    }
    @objc func doneBtn(){
        limitDataField.resignFirstResponder()
    }
    
    @IBAction func tapImageView(_ sender: Any) {
        showAlert()
    }
    
    func checkCamera(){
        let sourceType:UIImagePickerController.SourceType = .camera
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true,completion: nil)
        }
    }
    
    func checkAlbam() {
        let sourceType:UIImagePickerController.SourceType = .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true,completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(){
        let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (alert) in
            self.checkCamera()
        }
        
        let albamAction = UIAlertAction(title: "アルバム", style: .default) { (alert) in
            self.checkAlbam()
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertController.addAction(cameraAction)
        alertController.addAction(albamAction)
        alertController.addAction(cancelAction)
        self.present(alertController,animated: true,completion: nil)
    }
    
    @IBAction func createButton(_ sender: Any) {
        postCharenge(title: titleTextField.text!, body: bodyTextField.text!, limitData: limitDataField.text!)
    }
    
    func postCharenge(title: String, body: String, limitData: String) {
        let url = "http://localhost/api/charenges"
        
        let headers: HTTPHeaders = [
            "Content-Type": "multipart/form-data",
            "ACCEPT": "application/json"
        ]
        
        AF.upload(
            multipartFormData: {(multipartFormData) in
                multipartFormData.append(self.postImage!.jpegData(compressionQuality: 1)!, withName: "image", fileName: "postfile.jpg", mimeType: "image/jpeg")
//                multipartFormData.appendBodyPart(fileURL: imagePathUrl!, name: "image")

//                multipartFormData.append([画像データ], withName: "[名前]", fileName: "[画像ファイル名]", mimeType: "[画像の種類]")
                // 文字データ
                multipartFormData.append(title.data(using: .utf8)!, withName: "title")
                multipartFormData.append(body.data(using: .utf8)!, withName: "body")
                multipartFormData.append(limitData.data(using: .utf8)!, withName: "limit_data")
            },
            to: url,
            method: .post,
            headers: headers
        ).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \n\(json)")
//                self.clearTextField()
            case .failure(let err):
                print(err.localizedDescription)
                print("エラー!")
            }
        }
    }
    
    func clearTextField() {
        titleTextField.text = ""
        bodyTextField.text = ""
        limitDataField.text = ""
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 選択されたimageを取得
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage? else {return}
        
        // imageをimageViewに設定
        imageView.image = selectedImage
        postImage = selectedImage
        //        backgroundImageView.image = backgroundImage
        
        // imagePickerの削除
        self.dismiss(animated: true, completion: nil)
    }
}
