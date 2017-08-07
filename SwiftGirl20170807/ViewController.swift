//
//  ViewController.swift
//  SwiftGirl20170807
//
//  Created by HsiaoShan on 2017/7/14.
//  Copyright © 2017年 ESoZuo. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var img: UIImageView!
    var myAlbum: PHAssetCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //請求相機權限
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
            print("camera access:\(granted)")
        }
        
        //請求照片權限
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                //取得自訂相簿,不存在則建立自定相簿
                if let collection = self.fetchAssetCollection(with: "SwiftGirls") {
                    self.myAlbum = collection
                } else {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "SwiftGirls")
                    }) { success, error in
                        if success {
                            print("Custom album create success.")
                            if let album = self.fetchAssetCollection(with: "SwiftGirls") {
                                self.myAlbum = album
                            }
                        } else {
                            print("error creating album: \(String(describing: error))")
                        }
                    }
                }
            case .denied:
                print("denied..")
            case .notDetermined:
                print("notDetermined..")
            case .restricted:
                print("restricted..")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //打開相機拍照
    @IBAction func goCamera(_ sender: Any) {
        guard AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized else {
            print("not authorized....")
            return
        }
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available.")
            return
        }
        
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
        
    }
    
    //打開相簿
    @IBAction func goPhoto(_ sender: Any) {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            print("PHPhotoLibrary not available.")
            return
        }
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Camera not available.")
            return
        }
        
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    //儲存照片至自訂相簿
    @IBAction func saveToCustomAlbum(_ sender: Any) {
        if self.img.image == nil {
            return
        }
        guard myAlbum != nil else {
            print("Custom album not found.")
            return
        }
        
        //儲存照片至指定相簿
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: self.img.image!)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.myAlbum!)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
        }, completionHandler:  {success, error in
            if success {
                print("save success.")
            } else {
                print("error creating asset: \(String(describing: error))")
            }
        })
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    //拍完新照片或從相簿選擇照片以後要做的事情
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(".....info.....\n\(info)")
        //從info取出拍好的照片
        if let pickedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage {
            img.image = pickedPhoto
            
            if picker.sourceType == .camera {
                //儲存照片至相機膠卷
                //1. UIKit method, iOS 2.0+
                //                UIImageWriteToSavedPhotosAlbum(pickedPhoto, nil, nil, nil)
                
                //2. Use Photos Library ,iOS 8.0+
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: pickedPhoto)
                }, completionHandler:  {success, error in
                    if success {
                        print("save success.")
                    } else {
                        print("error creating asset: \(String(describing: error))")
                    }
                })
            }
        }
        //取得PHAsset, iOS 11.0+
        //        if let result = info[UIImagePickerControllerPHAsset] as? PHAsset {
        
        //取得PHAsset, iOS 4.1-11.0, Deprecated
        if let assetURL = info[UIImagePickerControllerReferenceURL] as? NSURL {
            let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL as URL], options: nil)
            guard let result = asset.firstObject else {
                return
            }
            
            //取得ImageData
            PHImageManager.default().requestImageData(for: result , options: nil, resultHandler:{
                (data, responseString, imageOriet, info) -> Void in
                let imageData: NSData = data! as NSData
                if let imageSource = CGImageSourceCreateWithData(imageData, nil) {
                    let imgprop = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as NSDictionary
                    print("....metadata....\n\(imgprop)")
                    let pixelHeight = imgprop["PixelHeight"] as? Int
                    let pixelWidth = imgprop["PixelWidth"] as? Int
                    print("Height:\(pixelHeight ?? 0)")
                    print("Width:\(pixelWidth ?? 0)")
                    
                }
            })
        }
        //把相機畫面關掉
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel imagePickerController.")
        picker.dismiss(animated: true, completion: nil)
    }
    
    //依照相簿名稱取得相簿,不存在則回nil
    func fetchAssetCollection(with name: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let collection = collections.firstObject {
            return collection
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addStickers" {
            let vc = segue.destination as! AddStickersViewController
            if img.image != nil {
                vc.myImage = img.image
            }
        }
        
        if segue.identifier == "facedetect" {
            let vc = segue.destination as! FaceDetectViewController
            if img.image != nil {
                vc.myImage = img.image
            }
        }
    }
}

