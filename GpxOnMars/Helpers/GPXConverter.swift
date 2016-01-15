//
//  GPXConverter.swift
//  GpxOnMars
//
//  Created by Hran on 16/1/11.
//  Copyright © 2016年 Luda Zhuang. All rights reserved.
//

import Foundation
class GPXConverter {
    func convertToMars(gpxFile: String) -> GPXRoot {
        let gpx = GPXParser.parseGPXAtPath(gpxFile)
        return convertToMars(gpx)
    }
    func convertToMars(gpx: GPXRoot) -> GPXRoot {
        let locationConverter = LocationConverter.Instance
        let waypoints = gpx.waypoints as! [GPXWaypoint]
        for waypoint in waypoints {
            let newPoint = locationConverter.convertEarthFromMars(Double(waypoint.latitude), lon: Double(waypoint.longitude))
            waypoint.latitude = CGFloat(newPoint.latitude)
            waypoint.longitude = CGFloat(newPoint.longitude)
        }
        let tracks = gpx.tracks as! [GPXTrack]
        for track in tracks {
            let tracksegments = track.tracksegments as! [GPXTrackSegment]
            for tracksegment in tracksegments {
                let trackpoints = tracksegment.trackpoints as! [GPXTrackPoint]
                for trackpoint in trackpoints {
                    let newPoint = locationConverter.convertEarthFromMars(Double(trackpoint.latitude), lon: Double(trackpoint.longitude))
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