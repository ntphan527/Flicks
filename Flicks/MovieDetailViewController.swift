//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by Phan, Ngan on 9/15/17.
//  Copyright © 2017 Phan, Ngan. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var movieDetailScrollView: UIScrollView!
    @IBOutlet weak var movieDetailInfoView: UIView!
    @IBOutlet weak var networkErrorView: UIView!
    
    var movie: NSDictionary!
    let smallBaseImageURL = "https://image.tmdb.org/t/p/w92"
    let largeBaseImageURL = "https://image.tmdb.org/t/p/original"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        movieDetailScrollView.contentSize = CGSize(width: movieDetailScrollView.frame.size.width,
                                                   height: movieDetailInfoView.frame.origin.y + movieDetailInfoView.frame.size.height)
        // Do any additional setup after loading the view.
        titleLabel.text = movie.value(forKeyPath: "title") as? String
        overviewLabel.text = movie.value(forKeyPath: "overview") as? String
        overviewLabel.sizeToFit()
        networkErrorView.isHidden = true
        view.backgroundColor = UIColor(red:0.81, green:0.85, blue:0.73, alpha:1.0)
        
        if let imageString = movie.value(forKeyPath: "poster_path") as? String {
            let smallImageUrlString = smallBaseImageURL + imageString
            let largeImageUrlString = largeBaseImageURL + imageString
            loadImage(smallImageUrl: smallImageUrlString, largeImageUrl: largeImageUrlString)
        }

    }
    
    func loadImage(smallImageUrl: String, largeImageUrl: String) {
        let smallImageRequest = URLRequest(url: URL(string: smallImageUrl)!)
        let largeImageRequest = URLRequest(url: URL(string: largeImageUrl)!)
        
        self.posterImageView.setImageWith(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // imageResponse will be nil if the image is cached
                if smallImageResponse != nil {
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = smallImage
                    
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        
                        self.posterImageView.alpha = 1.0
                        
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        self.posterImageView.setImageWith(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.posterImageView.image = largeImage
                                
                        },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                    })
                } else {
                    self.posterImageView.setImageWith(
                        largeImageRequest,
                        placeholderImage: smallImage,
                        success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                            
                            self.posterImageView.image = largeImage
                            
                    },
                        failure: { (request, response, error) -> Void in
                            // do something for the failure condition of the large image request
                            // possibly setting the ImageView's image to a default image
                            self.networkErrorView.isHidden = false
                    })
                }
            },
            failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
                self.networkErrorView.isHidden = false
        })
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
