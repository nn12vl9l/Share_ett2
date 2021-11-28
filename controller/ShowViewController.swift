//
//  ShowViewController.swift
//  Share_ett
//
//  Created by 小倉瑞希 on 2021/11/26.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess
import Kingfisher

class ShowViewController: UIViewController {
    
    var charenges:[Charenge] = []
    var posts:[Post] = []
    var charengeId = ""
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var entryButton: UIButton!
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        entryButton.layer.cornerRadius = 10.0
        getCharengeInfo(charengeId: charengeId)
        
        postTableView.dataSource = self
        postTableView.delegate = self
        
        let url = "http://localhost/api/posts"
        
        AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value).arrayValue
                print(json)
                self.posts = []
                for posts in json {
                    let post = Post(
                        id: posts["id"].int!,
                        body: posts["body"].string!,
                        imageUrl: posts["image_url"].string!
                    )
                    self.posts.append(post)
                }
                self.postTableView.reloadData()
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func getCharengeInfo(charengeId: String) {
        let url = "http://localhost/api/charenges/" + charengeId
        
        let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "ACCEPT": "application/json"
            ]
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let charenge = Charenge(
                    id: json["id"].int!,
                    title: json["title"].string!,
                    body: json["body"].string!,
                    limitData: json["limit_data"].string!,
                    imageUrl: json["image_url"].string!
                )                
                self.setCharenge(charenge: charenge)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func setCharenge(charenge: Charenge) {
        titleLabel.text = charenge.title
        bodyLabel.text = charenge.body
        let imageUrl = URL(string: charenge.imageUrl)!
        imageView.kf.setImage(with: imageUrl)
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func entryButton(_ sender: Any) {
        print("エントリーされました")
    }
}

extension ShowViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.kf.setImage(with: URL(string: posts[indexPath.row].imageUrl)!)
        let bodyLabel = cell.viewWithTag(2) as! UILabel
        bodyLabel.text = posts[indexPath.row].body
        return cell
    }
}

extension ShowViewController: UITableViewDelegate {
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        vc.postId = String(posts[indexPath.row].id)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}
