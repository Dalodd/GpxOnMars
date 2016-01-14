//
//  ShareViewController.swift
//  convertExtension
//
//  Created by 庄麓达 on 16/1/14.
//  Copyright © 2016年 Luda Zhuang. All rights reserved.
//

import UIKit
import MobileCoreServices

class ShareViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    private let UTI_BODUNOV_GPX = "com.bodunov.gpx"
    private let UTI_TOPOGRAFIX_GPX = "com.topografix.gpx"
    private var convertedGPXFileURL:NSURL?
    private var documentController:UIDocumentInteractionController!
    @IBOutlet weak var shareBarBtnItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        SVProgressHUD.setViewForExtension(self.view)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SVProgressHUD.showWithStatus("Converting")
        if let inputItems = self.extensionContext?.inputItems as? [NSExtensionItem] {
            loadGpxFromExtensionItem(inputItems, completionHandler: { gpx in
                if let path = gpx?.path {
                    let importedGPXFile = File(path)
                    if importedGPXFile.exists {
                        print(importedGPXFile.path)
                        let converter = GPXConverter()
                        self.convertedGPXFileURL = File.applicationCacheDirectory.URLByAppendingPathComponent("translated_" + importedGPXFile.fileName)
                        if self.convertedGPXFileURL!.pathExtension != "gpx" {
                            self.convertedGPXFileURL!.URLByAppendingPathExtension("gpx")
                        }
                        converter.convertToMars(importedGPXFile.path).saveTo(self.convertedGPXFileURL!)
                        importedGPXFile.deleteFile()
                        SVProgressHUD.dismiss()
                        self.documentController = UIDocumentInteractionController(URL: self.convertedGPXFileURL!)
                        self.documentController.delegate = self
                        self.documentController.UTI = self.UTI_TOPOGRAFIX_GPX
                        self.documentController.presentOptionsMenuFromBarButtonItem(self.shareBarBtnItem, animated: true)
                    } else {
                        SVProgressHUD.dismiss()
                        print(importedGPXFile.path)
                        self.showFailedAlert("Gpx file is missing!")
                    }
                } else {
                    SVProgressHUD.dismiss()
                    print(gpx)
                    self.showFailedAlert("No gpx file found!")
                }
            })
        }
    }
    func loadGpxFromExtensionItem(inputItems: [NSExtensionItem], completionHandler: (gpx: NSURL?)->Void) {
        let urlHandle:NSItemProviderCompletionHandler = {
            (secureCodingData, error) -> Void in
            if let e = error {
                print("Item loading error: \(e.localizedDescription)")
            }
            var url = secureCodingData as? NSURL
            if let pathExtension = url?.pathExtension?.lowercaseString {
                if pathExtension != "gpx" {
                    url = nil
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler(gpx: url)
            }
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, UInt(0))) {
            for item in inputItems {
                if let attachments = item.attachments as? [NSItemProvider] {
                    for attachment in attachments{
                        if attachment.hasItemConformingToTypeIdentifier(self.UTI_TOPOGRAFIX_GPX) {
                            attachment.loadItemForTypeIdentifier(self.UTI_TOPOGRAFIX_GPX, options: nil, completionHandler: urlHandle)
                            return
                        } else if attachment.hasItemConformingToTypeIdentifier(self.UTI_BODUNOV_GPX) {
                            attachment.loadItemForTypeIdentifier(self.UTI_BODUNOV_GPX, options: nil, completionHandler: urlHandle)
                            return
                        } else if attachment.hasItemConformingToTypeIdentifier(kUTTypeFileURL as String) {
                            attachment.loadItemForTypeIdentifier(kUTTypeFileURL as String, options: nil, completionHandler: urlHandle)
                            return
                        } else {
                            
                        }
                    }
                }
            }
            completionHandler(gpx: nil)
        }
    }
    
    func showFailedAlert(info: String) {
        let alertController = UIAlertController(title: "Gpx On Mars", message: info, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: {action in
            alertController.dismissViewControllerAnimated(true, completion: nil)
            self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
        })
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    func documentInteractionControllerDidDismissOpenInMenu(controller: UIDocumentInteractionController) {
        print("DidDismissOpenInMenu")
        self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
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
        self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
    }
}
