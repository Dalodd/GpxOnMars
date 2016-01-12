//
//  GPXConverter.swift
//  GpxOnMars
//
//  Created by 庄麓达 on 16/1/11.
//  Copyright © 2016年 Luda Zhuang. All rights reserved.
//

import Foundation
class GPXConverter {
    func convertToMars(gpxFile: String) -> GPXRoot {
        let gpx = GPXParser.parseGPXAtPath(gpxFile)
        return convertToMars(gpx)
    }
    func convertToMars(gpx: GPXRoot) -> GPXRoot {
        let locationTranslater = LocationTranslater.Instance
//        print("WAY POINTS:")
        let waypoints = gpx.waypoints as! [GPXWaypoint]
        for waypoint in waypoints {
//            print("(\(waypoint.latitude), \(waypoint.longitude))  [ele: \(waypoint.elevation), \(waypoint.time)]")
            let newPoint = locationTranslater.transformEarthFromMars(Double(waypoint.latitude), lon: Double(waypoint.longitude))
            waypoint.latitude = CGFloat(newPoint.latitude)
            waypoint.longitude = CGFloat(newPoint.longitude)
        }
//        print("TRACKS:")
        let tracks = gpx.tracks as! [GPXTrack]
        for track in tracks {
//            print("    \(track.name):")
            let tracksegments = track.tracksegments as! [GPXTrackSegment]
            for tracksegment in tracksegments {
//                print("        TRACKS SEGMENTS:")
                let trackpoints = tracksegment.trackpoints as! [GPXTrackPoint]
                for trackpoint in trackpoints {
//                    print("            (\(trackpoint.latitude), \(trackpoint.longitude))  [ele: \(trackpoint.elevation), \(trackpoint.time)]")
                    let newPoint = locationTranslater.transformEarthFromMars(Double(trackpoint.latitude), lon: Double(trackpoint.longitude))
                    trackpoint.latitude = CGFloat(newPoint.latitude)
                    trackpoint.longitude = CGFloat(newPoint.longitude)
                }
            }
        }
        return gpx
    }
}

extension GPXRoot {
    func saveTo(fileURL:NSURL) {
        print("Saving file at path: \(fileURL)")
        do {
            try self.gpx().writeToFile(fileURL.path!, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print("[ERROR] GPXFileManager:save: \(error.localizedDescription)")
        }
    }
}