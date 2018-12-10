//
//  MovieDetailInfoTableVC.swift
//  boostcamp_3_iOS_BoxOffice
//
//  Created by Kim DongHwan on 08/12/2018.
//  Copyright © 2018 Kim DongHwan. All rights reserved.
//

import UIKit

class MovieDetailInfoTableVC: UITableViewController, UIGestureRecognizerDelegate {
    
    var movieId: String?
    var movie: Movie? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var comments: [Comment]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        setupTableView()
        getMovie()
        getComments()
    }
    
    func setupRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = .blue
        self.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        getMovie()
        getComments()
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .clear
        let nibNames = ["MainInfoCell", "SynopsisCell", "ActorCell", "FirstCommentCell", "CommentCell"]
        let identifiers = ["mainInfoCell", "synopsisCell", "actorCell", "firstCommentCell", "commentCell"]
        
        self.registerCustomCells(nibNames: nibNames, forCellReuseIdentifiers: identifiers)
    }
    
    private func getMovie() {
        guard let movieId = movieId else {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            Manager.getMovie(movieId: movieId) { (data, error) in
                guard let movie = data else {
                    DispatchQueue.main.async {
                        self.alert("영화 정보를 가져오지 못했습니다.\n다시 시도해주세요.") {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.navigationItem.title = movie.title
                }
                
                self.movie = movie
            }
        }
    }
    
    private func getComments() {
        guard let movieId = movieId else {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            Manager.getComments(movieId: movieId) { (data, error) in
                guard let comments = data else {
                    DispatchQueue.main.async {
                        self.alert("한줄평 정보를 가져오지 못했습니다.\n다시 시도해주세요.") {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                
                self.comments = comments
            }
        }
    }
    
    //MARK: UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 2:
            return 1
        case 3:
            guard let comments = comments else { return 0 }
            return comments.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    @objc func presentFullScreenImageVC() {
        guard let movie = self.movie else {
            return
        }
        
        let fullScreenImageVC = FullScreenImageVC()
        fullScreenImageVC.path = movie.image
        
        self.present(fullScreenImageVC, animated: false, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let movie = self.movie else {
            return UITableViewCell()
        }
        
        guard let comments = self.comments else {
            return UITableViewCell()
        }
        
        let comment = comments[indexPath.row]
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainInfoCell", for: indexPath) as? MainInfoCell else {
                return UITableViewCell()
            }
            
            if cell.movieThumbImage.gestureRecognizers?.count ?? 0 == 0 {
                let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
                tapGesture.delegate = self
                tapGesture.addTarget(self, action: #selector(presentFullScreenImageVC))
                cell.movieThumbImage.addGestureRecognizer(tapGesture)
            }
            
            cell.movie = movie
            
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "synopsisCell", for: indexPath) as? SynopsisCell else {
                return UITableViewCell()
            }
            
            cell.movie = movie
            
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "actorCell", for: indexPath) as? ActorCell else {
                return UITableViewCell()
            }
            
            cell.movie = movie
            
            return cell
        case 3:
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "firstCommentCell", for: indexPath) as? FirstCommentCell else {
                    return UITableViewCell()
                }
                
                cell.comment = comment
                
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentCell else {
                    return UITableViewCell()
                }
                
                cell.comment = comment

                return cell
            }
        default:
            return UITableViewCell()
        }
    }
}
