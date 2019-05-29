//
//  ImageViewController.swift
//  TipResult
//
//  Created by Jack on 5/17/19.
//  Copyright © 2019 Jack. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ImageViewController: UIViewController {
    
    @IBOutlet weak var adBannerView: GADBannerView!
    @IBOutlet weak var largeImage: UIImageView!
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        largeImage.image = selectedImage
        adBannerView.adUnitID = "ca-app-pub-8519552575120945/1025960537"
        adBannerView.rootViewController = self
        adBannerView.load(GADRequest())
    }
    

}
