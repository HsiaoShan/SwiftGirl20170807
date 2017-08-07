//
//  Sticker.swift
//  SwiftGirl20170807
//
//  Created by HsiaoShan on 2017/7/14.
//  Copyright © 2017年 ESoZuo. All rights reserved.
//

import UIKit

class Sticker: UIImageView {
    
    let img = #imageLiteral(resourceName: "flower")
    
    init(x: CGFloat, y: CGFloat) {
        let width = img.size.width
        let height = img.size.height
        let cgrect = CGRect(x: x - (width / 2), y: y - (height / 2), width: width, height: height)
        super.init(frame: cgrect)
        self.image = img
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //該貼圖被點擊到就從畫面上刪除
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
    }
}
