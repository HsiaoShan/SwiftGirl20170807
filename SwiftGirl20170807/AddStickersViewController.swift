//
//  AddStickersViewController.swift
//  SwiftGirl20170807
//
//  Created by HsiaoShan on 2017/7/14.
//  Copyright © 2017年 ESoZuo. All rights reserved.
//

import UIKit

class AddStickersViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var myImage: UIImage?
    @IBOutlet weak var myImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let img = myImage {
            myImageView.image = img
        }

        //對stickersView建立Tap手勢
        let singleTap = UITapGestureRecognizer(
            target:self, action:#selector(self.addSticker(recognizer:)))
        singleTap.delegate = self
        self.myImageView.addGestureRecognizer(singleTap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //儲存新照片
    @IBAction func saveNewImage(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(myImageView.frame.size, false, 0)
        myImageView.image?.draw(in: CGRect(x: 0, y: 0, width: myImageView.frame.size.width, height: myImageView.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        myImageView.subviews.forEach { view in
            if let imageView = view as? UIImageView {
                imageView.image?.draw(in: CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y, width: imageView.frame.size.width, height: imageView.frame.size.height))
            }
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(newImage!, nil, nil, nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //在手指點擊位置加一個貼圖
    func addSticker(recognizer:UITapGestureRecognizer){
        let point = recognizer.location(in: myImageView)
        let sticker = Sticker(x: point.x, y: point.y)
        myImageView.addSubview(sticker)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view as? Sticker) != nil {
            return false
        }
        return true
    }
}
