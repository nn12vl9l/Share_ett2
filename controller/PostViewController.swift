                        //
//  PostViewController.swift
//  Share_ett
//
//  Created by 小倉瑞希 on 2021/11/27.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess
import Kingfisher

class PostViewController: UIViewController {
    
    var posts:[Post] = []
    var comments: [Comment] = []
    var postId = ""

    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var postImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getPostInfo(postId: postId)
        getCommentsInfo()
        commentTableView.dataSource = self
        
    }
    
    func getPostInfo(postId: String) {
        let url = "http://localhost/api/posts/" + postId
        
        let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "ACCEPT": "application/json"
            ]
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let post = Post(
                    id: json["id"].int!,
                    body: json["body"].string!,
                    imageUrl: json["image_url"].string!
                )
                self.setPost(post: post)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func getCommentsInfo() {
        let url = "http://localhost/api/posts/" + postId + "/comments"
        let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "ACCEPT": "application/json"
            ]
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                // success
            case .success(let value):
                self.comments = []
                let json = JSON(value).arrayValue
                print(json)
                for comments in json {
                    let comment = Comment(
                        id: comments["id"].int!,
                        comment: comments["comment"].string!
                    )
                    self.comments.append(comment)
                }
                self.commentTableView.reloadData()
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func setPost(post: Post) {
        bodyLabel.text = post.body
        let imageUrl = URL(string: post.imageUrl)!
        postImageView.kf.setImage(with: imageUrl)
    }

    
    @IBAction func tapBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func likeButton(_ sender: Any) {
        like()
    }
    
    func like() {
        let url = "http://localhost/api/posts/" + postId + "/likes"
        
        let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "ACCEPT": "application/json"
            ]
        AF.request(url, method: .post, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \n\(json)")
            case .failure(let err):
                print("### ERROR ###")
                print(err.localizedDescription)
            }
        }
    }
    
    @IBAction func sendButton(_ sender: Any) {
        if (commentTextField.text != "") {
            comment()
        }
        
        func comment() {
            let url = "http://localhost/api/posts/" + postId + "/comments"
            
            let headers: HTTPHeaders = [
                    "Content-Type": "application/json",
                    "ACCEPT": "application/json"
                ]
            AF.request(url, method: .post, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("JSON: \n\(json)")
                case .failure(let err):
                    print("### ERROR ###")
                    print(err.localizedDescription)
                }
            }
        }
    }
}

extension PostViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = comments[indexPath.row].comment
        return cell
    }
        
}

