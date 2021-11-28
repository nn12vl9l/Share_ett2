//
//  WelcomeViewController.swift
//  Share_ett
//
//  Created by 小倉瑞希 on 2021/11/25.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        startButton.layer.cornerRadius = 10.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func tapButon(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        nextVC.modalPresentationStyle = .fullScreen
        present(nextVC, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
