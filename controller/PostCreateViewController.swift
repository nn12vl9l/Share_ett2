//
//  PostCreateViewController.swift
//  Share_ett
//
//  Created by 小倉瑞希 on 2021/11/26.
//

import UIKit
import HealthKit
import SwiftUI

class PostCreateViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var charengeChoose: UITextField!
    @IBOutlet weak var bodyTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var walkTextField: UITextField!
    @IBOutlet var postDayTextField: UITextField!
    
    var toolBar: UIToolbar!
    var stepDay: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postDayTextField.delegate = self
        setupToolbar()
        
        
        // Do any additional setup after loading the view.
        
        guard HKHealthStore.isHealthDataAvailable() else { return print("HealthKit is not available") }
        let dataTypes = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])
        HKHealthStore().requestAuthorization(toShare: nil, read: dataTypes) { success, Error in
            if success {
                print("success?:", success)
            }
        }
    }
    
    func setupToolbar() {
        toolBar = UIToolbar()
        toolBar.sizeToFit()
        let toolBarBtn = UIBarButtonItem(title: "DONE", style: .plain, target: self, action: #selector(doneBtn))
        toolBar.items = [toolBarBtn]
        postDayTextField.inputAccessoryView = toolBar
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
        stepDay = sender.date
        postDayTextField.text = dateFormatter.string(from: sender.date)
    }
    @objc func doneBtn(){
        postDayTextField.resignFirstResponder()
    }
    
    func getSteps(day: Date) {
        var sampleArray: [Double] = []
        let startDate = Calendar.current.startOfDay(for: day)
        let nextDay = Calendar.current.date(byAdding: DateComponents(day: 1), to: day)!
        let endDate = Calendar.current.startOfDay(for: nextDay )
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let query = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: .stepCount)!,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: startDate,
                                                intervalComponents: DateComponents(day: 1))
        
        query.initialResultsHandler = {_, results, _ in
            guard let statsCollection = results else { return }
            
            statsCollection.enumerateStatistics(from: startDate, to: Date()) { statistics, _ in
                if let quantity = statistics.sumQuantity() {
                    
                    let stepValue = quantity.doubleValue(for: HKUnit.count())
                    sampleArray.append(floor(stepValue))
                } else {
                    sampleArray.append(0.0)
                }
            }
            DispatchQueue.main.async {
                self.walkTextField.text = String(Int(sampleArray[0]))
            }
        }
        HKHealthStore().execute(query)
        
    }
    
    @IBAction func getWalkButton(_ sender: Any) {
        print("stepDay : \(stepDay)")
        getSteps(day: stepDay)
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
    
    @IBAction func postButton(_ sender: Any) {
        //        postCreate(charenge: charengeChoose.text!, body: bodyTextField.text!, weight: weightTextField!, walk: walkTextField, postDay: postDayTextField!)
    }
    
    //    func postCreate(charenge: String, body: String, weight: Double, walk: Double, postDay: String) {
    //        let url = "http://localhost/api/posts"
    //
    //        let headers: HTTPHeaders = [
    //            "Content-Type": "multipart/form-data",
    //            "ACCEPT": "application/json"
    //        ]
    //    }
}
