//
//  Extensions.swift
//  JustGoWithIt
//
//  Created by Joseph, Ethan on 6/15/18.
//  Copyright © 2018 Joseph, Ethan. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

extension Date {
    var day: Int { return Calendar.current.component(.day, from:self) }
    var month: Int { return Calendar.current.component(.month, from:self) }
    var year: Int { return Calendar.current.component(.year, from:self) }
    
    func formatDateAsString() -> String {
        let dateFormater = DateFormatter()
        if (self.month < 10) {
            dateFormater.dateFormat = "M/dd/yy"
        } else {
            dateFormater.dateFormat = "MM/dd/yy"
        }
        return dateFormater.string(from: self)
    }
}

extension UIView {
    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = 4.0
        self.layer.cornerRadius = 5.0
    }
    
    func bottomScrollShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
    }
    
    func roundCorners(radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func createGradientLayer(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        
        if let current = self.layer.sublayers?[0] {
            self.layer.replaceSublayer(current, with: gradientLayer)
        } else {
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}

// MARK: Number Utilities - Based on code from https://github.com/raizlabs/swiftilities
extension FloatingPoint {
    
    public func scaled(from source: ClosedRange<Self>, to destination: ClosedRange<Self>, clamped: Bool = false, reversed: Bool = false) -> Self {
        let destinationStart = reversed ? destination.upperBound : destination.lowerBound
        let destinationEnd = reversed ? destination.lowerBound : destination.upperBound
        
        // these are broken up to speed up compile time
        let selfMinusLower = self - source.lowerBound
        let sourceUpperMinusLower = source.upperBound - source.lowerBound
        let destinationUpperMinusLower = destinationEnd - destinationStart
        var result = (selfMinusLower / sourceUpperMinusLower) * destinationUpperMinusLower + destinationStart
        if clamped {
            result = result.clamped(to: destination)
        }
        return result
    }
}

public extension Comparable {
    
    func clamped(to range: ClosedRange<Self>) -> Self {
        return clamped(min: range.lowerBound, max: range.upperBound)
    }
    
    func clamped(min lower: Self, max upper: Self) -> Self {
        return min(max(self, lower), upper)
    }
    
}

extension UIImage {
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func imageRotatedByDegrees(deg degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension UINavigationBar {
    static func styleTitle(with color: UIColor) {
        let titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 22)!,
            NSAttributedStringKey.foregroundColor: color
        ]
        UINavigationBar.appearance().titleTextAttributes = titleTextAttributes
    }
}

extension GMSMapView {
    func addMapMarker(for place: GMSPlace, label: String?)->GMSMarker{
        let coordinate = place.coordinate
        let marker = GMSMarker(position: coordinate)
        marker.title = place.name
        marker.snippet = label
        marker.map = self
        return marker
    }
    
    func createMapMarkers(for city: PrimaryLocation)->[GMSMarker] {
        let places = city.subLocations
        var markers = [GMSMarker]()
        for place in places {
            if let gms = GoogleResourceManager.sharedInstance.getPlaceForId(ID: place.placeID) {
                let coordinate = gms.coordinate
                let marker = GMSMarker(position: coordinate)
                marker.title = gms.name
                marker.snippet = place.label
                marker.map = self
                markers.append(marker)
            }
        }
        return markers
    }
}
