//
//  File.swift
//  Photos
//
//  Created by 庄麓达 on 15/9/23.
//  Copyright © 2015年 Luda Zhuang. All rights reserved.
//

import Foundation
public class File {
    public static let Sperator = "/"
    public static let FileManager = NSFileManager.defaultManager()
    public var path:String
    public var fileName:String{
        get{
            var _fileName = ""
            let index = path.lastIndexOf(File.Sperator)
            if index != nil {
                _fileName = path.substringFromIndex(index!.successor())
            }
            return _fileName
        }
    }
    public var fileExtension:String{
        get{
            var _fileExtension = ""

            let index = path.lastIndexOf(".")
            if index != nil {
                _fileExtension = path.substringFromIndex(index!.successor()).lowercaseString
            }

            return _fileExtension
        }
    }
    public var parentFilePath:String?{
        get{
            var _parentFile:String?
            if path.hasSuffix("/") && path.characters.count > 1{
                path = path.substringToIndex(path.endIndex.predecessor())
            }

            let index = path.lastIndexOf("/")
            if index != nil {
                _parentFile = path.substringToIndex(index!)
            }else{
                _parentFile = nil
            }
            return _parentFile
        }
    }
    public var parentFile:File?{
        get{
            let parentPath = self.parentFilePath
            if parentPath == nil {
                return nil
            }
            return File(parentPath!)
        }
    }
    public var exists:Bool{
        return File.FileManager.fileExistsAtPath(path)
    }
    /// Returns `true` if the current process has write privileges for the file at the path.
    public var isWritable: Bool {
        return File.FileManager.isWritableFileAtPath(path)
    }

    /// Returns `true` if the current process has read privileges for the file at the path.
    public var isReadable: Bool {
        return File.FileManager.isReadableFileAtPath(path)
    }

    /// Returns `true` if the current process has execute privileges for the file at the path.
    public var isExecutable: Bool {
        return  File.FileManager.isExecutableFileAtPath(path)
    }

    /// Returns `true` if the current process has delete privileges for the file at the path.
    public var isDeletable: Bool {
        return  File.FileManager.isDeletableFileAtPath(path)
    }
    public var isDirectory:Bool {
        var isDir:ObjCBool = false
        return File.FileManager.fileExistsAtPath(path, isDirectory: &isDir) && isDir
    }
    public var isFile:Bool {
        var isDir:ObjCBool = false
        return File.FileManager.fileExistsAtPath(path, isDirectory: &isDir) && !isDir
    }
    public var fileAttributes:[String: AnyObject]{
        do {
            return try File.FileManager.attributesOfItemAtPath(path)
        }catch{
            //nothing
        }
        return [:]
    }
    /// Modify attributes
    private func setAttributes(attributes: [String : AnyObject]) {
        do {
            try File.FileManager.setAttributes(attributes, ofItemAtPath: self.path)
        } catch {

        }
    }

    // Modify one attribute
    private func setAttribute(key: String, value : AnyObject) {
        setAttributes([key:value])
    }
    public var fileSize:Int64?{
        let attr = fileAttributes["NSFileSize"]
        if attr != nil {
            return Int64(attr as! Int)
        }else{
            return nil
        }
    }

    public var fileCreationDate:NSDate? {
        get {
            let attr = fileAttributes["NSFileCreationDate"]
            if attr != nil {
                return attr as? NSDate
            }else{
                return nil
            }
        }
        set {
            if newValue != nil {
                setAttribute("NSFileCreationDate", value: newValue!)
            }
        }
    }

    public var fileModificationDate:NSDate?{
        get {
            let attr = fileAttributes["NSFileModificationDate"]
            if attr != nil {
                return attr as? NSDate
            }else{
                return nil
            }
        }
        set {
            if newValue != nil {
                setAttribute("NSFileModificationDate", value: newValue!)
            }
        }
    }
    public subscript(key: String) -> AnyObject? {
        if key == "Attributes" {
            return fileAttributes
        }
        return fileAttributes[key]
    }
    public init(){
        path = "/"
    }

    public init(_ path:String){
        self.path = path
    }

    public func listAllFileAndDirectories() -> [String]{
        if(exists){
            let result = File.FileManager.subpathsAtPath(path)
            if result != nil {
                return result!
            }
        }
        return [String]()
    }
    public func listFileAndDirectories() -> [String]{
        var files = [String]()
        let childFiles = listAllFileAndDirectories()
        for fileName in childFiles {
            if !fileName.containsString(File.Sperator) {
                files.append(fileName)
            }
        }
        
        return files
    }
    public func listAllFiles() -> [String]{
        var files = [String]()
        let childFiles = listAllFileAndDirectories()
        for fileName in childFiles {
            var isDir:ObjCBool = false
            if File.FileManager.fileExistsAtPath(path + File.Sperator + fileName, isDirectory: &isDir) && !isDir {
                files.append(fileName)
            }
        }

        return files
    }
    
    public func listFiles() -> [String]{
        var files = [String]()
        let childFiles = listAllFileAndDirectories()
        for fileName in childFiles {
            var isDir:ObjCBool = false
            if File.FileManager.fileExistsAtPath(path + File.Sperator + fileName, isDirectory: &isDir) && !isDir {
                if !fileName.containsString(File.Sperator) {
                    files.append(fileName)
                }
            }
        }
        
        return files
    }
    
    public func listAllDirectories() -> [String]{
        var dirs = [String]()
        let childFiles = listAllFileAndDirectories()
        for fileName in childFiles {
            var isDir:ObjCBool = false
            if File.FileManager.fileExistsAtPath(path + File.Sperator + fileName, isDirectory: &isDir) && isDir {
                dirs.append(fileName)
            }
        }
        
        return dirs
    }
    
    public func listDirectories() -> [String]{
        var dirs = [String]()
        let childFiles = listAllFileAndDirectories()
        for fileName in childFiles {
            var isDir:ObjCBool = false
            if File.FileManager.fileExistsAtPath(path + File.Sperator + fileName, isDirectory: &isDir) && isDir {
                if !fileName.containsString(File.Sperator) {
                    dirs.append(fileName)
                }
            }
        }
        return dirs
    }
    
    public func mkdirs() -> Bool{
        if exists {
            return true
        }
        var dirsToMks = ""
        if path.hasSuffix("/") && path.characters.count > 1 {
            dirsToMks = path
        }else {
            let p = parentFile
            if p != nil && p!.exists {
                return true
            }
            dirsToMks = p!.path
        }
        
        do {
            try File.FileManager.createDirectoryAtPath(dirsToMks, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            print("Failed to mkdirs: \(dirsToMks), Please Check the Path or Permission")
            return false
        }
    }

    // Moves the file at `self` to a path.
    public func moveFileTo(path: File) -> Bool {
        if self.exists {
            if !path.exists {
                do {
                    path.mkdirs()
                    try File.FileManager.moveItemAtPath(self.path, toPath: path.path)
                    return true
                } catch {
                }
            }
        }
        return false
    }
    // Copies the file at `self` to a path.
    public func copyFileTo(path: File) -> Bool {
        if self.exists {
            if !path.exists {
                do {
                    path.mkdirs()
                    try File.FileManager.copyItemAtPath(self.path, toPath: path.path)
                    return true
                } catch {
                }
            }
        }
        return false
    }
    public func deleteFile() -> Bool{
        do {
            try File.FileManager.removeItemAtPath(path)
            return true
        } catch {
            return false
        }
    }
    public var hashValue: Int {
        return path.hashValue
    }

    // MARK: - CustomStringConvertible

    /// A textual representation of `self`.
    public var description: String {
        return path
    }

    // MARK: - CustomDebugStringConvertible

    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        return String(self.dynamicType) + ": " + path.debugDescription
    }

}

extension File {
    static var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    static var applicationCacheDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory , inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    static var applicationLibraryDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory , inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
}

extension String{
    func indexOf(substr:String)->Index?{
        return self.rangeOfString(substr)?.startIndex
    }
    func lastIndexOf(substr:String)->Index?{
        return self.rangeOfString(substr, options: .BackwardsSearch)?.startIndex
    }
}

extension Int64 {
    func toFileSize() -> String {
        let symb = ["Byte", "KB", "MB", "GB", "TB", "PB"]
        var size = Double(self)
        var count = 0
        while size >= 1024 {
            size /= 1024
            count++
        }
        
        return "\(size.toString("%.1f")) \(symb[count])"
    }
    
}
extension Double {
    func toString(format: String? = nil) -> String{
        if format == nil {
            return "\(self)"
        }
        return String(format: format!, self)
    }
}
