//
//  MemeDetailViewController.swift
//  MemeMe v2.0
//
//  Created by Mattia Sanfilippo on 11/04/2020.
//  Copyright © 2020 Mattia Sanfilippo. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController{
    var memeToShow: Meme!
    @IBOutlet var memeImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memeImageView.image = memeToShow.memedImage
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}
