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
    let baseImageURL = "https://image.tmdb.org/t/p/w500"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        movieDetailScrollView.contentSize = CGSize(width: movieDetailScrollView.frame.size.width,
                                                   height: movieDetailInfoView.frame.origin.y + movieDetailInfoView.frame.size.height)
        // Do any additional setup after loading the view.
        titleLabel.text = movie.value(forKeyPath: "title") as? String
        overviewLabel.text = movie.value(forKeyPath: "overview") as? String
        overviewLabel.sizeToFit()
        
        if let imageString = movie.value(forKeyPath: "poster_path") as? String {
            let imageUrlString = baseImageURL + imageString
            if let imageUrl = URL(string: imageUrlString) {
                // URL(string: imageUrlString!) is NOT nil, go ahead and unwrap it and assign it to imageUrl and run the code in the curly braces
                posterImageView.setImageWith(imageUrl)
            } else {
                // URL(string: imageUrlString!) is nil. Good thing we didn't try to unwrap it!
            }
        }

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
