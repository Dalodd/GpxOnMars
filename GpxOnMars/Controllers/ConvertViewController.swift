//
//  ConvertViewController.swift
//  GpxOnMars
//
//  Created by 庄麓达 on 16/1/11.
//  Copyright © 2016年 Luda Zhuang. All rights reserved.
//

import UIKit

class ConvertViewController: UIViewController {

    @IBOutlet weak var shareBarBtnItem: UIBarButtonItem!
    @IBOutlet weak var msgLabel: UILabel!
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        msgLabel.text = "Converting"
        print(msgLabel.text)
        print(AppConfig.gpxFileToConvert)
        if let path = AppConfig.gpxFileToConvert?.path {
            let file = File(path)
            if file.exists {
                print(file.path)
                let converter = GPXConverter()
                let fileURL: NSURL = File.applicationDocumentsDirectory.URLByAppendingPathComponent("translated_" + file.fileName)
                if fileURL.pathExtension != "gpx" {
                    fileURL.URLByAppendingPathExtension("gpx")
                }
                converter.convertToMars(file.path).saveTo(fileURL)
                self.msgLabel.text = "Convert Completed"
                
                let actpro = GPXActivityItemProvider(placeholderItem: fileURL)
//                let share = self.toolbarItems![1]
                let activity = OpenInActivity(url: actpro.fileURL, barItem: shareBarBtnItem)
                
                let sheet = UIActivityViewController(activityItems: [actpro], applicationActivities: [activity])
                sheet.excludedActivityTypes =
                    [UIActivityTypePostToWeibo,
                        UIActivityTypePrint,
                        UIActivityTypeSaveToCameraRoll,
                        UIActivityTypeAddToReadingList,
                        UIActivityTypePostToFlickr,
                        UIActivityTypePostToVimeo,
                        UIActivityTypePostToTencentWeibo]
                self.presentViewController(sheet, animated: true, completion: nil)
                
//                let gpxProvider = GPXActivityItemProvider(placeholderItem: fileURL)
//                let activity = UIActivityViewController(activityItems: [gpxProvider], applicationActivities: nil)
//                activity.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
//                    
//                }

//                if let popover = activity.popoverPresentationController {
////                    popover.sourceView = self.msgLabel
//                    popover.permittedArrowDirections = .Up
//                }
//                self.presentViewController(activity, animated: true, completion: { ()->Void in
//                    print("present done.")
//                })
            } else {
                print(file.path)
            }
        } else {
            print("GPX file not found")
        }
    }
    @IBAction func convertAction(sender: UIButton) {
    }

}
