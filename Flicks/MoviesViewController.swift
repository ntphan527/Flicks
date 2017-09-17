//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Phan, Ngan on 9/15/17.
//  Copyright © 2017 Phan, Ngan. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var listOrGridSegmentedControl: UISegmentedControl!
    @IBOutlet weak var movieTableSearchBar: UISearchBar!
    
    var movies: [NSDictionary] = []
    var filteredMovies: [NSDictionary] = []
    var filteredCollectionMovies: [NSDictionary] = []
    var endpoint: String!
    let refreshControl = UIRefreshControl()
    var searchActive: Bool = false
    var searchCollectionActive: Bool = false
    var isReloadingCollectionView = false
    let baseImageURL = "https://image.tmdb.org/t/p/w500"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        movieTableView.delegate = self
        movieTableView.dataSource = self
        movieTableSearchBar.delegate = self
        
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
        
        networkErrorView.isHidden = true
        
        // Initialize a UIRefreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        
        showListOrGrid(self)
    }
    
    @IBAction func showListOrGrid(_ sender: Any) {
        switch listOrGridSegmentedControl.selectedSegmentIndex {
        case 0:
            movieCollectionView.isHidden = true
            movieTableView.isHidden = false
            movieTableView.insertSubview(refreshControl, at: 0)
        case 1:
            movieCollectionView.isHidden = false
            movieTableView.isHidden = true
            movieCollectionView.insertSubview(refreshControl, at: 0)
        default:
            break
        }
        
        // Load data from movies DB
        MoviesViewController.fetchMovies(sender: self, refreshControl: nil, successCallBack: successCallBack(dataDictionary:), errorCallBack: errorCallBack(error:))
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        MoviesViewController.fetchMovies(sender: self, refreshControl: refreshControl, successCallBack: successCallBack(dataDictionary:), errorCallBack: errorCallBack(error:))
        print(movies)
    }

    class func fetchMovies(sender: MoviesViewController, refreshControl: UIRefreshControl?, successCallBack: @escaping (NSDictionary) -> (), errorCallBack: ((Error?) -> ())?) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(sender.endpoint!)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        if refreshControl == nil {
            MBProgressHUD.showAdded(to: sender.view, animated: true)
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                errorCallBack?(error)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                successCallBack(dataDictionary)
            }
            if let refreshControl = refreshControl {
                refreshControl.endRefreshing()
            } else {
                MBProgressHUD.hide(for: sender.view, animated: true)
            }
        }
        task.resume()
    }
    
    func errorCallBack(error: Error?) {
        networkErrorView.isHidden = false
    }
    
    func successCallBack(dataDictionary: NSDictionary) {
        if let moviesDictionary = dataDictionary["results"] as? [NSDictionary] {
            networkErrorView.isHidden = true
            movies = moviesDictionary
            print(movies)
            if !movieTableView.isHidden {
                movieTableView.reloadData()
            } else {
                movieCollectionView.reloadData()
            }
        } else {
            networkErrorView.isHidden = false
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if movieTableView.isHidden {
            print("collection begin")
            searchCollectionActive = true
        } else {
            print("begin")
            searchActive = true
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if movieTableView.isHidden {
            print("collection end")
            if isReloadingCollectionView {
                print("reloading: \(isReloadingCollectionView) true")
                searchCollectionActive = true
            } else {
                print("reloading: \(isReloadingCollectionView) false")
                searchCollectionActive = false
            }
        } else {
            print("end")
            searchActive = false
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if movieTableView.isHidden {
            print("collection cancel")
            searchCollectionActive = false
        } else {
            print("cancel")
            searchActive = false
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if movieTableView.isHidden {
            print("collection search")
            searchCollectionActive = false
        } else {
            print("search")
            searchActive = false
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let tempFilteredMovies = movies.filter({ (compareMovie) -> Bool in
            let movie: NSDictionary = compareMovie
            if let title = movie.value(forKeyPath: "title") as? String {
                if let range = title.range(of: searchText, options: NSString.CompareOptions.caseInsensitive) {
                    return !range.isEmpty
                }
            }
            return false
        })
        
        if movieTableView.isHidden {
            print("collection text change")
            
            filteredCollectionMovies = tempFilteredMovies
            print("search: \(searchText) results: \(filteredCollectionMovies.count)")
            if(filteredCollectionMovies.count == 0){
                searchCollectionActive = false;
            } else {
                searchCollectionActive = true;
            }
            
            isReloadingCollectionView = true
            movieCollectionView.reloadData()
            isReloadingCollectionView = false
        } else {
            print("text change")
            filteredMovies = tempFilteredMovies
            if(filteredMovies.count == 0){
                searchActive = false;
            } else {
                searchActive = true;
            }
            movieTableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        var movie = movies[indexPath.row]
        if searchActive {
            movie = filteredMovies[indexPath.row]
        }
        
        cell.titleLabel.text = movie.value(forKeyPath: "title") as? String
        cell.overviewLabel.text = movie.value(forKeyPath: "overview") as? String
        cell.overviewLabel.sizeToFit()
        
        if let imageString = movie.value(forKeyPath: "poster_path") as? String {
            let imageUrlString = baseImageURL + imageString
            if let imageUrl = URL(string: imageUrlString) {
                // URL(string: imageUrlString!) is NOT nil, go ahead and unwrap it and assign it to imageUrl and run the code in the curly braces
                cell.posterImageView.setImageWith(imageUrl)
            } else {
                // URL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredMovies.count
        }
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        movieTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchCollectionActive {
            print(filteredCollectionMovies.count)
            return filteredCollectionMovies.count
        }
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionCell", for: indexPath) as! MovieCollectionCell
        var movie = movies[indexPath.row]
        if searchCollectionActive {
            //print("filtered")
            movie = filteredCollectionMovies[indexPath.row]
        }
        
        cell.titleLabel.text = movie.value(forKeyPath: "title") as? String
        cell.overviewLabel.text = movie.value(forKeyPath: "overview") as? String
        print(cell.titleLabel.text ?? "")
        
        if let imageString = movie.value(forKeyPath: "poster_path") as? String {
            let imageUrlString = baseImageURL + imageString
            if let imageUrl = URL(string: imageUrlString) {
                // URL(string: imageUrlString!) is NOT nil, go ahead and unwrap it and assign it to imageUrl and run the code in the curly braces
                cell.posterImageView.setImageWith(imageUrl)
            } else {
                // URL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "MovieCollectionReusableView", for: indexPath)
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let movieDetailViewController = segue.destination as! MovieDetailViewController
        
        if movieTableView.isHidden {
            let indexPath = movieCollectionView.indexPath(for: sender as! UICollectionViewCell)!
            if searchCollectionActive {
                movieDetailViewController.movie = filteredCollectionMovies[indexPath.row]
            } else {
                movieDetailViewController.movie = movies[indexPath.row]
            }
        } else {
            let indexPath = movieTableView.indexPath(for: sender as! UITableViewCell)!
            if searchActive {
                movieDetailViewController.movie = filteredMovies[indexPath.row]
            } else {
                movieDetailViewController.movie = movies[indexPath.row]
            }
        }
    }
}
