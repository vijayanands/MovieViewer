//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Vijayanand on 9/12/17.
//  Copyright © 2017 Vijayanand. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var moviesSearchBar: UISearchBar!
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var errorsView: UIView!
    @IBOutlet weak var warningImage: UIImageView!
    @IBOutlet weak var errorHUD: UILabel!

    var movies: [NSDictionary]?
    var endpoint: String?
    var isSearching = false;
    var filteredData: [NSDictionary]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        movieTableView.dataSource = self
        movieTableView.delegate = self
        moviesSearchBar.delegate = self
        moviesSearchBar.returnKeyType = UIReturnKeyType.done
        
        warningImage.image = UIImage(named: "warning")
        errorHUD.text = "Network Error"
        errorHUD.sizeToFit()
        errorsView.isHidden = true
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        movieTableView.insertSubview(refreshControl, at: 0)
        
        networkRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        networkRequest()
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
    }
    
    func networkRequest() {
        let url = URL(string:"https://api.themoviedb.org/3/movie/\(self.endpoint!)?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
        var request = URLRequest(url: url!)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler:
        { (dataOrNil, response, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let data = dataOrNil {
                
                let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                print(dictionary)
                
                self.errorsView.isHidden = true
                self.movies = dictionary["results"] as? [NSDictionary]
                self.movieTableView.reloadData()
            } else {
                self.errorsView.isHidden = false
            }
        });
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearching) {
            return (filteredData?.count)!
        }
        
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        var movie: NSDictionary
        if (isSearching) {
            movie = (filteredData?[indexPath.row])!
        } else {
            movie = (movies?[indexPath.row])!
        }
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            let imageRequest = NSURLRequest(url: posterUrl! as URL)
            
            cell.posterView.setImageWith(
                imageRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.posterView.image = image
                    }
            },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterView.image = nil
        }
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.cyan
        cell.selectedBackgroundView = backgroundView
        
        print("row \(indexPath.row)")
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text == nil) || (searchBar.text == "") {
            isSearching = false
            view.endEditing(true)
            movieTableView.reloadData()
        } else {
            isSearching = true
            let predicate = NSPredicate(format: "%K == %@", "title", "\(searchText)")
            filteredData = movies?.filter(predicate.evaluate)
            movieTableView.reloadData()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        let detailsViewController = segue.destination as! DetailsViewController
        let cell = sender as! UITableViewCell
        let indexPath = movieTableView.indexPath(for: cell)
        
        // Pass the selected object to the new view controller.
        let movie = movies?[(indexPath?.row)!]
        detailsViewController.movie = movie
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
