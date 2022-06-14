//
//  ViewController.swift
//  AsyncAwait
//
//  Created by Grigor Aghabalyan on 14.06.22.
//

import UIKit

enum MyError: Error {
    case failure
}

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Varibales
    
    var posts: [Post] = []
    
    var urlPosts = URL(string: "https://jsonplaceholder.typicode.com/posts")
    
    private let postCell = "PostCell"
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        registerCell()
        
        Task {
            // get posts
            let result = await fetchPosts()
            
            switch result {
            case .success(var posts):
                if let id = posts.first?.id {
                    // get comments
                    let comments = await fetchComments(postId: id)
                    posts[0].addComments(comments: comments)
                }

                self.posts = posts
                
            case .failure(let error):
                print(error)
            }
        
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Register
    
    private func registerCell() {
        let nib = UINib(nibName: postCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: postCell)
    }
    
    // MARK: - Requests
    
    private func fetchPosts() async -> Result<[Post], Error> {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        guard let urlPosts else {
            return .failure(MyError.failure)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: urlPosts)
            let posts = try JSONDecoder().decode([Post].self, from: data)
            activityIndicator.stopAnimating()
            return .success(posts)
        } catch let error {
            print(error)
            return .failure(error)
        }
    }
    
    private func fetchComments(postId: Int) async -> [Comment] {
        
        let urlString = "https://jsonplaceholder.typicode.com/posts/\(postId)/comments"
        let url = URL(string: urlString)
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        guard let url else {
            return []
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let comments = try JSONDecoder().decode([Comment].self, from: data)
            activityIndicator.stopAnimating()
            return comments
        } catch let error {
            print(error)
            return []
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: postCell, for: indexPath) as! PostCell
        cell.titleLabel?.text = posts[indexPath.row].title
        cell.subtitleLabel?.text = posts[indexPath.row].body
        cell.commentLabel.text = posts[indexPath.row].comments.first?.name
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

