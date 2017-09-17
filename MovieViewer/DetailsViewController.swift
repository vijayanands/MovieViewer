//
//  DetailsViewController.swift
//  MovieViewer
//
//  Created by Vijayanand on 9/15/17.
//  Copyright © 2017 Vijayanand. All rights reserved.
//

import UIKit
import AFNetworking

class DetailsViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)

        // Do any additional setup after loading the view.
        let title = movie["title"]
        let overview = movie["overview"]
        
        titleLabel.text = title as? String
        overviewLabel.text = overview as? String
        overviewLabel.sizeToFit()
        
        if let posterPath = movie?["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            let imageRequest = NSURLRequest(url: posterUrl! as URL)

            self.posterImageView.setImageWith(
                imageRequest as URLRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        self.posterImageView.alpha = 0.0
                        self.posterImageView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.posterImageView.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        self.posterImageView.image = image
                    }
            },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
            // posterImageView.setImageWith(posterUrl! as URL)
        }
        
        setupNavigationBarItems()
    }
    
    func setupNavigationBarItems() {
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "movie_info"))
        titleImageView.frame = CGRect(x:0, y:0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
