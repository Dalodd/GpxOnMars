//
//  GPXActivityItemProvider.swift
//  GpxOnMars
//
//  Created by 庄麓达 on 16/1/11.
//  Copyright © 2016年 Luda Zhuang. All rights reserved.
//
import UIKit

class GPXActivityItemProvider: UIActivityItemProvider {
    var fileURL:NSURL {
        return self.placeholderItem as! NSURL
    }
    override func activityViewController(activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: String?) -> String {
        return "com.topografix.gpx"
    }
    
    override func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        return fileURL
    }
    
    override func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        return File(fileURL.path!).fileName
    }
    
    override func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return fileURL
    }
    
}
