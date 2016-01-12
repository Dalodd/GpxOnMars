//
//  ConvertViewController.swift
//  GpxOnMars
//
//  Created by 庄麓达 on 16/1/11.
//  Copyright © 2016年 Luda Zhuang. All rights reserved.
//

import UIKit

class ConvertViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    private var documentController:UIDocumentInteractionController!
    @IBOutlet weak var shareBarBtnItem: UIBarButtonItem!
    @IBOutlet weak var msgLabel: UILabel!
    private var convertedGPXFileURL:NSURL?
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        msgLabel.text = "Converting"
        print(msgLabel.text)
        print(AppConfig.gpxFileToConvert)
        if let path = AppConfig.gpxFileToConvert?.path {
            let importedGPXFile = File(path)
            if importedGPXFile.exists {
                print(importedGPXFile.path)
                let converter = GPXConverter()
                self.convertedGPXFileURL = File.applicationDocumentsDirectory.URLByAppendingPathComponent("translated_" + importedGPXFile.fileName)
                if convertedGPXFileURL!.pathExtension != "gpx" {
                    convertedGPXFileURL!.URLByAppendingPathExtension("gpx")
                }
                converter.convertToMars(importedGPXFile.path).saveTo(convertedGPXFileURL!)
                importedGPXFile.deleteFile()
                AppConfig.gpxFileToConvert = nil
                self.msgLabel.text = "Convert Completed"
                self.documentController = UIDocumentInteractionController(URL: convertedGPXFileURL!)
                self.documentController.delegate = self
                self.documentController.UTI = "com.topografix.gpx"
//                self.documentController.presentOpenInMenuFromRect(self.view.bounds, inView: self.view, animated: true)
                self.documentController.presentOptionsMenuFromBarButtonItem(shareBarBtnItem, animated: true)
//                self.documentController.presentOpenInMenuFromBarButtonItem(shareBarBtnItem, animated: true)
            } else {
                print(importedGPXFile.path)
            }
        } else {
            print("GPX file not found")
        }
    }
    func documentInteractionControllerDidDismissOpenInMenu(controller: UIDocumentInteractionController) {
        print("DidDismissOpenInMenu")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func documentInteractionController(controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        print("didEndSendingToApplication")
        if let convertedGPXFilePath = self.convertedGPXFileURL?.path {
            File(convertedGPXFilePath).deleteFile()
            self.convertedGPXFileURL = nil
        }
    }
    func documentInteractionControllerDidDismissOptionsMenu(controller: UIDocumentInteractionController) {
        print("DidDismissOptionsMenu")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
