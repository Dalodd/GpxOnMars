//
//  LocationTranslater.swift
//  GpxOnMars
//
//  Created by 庄麓达 on 16/1/11.
//  Copyright © 2016年 Luda Zhuang. All rights reserved.
//

import Foundation
class LocationTranslater {
    private static let a:Double = 6378245.0;
    private static let ee:Double = 0.00669342162296594323;
    static let Instance = LocationTranslater()
    func transformEarthFromMars(lat: Double, lon: Double) -> (latitude: Double, longitude: Double) {
        if outOfChina(lat, lon: lon) {
            return (latitude: lat, longitude: lon)
        }
        var dLat: Double = transformEarthFromMarsLat(lon - 105.0, y: lat - 35.0);
        var dLon: Double = transformEarthFromMarsLon(lon - 105.0, y: lat - 35.0);
        let radLat: Double = lat / 180.0 * M_PI;
        var magic:Double = sin(radLat);
        magic = 1 - LocationTranslater.ee * magic * magic;
        let sqrtMagic: Double = sqrt(magic);
        dLat = (dLat * 180.0) / ((LocationTranslater.a * (1 - LocationTranslater.ee)) / (magic * sqrtMagic) * M_PI);
        dLon = (dLon * 180.0) / (LocationTranslater.a / sqrtMagic * cos(radLat) * M_PI);
        let resLat = lat + dLat;
        let resLon = lon + dLon;
        return (latitude: resLat, longitude: resLon)
    }
    
    private func transformEarthFromMarsLat(x: Double, y: Double) -> Double {
        var ret:Double = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y
        ret += 0.1 * x * y + 0.2 * sqrt(fabs(x))
        ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
        ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0
        ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0
        return ret
    }
    
    private func transformEarthFromMarsLon(x: Double, y: Double) -> Double {
        var ret:Double = 300.0 + x + 2.0 * y + 0.1 * x * x
        ret += 0.1 * x * y + 0.1 * sqrt(fabs(x))
        ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
        ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0
        ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0
        return ret
    }
    

    
    func outOfChina(lat: Double, lon: Double) -> Bool {
        if lon < 72.004 || lon > 137.8347 {
            return true
        }
        if lat < 0.8293 || lat > 55.8271 {
            return true
        }
        return false
    }
}