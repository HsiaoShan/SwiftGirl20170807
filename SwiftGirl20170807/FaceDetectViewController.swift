//
//  FaceDetectViewController.swift
//  SwiftGirl20170807
//
//  Created by HsiaoShan on 2017/8/1.
//  Copyright © 2017年 ESoZuo. All rights reserved.
//

import UIKit
import CoreImage

class FaceDetectViewController: UIViewController {
    
    var myImage: UIImage?
    @IBOutlet weak var myImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let img = myImage {
            myImageView.image = img
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //臉部辨識
    @IBAction func detect(_ sender: Any) {
        guard let ciimage = CIImage(image: myImageView.image!) else {
            return
        }
        let ciImageSize = ciimage.extent.size
        
        //用於轉換座標
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        let viewSize = myImageView.bounds.size
        let scale = min(viewSize.width / ciImageSize.width,
                        viewSize.height / ciImageSize.height)
        //開始臉部辨識
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: ciimage)
        
        print("Face: \(faces?.count ?? 0)")
        var i = 1
        for face in faces as! [CIFaceFeature] {
            //將CoreImage用的座標轉乘UIView用的座標
            var faceViewBounds = face.bounds.applying(transform)
            print("faceBounds..\(faceViewBounds)...")
            // Calculate the actual position and size of the rectangle in the image view
            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            print("faceBounds scale..\(faceViewBounds)...")
            
            let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
            let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
            print("offsetX..\(offsetX)...offsetY...\(offsetY)")
            faceViewBounds.origin.x += offsetX
            faceViewBounds.origin.y += offsetY
            
            print("\(i) bounds: \(face.bounds)...\(faceViewBounds)")
            
            let faceBox = UIView(frame: faceViewBounds)
            faceBox.layer.borderWidth = 3
            faceBox.layer.borderColor = UIColor.red.cgColor
            faceBox.backgroundColor = UIColor.clear
            myImageView.addSubview(faceBox)
            
            if face.hasLeftEyePosition {
                print("\(i) Left eye bounds are \(face.leftEyePosition)")
            }
            if face.hasRightEyePosition {
                print("\(i) Right eye bounds are \(face.rightEyePosition)")
            }
            if face.hasMouthPosition {
                print("\(i) Mouth bounds are \(face.mouthPosition)")
                var mouthPosition = face.mouthPosition.applying(transform)
                mouthPosition = mouthPosition.applying(CGAffineTransform(scaleX: scale, y: scale))
                let lipSize: CGFloat = faceViewBounds.width / 2
                let x = mouthPosition.x + offsetX - (lipSize / 2)
                let y = mouthPosition.y + offsetY - (lipSize / 2)
                let frame = CGRect(x: x, y: y, width: lipSize, height: lipSize)
                let mouth = UIImageView(frame: frame)
                mouth.image = #imageLiteral(resourceName: "lips")
                myImageView.addSubview(mouth)
            }
            i += 1
        }
    }
    
    @IBAction func save(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(myImageView.frame.size, false, 0)
        myImageView.image?.draw(in: CGRect(x: 0, y: 0, width: myImageView.frame.size.width, height: myImageView.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        myImageView.subviews.forEach { view in
            if let imageView = view as? UIImageView {
                imageView.image?.draw(in: CGRect(x: imageView.frame.origin.x, y: imageView.frame.origin.y, width: imageView.frame.size.width, height: imageView.frame.size.height))
            } else {
                view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
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
    
    
    
}
