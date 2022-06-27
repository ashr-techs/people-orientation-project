
//
//  AppDelegate.swift
//  Orientamento
//
//  Created by Mauro Antonio Giacomello on 18/02/2020.
//  The name of MAURO ANTONIO GIACOMELLO may not be used to endorse or promote
//  products derived from this software without specific prior written permission.
/*******************************************************************************
*
* The MIT License (MIT)
*
* Copyright (c) 2020, 2021, 2022  Mauro Antonio Giacomello
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*******************************************************************************/
//
import UIKit
import WebKit
import CoreData
import CoreLocation
import AVFoundation
import Foundation
import JavaScriptCore
import SwiftUI
class SetUpTheVirtualCoordinateSystem {
    
    // set up a reference system (just to establish a coordinate reference system
    // as alternative to what googlemap is doing for you when you use overlays)
    // A [45.18779, 9.156248,5,"fence","UNIPVSP pt 04"],
    // C [45.187293,9.158488,5,"fence","UNIPVSP pt 05"],
    // B [45.186496,9.158393,5,"fence","UNIPVSP pt 06"],
    // D [45.186261,9.156675,5,"fence","UNIPVSP pt 07"],
    private let geoPointA:[Float]           = [45.18779,9.15630]
    private let geoPointB:[Float]           = [45.18629,9.15662]
    private let geoPointC:[Float]           = [45.18730,9.15833]
    private let geoPointD:[Float]           = [45.186515,9.158306]
    private var geoPoint00:[Float]          = []
    private var geoPointZZ:[Float]          = []
    
    private var latAvgFactor:Float          = 0.0
    private var lngAvgFactor:Float          = 0.0
    
    private let distFisicaMetriAC:Float     = 171.84
    private let distFisicaMetriAB:Float     = 168.43
    private let distFisicaMetriBC:Float     = 173.24
    private let distFisicaMetriAD:Float     = 211.94
    private var distFisicaMetri00ZZ:Float   = 0.0
    private var distFisicaMetri00ZZlng:Float = 0.0
    private var distFisicaMetri00ZZlat:Float = 0.0
    private let pictureWidth:Double         = 996
    private let pictureHeight:Double        = 886
    private var viewWidht:Double            = 394
    private var viewHeight:Double           = 420
    private let offsetPointA:[Float]        = [166.0,17.0]    // x,y 167 museo volta angolo via strada nuova via carlo alberto
    private let offsetPointB:[Float]        = [315.0,736.0]   // x,y 319 aula magna
    private let offsetPointC:[Float]        = [874.0,226.0]   // x,y via Carlo Alberto
    private let offsetPointD:[Float]        = [857.0,607.0]   // x,y collegio angolo sud/est
    private var offsetPoint00:[Float]       = []              // x,y 00
    private var offsetPointZZ:[Float]       = []              // x,y 996,886
    
    private var ddd:[Double] = []
    private var fff:[Float] = []
    
    init() {
        self.ddd = [3,5]
        self.fff = [0.6,1.3]
    }
    
    func getViewHeight() -> Double {
        return self.viewHeight
    }
    func getViewWidht()  -> Double {
        return self.viewWidht
    }
    
    func locationWithBearing(bearingRadians:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        // bearing = 0 North, 180 South, 270 West, 90 Est
        let distRadians = distanceMeters / (6372797.6) // earth radius in meters
        let lat1 = origin.latitude * Double.pi / 180
        let lon1 = origin.longitude * Double.pi / 180
        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearingRadians))
        let lon2 = lon1 + atan2(sin(bearingRadians) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
    
     
    
    func distance(_ fromX:Double,_ fromY:Double,_ toX:Double,_ toY:Double) -> Double {
            let coordinate₀ = CLLocation(latitude: fromX, longitude: fromY)
            let coordinate₁ = CLLocation(latitude: toX, longitude:  toY)
            let distanceInMeters = coordinate₀.distance(from: coordinate₁)
            return distanceInMeters
        }
    
    func setBasicImageReferences( guidaImageView :UIImageView ) -> UIImageView {
        offsetPoint00 = [Float(0.0),Float(0.0)]
        offsetPointZZ = [Float(self.pictureWidth),Float(self.pictureHeight)]
        
        // CALCOLO PUNTO geo00
        
        /* AB */
        
        let dABlat = (geoPointA[0]-geoPointB[0])
        let dABlng = (geoPointA[1]-geoPointB[1])
        let geoDistMetersAB = distance(Double(geoPointA[0]),Double(geoPointA[1]),Double(geoPointB[0]),Double(geoPointB[1]))
        print("AB \(Float(geoDistMetersAB)/distFisicaMetriAB)")
        
        let geoDistMetersABlat = distance(Double(geoPointA[0]),Double(geoPointB[1]),Double(geoPointB[0]),Double(geoPointB[1]))
        print("ABlat \(Float(geoDistMetersABlat))")
        
        let geoDistMetersABlng = distance(Double(geoPointA[0]),Double(geoPointB[1]),Double(geoPointA[0]),Double(geoPointA[1]))
        print("ABlng \(Float(geoDistMetersABlng))")
        
        // Prova del 9 >>> sounds very good !
        let geoDistMetersABpitagora = sqrt((geoDistMetersABlng*geoDistMetersABlng)+(geoDistMetersABlat*geoDistMetersABlat))
        print("ABpit \(Float(Float(geoDistMetersABpitagora)/Float(geoDistMetersAB)))")
        // Calcolo una tantum la distanza AD perchè non la conosco
        
        let geoDistMetersAD = distance(Double(geoPointA[0]),Double(geoPointA[1]),Double(geoPointD[0]),Double(geoPointD[1]))
        print("AD \(Float(geoDistMetersAD)/distFisicaMetriAD)")
        
        
        /* BC */
        
        let dBClat = (geoPointB[0]-geoPointC[0])
        let dBClng = (geoPointB[1]-geoPointC[1])
        let geoDistMetersBC = distance(Double(geoPointB[0]),Double(geoPointB[1]),Double(geoPointC[0]),Double(geoPointC[1]))
        print("BC \(Float(geoDistMetersBC)/distFisicaMetriBC)")
        /* AC */
        
        let dAClat = (geoPointA[0]-geoPointC[0])
        let dAClng = (geoPointA[1]-geoPointC[1])
        let geoDistMetersAC = distance(Double(geoPointA[0]),Double(geoPointA[1]),Double(geoPointC[0]),Double(geoPointC[1]))
        print("AC \(Float(geoDistMetersAC)/distFisicaMetriAC)")
        
        
        // calculating the distance in meters between a point to another (expressed in offset)
        // it's possible to find the relative geo coordinate of such new point
        
        // AB to find pointAB00 geoCoordinate
        
        // segmets subtended by line AB
        let dABoffx = (offsetPointA[0]-offsetPointB[0])
        let dABoffy = (offsetPointA[1]-offsetPointB[1])
        
        let lengthABbyOffset = sqrt((dABoffy*dABoffy)+(dABoffx*dABoffx))
        // rapporto di equivalenza tra geo distanza e distanza in offset
        let ABequivalenza =  lengthABbyOffset / Float(geoDistMetersAC)
        let distanceOffsetPoint00PointA = sqrt((offsetPointA[0]*offsetPointA[0])+(offsetPointA[1]*offsetPointA[1]))
        let distanceInMetersPoint0PointA = distanceOffsetPoint00PointA / ABequivalenza
        
        let distanceOffsetPoint00PointB = sqrt((offsetPointB[0]*offsetPointB[0])+(offsetPointB[1]*offsetPointB[1]))
        let distanceInMetersPoint0PointB = distanceOffsetPoint00PointB / ABequivalenza
        
        let cosALPHAangoloPoint0PointA = offsetPointA[0] / distanceOffsetPoint00PointA
        print("0001 \(offsetPointA[0]) \(distanceOffsetPoint00PointA) \(cosALPHAangoloPoint0PointA)")
        let cosALPHAangoloPoint0PointB = offsetPointB[0] / distanceOffsetPoint00PointB
        print("0002 \(offsetPointB[0]) \(distanceOffsetPoint00PointB) \(cosALPHAangoloPoint0PointB)")
        let alpha = acos(cosALPHAangoloPoint0PointA)
        let beta  = acos(cosALPHAangoloPoint0PointB)
        
        var degreeAv00: Double = Double(alpha.radiansToDegrees)
        var degreeBv00: Double = Double(beta.radiansToDegrees)
        
        if (degreeAv00 >= 0 && degreeAv00 <= 90) { degreeAv00 = 270 + degreeAv00 }
        if (degreeBv00 >= 0 && degreeBv00 <= 90) { degreeBv00 = 270 + degreeBv00 }
        
        let point0Abview = locationWithBearing(
            bearingRadians: degreeAv00.degreesToRadians,
            distanceMeters: Double(distanceInMetersPoint0PointA),
            origin: CLLocationCoordinate2D( latitude: Double(geoPointA[0]), longitude: Double(geoPointA[1]) )
        )
        let point0aBview = locationWithBearing(
            bearingRadians: degreeBv00.degreesToRadians,
            distanceMeters: Double(distanceInMetersPoint0PointB),
            origin: CLLocationCoordinate2D( latitude: Double(geoPointB[0]), longitude: Double(geoPointB[1]) )
        )
        
        // acc non funziona fose a causa del bearingRadians quindi passiamo a movedBy() più semplice perchè non richiede l'angolo in quanto opera separatamente su asse longitudinale e latitudinale
        // =====================================================================
        // ATTENZIONE >>> LATITUDE = asse Y, LONGITUDE = asse X !!!!!!!!!!!
        // =====================================================================
        
        let dBCoffy = (offsetPointB[1]-offsetPointC[1])
        let dBCoffx = (offsetPointB[0]-offsetPointC[0])
        
        let dACoffy = (offsetPointA[1]-offsetPointC[1])
        let dACoffx = (offsetPointA[0]-offsetPointC[0])
        
        let fABy = dABlat / dABoffy
        let fABx = dABlng / dABoffx
        
        // dABx:dABlng=ABoffx:point00lngAB
        let y1 = offsetPointA[1] - offsetPoint00[1]
        let y2 = y1 / dABoffy
        let y3 = (y2 * dABlat)
        let point00latABa = y3 + geoPointA[1]
        
        let x1 = offsetPointB[1] - offsetPoint00[1]
        let x2 = x1/dABoffy
        let x3 = (x2 * dABlat)
        let point00latABb = x3 + geoPointB[1]
        
        let z1 = offsetPointA[0] - offsetPoint00[0]
        let z2 = (z1 * fABx)
        let point00lngABa = z2 + geoPointA[0]
        
        let w1 = offsetPointB[0] - offsetPoint00[0]
        let w2 = (w1 * fABx)
        let point00lngABb = w2 + geoPointB[0]
        
        
        // =====================================================================
        // proviamo con un approccio più semplice... utilizziamo punti A e D
        // =====================================================================
        
        // punto A offset x=166 y=16  Lat 45.18779  Lng 9.15630
        // punto D offset x=857 y=607 Lat 45.186515 Lng 9.158306
        // distanza AD Latitude Longitude
        
        
        let metersABlat = distance(Double(geoPointA[0]),Double(geoPointA[1]),Double(geoPointB[0]),Double(geoPointA[1]))
        let metersABlng = distance(Double(geoPointB[0]),Double(geoPointA[1]),Double(geoPointB[0]),Double(geoPointB[1]))
        
        let metersBClat = distance(Double(geoPointB[0]),Double(geoPointB[1]),Double(geoPointC[0]),Double(geoPointB[1]))
        let metersBClng = distance(Double(geoPointC[0]),Double(geoPointB[1]),Double(geoPointC[0]),Double(geoPointC[1]))
   
        let metersAClat = distance(Double(geoPointA[0]),Double(geoPointA[1]),Double(geoPointC[0]),Double(geoPointA[1]))
        let metersAClng = distance(Double(geoPointC[0]),Double(geoPointA[1]),Double(geoPointC[0]),Double(geoPointC[1]))
   
        let metersADlat = distance(Double(geoPointA[0]),Double(geoPointA[1]),Double(geoPointD[0]),Double(geoPointA[1]))
        let metersADlng = distance(Double(geoPointD[0]),Double(geoPointA[1]),Double(geoPointD[0]),Double(geoPointD[1]))
   
        // ricorda che geo è [lat,lng] mentre offset è [x (ovvero lng),y (ovvero lat)]
        let lngABFactor = metersABlng / abs(Double(offsetPointA[0]-offsetPointB[0]))
        let latABFactor = metersABlat / abs(Double(offsetPointA[1]-offsetPointB[1]))
        let lngBCFactor = metersBClng / abs(Double(offsetPointB[0]-offsetPointC[0]))
        let latBCFactor = metersBClat / abs(Double(offsetPointB[1]-offsetPointC[1]))
        let lngACFactor = metersAClng / abs(Double(offsetPointA[0]-offsetPointC[0]))
        let latACFactor = metersAClat / abs(Double(offsetPointA[1]-offsetPointC[1]))
        let lngADFactor = metersADlng / abs(Double(offsetPointA[0]-offsetPointD[0])) // (857-166) // metri per unità orizontale
        let latADFactor = metersADlat / abs(Double(offsetPointA[1]-offsetPointD[1]))// (607-16)  // metri per unità verticale
        latAvgFactor    = Float((lngABFactor+lngBCFactor+lngACFactor+lngADFactor)/4)
        lngAvgFactor    = Float((latABFactor+latBCFactor+latACFactor+latADFactor)/4)
        
        let meters0Alng =  lngAvgFactor * offsetPointA[0] // 166
        let meters0Alat =  latAvgFactor * offsetPointA[1] // 16
        
        let meters0Blng =  lngAvgFactor * offsetPointB[0]
        let meters0Blat =  latAvgFactor * offsetPointB[1]
        
        let meters0Clng =  lngAvgFactor * offsetPointC[0]
        let meters0Clat =  latAvgFactor * offsetPointC[1]
        
        let meters0Dlng =  lngAvgFactor * offsetPointD[0] // 857
        let meters0Dlat =  latAvgFactor * offsetPointD[1] // 607
        
        let geo0Alat = locationWithBearing(
            bearingRadians: 0.degreesToRadians,
            distanceMeters: Double(meters0Alat),
            origin: CLLocationCoordinate2D( latitude: Double(geoPointA[0]), longitude: Double(geoPointA[1]) )
        )
        let geo0A = locationWithBearing(
            bearingRadians: 270.degreesToRadians,
            distanceMeters: Double(meters0Alng),
            origin: CLLocationCoordinate2D( latitude: geo0Alat.latitude, longitude: geo0Alat.longitude )
        )
        let geo0Blat = locationWithBearing(
            bearingRadians: 0.degreesToRadians,
            distanceMeters: Double(meters0Blat),
            origin: CLLocationCoordinate2D( latitude: Double(geoPointB[0]), longitude: Double(geoPointB[1]) )
        )
        let geo0B = locationWithBearing(
            bearingRadians: 270.degreesToRadians,
            distanceMeters: Double(meters0Blng),
            origin: CLLocationCoordinate2D( latitude: geo0Blat.latitude, longitude: geo0Blat.longitude )
        )
        let geo0Clat = locationWithBearing(
            bearingRadians: 0.degreesToRadians,
            distanceMeters: Double(meters0Clat),
            origin: CLLocationCoordinate2D( latitude: Double(geoPointC[0]), longitude: Double(geoPointC[1]) )
        )
        let geo0C = locationWithBearing(
            bearingRadians: 270.degreesToRadians,
            distanceMeters: Double(meters0Clng),
            origin: CLLocationCoordinate2D( latitude: geo0Clat.latitude, longitude: geo0Clat.longitude )
        )
        let geo0Dlat = locationWithBearing(
            bearingRadians: 0.degreesToRadians,
            distanceMeters: Double(meters0Dlat),
            origin: CLLocationCoordinate2D( latitude: Double(geoPointD[0]), longitude: Double(geoPointD[1]) )
        )
        let geo0D = locationWithBearing(
            bearingRadians: 270.degreesToRadians,
            distanceMeters: Double(meters0Dlng),
            origin: CLLocationCoordinate2D( latitude: geo0Dlat.latitude, longitude: geo0Dlat.longitude )
        )
        geoPoint00.append(Float((geo0A.latitude+geo0B.latitude+geo0C.latitude+geo0D.latitude)/4))
        geoPoint00.append(Float((geo0A.longitude+geo0B.longitude+geo0C.longitude+geo0D.longitude)/4))
        
        // CALCOLO PUNTO geoZZ
        
        distFisicaMetri00ZZlng =  lngAvgFactor * offsetPointZZ[0] // 166
        distFisicaMetri00ZZlat =  latAvgFactor * offsetPointZZ[1] // 16
        
        let geoZZlat = locationWithBearing(
            bearingRadians: 180.degreesToRadians,
            distanceMeters: Double(distFisicaMetri00ZZlat),
            origin: CLLocationCoordinate2D( latitude: Double(geoPoint00[0]), longitude: Double(geoPoint00[1]) )
        )
        let geoZZ = locationWithBearing(
            bearingRadians: 90.degreesToRadians,
            distanceMeters: Double(distFisicaMetri00ZZlng),
            origin: CLLocationCoordinate2D( latitude: geoZZlat.latitude, longitude: geoZZlat.longitude )
        )
        geoPointZZ.append(Float(geoZZ.latitude))
        geoPointZZ.append(Float(geoZZ.longitude))
        
        distFisicaMetri00ZZ = Float(distance(Double(geoPoint00[0]),Double(geoPoint00[1]),Double(geoPointZZ[0]),Double(geoPointZZ[1])))
        return guidaImageView
    }
    
    func getBasicImageReferences(_ width: Double,_ height: Double) -> [[CGFloat]] {
        if (width == viewWidht && height == viewHeight) {
            print("view geometry aligned \(viewWidht)x\(viewHeight) vs \(width)x\(width)")
        }else{
            print("view geometry not aligned \(viewWidht)x\(viewHeight) vs \(width)x\(width)")
            viewWidht = width
            viewHeight = height
        }
        
        let xZZ = (Double(offsetPointZZ[0]) * viewWidht) / pictureWidth
        let yZZ = (Double(offsetPointZZ[1]) * viewHeight) / pictureHeight
        let ZZ:[CGFloat] = [CGFloat(xZZ),CGFloat(yZZ)]
        // centraggio basata su 4 punti A,B,C,D
        
        let xA = (Double(offsetPointA[0]) * viewWidht) / pictureWidth
        let yA = (Double(offsetPointA[1]) * viewHeight) / pictureHeight
        let A:[CGFloat] = [CGFloat(xA),CGFloat(yA)]
        let xB = (Double(offsetPointB[0]) * viewWidht) / pictureWidth
        let yB = (Double(offsetPointB[1]) * viewHeight) / pictureHeight
        let B:[CGFloat] = [CGFloat(xB),CGFloat(yB)]
        let xC = (Double(offsetPointC[0]) * viewWidht) / pictureWidth
        let yC = (Double(offsetPointC[1]) * viewHeight) / pictureHeight
        let C:[CGFloat] = [CGFloat(xC),CGFloat(yC)]
        let xD = (Double(offsetPointD[0]) * viewWidht) / pictureWidth
        let yD = (Double(offsetPointD[1]) * viewHeight) / pictureHeight
        let D:[CGFloat] = [CGFloat(xD),CGFloat(yD)]
        return [A,B,C,D]
    }
    
    func getPictureOffset( latitude: Float, longitude: Float ) -> [CGFloat] {
        //print("0003 \(geoPoint00)")
        let d00lng:Float = longitude - geoPoint00[1]  // delta longitude vs image 0,0
        let d00lat:Float = geoPoint00[0] - latitude   // delta latitude vs image 0,0
        
        let x3 = d00lng / (geoPointZZ[1] - geoPoint00[1])
        let x  = x3 * Float(pictureWidth)
        
        let y3 = d00lat / (geoPoint00[0] - geoPointZZ[0])
        let y  = y3 * Float(pictureHeight)
            
        // lonA:offAx = lon:off?
        let x1 = ((offsetPointA[0] * longitude)) / geoPointA[0]
        let x2 = (x1 * Float(viewWidht)) / Float(pictureWidth)
        
        // latA:offAy = latX:offY
        let y1 = ((offsetPointA[1] * latitude)) / geoPointA[1]
        let y2 = (y1 * Float(viewHeight)) / Float(pictureHeight)
        
        if (Float(x)>=0.0 && Float(x)<=Float(pictureWidth) && Float(y)>=0.0 && Float(y)<=Float(pictureHeight)) {
            //print("quadrante IN \(x) \(y)")
        }else{
            if (Float(x)>=0.0 && Float(x)<=Float(pictureWidth)) {
                //print("quadrante OUT-y \(x) \(y)")
            }else{
                //print("quadrante OUT-x \(x) \(y)")
            }
        }
        return [CGFloat(x),CGFloat(y)]
    }
    
    func getViewOffset( x: CGFloat, y: CGFloat ) -> [CGFloat] {
        let xout = (x / CGFloat(pictureWidth)) * CGFloat(viewWidht)
        let yout = (y / CGFloat(pictureHeight)) * CGFloat(viewHeight)
        
        return [CGFloat(xout),CGFloat(yout)]
    }
    
    func getGeoCoordinate( x: Double, y: Double ) -> [Float] {
        //facile basta sostituire [0,0] con [x,y] e invocare...setBasicImageReferences...?? bohh ??
        
        // CALCOLO PUNTO geoQQ
        
        let distFisicaMetri00QQlng =  lngAvgFactor * Float(x) // 166
        let distFisicaMetri00QQlat =  latAvgFactor * Float(y) // 16
        
        let geoQQlat = locationWithBearing(
            bearingRadians: 180.degreesToRadians,
            distanceMeters: Double(distFisicaMetri00QQlat),
            origin: CLLocationCoordinate2D( latitude: Double(geoPoint00[0]), longitude: Double(geoPoint00[1]) )
        )
        let geoQQ = locationWithBearing(
            bearingRadians: 90.degreesToRadians,
            distanceMeters: Double(distFisicaMetri00QQlng),
            origin: CLLocationCoordinate2D( latitude: geoQQlat.latitude, longitude: geoQQlat.longitude )
        )
        return [Float(geoQQ.latitude),Float(geoQQ.longitude)]
    }
    
}
extension Data {
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
public func splitAtFirst(str: String, delimiter: String) -> (a: String, b: String)? {
   guard let upperIndex = (str.range(of: delimiter)?.upperBound), let lowerIndex = (str.range(of: delimiter)?.lowerBound) else { return nil }
   let firstPart: String = .init(str.prefix(upTo: lowerIndex))
   let lastPart: String = .init(str.suffix(from: upperIndex))
   return (firstPart, lastPart)
}
extension Date {
    func toMillisDouble() -> Double! {
        let tme = Double(self.timeIntervalSince1970 * 1000) + Double(Double(status.secondsFromGMT * +1)*1000)
        return Double(tme)
    }
}
//https://betterprogramming.pub/organizing-your-swift-global-constants-for-beginners-251579485046
struct Constants {
    struct Colors {
        struct Primary {
            static let Blue = UIColor(displayP3Red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            static let BlueDisabled = UIColor.rgba(red:28, green:155, blue: 248, alpha: 1)
            static let Purple = UIColor.rgba(red:80, green:48, blue: 246, alpha: 1)
            static let PurpleDisabled = UIColor.rgba(red:98, green:68, blue: 255, alpha: 1)
        }
    }
}
enum AssetsColor: String {
    case backgroundGray
    case blue
    case colorAccent
    case colorPrimary
    case darkBlue
    case yellow
}
extension UIColor {
    var inverted: UIColor {
        var a: CGFloat = 0.0, r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0
        return getRed(&r, green: &g, blue: &b, alpha: &a) ? UIColor(red: 1.0-r, green: 1.0-g, blue: 1.0-b, alpha: a) : .black
    }
}
//UIColor.blue.inverted
public extension UIColor {
    
    /// Easily define two colors for both light and dark mode.
    /// - Parameters:
    ///   - color: The color to use in light mode.
    /// - Returns: A dynamic color based on the provided color or it inversion.
    static func invert (color: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return color }
            
        return UIColor { (traitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? color : color.inverted
        }
    }
}
infix operator |: AdditionPrecedence
public extension UIColor {
    
    /// Easily define two colors for both light and dark mode.
    /// - Parameters:
    ///   - lightMode: The color to use in light mode.
    ///   - darkMode: The color to use in dark mode.
    /// - Returns: A dynamic color that uses both given colors respectively for the given user interface style.
    static func | (_ lightMode: UIColor, darkMode: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return lightMode }
            
        return UIColor { (traitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? lightMode : darkMode
        }
    }
}
func saveImage(imageName: String, image: UIImage) {
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let fileName = imageName
    let fileURL = documentsDirectory.appendingPathComponent(fileName)
    var data_:Data
    if (imageName.lowercased().contains(".png")) {
        guard let data = image.pngData() else { return }
        data_ = data
    }else{
        if (imageName.lowercased().contains(".jpg")) {
            guard let data = image.jpegData(compressionQuality: 1) else { return }
            data_ = data
        }else{
            guard let data = image.jpegData(compressionQuality: 1) else { return }
            data_ = data
        }
    }
    
    
    //Checks if file exists, removes it if so.
    if FileManager.default.fileExists(atPath: fileURL.path) {
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
            print("Removed old image")
        } catch let removeError {
            print("couldn't remove file at path", removeError)
        }
    }
    do {
        try data_.write(to: fileURL)
    } catch let error {
        print("error saving file with error", error)
    }
}
func loadImageFromDiskWith(fileName: String) -> UIImage? {
  let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
    if let dirPath = paths.first {
        let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
        var data_ = NSData(contentsOfFile: imageUrl.path)
        
        let image = UIImage(data: data_! as Data)
        return image
        
    }
    return nil
}
extension UIColor {
    static func appColor(_ name: AssetsColor) -> UIColor? {
             return UIColor(named: name.rawValue)
        }
    static func rgba(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
struct DefaultsKeysDataStore {
    static let keyAboutThisAppReaded = "AboutThisAppReadedKey"
    static let keyConfigurationURL = "ConfigurationURLKey"
    static let keyConfigurationURLverified = "ConfigurationURLverifiedKey"
    static let keyInstructionsReaded = "InstructionsReadedKey"
    static let keyPrivacyAccepted = "PrivacyAcceptedKey"
    static let keyDisclaimerAccepted = "DisclamerAcceptedKey"
    static let keyOperativityMode = "OperativityModeKey"
    static let keyUserCharacter = "UserCharacterKey"
    
    static let keyBeaconOperationalMode = "BeaconOperationalModeKey"
    
    static let keyShakerOperationalMode = "ShakerOperationalModeKey"
    static let keyRouteSegmentsTuning = "RouteSegmentsTuningKey"
    static let keyBeaconsTuning = "BeaconsTuningKey"
    static let keyText2SpeechMode = "Text2SpeechModeKey"
    
    static let keyPositioningTechnique = "PositioningTechniqueKey"
    static let keyVoiceMode = "VoiceModeKey"
    static let keyUserPosture = "UserPostureKey"
    static let keyFeedbackMode = "FeedbackModeKey"
    static let keyManagedArea = "ManagedAreaKey"
    
    static let keyGraphTopologyData = "GraphTopologyDataKey"
    
    
}
// beacon configuration
struct BeaconConfig {
    var mjr:Double              // major
    var mnr:Double              // minor
    var lat:Float               // latitude
    var lng:Float               // longitude
    var floor:Int               // floor number -x:0:x+
    var tme:Double              // time interval
    var tx:Float                // signal intensity
    var db1m:Float              // signal strenght at 1m
    var sn:String               // serial number
    var id:String               // identifier - descriptor
    var mac:String              // mac address
    var nm:String               // name
    var qrc:String              // qrcode
    var inUseFlag:Bool          // used item
    var bRTV:[Float]            // delta threshold intensity of beacon signals
}
struct BeaconsTopology {
    var id:String
    var uuid:String
    var beacons:[BeaconConfig]
}
struct FtrsStatus {
    var ent:[String]
    var ext:[String]
}
// fence configuration
struct FenceConfig {
    var lat:Float                   // latitude
    var lng:Float                   // longitude
    var radius:Float                // radius in meters
    var floor:Int                   // floor number -x:0:x+
    var xid:String                  // xid hash generated key
    var id:String                   // identifier - descriptor
    var alias:String                // id alias
    var qrc:String                  // qrcode
    var inUseFlag:Bool              // used item
    var ftrsSts:FtrsStatus          // setting on/off features (entering/exiting)
}
struct FencesTopology {
    var id:String
    var fences:[FenceConfig]
}
// indicazioni percorsi
struct TestoIndicazione {
    let lang:String
    let text:String
}
struct IndicazionePercorsoSingoloTratto {
    let from:String
    let to:String
    let comment:String
    let msg:[TestoIndicazione]
    let inUseFlag:Bool
}
struct IndicazioniPercorsi {
    var id:String
    var indicazioni:[[IndicazionePercorsoSingoloTratto]]
}
struct _Vert {
    var value:String                // Vertex level
    var number:Int                  // Vertex level
    var coordinates:[Float]         // Vertex level
    var inUseFlag:Bool              // Vertex level
    var floor:Int                   // Vertex level
    var links:Int                   // Vertex level
    var inside:Bool                 // Edge level
    var nosteps:Bool                // Edge level
    var weight:Double               // Edge level
    var nodinoBline:Float             // Vertex level e per mero errore suffissate con nodino...
    var nodinoCoordinates:[Float]     // Vertex level e per mero errore suffissate con nodino...
    var adiacenti:[String]      // Vertex level e per mero errore suffissate con nodino...
}
struct _Edge:Codable {
    var da:Int                      // Edge level
    var a:Int                       // Edge level
    var weight:Double               // Edge level
    var nosteps:Bool                // Edge level
    var inside:Bool                 // Edge level
}
// indicazioni orientamento
struct _indicazione {
    var id:String
    var msg:String
    var inUseFlag:Bool
}
struct IndicazioniOrientamento {
    var id:String
    var indicazioni:[_indicazione]
}
let rowsCol1Order =             [   "inst", "",     "prx",  "voce", "from", "bda" ]
let rowsCol1Width:[Double] =    [   0,      0,      120,    120,    40,     30 ]
let rowsCol2Order =             [   nil,    "wrer", "",     "",     "to",   "ba" ]
let rowsCol2Width:[Double] =    [   0 ,     170,    120,    120,    40,     30 ]
//---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---//
// questa sezione serve per forzare il software a limitare l'estensione prevista dalla parametrizzazione
// è quindi utile per limitare l'utilizzo di opzioni o di configurazioni
let availableStartingPoints:[String] = [/*"any start point","aaa","bbb"...*/]
let availableEndingPoints:[String] = [/*"any destination point","zzz","www",...*/]
let availableOperativityMode = ["anonimate"]
let availableUserCharacters = ["any"]
let availableModalita = ["on-premise","pre-simulation"]
let availableCriteri = ["shortest"]
let availableBeacon = 50                    // pay attention to resource consumption !!!
let availableFence = 50                     // pay attention to resource consumption !!!
let availableRoute = availableFence / 2     // pay attention to resource consumption !!!
//---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---//
struct PercorsoInPlace {
    var percorsoSelezionato:[String]
    var percorsoTecnico:[String]
    var percorsoTecnicoAttributi:[[Float]]
    var percorsoTecnicoCoordinate:[[Float]]
}
struct _C {
    var comando: String
    var utente: String
    var percorso: String
    var ver: String
    var ms: Int64
    var LATITUDE: Float
    var LONGITUDE: Float
    var FLOOR: Int
    var _PATH:[[String]]
    var esitoCreazionePercorso:Int
    var motivoCreazionePercorso:String
    var esitoAttivazione:Int
    var motivoAttivazione:String
    var pathInPlace:String
    var esitoSegnale:Int
    var testoSegnale:[[Any]]
    var motivoSegnale:String
    var timeToSpeechSegnale:[Double]
    var waitBeforeSpeechSegnale:[Double]
}
struct NavigatorCockpit {
    var status:Bool
    var suspended:Bool
    var houseKeeping:Bool
    var beaconInProximity:[[Float]]
    var beaconInRange:[[Float]]
    var beaconAtTheHorizon:[[Float]]
    var beaconInTheMist:Double
    var fenceInPlace:[[Float]]
    var percorsoInPlace:PercorsoInPlace
    var lastSignaledBeacon:[Any]
    var suspSignals:[String]
    var geoSignal:[Any]
    var forcedGEOsignal:[Float]
    var c:_C
}
struct SceneDetails:Codable {
    let url:String
    let llc:Double      // left low
    let lhc:Double      // left high
    let rhc:Double      // right low
    let rlc:Double      // right high
}
struct SceneDescriptor:Codable {
    let title:String
    let icon1url:String
    let icon2url:String
    let scene1:SceneDetails
    let scene2:SceneDetails
}
struct TextStatements:Codable {
    let language:String
    let aboutThisApp:String
    let instructions:String
    let privacy:String
    let disclaimer:String
}
struct VerticeBase:Codable {
    var id:String
    var alias:String
    var lat:Double
    var lng:Double
}
struct SegmentoBase:Codable {
    var da:String
    var a:String
}
struct SceneModel {
    var icon1:UIImage? = nil
    var icon2:UIImage? = nil
    var scene1:UIImage? = nil
    var scene2:UIImage? = nil
}
struct GuidaDataModel {
    static let versionSuppModes =   ["b087-20220516"]             //ptf-210109
    
    static var operatingFeatures =  [
                                     "Beacon"
                                     
                                     ,"Shaker","T2S"
                                     
                                     ]
    static let aboutThisAppModes =  ["no","yes"]
    static let instructionsModes =  ["no","yes"]
    static let privacyModes =       ["no","yes"]
    static let disclaimerModes =    ["no","yes"]
    static var operativityModes =   ["anonimate"
                                     ]
    static var userCharacters =     ["any"
                                    ]
    static var possibiliModalita =  ["on-premise"
                                     
                                     ,"pre-simulation"
                                     
                                     
                                     ]
    static var voiceModes =         ["standard reader"
                                     ]
    static var positioningTechniques = ["prx"
                                        ]
    static var phoneModes =         ["in hand","dressed"
                                     ]
    static var feedbackModes =      [
                                    "shake"]
    
    
    
    
    
    
    
    
    static let managedAreas =       ["UNIPVSP"
                                     ]
    static var zRTV:[Float]         = [-20,-70,-99] // Beacon threshold baseline levels
    //static let zRTV:[Float]         = [-57,-75,-87] // Beacon threshold baseline levels
    
    
    
    static let auxCommands =        ["none"
                                     ]
    
    
    static var scene =              SceneModel()
    static var formality =          [TextStatements(language: "??", aboutThisApp: "??", instructions: "??", privacy: "??", disclaimer: "??")]
    static var sceneDescriptor  =   SceneDescriptor( title: "??", icon1url: "https://??", icon2url: "https://??", scene1: SceneDetails.init(url: "https://??", llc: 0.0, lhc: 0.0, rhc: 0.0, rlc: 0.0), scene2: SceneDetails(url: "https://??", llc: 0.0, lhc: 0.0, rhc: 0.0, rlc: 0.0 ))
    static let talkedLanguages =    ["en","en-EN","en-US","it","it-IT","it-US"]
    
    static let beaconModes =        ["no","yes"]
    
    static let shakerModes =        ["no","yes"]
    static let t2sModes =           ["no","yes"]
    
    
    static let vertici:[VerticeBase]    =  []
    static let segmenti:[SegmentoBase]  =  []
    static let percorsi:[[SegmentoBase]]  =  []
    
    static let fencingConfiguration = [fencingConfigurationPRIMEXX
                                       ]
    
    static let beaconConfiguration = [beaconConfigurationPRIMEXX
                                      
                                      ]  //to be removed
    
    static let indicazioniOrientamento = [indicazioniPRIMEXX
                                         ]
    
    static let indicazioniPercorsi = [percorsiPRIMEXX
                                      ]
    
    static let beaconConfigurationPRIMEXX =   BeaconsTopology.init(
        id: "UNIPVSP",
        uuid: "00000000-0000-0000-0000-000003002001",
        beacons: [
            
         ]
    )
    
    
    
    
    
                                        //to be removed
    
    static let fencingConfigurationPRIMEXX =   FencesTopology.init(
        id: "UNIPVSP",
        fences: [
            
        ]
    )
    
    
    
    
    
    
    
    static let indicazioniPRIMEXX = IndicazioniOrientamento.init(
        id: "UNIPVSP",
        indicazioni: [
            
        ]
    )
    
    
    
    
    
    
    
    
    static let percorsiPRIMEXX = IndicazioniPercorsi.init(
        id: "UNIPVSP",
        indicazioni: [
            [
            
                ]
        ]
    )
    
    
    
    
}
class ConfigInPlace : Codable {
    let versions =              GuidaDataModel.versionSuppModes
    
    var operatingFeatures =     GuidaDataModel.operatingFeatures
    var configurationURL =      "";
    var configurationURLverified = true;
    var aboutThisApp =          false;
    var instructions =          false;
    var privacy =               false;
    var disclaimer =            false;
    var operativityMode =       [-1,0,-2];
    var userCharacterMode =     [-1,0,-2];
    var positioningTechnique =  [-1,0,-2];
    var phoneMode =             [-1,0,-2];
    var userPosture =           [-1,0,-2];
    var voiceMode =             [-1,0,-2];
    var feedbackMode =          [-1,0,-2];
    var selectedArea =          [-1,0,-2];
    
    var beacon =                false;
    
    var shaker =                false;
    var t2s =                   false;
    
    var background =            true;
    
    
    var timeBombed =            false;
    
    
    
}
var configInPlace = ConfigInPlace()
class Statistics : Codable {
    
    var versions =              GuidaDataModel.versionSuppModes
    
    var beacon =                0;
    var missedBeacon =          0;
    
    var shaker =                0;
    var missedShaker =          0;
    var t2s =                   0;
    var missedT2S =             0;
    
    
    
    
}
var statistics = Statistics()
struct _Counters {
    var generic:Double
    var beacons:Double
    var shakes:Double
    
    var others:Double
    var dusts:Double
}
struct StatusController : Codable {
    
    static let versione                         = GuidaDataModel.versionSuppModes[0] // current version
    static let origine                          = ""
    static let destinazione                     = ""
    static var percorsoSelezionato:[String]     = ["?"]
    static var percorsoTecnico:[String]         = ["?"]
    static var percorsoTecnicoCoordinate:[[Float]] = []
    static var percorsoTecnicoAttributi:[[Float]] = []
    static var tappaGenericaDelPercorsoSelezionato: String = ""
    static var lunghezzaPercorsoSelezionato:Double = 0
    static var numPercorsiPossibili             = 0
    
    static var prevOrigine                      = ""
    static var prevDestinazione                 = ""
    
    static var modalita                         = ""
    static var criterio                         = ""
    
    static var voiceReaderVolume:Float          = 1.0
    static var voiceReaderSpeed:Float           = 0.5
    static var voiceReaderPaceing:Float         = 0.5
    static var voiceRepetitions:Float           = 0.0   // from 0 to 1 (infinite)
    static var voiceReaderCharacter:String      = ""
    
    static var selectedArea                     = ""
    
    static var selectedAuxCommand               = ""
    
    static var forceQuit:Bool                   = false
    
    static var forceReset:Bool                  = false
    
    static var forceExit:Int                    = 0
    
    static var inFlight:Bool                    = false
    
    static var OTResetRequest:Bool              = false
    
    var vertici                                 = GuidaDataModel.vertici
    var segmenti                                = GuidaDataModel.segmenti
    var percorsi                                = GuidaDataModel.percorsi
    
    // fix 20211020 - steps to be strictly performed just one time or under a predeterminated sequence 0 to .... n
    static var fireTimingClock                  = 0
    static var fireTimingSniffInsideRetrievedData = 0
    static var fireTimingMonitorForIssues       = 0
    static var fireTimingSignalProcessor        = 0
    static var fireTimingPreSimulator           = 0
    static var fireTimingNavigatorCockpit       = 0
    
    
    static var orentationMapInitialized:Bool    = false
    static var virtualCoordinateActivated:Bool  = false
    
    
    
    
    
    
    
    
    
    
    static var retrievedData: [String]          = []
    
    static var signalsCounters:_Counters        = _Counters(generic: 0, beacons: 0, shakes: 0, others: 0, dusts: 0)
    static var signalProcessor                  = false
    static var signalProcessorRendering         = false
    
    static var navigatorCockpit:NavigatorCockpit = NavigatorCockpit(status: false, suspended: false, houseKeeping: false, beaconInProximity: [], beaconInRange: [], beaconAtTheHorizon: [], beaconInTheMist: 0, fenceInPlace: [], percorsoInPlace: PercorsoInPlace(percorsoSelezionato: [], percorsoTecnico: [], percorsoTecnicoAttributi: [], percorsoTecnicoCoordinate: []), lastSignaledBeacon: [], suspSignals: [], geoSignal: [], forcedGEOsignal: [], c: _C(comando: "", utente: "", percorso: "", ver: "100", ms: 0, LATITUDE: 0.0, LONGITUDE: 0.0, FLOOR: 0, _PATH: [], esitoCreazionePercorso: 0, motivoCreazionePercorso: "", esitoAttivazione: 0, motivoAttivazione: "", pathInPlace: "", esitoSegnale: 0, testoSegnale: [],  motivoSegnale: "", timeToSpeechSegnale: [], waitBeforeSpeechSegnale: []))
    
    static var signalsBEACONdata:[[Any]]        = []
    static var lastSignalProcessed:_Counters    = _Counters(generic: 0, beacons: 0, shakes: 0, others: 0, dusts: 0)
    static var linguaCorrente                   = ""
    
    
    
    static var rotatedFirstView                 = false
    
    static var _touches: [UITouch]              = []
    static var _touchesLocations: [CGPoint]     = []
    
    static var _currentWidth:CGFloat            = 0.0
    static var _currentHeight:CGFloat           = 0.0
    
    static var _previousImageAngle:Double       = 0.0
    static var _currentImageAngle:Double        = 0.0
     
    
    
    
    
    static var positioningTechnique             = "?"
    static var feedbackMode                     = "?"
    
    static var bitg:[String]                    = []
    static var bitg_shadow:[String]             = []
    static var bitg_:Double                     = 0
    static var bnitg:[String]                   = []
    static var bnitg_:Double                    = 0
    
    static var butf:[String]                    = []
    // butf si differenzia da beaconsUnderTheFocus perchè sottente il beacon in target
    // nella logica Da->A indica il beacon A
    static var bnutf:[String]                   = []
    
    static var jsRTEhandler:Bool                = false
    static var routePois:[String]               = []    //route pois as returned by efesto
    
    static var fonr:[String]                    = []    //fences on route
    static var bonr:[String]                    = []    //beacons on route
    static var bonr_shadow:[String]             = []
    
    static var routeSegmentF2FUnderTheFocus:[String] = []
    
    static var beaconsUnderTheFocus:[String]    = []
    // beaconsUnderTheFocus si differenzia da butf perchè sottente i beacon del segment
    // nella logica Da->A indica il beacon Da ed il beacon A)
    
    
    static var autoLocation                     = false
    
    
    
    static var efestoForcedDelay:Int64          = 0
    
    static var shakedDevice:Double              = 0
    
    static var md5js:String                     = ""
    
    
    static var days2EOS:String                  = ""
    
    static var secondsFromGMT:Int               = 0
    
    static var __tabDestinations                = UIViewController()
    static var __tabMap                         = UIViewController()
    static var __tabSettings                    = UIViewController()
    static var __tabTuning                      = UIViewController()
    static var __tabSSettings                   = UIViewController()
    static var __tabRoutes                      = UIViewController()
    
}
struct RouteSegmentTuning: Codable {
    var da:String
    var a:String
    var outDa:[Double]
    var inA:[Double]
}
struct BeaconTuning: Codable {
    var id:String
    var exiting:[Double]
    var entering:[Double]
}
struct RouteController {
    static var possibiliOriginiBase: [String]               = ["current position"]
    static var possibiliOrigini: [String]                   = [""]
    static var possibiliDestinazioniBase: [String]          = ["please set starting point"]
    static var possibiliDestinazioni: [String]              = [""]
    static var possibiliCriteri: [String]                   = ["shortest","fastest","no steps","no lift","outdoor","inside"]
    static var possibiliModalita: [String]                  = GuidaDataModel.possibiliModalita
    static var puntiOrigineDichiarati:[String]              = []
    static var originiNonSelezionabili:[String]             = []
    static var destinazioniNonSelezionabili                 = ["Beacon"]
    static var originiAttivate:[String]                     = []
    static var destinazioniAttivate:[String]                = []
    static var ulterioriTermini                             = ["starting point auto-detected"]
    static var managedAreas                                 = GuidaDataModel.managedAreas
    static var zRTV                                         = GuidaDataModel.zRTV
    static var beaconConfiguration                          = GuidaDataModel.beaconConfiguration
    static var fencingConfiguration                         = GuidaDataModel.fencingConfiguration
    static var indicazioniOrientamento                      = GuidaDataModel.indicazioniOrientamento
    static var indicazioniPercorsi                          = GuidaDataModel.indicazioniPercorsi
    static var routeSegmentsTuning:[RouteSegmentTuning]     = []
    static var forcedRouteSegmentsTuning:[RouteSegmentTuning] = []
    static var forcedBeaconsTuning:[BeaconTuning]           = []
    static var missFencesSegmentTuning:[String]             = []
    static var missBeaconsSegmentTuning:[String]            = []
    static var beaconsTuning:[BeaconTuning]                 = []
}
class Status {
    
    var versione                                = StatusController.versione
    var versioneRunPrecedente                   = StatusController.versione  //ptf-210126
    var origine                                 = StatusController.origine
    var destinazione                            = StatusController.destinazione
    var percorsoSelezionato                     = StatusController.percorsoSelezionato
    var percorsoTecnico                         = StatusController.percorsoTecnico
    var percorsoTecnicoCoordinate               = StatusController.percorsoTecnicoCoordinate
    var percorsoTecnicoAttributi                = StatusController.percorsoTecnicoAttributi
    var tappaGenericaDelPercorsoSelezionato     = StatusController.tappaGenericaDelPercorsoSelezionato
    var lunghezzaPercorsoSelezionato            = StatusController.lunghezzaPercorsoSelezionato
    var numPercorsiPossibili                    = StatusController.numPercorsiPossibili
    var modalita                                = StatusController.modalita
    var criterio                                = StatusController.criterio
    
    var prevOrigine                             = StatusController.prevOrigine
    var prevDestinazione                        = StatusController.prevDestinazione
    
    var voiceReaderVolume                       = StatusController.voiceReaderVolume
    var voiceReaderSpeed                        = StatusController.voiceReaderSpeed
    var voiceReaderPaceing                      = StatusController.voiceReaderPaceing
    var voiceRepetitions                        = StatusController.voiceRepetitions
    var voiceReaderCharacter                    = StatusController.voiceReaderCharacter
    
    var forceQuit                               = StatusController.forceQuit
    
    var forceReset                              = StatusController.forceReset
    
    var forceExit                               = StatusController.forceExit
    
    var inFlight                                = StatusController.inFlight
    
    var OTResetRequest                          = StatusController.OTResetRequest
    
    var vertici                                 = GuidaDataModel.vertici
    var segmenti                                = GuidaDataModel.segmenti
    var percorsi                                = GuidaDataModel.percorsi
    
    
    
    
    
    
    
    
    
    var retrievedData                           = StatusController.retrievedData
    
    var signalsCounters                         = StatusController.signalsCounters
    var signalProcessor                         = StatusController.signalProcessor
    var signalProcessorRendering                = StatusController.signalProcessorRendering
    var navigatorCockpit                        = StatusController.navigatorCockpit
    
    var signalsBEACONdata:[[Any]]               = StatusController.signalsBEACONdata
    var lastSignalProcessed                     = StatusController.lastSignalProcessed
    
    // fix 20211020 - steps to be strictly performed just one time or under a predeterminated sequence 0 to .... n
    var fireTimingClock                         = StatusController.fireTimingClock
    var fireTimingSniffInsideRetrievedData      = StatusController.fireTimingSniffInsideRetrievedData
    var fireTimingMonitorForIssues              = StatusController.fireTimingMonitorForIssues
    var fireTimingSignalProcessor               = StatusController.fireTimingSignalProcessor
    var fireTimingPreSimulator                  = StatusController.fireTimingPreSimulator
    var fireTimingNavigatorCockpit              = StatusController.fireTimingNavigatorCockpit
    
    
    var orentationMapInitialized                = StatusController.orentationMapInitialized
    var virtualCoordinateActivated              = StatusController.virtualCoordinateActivated
    
    
    
    var linguaCorrente                          = StatusController.linguaCorrente
    
    
    
    var rotatedFirstView                        = StatusController.rotatedFirstView
    
    var _touches                                = StatusController._touches
    var _touchesLocations                       = StatusController._touchesLocations
     
    var _currentWidth                           = StatusController._currentWidth
    var _currentHeight                          = StatusController._currentHeight
    
    var _previousImageAngle                     = StatusController._previousImageAngle
    var _currentImageAngle                      = StatusController._currentImageAngle
    
    var possibiliOriginiBase                    = RouteController.possibiliOriginiBase
    var possibiliOrigini                        = RouteController.possibiliOrigini
    
    var possibiliDestinazioniBase               = RouteController.possibiliDestinazioniBase
    var possibiliDestinazioni                   = RouteController.possibiliDestinazioni
    
    var possibiliCriteri                        = RouteController.possibiliCriteri
    var possibiliModalita                       = RouteController.possibiliModalita
    
    var puntiOrigineDichiarati                  = RouteController.puntiOrigineDichiarati
    var originiNonSelezionabili                 = RouteController.originiNonSelezionabili
    var destinazioniNonSelezionabili            = RouteController.destinazioniNonSelezionabili
    
    var originiAttivate                         = RouteController.originiAttivate
    var destinazioniAttivate                    = RouteController.destinazioniAttivate
    
    var ulterioriTermini                        = RouteController.ulterioriTermini
    
    var selectedAuxCommand                      = StatusController.selectedAuxCommand
    
    var managedAreas                            = RouteController.managedAreas
    var zRTV                                    = RouteController.zRTV
    var selectedArea                            = StatusController.selectedArea
    var beaconConfiguration                     = RouteController.beaconConfiguration
    var forcedRouteSegmentsTuning               = RouteController.forcedRouteSegmentsTuning
    var forcedBeaconsTuning                     = RouteController.forcedBeaconsTuning
    var fencingConfiguration                    = RouteController.fencingConfiguration
    var indicazioniOrientamento                 = RouteController.indicazioniOrientamento
    var indicazioniPercorsi                     = RouteController.indicazioniPercorsi
    
    var routeSegmentsTuning                     = RouteController.routeSegmentsTuning
    var missBeaconsSegmentTuning                = RouteController.missBeaconsSegmentTuning
    var missFencesSegmentTuning                 = RouteController.missFencesSegmentTuning
    var beaconsTuning                           = RouteController.beaconsTuning
    
    
    
    
    
    var positioningTechnique                    = StatusController.positioningTechnique
    var feedbackMode                            = StatusController.feedbackMode
    
    var bitg                                    = StatusController.bitg     // beacon operating under the selected area
    var bitg_shadow                             = StatusController.bitg_shadow
    var bitg_                                   = StatusController.bitg_
    var bnitg                                   = StatusController.bnitg    // beacon not operating along the selected area
    var bnitg_                                  = StatusController.bnitg_
    
    var butf                                    = StatusController.butf     // beacon under the path/segment in place
    var bnutf                                   = StatusController.bnutf    // beacon logically suspended
    
    var jsRTEhandler                            = StatusController.jsRTEhandler
    var routePois                               = StatusController.routePois // point of interest from route (js)
    var fonr                                    = StatusController.fonr     // fences involved in the route
    var bonr                                    = StatusController.bonr     // beacons involved in the route
    var bonr_shadow                             = StatusController.bonr_shadow
    
    var routeSegmentF2FUnderTheFocus            = StatusController.routeSegmentF2FUnderTheFocus
    
    var beaconsUnderTheFocus                    = StatusController.beaconsUnderTheFocus
    
    
    
    var autoLocation                            = StatusController.autoLocation
    
    
    
    var shakedDevice                            = StatusController.shakedDevice
    
    var efestoForcedDelay                       = StatusController.efestoForcedDelay
    
    var md5js                                   = StatusController.md5js
    
    
    var days2EOS                                = StatusController.days2EOS
    
    var secondsFromGMT                          = StatusController.secondsFromGMT
    
    var __tabDestinations                       = StatusController.__tabDestinations
    var __tabMap                                = StatusController.__tabMap
    var __tabSettings                           = StatusController.__tabSettings
    var __tabTuning                             = StatusController.__tabTuning
    var __tabSSettings                          = StatusController.__tabSSettings
    var __tabRoutes                             = StatusController.__tabRoutes
    
    
    
}
var status = Status()
struct EntitiesData: Codable {                                                                  //ptf-210109
    
    static var versionSuppModes = GuidaDataModel.versionSuppModes
    
    static var beaconDATA: [(xid: String, signals: [(rssi: Double, distance: Double, timestamp: Int64)])] = []
    static var gpsPosition: [(latitude: Double, longitude: Double, altitude: Double, timestamp: Int64)] = []
    static var beaconsWeighed: [(xid: String, signals: [(rssi: Double, distance: Double, timestamp: Int64)])] = []
    static var trilateratedPosition: [(latitude: Double, longitude: Double, timestamp: Int64)] = []
}
// create a sound ID, in this case its the tweet sound.
let sound1000: SystemSoundID = 1000
let sound1001: SystemSoundID = 1001
let sound1002: SystemSoundID = 1002
let sound1003: SystemSoundID = 1003
let sound1004: SystemSoundID = 1004
let sound1005: SystemSoundID = 1005
let sound1006: SystemSoundID = 1006
let sound1007: SystemSoundID = 1007
let sound1008: SystemSoundID = 1008
let sound1009: SystemSoundID = 1009
let sound1010: SystemSoundID = 1010
let sound1011: SystemSoundID = 1011
let sound1012: SystemSoundID = 1012
let sound1013: SystemSoundID = 1013
let sound1014: SystemSoundID = 1014
let sound1015: SystemSoundID = 1015
let sound1016: SystemSoundID = 1016
let sound1017: SystemSoundID = 1017
let sound1018: SystemSoundID = 1018
let sound1019: SystemSoundID = 1019
let sound1020: SystemSoundID = 1020
let beep1005:  SystemSoundID = 1005
let beep1007:  SystemSoundID = 1007
let beep1103:  SystemSoundID = 1103
let beep1209:  SystemSoundID = 1209
let beep1306:  SystemSoundID = 1306
let codifiedSounds =     [sound1000,sound1001,sound1002,sound1003,sound1004,sound1005,sound1006,sound1007,sound1008,sound1009,sound1010,sound1011,sound1012,sound1013,sound1014,sound1015,sound1016,sound1017,sound1018,sound1019,sound1020]
let achievedNextFenceSound = 16
let routeSignalsDroppedDueToManualTuningOn = 12
let codifiedBeeps = [beep1005,beep1007,beep1103,beep1209,sound1016,beep1306]
let shakedDeviceBeep = 3
let autoLocationResolved = 4
let delayBypased = 1
var sortedList:[String] = []
let threadSafeEnforcementBeacon = NSLock()
let threadSafeEnforcementGPS = NSLock()
let threadSafeSignalProcessor = NSLock()
let threadSafeNavigatorCockpit = NSLock()
let threadSafeNotificationRoute = NSLock()
let threadSafeManualTuning = NSLock()
var _tknForOri: NSObjectProtocol?
var _loadedLogData:[String] = []
var _ftPRLD = Timer()
var jsContext: JSContext!
class CodableStatus : Codable {
    
    var versioneRunPrecedente                   = StatusController.versione
    
    var origine                                 = StatusController.origine
    var destinazione                            = StatusController.destinazione
    var percorsoSelezionato                     = StatusController.percorsoSelezionato
    var percorsoTecnico                         = StatusController.percorsoTecnico
    var lunghezzaPercorsoSelezionato            = StatusController.lunghezzaPercorsoSelezionato
    var modalita                                = StatusController.modalita
    var criterio                                = StatusController.criterio
    
    var prevOrigine                             = StatusController.prevOrigine
    var prevDestinazione                        = StatusController.prevDestinazione
    
    var voiceReaderVolume                       = StatusController.voiceReaderVolume
    var voiceReaderSpeed                        = StatusController.voiceReaderSpeed
    var voiceReaderPaceing                      = StatusController.voiceReaderPaceing
    var voiceRepetitions                        = StatusController.voiceRepetitions
    var voiceReaderCharacter                    = StatusController.voiceReaderCharacter
    
    var selectedArea                            = StatusController.selectedArea
    
    var inFlight                                = StatusController.inFlight
    
    
    
    var linguaCorrente                          = StatusController.linguaCorrente
     
    var possibiliOriginiBase                    = RouteController.possibiliOriginiBase
    var possibiliOrigini                        = RouteController.possibiliOrigini
    var possibiliDestinazioniBase               = RouteController.possibiliDestinazioniBase
    var possibiliDestinazioni                   = RouteController.possibiliDestinazioni
    var possibiliCriteri                        = RouteController.possibiliCriteri
    var possibiliModalita                       = RouteController.possibiliModalita
    var puntiOrigineDichiarati                  = RouteController.puntiOrigineDichiarati
    var originiNonSelezionabili                 = RouteController.originiNonSelezionabili
    var destinazioniNonSelezionabili            = RouteController.destinazioniNonSelezionabili
    var originiAttivate                         = RouteController.originiAttivate
    var destinazioniAttivate                    = RouteController.destinazioniAttivate
    var zRTV                                    = RouteController.zRTV
    var missBeaconsSegmentTuning                = RouteController.missBeaconsSegmentTuning
    var missFencesSegmentTuning                 = RouteController.missFencesSegmentTuning
    
    var positioningTechnique                    = StatusController.positioningTechnique
    var feedbackMode                            = StatusController.feedbackMode
    
    
}
var codableStatus = CodableStatus()
/*?@-@FuncBegin@*/
public struct Matrix: Equatable {
    // Properties
    public let rows: Int, columns: Int
    public var grid: [Double]
    
    public func indexIsValid(forRow row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    public subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValid(forRow: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(forRow: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}
/*?@-@FuncEnd@*/
class Entities {
    
    let BeaconDepth = 21
    let GPSDepth = 21
    let TimeFrame = 15000
    let MinNumberOfSignals = 5
    
    let versions =              EntitiesData.versionSuppModes
    
    var beaconDATA =            EntitiesData.beaconDATA
    
    var gpsPosition =           EntitiesData.gpsPosition
    
    var beaconsWeighed =        EntitiesData.beaconsWeighed
    
    var trilateratedPosition =  EntitiesData.trilateratedPosition
    
    
    
}
var entities = Entities()
extension Date {
    //var _secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
    func toMillis() -> Int64! {
        let tme = Int64(self.timeIntervalSince1970 * 1000) + Int64(Double(status.secondsFromGMT * +1)*1000)
        return Int64(tme)
    }
}
func _s2f(_ s:String) -> Float {
    if (s=="far") {
        return 3
    }else{
        if (s=="near") {
            return 2
        }else{
            if (s=="right here") {
                return 1
            }else{
                return 0
            }
        }
    }
}
func _i2t(_ i:Float) -> String {
    if (i==3) {
        return "far"
    }else{
        if (i==2){
            return "near"
        }else{
            if (i==1) {
                return "right here"
            }else{
                return "nowhere"
            }
        }
    }
}
public extension UIDevice {
    var modelName: String {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            let DEVICE_IS_SIMULATOR = true
        #else
            let DEVICE_IS_SIMULATOR = false
        #endif
        var machineString : String = ""
        if DEVICE_IS_SIMULATOR == true
        {
            if let dir = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                machineString = dir
            }
        }
        else {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            machineString = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        }
        // forced or not forced to be an iPhone 8.... this is the problem !!!
        return "iPhone 8 Plus" // forced giak
        switch machineString {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,2", "iPhone9,3":     return "iPhone 7"
            case "iPhone10,1", "iPhone10,2", "iPhone10,3", "iPhone10,4":                                                                                 return "iPhone 8"
            case "iPhone10,5":                              return "iPhone 8 Plus"
            case "iPhone11,1", "iPhone11,2", "iPhone11,3", "iPhone11,4", "iPhone11,5":                                                                   return "iPhone 10"
            case "iPhone12,1", "iPhone12,2":                return "iPhone 11"
            case "iPhone12,3", "iPhone12,4":                return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE"
            case "iPhone13,1":                              return "iPhone 12 mini"
            case "iPhone13,2":                              return "iPhone 12"
            case "iPhone13,3":                              return "iPhone 12 Pro"
            case "iPhone13,4", "iPhone13,5":                return "iPhone 12 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro"
            case "AppleTV5,3":                              return "Apple TV"
            default:                                        return machineString
        }
    }
}
 
let _textLightModeColor = UIColor.black
let _textDarkModeColor = UIColor.white
let _textDynamicColor = _textLightModeColor | _textDarkModeColor
// non funziona private let π = Double.pi // pi greco
/* --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- */
// https://developer.apple.com/swift/blog/?id=37
class MultilingualLabelMngr {
    var n = 0
    var m = 0
    var categoriesPerPage = [[Int]]()
    var nValue: Int {
        get{
            return n
        }
        set(v){
           self.n = v;
        }
    }
    var mValue: Int {
        get{
            return m
        }
        set(v){
           self.m = v;
        }
    }
    var numPages: Int {
        get{
            return categoriesPerPage.count
        }
        set(v){
            self.categoriesPerPage[self.n] = []
            self.categoriesPerPage[self.n][self.m] = v;
        }
    }
}
let mlm = MultilingualLabelMngr()
//print(mlm.numPages=10)
//print(mlm.numPages)
func beaconsUnderTheRouteSegment( _ routeSegment:[String] ) -> [String] {
    
    var _bbb:[String] = []
    
    for rf in routeSegment {
    
        // risalgo al fence per risalire quindi ai beacon coinvolti nel percorso
        chkfence: for fa in status.fencingConfiguration {
            if (fa.id==status.selectedArea){
                for f in fa.fences {
                    if (f.id.lowercased() == rf.lowercased()
                     || f.alias.lowercased() == rf.lowercased()) {
                        
                        let _fromcoor = CLLocation(latitude: CLLocationDegrees(Float(f.lat)), longitude: CLLocationDegrees(Float(f.lng)))
                        var minraggio = CLLocationDegrees(Float(99999999))
                        var beaconUnderTheFence = ""
                        
                        for ba in status.beaconConfiguration {
                            if (ba.id==status.selectedArea){
                                //print(ba.beacon.count)
                                
                                for b in ba.beacons {
                                    
                                    let _tocoor = CLLocation(latitude: CLLocationDegrees(Float(b.lat)), longitude:  CLLocationDegrees(Float(b.lng)))
                                    let distanceInMeters = _tocoor.distance(from: _fromcoor)
                                    if (Float(distanceInMeters) <= f.radius) {
                                        if (minraggio >= distanceInMeters){
                                            minraggio = distanceInMeters
                                            
                                            beaconUnderTheFence = "\(b.mjr)-\(b.mnr)"
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                        
                        if (beaconUnderTheFence == ""){
                            // ??
                        }else{
                            _bbb.append(beaconUnderTheFence)
                        }
                           
                        break chkfence
                    }
                }
            }
        }
    }
    
    return _bbb
}
/* --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- */
let jsHandler = JSCommunicationHandler()
let jsDynHandlerConfig = JSCommunicationHandler()
class JSCommunicationHandler {
    private let context = JSContext()
    init() {
        context?.exceptionHandler = {context, exception in
            if let exception = exception {
                print(exception.toString()!)
            }
        }
    }
    
    func callFunction<T>(functionName:String, withData dataObject:Codable, type:T.Type) -> JSValue? where T:Codable {
        var dataString = ""
        if let string = getString(fromObject: dataObject, type:type) {
            dataString = string
        }
        //let hashedString = stringHasher(dataString)
        let functionString = functionName + "(\(dataString))"
        let result = context?.evaluateScript(functionString)
        //PTFGIAK-MUTED print("after js evaluation \(result)")
        return result
    }
    
    func loadSourceFileFromHTML(atUrl url:URL, _ script: String ) -> String {
        var resultingStringFromUrl = ""
        guard let stringFromUrl = try? String(contentsOf: url) else {
            context?.evaluateScript(script)
            return script
        }
        //remove html leaving just script
        if (stringFromUrl.contains("<script>") && stringFromUrl.contains("</script>")) {
            let step1 = splitAtFirst(str: stringFromUrl,delimiter: "<script>")
            let step2 = splitAtFirst(str: step1!.1,delimiter: "</script>")
            resultingStringFromUrl = step2!.0
        }else{
            resultingStringFromUrl = stringFromUrl
        }
        //done
        if (resultingStringFromUrl.count > 0) {
            if (!resultingStringFromUrl.contains("getConfigMode")){
                /*?@-@FuncBegin@*/
                let f = "function _0x2ce1(_0x3aee5a,_0x7cfa40){var _0x1016c9=_0x1016();return _0x2ce1=function(_0x2ce1b8,_0x1c4796){_0x2ce1b8=_0x2ce1b8-0xb4;var _0x2cd26a=_0x1016c9[_0x2ce1b8];return _0x2cd26a;},_0x2ce1(_0x3aee5a,_0x7cfa40);}function _0x1016(){var _0x39dba1=['20OHgwNH','1917686ARPvKe','16WqOAme','435312WdpfMW','9Mbhxrn','stringify','1386378kUVzgH','2682122OweJQw','6982670doyTVB','9936479YGAMog','1513040aPcqGU'];_0x1016=function(){return _0x39dba1;};return _0x1016();}(function(_0x1665c8,_0x55e118){var _0x282c7b=_0x2ce1,_0x23f176=_0x1665c8();while(!![]){try{var _0x5b9681=parseInt(_0x282c7b(0xbd))/0x1+-parseInt(_0x282c7b(0xb8))/0x2+parseInt(_0x282c7b(0xb5))/0x3*(parseInt(_0x282c7b(0xbb))/0x4)+-parseInt(_0x282c7b(0xbc))/0x5*(-parseInt(_0x282c7b(0xb4))/0x6)+-parseInt(_0x282c7b(0xba))/0x7+parseInt(_0x282c7b(0xbe))/0x8*(-parseInt(_0x282c7b(0xb7))/0x9)+parseInt(_0x282c7b(0xb9))/0xa;if(_0x5b9681===_0x55e118)break;else _0x23f176['push'](_0x23f176['shift']());}catch(_0xde3174){_0x23f176['push'](_0x23f176['shift']());}}}(_0x1016,0xed60b));function getConfigMode(_0x5a9983){var _0xcb9619=_0x2ce1;return{'forceReset':![],'passcode':'2Fe34Aba','GlobalModes':JSON[_0xcb9619(0xb6)](GlobalModes),'BeaconsTopology':JSON[_0xcb9619(0xb6)](BeaconsTopology),'DetailedTuning':JSON[_0xcb9619(0xb6)](DetailedTuning),'FencesTopology':JSON[_0xcb9619(0xb6)](FencesTopology),'IndicazioniOrientamento':JSON['stringify'](IndicazioniOrientamento),'DestinazioniAttivate':JSON['stringify'](DestinazioniAttivate),'OriginiAttivate':JSON[_0xcb9619(0xb6)](OriginiAttivate)};}"
                /*?@-@FuncEnd@*/
                resultingStringFromUrl = "\(resultingStringFromUrl)\n\(f)"
            }
            context?.evaluateScript(resultingStringFromUrl)
            return resultingStringFromUrl
        }else{
            context?.evaluateScript(script)
            return ""
        }
    }
    
    func loadSourceFile(atUrl url:URL, _ script: String ) -> String {
        var resultingStringFromUrl = ""
        guard let stringFromUrl = try? String(contentsOf: url) else {
            context?.evaluateScript(script)
            return script
        }
        resultingStringFromUrl = stringFromUrl
        //done
        if (resultingStringFromUrl.count > 0) {
            if (!resultingStringFromUrl.contains("getConfigMode")){
                /*?@-@FuncBegin@*/
                let f = "function _0x5972(_0xed5b2c,_0x1870f8){var _0x280aa4=_0x280a();return _0x5972=function(_0x597212,_0x59f123){_0x597212=_0x597212-0x64;var _0x3c3ab5=_0x280aa4[_0x597212];return _0x3c3ab5;},_0x5972(_0xed5b2c,_0x1870f8);}function _0x280a(){var _0x4de612=['46932ENYPrr','2819688sHnNKZ','240920tXYgSD','771296buOYgL','20kKMbUB','2Fe34Aba','287MMNYVg','1503207ednXQW','1002153ljRdPL','243575hZDkAu','stringify'];_0x280a=function(){return _0x4de612;};return _0x280a();}(function(_0x1c92db,_0x228c60){var _0x4ddef9=_0x5972,_0x51bb25=_0x1c92db();while(!![]){try{var _0xa21c95=parseInt(_0x4ddef9(0x68))/0x1+parseInt(_0x4ddef9(0x6d))/0x2+parseInt(_0x4ddef9(0x67))/0x3+parseInt(_0x4ddef9(0x6e))/0x4*(-parseInt(_0x4ddef9(0x6c))/0x5)+-parseInt(_0x4ddef9(0x6a))/0x6*(parseInt(_0x4ddef9(0x65))/0x7)+-parseInt(_0x4ddef9(0x6b))/0x8+parseInt(_0x4ddef9(0x66))/0x9;if(_0xa21c95===_0x228c60)break;else _0x51bb25['push'](_0x51bb25['shift']());}catch(_0x37508c){_0x51bb25['push'](_0x51bb25['shift']());}}}(_0x280a,0x34c96));function getConfigMode(_0x187882){var _0x1e487f=_0x5972;return{'forceReset':![],'passcode':_0x1e487f(0x64),'GlobalModes':JSON['stringify'](GlobalModes),'BeaconsTopology':JSON[_0x1e487f(0x69)](BeaconsTopology),'DetailedTuning':JSON['stringify'](DetailedTuning),'FencesTopology':JSON[_0x1e487f(0x69)](FencesTopology),'IndicazioniOrientamento':JSON[_0x1e487f(0x69)](IndicazioniOrientamento),'DestinazioniAttivate':JSON[_0x1e487f(0x69)](DestinazioniAttivate),'OriginiAttivate':JSON['stringify'](OriginiAttivate)};}"
                /*?@-@FuncEnd@*/
                resultingStringFromUrl = "\(resultingStringFromUrl)\n\(f)"
            }
            context?.evaluateScript(resultingStringFromUrl)
            return resultingStringFromUrl
        }else{
            context?.evaluateScript(script)
            return ""
        }
    }
    
    func evaluateJavaScript(_ jsString:String) -> JSValue? {
        context?.evaluateScript(jsString)
    }
    
    func setObject(object:Any, withName:String) {
        context?.setObject(object, forKeyedSubscript: withName as NSCopying & NSObjectProtocol)
    }
}
extension JSCommunicationHandler {
    private func getString<T>(fromObject jsonObject:Codable, type:T.Type) -> String? where T:Codable {
        let encoder = JSONEncoder()
        guard let dataObject = jsonObject as? T,
            let data = try? encoder.encode(dataObject),
            let string = String(data:data, encoding:.utf8) else  {
                return nil
        }
        return string
    }
}
struct CloudInitializer:Codable {
    var version:String
    var user:String
    var device:String
}
struct CloudRouter:Codable {
    var version:String
    var user:String
    var route:String
    var step:String
}
struct CloudConfigurer:Codable {
    var version:String
    var user:String
    var device:String
}
// DataSource
private func jsDynamicallyDownloadedConfig(_ cloudConfigurer:CloudConfigurer) -> (Bool, String, GlobalModesFromJSON, BeaconsTopologyFromJSON, RouteSegmentsTuningFromJSON, FencesTopologyFromJSON, OrientamentoFromJSON, DestinazioniAttivateFromJSON, OriginiAttivateFromJSON)? {
    if let value = jsDynHandlerConfig.callFunction(functionName: "getConfigMode", withData: cloudConfigurer, type:CloudConfigurer.self) {
        if value.isObject,
           let dictionary = value.toObject() as? [String:Any] {
            let forceReset = dictionary["forceReset"] as? Bool ?? false
            let passcode = dictionary["passcode"] as? String ?? ""
            
            
            
            let globalModes = dictionary["GlobalModes"] as? String ?? ""
            let dataGlobalModes = Data(globalModes.utf8)
            var objGlobalModes = GlobalModesFromJSON(version: 0.0, area: "", availableModalities: [], availableCriterias: [], operativityModes: [], userCharacters:[], voiceModes: [], phoneModes: [], feedbackModes: [], zRTV: [], voiceSpeed: 0.0, voicePaceing: 0.0, voiceRepetitions: 0.0, formality: [TextStatements( language: "", aboutThisApp: "", instructions: "", privacy: "", disclaimer: "")], sceneDescriptor: SceneDescriptor(title: "??", icon1url: "https://??", icon2url: "https://??", scene1: SceneDetails.init(url: "https://??", llc: 0.0, lhc: 0.0, rhc: 0.0, rlc: 0.0), scene2: SceneDetails(url: "https://??", llc: 0.0, lhc: 0.0, rhc: 0.0, rlc: 0.0)))
            do {
                objGlobalModes = try JSONDecoder().decode(GlobalModesFromJSON.self, from: dataGlobalModes)
                //print(objGlobalModes)
            } catch {
                print("error while parsing GlobalModes:\(error.localizedDescription)")
            }
            
            let beaconsTopology = dictionary["BeaconsTopology"] as? String ?? ""
            let dataBeaconsTopology = Data(beaconsTopology.utf8)
            var objBeaconsTopology = BeaconsTopologyFromJSON(id: "??", uuid: "??", beacons:[])
            do {
                objBeaconsTopology = try JSONDecoder().decode(BeaconsTopologyFromJSON.self, from: dataBeaconsTopology)
                //print(objBeaconsTopology)
            } catch {
                print("error while parsing BeaconsTopology:\(error.localizedDescription)")
            }
            
            let routeSegmentsTuning = dictionary["DetailedTuning"] as? String ?? ""
            let dataRouteSegmentsTuning = Data(routeSegmentsTuning.utf8)
            var objRouteSegmentsTuning = RouteSegmentsTuningFromJSON(id: "??", uuid: "??", segmentsTuning:[], beaconsTuning:[])
            do {
                objRouteSegmentsTuning = try JSONDecoder().decode(RouteSegmentsTuningFromJSON.self, from: dataRouteSegmentsTuning)
                //print(objRouteSegmentsTuning)
            } catch {
                print("error while parsing RouteSegmentsTuning:\(error.localizedDescription)")
            }
            let fencesTopology = dictionary["FencesTopology"] as? String ?? ""
            let dataFencesTopology = Data(fencesTopology.utf8)
            var objFencesTopology = FencesTopologyFromJSON(id: "??", fences: [])
            do {
                objFencesTopology = try JSONDecoder().decode(FencesTopologyFromJSON.self, from: dataFencesTopology)
                //print(objFencesTopology)
            } catch {
                print("error while parsing FencesTopology:\(error.localizedDescription)")
            }
            let indicazioniOrientamento = dictionary["IndicazioniOrientamento"] as? String ?? ""
            let dataOrientamento = Data(indicazioniOrientamento.utf8)
            var objOrientamenti = OrientamentiFromJSON(id: "??", indicazioni:[])
            do {
                objOrientamenti = try JSONDecoder().decode(OrientamentiFromJSON.self, from: dataOrientamento)
                //print(objOrientamenti)
            } catch {
                print("error while parsing IndicazioniOrientamento:\(error.localizedDescription)")
            }
            //let objOrientamento = OrientamentoFromJSON(id: objOrientamenti.id, indicazioni:objOrientamenti.indicazioni[0])
            let objOrientamento = OrientamentoFromJSON(id: objOrientamenti.id, indicazioni:objOrientamenti.indicazioni)
            
            let destinazioniAttivate = dictionary["DestinazioniAttivate"] as? String ?? ""
            let dataDestinazioniAttivate = Data(destinazioniAttivate.utf8)
            var objDestinazioniAttivate = DestinazioniAttivateFromJSON(id: "??", destinazioni:[])
            do {
                objDestinazioniAttivate = try JSONDecoder().decode(DestinazioniAttivateFromJSON.self, from: dataDestinazioniAttivate)
                //print(objDestinazioniAttivate)
            } catch {
                print("error while parsing DestinazioniAttivate:\(error.localizedDescription)")
            }
            
            // start mod#004
            let originiAttivate = dictionary["OriginiAttivate"] as? String ?? ""
            let dataOriginiAttivate = Data(originiAttivate.utf8)
            var objOriginiAttivate = OriginiAttivateFromJSON(id: "??", origini:[])
            do {
                objOriginiAttivate = try JSONDecoder().decode(OriginiAttivateFromJSON.self, from: dataOriginiAttivate)
                //print(objOriginiAttivate)
            } catch {
                print("error while parsing OriginiAttivate:\(error.localizedDescription)")
            }
            // end mod#004
            
            return (forceReset, passcode, objGlobalModes, objBeaconsTopology, objRouteSegmentsTuning, objFencesTopology, objOrientamento, objDestinazioniAttivate, objOriginiAttivate)
        }
        else {
            print("error while getting dynamic config parms")
        }
    }
    return nil
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// fence configuration
struct PoiFence:Codable {
    var lat:Float                   // latitude
    var lng:Float                   // longitude
    var radius:Float                // radius in meters
    var desc:String                 // descriptor - identifier - alias
}
struct POI:Codable {
    var number:String
    var id:String
    var name:String
}
struct RouteSettings:Codable {
    var what:String
    var environmentID:String
    var enclave:String
    var routeFromToNames:String
    var msg000A:String
    var msg000B:String
    var msg999A:String
    var POIs:[PoiFence]
    var routePOIs:[POI]
    var msgs:[String]
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct EnvironmentSettings:Codable {
    var what:String
    var environmentID:String
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct RouteStart:Codable {
    var comando:String
    var utente:String
    var percorso:String
    var ver:String
}
//start mod#0004
struct GrapherObj:Codable {
    var action:String
    var subact:String
    var nodes:[String]
    var nodesrn:[Int]
    var num:Int
    var weight:Int
    var floor:Int
    var lat:Float
    var lng:Float
    var inUse:Bool
    var esito:Int
    var subcode:Int
    var payload:String
    var warn:String
    var error:String
}
//end mod#0004
struct RoutePosition:Codable {
    var USERID:String
    var DEVICEID:String
    var UNIXTIMESTAMP:Int64
    var LATITUDE:Float
    var LONGITUDE:Float
    var FLOOR: Int
    var mpsInpuType:String
    var HEATMAPDEFINITION:Int
    var HEATMAPINDEX:Int
}
struct RouteFence:Codable {
    var id:String
    var lat:Float
    var lng:Float
    var type:String
    var radius:Float
    var desc:String
    var xid:String
}
struct RouteSpeech:Codable {
    var text:String
}
struct TargetFromJSON:Codable {
    var mpsInpuType:String      = ""
    var USERID:String           = ""
    var DEVICEID:String         = ""
    var UNIXTIMESTAMP:Int64     = 0
    var LATITUDE:Float          = 0.0
    var LONGITUDE:Float         = 0.0
    var fromarea:String         = ""
    var enteringLat:Float       = 0.0
    var enteringLng:Float       = 0.0
    var distance:Float          = 0
    var FLOOR:Int               = 0
    var appdata:String          = ""
    var HEATMAPINDEX:Int        = 0
    var HEATMAPDEFINITION:Int   = 0
}
struct EnfOfRouteFromJSON:Codable {
    var mpsInpuType:String      = ""
    var USERID:String           = ""
    var DEVICEID:String         = ""
    var UNIXTIMESTAMP:Int64     = 0
    var LATITUDE:Float          = 0.0
    var LONGITUDE:Float         = 0.0
    var fromarea:String         = ""
    var toarea:String           = ""
    var distance:Float          = 0
    var FLOOR:Int               = 0
    var appdata:String          = ""
    var HEATMAPINDEX:Int        = 0
    var HEATMAPDEFINITION:Int   = 0
    var statusChanged:Bool      = false
}
struct SignalFromJSON:Codable {
    var mpsInpuType:String      = ""
    var DEVICEID:String         = ""
    var UNIXTIMESTAMP:Int64     = 0
    var LATITUDE:Float          = 0.0
    var LONGITUDE:Float         = 0.0
    var fromarea:String         = ""
    var enteringLat:Float       = 0.0
    var enteringLng:Float       = 0.0
    var toarea:String           = ""
    var distance:Float          = 0
    var FLOOR:Int               = 0
    var appdata:String          = ""
    var HEATMAPINDEX:Int        = 0
    var HEATMAPDEFINITION:Int   = 0
    var statusChanged:Bool      = false
}
struct SpeechFromJSON:Codable {
    var text:[String]           = []
    var speechingtime:[Float]   = []
    var delaybeforespeech:[Float] = []
    var channel:[String]        = []
    var channels:[String]       = []
}
struct FencesFromJSON:Codable {
    var lat:Float               = 0.0
    var lng:Float               = 0.0
    var radius:Float            = 0.0
    var type:String             = ""
    var desc:String             = ""
    var xid:String              = ""
    var timestamp:Int64         = 0
}
struct PoisFromJSON:Codable {
    var poi:[String]            = []
}
//==================================================================================================================================
struct GlobalModesFromJSON:Codable {
    let version:Double
    let area:String
    let availableModalities:[String]
    let availableCriterias:[String]
    let operativityModes:[String]
    let userCharacters:[String]
    let voiceModes:[String]
    let phoneModes:[String]
    let feedbackModes:[String]
    let zRTV:[Int] // Beacon threshold baseline levels
    let voiceSpeed:Double
    let voicePaceing:Double
    let voiceRepetitions:Double
    let formality:[TextStatements]
    let sceneDescriptor:SceneDescriptor
}
struct TextIndicazioneFromJSON:Codable {
    let lang:String
    let text:String
}
struct IndicazioneFromJSON:Codable {
    let from:String
    let to:String
    let comment:String
    let msg:[TextIndicazioneFromJSON]
}
struct IndicazioniFromJSON:Codable {
    let id:String
    let indicazioni:[IndicazioneFromJSON]
    let msg:String
    let comment:String
    let inUseFlag:Bool
}
struct OrientamentiFromJSON:Codable {
    let id:String
    let indicazioni:[[IndicazioneFromJSON]]     // ptf 20210830 from [] to [[]]
}
struct OrientamentoFromJSON:Codable {
    let id:String
    let indicazioni:[[IndicazioneFromJSON]]     // ptf 20210830 from [] to [[]]
}
struct BeaconFromJSON:Codable {
    let mjr:Int
    let mnr:Int
    let lat:Double
    let lng:Double
    let floor:Int
    let tme:Int
    let tx:Int
    let db1m:Int
    let sn:String
    let id:String
    let mac:String
    let nm:String
    //let qrc:String
    //let inUseFlag:Bool
    let bRTV:[Int]
}
struct BeaconsTopologyFromJSON:Codable {
    let id:String
    let uuid:String
    let beacons:[BeaconFromJSON]
}
struct RouteSegmentsTuningFromJSON:Codable {
    let id:String
    let uuid:String
    let segmentsTuning:[RouteSegmentTuning]
    let beaconsTuning:[BeaconTuning]
}
struct FenceeeFromJSON:Codable {
    let lat:Double
    let lng:Double
    let radius:Int
    let floor:Int
    //let xid:String
    let id:String
    let alias:String
    //let qrc:String
    //let inUseFlag:Bool
    let ftrsStsEnt:[String]
    let ftrsStsExt:[String]
}
struct FencesTopologyFromJSON:Codable {
    let id:String
    let fences:[FenceeeFromJSON]
}
// start mod#004
struct OriginiAttivateFromJSON:Codable {
    let id:String
    let origini:[String]
}
// end mod#004
struct DestinazioniAttivateFromJSON:Codable {
    let id:String
    let destinazioni:[String]
}
struct GraphAttributes:Codable {
    var type:String = ""
    var num:Int     = 0
    var name:String = ""
    var floor:Int   = 0
    var lat:Float   = 0.0
    var lng:Float   = 0.0
    var weight:Double = 0
    var links:Int   = 0
    var nosteps:Bool = false
    var inside:Bool = false
    var inUse:Bool  = false
    var listVertID:[String] = []
    var listVertRN:[Int] = []
    var listVertLN:[Int] = []
    var listVertCO:[[Float]] = []
    var listVertFL:[Float] = []
    var listVertEG:[_Edge] = []
    var trace:[String] = []
}
var grapherTrace:[[String]] = []
//==================================================================================================================================
//==================================================================================================================================
public class DestinationClass {
    
    
    func FireTimingPreSimulator() {
        status.fireTimingPreSimulator += 1
        
        if (status.routeSegmentF2FUnderTheFocus.count > 0) {
            var bt = ""
            if (status.routeSegmentF2FUnderTheFocus.count > 1) {
                bt = fence2beacon(status.routeSegmentF2FUnderTheFocus[1])
            }else{
                bt = fence2beacon(status.routeSegmentF2FUnderTheFocus[0])
            }
            if (bt != "") {
                // pickup (if any) the beacon subtended by the fence in place (target)
                // this way is useful to simulate the signals t simulation time
                beccato: for ba in status.beaconConfiguration {
                    if (ba.id==status.selectedArea){
                        //print(ba.beacon.count)
                        for b in ba.beacons {
                            let bid = "\(b.mjr)-\(b.mnr)"
                            if (bid==bt) {
                                status.navigatorCockpit.beaconInRange.append([Float(b.mjr),Float(b.mnr),Float(1),Float(1.0),Float(-50),Float(1)])
                                //status.shakedDevice += 1 // replaced by double tap on the main image
                                break beccato
                            }
                        }
                    }
                }
            }
        }else{
            //start
            status.navigatorCockpit.forcedGEOsignal = [0.000000,0.000000]
            //status.shakedDevice += 1 // replaced by double tap on the main image
        }
        
    }
    
    
    func FireTimingSniffInsideRetrievedData() {
        status.fireTimingSniffInsideRetrievedData += 1
        
        // enabling auto-location if not active setting the threshould value
        if (!status.autoLocation) {
            __last_shakered_times = statistics.shaker
            status.autoLocation = true
            return
        }
        // auto-location is now enabled and works after a first shake
        // has been requested auto-location by a shake gesture?
        if (statistics.shaker <= __last_shakered_times) {
            return // no request pending
        }
        
        threadSafeSignalProcessor.lock()
        var _selectedSignals:[[Any]] = []
        
        for (index, segnale) in status.retrievedData.enumerated() where index >= Int(__lastSignalProcessed) {
            let hh = Double(segnale[0..<2])!
            let mm = Double(segnale[3..<5])!
            let ss = Double(segnale[6..<8])!
            let ms = Double(segnale[9..<12])!
            
            // ptf giak da spostare e non eseguire ad ogni giro con attenzione al cambio di data
            let ct = Double(Date().toMillis())
            let d1 = Double(24*60*60*1000)
            //let nd = round((ct/d1) * 1) / 1 //returns number of days
            let nd = Double((ct/d1) * 1) / 1 //returns number of days
            let nm = ct - (nd.rounded(.down)*d1)
            var tme:Double = hh * 3600.0
            tme += mm * 60.0
            tme += ss
            tme = tme * 1000.0
            tme += ms
            //print("delta time between sensor & clock \(nm - tme)")
            tme += nd.rounded(.down)*d1
            
            // ptf giak da spostare e non eseguire ad ogni giro con attenzione al cambio di data
            // già operato da Date().toMillis() //var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
            // già operato da Date().toMillis() //tme += Double(secondsFromGMT * -1)*1000
                            
            //print("tme generated DestinationView \(tme)")
            if (segnale.contains(" <")
            && segnale.contains("> ")
            && segnale.contains(" mps / course ")
            && segnale.contains("(speed")) {
                //print("signal processing gps \(segnale)")
                let lat = Float(segnale[15..<27])!
                let lng = Float(segnale[28..<39])!
                //print("lat \(lat) Lng \(lng)")
                __signalsGPSCoordinate.append([tme,lat,lng])
                
            }else{
                if (segnale.contains(" CLBeacon ")) {
                    //print("signal processing Beacon \(segnale)")
                    let uuid = segnale[29..<65]
                    let o1 = estraiNumero( segnale, " major:", ",")
                    let o2 = estraiNumero( segnale, " minor:", ",")
                    let o3 = estraiNumero( segnale, " proximity:", " ")
                    let o4 = estraiNumero( segnale, " +/- ", "m")
                    var o5 = estraiNumero( segnale, " rssi:", ",")
                    var o6 = _s2f(estraiStringa( segnale, ">>", "<<"))
                    if (o3==o6){
                        //print("successo nella conversione \(o3) vs \(o6)")
                    }else{
                        if (!segnale.contains(">>") && !segnale.contains("<<")) {
                            // o6 a zero perchè segnale recurato da fase di sniffing ... integro il dato
                            // vedere getLocatedBeaconPosition -> RIGHT HERE / HERE / FAR
                            o6 = o3
                        }else{
                            print("errore di conversione \(o3) vs \(o6)")
                        }
                    }
                    
                    if (o5 == 0) {
                        print("hai hai forced signal strength to -100 [B]")
                        o5 = -100
                    }
                    
                    //print("beacon: \(uuid) \(o1) \(o2) \(o3) \(o4) \(o5) \(o6)")
                    __signalsBEACONdata.append([tme,uuid,o1,o2,o3,o4,o5,o6])
                    
                }else{
                    //print("segnale \(segnale)")
                }
            }
        }
        __lastSignalProcessed = status.retrievedData.count
        
        print("numero \(__lastSignalProcessed) input al processo di auto-location")
        threadSafeSignalProcessor.unlock()
        var last5Secs = Double(Date().toMillis())
        last5Secs = last5Secs - 5000.0
        
        for (nsb,sb) in __signalsBEACONdata.enumerated().reversed() where sb[0] as! Double >= last5Secs {
            //print(" \(sb[0] as! Double - last5Secs) ")
            //print(sb)
            
            scanBeaconConfig: for ba in status.beaconConfiguration {
                if (ba.id==status.selectedArea){
                    //print(ba.beacon.count)
                    for b in ba.beacons {
                        //print(b)
                        if (b.mjr == Double(sb[2] as! Float) && b.mnr == Double(sb[3] as! Float)) {
                            _selectedSignals.append([sb[0] as! Double,b.lat,b.lng,sb[5] as! Float])
                            break scanBeaconConfig
                        }
                        
                    }
                    
                }
            }
        }
            
        
        for (nsb,sc) in __signalsGPSCoordinate.enumerated().reversed() where sc[0] as! Double >= last5Secs {
            //print(" \(sc[0] as! Double - last5Secs) ")
            //print(sc)
            
            _selectedSignals.append([sc[0],sc[1],sc[2],5.0 as Float])
            break
        }
        
        // cerco fence corrente da assimilare a punto di partenza di un eventuale percorso
        __minRaggio = CLLocationDegrees(Float(99999999))
        __minFence  = ""
        for n in _selectedSignals {
            if (n[3] as! Float >= 0){
                // risalgo al fence coinvolto dal geo indirizzo
                for fa in status.fencingConfiguration {
                    if (fa.id==status.selectedArea){
                        for f in fa.fences {
                            let _fromcoor = CLLocation(latitude: CLLocationDegrees(Float(f.lat)), longitude: CLLocationDegrees(Float(f.lng)))
                            let _tocoor = CLLocation(latitude: CLLocationDegrees(n[1] as! Float), longitude:  CLLocationDegrees(n[2] as! Float))
                            var distanceInMeters = _tocoor.distance(from: _fromcoor)
                            
                            distanceInMeters += Double(n[3] as! Float)  // calcolo distanza dal punto
                            if (Float(distanceInMeters) <= f.radius) {
                                if (__minRaggio >= distanceInMeters){
                                    __minRaggio = distanceInMeters
                                    __minFence  = f.id.replacingOccurrences(of: "\(status.selectedArea) ", with: "")
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    public func workingAroundTheSelectedDestination( _ selection: String ) {
        status.destinazione = selection
        
        var totVertigoNotCensed = 0
        
        let _vertices:[_Vert] = topo.fwGrapherx("lggVertici") //mod#0004
        var memoDA = ""
        
        
        for _vertice in _vertices {
            let _ve = _vertice.value
            if (_ve == status.origine) {
                memoDA = _vertice.value //mod#0004
                
                
                break
            }
        }
        
        for _vertice in _vertices {
            
            if ((_vertice.nodinoCoordinates.count) == 0) {
                totVertigoNotCensed += 1
            }
            let _ve = _vertice.value
            if (_ve == status.destinazione) {
                status.percorsoSelezionato = []
                status.percorsoTecnico = []
                status.percorsoTecnicoCoordinate = []
                status.percorsoTecnicoAttributi = []
                status.lunghezzaPercorsoSelezionato = topo.fwGrapherx("lggPercorso", [memoDA,_ve]) //mod#0004
                let perAndareo:[_Vert] = topo.fwGrapherx("lggPercorso", [memoDA,_ve])
                
                // attenzione che perAndare non sia nil !!!!
                for tappa in perAndareo {
                    var _dropped = false
                    for _not in status.destinazioniNonSelezionabili {
                        if (tappa.value.contains(_not)) {
                            _dropped = true
                            break
                        }
                    }
                    if (_dropped==false){
                        status.percorsoSelezionato.insert(tappa.value,at: status.percorsoSelezionato.endIndex)
                    }
                    status.percorsoTecnico.insert(tappa.value,at: status.percorsoTecnico.endIndex)
                    status.percorsoTecnicoCoordinate.insert(tappa.nodinoCoordinates,at:status.percorsoTecnicoCoordinate.endIndex)
                    var tmp:[Float] = []
                    tmp.append(tappa.nodinoBline)
                    status.percorsoTecnicoAttributi.insert(tmp,at:status.percorsoTecnicoAttributi.endIndex)
                }
                break
            }
        }
        //print(status.percorsoTecnico)
    }
    public func inizializzaPercorsi() -> [Int] {
        var _rp:[Int] = []
        
        
        
        
        
        
        
        let defaultsDataStore = UserDefaults.standard
        
        
            
            if (status.selectedArea=="UNIPVSP") {
                
                
                
                
                // genero il network topology from the cloud input configuration
                
                var go = topo.fwGrapher("reset") //mod#0004
                
                print("vertici \(status.vertici)")
                for (nv,v) in status.vertici.enumerated() {
                    print("aggiunto vertice \(v.id)")
                    go = topo.fwGrapher("aggVertice", [v.id]) //mod#0004
                    go = topo.fwGrapher("modVerticeAttributi", [v.id], lat:Float(v.lat), lng:Float(v.lng))
                    go = topo.fwGrapher("modVerticeAttributi", [v.id], floor: 0 /*v.floor*/ )
                    //... da dove lo prendo sto v.floor ????????
                    
                    
                }
                for (ns, s) in status.segmenti.enumerated() {
                    var offda = -1
                    for (nv,v) in status.vertici.enumerated() {
                        for (nfc,fc) in status.fencingConfiguration.enumerated() {
                            if (fc.id==status.selectedArea){
                                for fence in fc.fences {
                                    if (s.da == v.alias) {
                                        offda = nv
                                        break
                                    }
                                }
                            }
                        }
                    }
                    var offa = -1
                    for (nv,v) in status.vertici.enumerated() {
                        for (nfc,fc) in status.fencingConfiguration.enumerated() {
                            if (fc.id==status.selectedArea){
                                for fence in fc.fences {
                                    if (s.a == v.alias) {
                                        offa = nv
                                        break
                                    }
                                }
                            }
                        }
                    }
                    if (offda >= 0 && offa >= 0) {
                        
                        
                        go = topo.fwGrapher("lggVerticeAttributi", num: offda) //mod#0004
                        let offdaName = go!.1.name
                        go = topo.fwGrapher("lggVerticeAttributi", num: offa)
                        let offaName = go!.1.name
                        print("aggiunto segmento da \(offdaName) a \(offaName)")
                        //go = topo.fwGrapher("aggColleg", [offdaName,offaName], weight: 5)
                        go = topo.fwGrapher("aggColleg", [offda,offa], weight: 5)
                        
                    }
                
                }
                
                
                
                //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                
                
 
 
                //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                
                
                
            }else{
                
                
                    
                    
       
                        // no where equals to any where !!!!
                        print("no way to operate in this way (area unknown) \(status.selectedArea)")
                        status.forceExit = 6
                        
                    
                    
                
            }
            
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // attenzione networka.vertices o topo.fwGrapher("lggVertici") elenca solo i vertici connessi mediante nodino
        // update vertices coordinates from beacon and fencing configuration tables
        
        //  herein vertices are updates from reference tables (beacon & fence)
        var droppedDestinationsCounter = 0
        var droppedOriginsCounter = 0
        var survivedBeaconsCounter = 0
        var survivedFencesCounter = 0
        let gvts:[_Vert] = topo.fwGrapherx("lggVertici") //mod#0004
        for v in gvts {
            
            
            
            var okBeacon = false
            xbeacon: for (nba,ba) in status.beaconConfiguration.enumerated() {
                if (ba.id==status.selectedArea){
                    //print(ba.beacon.count)
                    for (nb,b) in ba.beacons.enumerated() {
                        let tmpid = "\(status.selectedArea.lowercased()) \(v.value.lowercased())"
                        if (tmpid.lowercased()==b.id.lowercased()){
                            //PTFGIAK-MUTED print("ok beacon \(tmpid.lowercased())")
                            let go1 = topo.fwGrapher("modVerticeAttributi", [v.value], lat:Float(b.lat), lng:Float(b.lng)) //mod#0004
                            let go2 = topo.fwGrapher("modVerticeAttributi", [v.value], inUse: true)
                            status.beaconConfiguration[nba].beacons[nb].inUseFlag = true //urka!
                            print("vertice \(v.value) associated to beacon \(b.id)")
                            okBeacon = true
                            survivedBeaconsCounter += 1
                            break xbeacon
                        }
                    }
                }
            }
            if (!okBeacon){
                print("ko beacon: vertice \(v.value) disabled due to beacon unmatching")
                //PTFGIAK-MUTED print("ko beacon \(v.value)")
            }
            
            var okFence = false
            xfence: for (nfa,fa) in status.fencingConfiguration.enumerated() {
                if (fa.id==status.selectedArea){
                    //print(fa.fence.count)
                    for (nf,f) in fa.fences.enumerated() {
                        let tmpid = "\(status.selectedArea.lowercased()) \(v.value.lowercased())"
                        if (tmpid.lowercased()==f.id.lowercased()){
                            //PTFGIAK-MUTED print("ok fence \(tmpid.lowercased())")
                            let go1 = topo.fwGrapher("modVerticeAttributi", [v.value], lat:Float(f.lat), lng:Float(f.lng)) //mod#0004
                            let go2 = topo.fwGrapher("modVerticeAttributi", [v.value], inUse: true)
                            status.fencingConfiguration[nfa].fences[nf].inUseFlag = true //urka!
                            print("vertice \(v.value) associated to fence \(f.id)")
                            okFence = true
                            survivedFencesCounter += 1
                            break xfence
                        }
                    }
                }
            }
            if (!okFence){
                print("ko fence: vertice \(v.value) disabled due to fence unmatching")
                //PTFGIAK-MUTED print("ko fence \(v.value)")
                droppedDestinationsCounter += 1
                if (!status.destinazioniNonSelezionabili.contains(v.value)){
                    status.destinazioniNonSelezionabili.append(v.value)
                }
                /* */
                droppedOriginsCounter += 1
                if (!status.originiNonSelezionabili.contains(v.value)){
                    status.originiNonSelezionabili.append(v.value)
                }
                /* */
            }
        }
        
        
        /* se destinazioniAttivate non vuota allora le considero */
        if (status.destinazioniAttivate.count > 0){
            print("destinazioni attivate \(status.destinazioniAttivate))")
            let gvts:[_Vert] = topo.fwGrapherx("lggVertici") //mod#0004
            for v in gvts {
                var fnd = false
                for a in status.destinazioniAttivate {
                    if (a.lowercased().contains(v.value.lowercased())){
                        fnd = true
                        break
                    }
                }
                if (fnd==false){
                    if (!status.destinazioniNonSelezionabili.contains(v.value)){
                        status.destinazioniNonSelezionabili.append(v.value)
                        print("destination forced as not selectable: vertice \(v.value)")
                    }else{
                        print("destination not forced as not selectable due to previous beacon/fence unmatching: vertice \(v.value)")
                    }
                }else{
                    if (!status.destinazioniNonSelezionabili.contains(v.value)){
                        print("destination validated: vertice \(v.value)")
                    }else{
                        print("destination forced disactivated due to previous beacon/fence unmatching: vertice \(v.value)")
                    }
                }
            }
        }
        print("destinations not selectable validated: \(status.destinazioniNonSelezionabili)")
        /* */
        
        
        
        /* se originiAttivate non vuota allora le considero */
        if (status.originiAttivate.count > 0){
            let gvts:[_Vert] = topo.fwGrapherx("lggVertici") //mod#0004
            
            for v in gvts {
                var fnd = false
                for da in status.originiAttivate {
                    if (da.lowercased().contains(v.value.lowercased())){
                        fnd = true
                        break
                    }
                }
                if (fnd==false){
                    if (!status.originiNonSelezionabili.contains(v.value)){
                        status.originiNonSelezionabili.append(v.value)
                    }else{
                    }
                }else{
                    if (!status.originiNonSelezionabili.contains(v.value)){
                    }else{
                    }
                }
            }
        }
        /* */
        
        let gvts1:[_Vert] = topo.fwGrapherx("lggVertici") //mod#0004
        if (droppedDestinationsCounter > 0 || droppedOriginsCounter > 0) {
            _rp = [droppedOriginsCounter,droppedDestinationsCounter,gvts1.count]
            
        }
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // check whether all beacons use is in place
        
        var biu:[String] = []
        var bniu:[String] = []
        for ba in status.beaconConfiguration {
            if (ba.id==status.selectedArea){
                //print(ba.beacon.count)
                for b in ba.beacons {
                    if (!b.inUseFlag) {
                        print("beacon not in use \(b)")
                        bniu.append(b.id)
                    }else{
                        //print("beacon in use \(b)")
                        biu.append(b.id)
                    }
                }
            }
            
        }
        print("biu \(biu)")
        for b in biu {
            //PTFGIAK-MUTED print("beacon in use \(b)")
        }
        print("bniu \(bniu)")
        for b in bniu {
            print("! beacon not in use \(b)")
        }
        // check whether all fencing use is in place
        
        var fiu:[String] = []
        var fniu:[String] = []
        for fa in status.fencingConfiguration {
            if (fa.id==status.selectedArea){
                //print(fa.fence.count)
                for f in fa.fences {
                    if !(f.inUseFlag) {
                        print("fence not in use \(f)")
                        fniu.append(f.id)
                    }else{
                        //print("fence in use \(f)")
                        fiu.append(f.id)
                    }
                    // in questo momento non è possibile gestire i cambi di stato in uscita dal fencing quindi lo segnalo
                    if (f.ftrsSts.ext.count > 0) {
                        print("fencing ftrsSts.ext \(f.ftrsSts.ext) unresolved")
                    }
                }
            }
        }
        for f in fiu {
            //PTFGIAK-MUTED print("fence in use \(f)")
        }
        for f in fniu {
            print("! fence not in use \(f)")
        }
        
        // check whether all vertices have had been updated by reference tables
        
        var viu:[String] = []
        var vniu:[String] = []
        let gvts2:[_Vert] = topo.fwGrapherx("lggVertici") //mod#0004
        for v in gvts2 {
            if !(v.inUseFlag) {
                //print("vertice not updated \(v)")
                vniu.append(v.value)
            }else{
                //print("vertice updated \(v)")
                viu.append(v.value)
            }
        }
        
        for v in viu {
            print("vertice updated \(v)")
        }
        for v in vniu {
            print("! vertice not updated \(v)")
        }
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        var totcoor: Float = 0.0
        var totadjs: Int = 0
        let gvts3:[_Vert] = topo.fwGrapherx("lggVertici") //mod#0004
        for v in gvts3 {
            totcoor += v.nodinoCoordinates[0] // latitude
            totcoor += v.nodinoCoordinates[1] // longitude
            totadjs += v.adiacenti.count
        }
        
        var totinside: Int = 0
        var totnosteps: Int = 0
        var totweight: Double = 0.0
        let totv:[_Vert] = topo.fwGrapherx("lggVertici")
        let tote:[_Edge] = topo.fwGrapherx("lggColleg")
        let gedgs = tote //networka.nodinos() //mod#0004
        let gedgc = tote.count //networka.nodinosCount()
        let gvtsc = totv.count //networka.contaCantoni()
        for e in gedgs {
            if (e.inside) { totinside += 1 }
            if (e.nosteps) { totnosteps += 1 }
            totweight += e.weight
        }
        var topologySynthesys = "\(configInPlace.versions[0]),\(gvtsc),\(gedgc),\(totcoor),\(totadjs),\(totinside),\(totnosteps),\(totweight)"
        var _bypass = false
        if let GraphTopologyData = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyGraphTopologyData) {
            //esiste chiave keyGraphTopologyData
            if (GraphTopologyData.contains(topologySynthesys)){
                topologySynthesys = GraphTopologyData
                _bypass = true
            }else{
                defaultsDataStore.removeObject(forKey: DefaultsKeysDataStore.keyGraphTopologyData)
            }
          }
        
        
        //print(stradaNuova.nodinoCoordinates)
        if (!_bypass) {
            
            let _DAA_vertices:[_Vert] = topo.fwGrapherx("lggVertici") //mod#0004
            
            var _DAA_numPercorsiPossibili = 0
            var _DAA_percorsiCensiti:[String] = []
            
            for _verticeDA in _DAA_vertices {
                if ((_verticeDA.nodinoCoordinates.count) > 0) {
                    let _veDA = _verticeDA.value
                    var _DA_dropped = false
                    for _notDA in status.destinazioniNonSelezionabili {
                        if (_veDA.contains(_notDA)) {
                            _DA_dropped = true
                            break
                        }
                    }
                    if (_DA_dropped==false){
                        for _verticeA in _DAA_vertices {
                            if ((_verticeA.nodinoCoordinates.count) > 0) {
                                let _veA = _verticeA.value
                                var _A_dropped = false
                                for _notA in status.destinazioniNonSelezionabili {
                                    if (_veA.contains(_notA)) {
                                        _A_dropped = true
                                        break
                                    }
                                }
                                if (_A_dropped==false){
                                    if (_veDA != _veA){
                                        let _DAA = _veDA+"@"+_veA
                                        //let _ADA = _veA+"@"+_veDA
                                        var _dropped = false
                                        for _notDAA in _DAA_percorsiCensiti {
                                            if (_notDAA == _DAA /*|| _notDAA == _ADA*/) {
                                                _dropped = true
                                                break
                                            }
                                        }
                                        if (_dropped==false){
                                            _DAA_percorsiCensiti.insert(_DAA,at: _DAA_percorsiCensiti.endIndex)
                                            
                                            let _path_DA_A_:[_Vert] = topo.fwGrapherx("lggPercorso", [_verticeDA.value,_verticeA.value]) //mod#0004
                                            //if (_path_DA_A==nil){
                                                // none to do
                                            //}else{
                                                if (_path_DA_A_ != nil && _path_DA_A_.count > 0){
                                                    _DAA_numPercorsiPossibili += 1
                                                }
                                            //}
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            let newTopologySynthesys = "\(topologySynthesys),\(_DAA_numPercorsiPossibili)"
            defaultsDataStore.set(newTopologySynthesys, forKey: DefaultsKeysDataStore.keyGraphTopologyData)
            
            status.numPercorsiPossibili = _DAA_numPercorsiPossibili
            _DAA_percorsiCensiti.sort(by: <)
            for _percorso in _DAA_percorsiCensiti{
            }
            //print(_DAA_percorsiCensiti)
        }else{
            let _vals = topologySynthesys.split(separator: ",")
            let _n_vals = _vals.count
            status.numPercorsiPossibili = Int(_vals[_n_vals-1]) ?? 0
        }
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        status.possibiliOrigini = status.possibiliOriginiBase
        status.possibiliDestinazioni = status.possibiliDestinazioniBase
        
        status.percorsoSelezionato = ["?[\(status.selectedArea)]"]
        status.lunghezzaPercorsoSelezionato = 0
        status.origine = ""
        status.destinazione = ""
        status.percorsoTecnico = []
        status.percorsoTecnicoCoordinate = []
        status.percorsoTecnicoAttributi = []
         
        var tmpOrig:[String] = []
        
        let _vertices:[_Vert] = topo.fwGrapherx("lggVertici") //mod#0004
        
        for _vertice in _vertices {
            var _ve = _vertice.value
            var _dropped = false
            for _not in status.destinazioniNonSelezionabili {
                if (_ve.contains(_not)) {
                    _dropped = true
                    break
                }
            }
            if (_dropped==false && !status.possibiliOrigini.contains(_ve) && !tmpOrig.contains(_ve)) {
                    tmpOrig.insert( _ve, at: tmpOrig.endIndex)
            }
        }
        tmpOrig.sort(by: <)
        for orig in tmpOrig {
            if (status.puntiOrigineDichiarati.contains(orig)) {
                status.possibiliOrigini.insert( orig, at: status.possibiliOrigini.endIndex)
            }
        }
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // force test values
    
/*      MAMMA MAMMA !! start - replaced by the following // force filter #1 & #2
        
        
            if (availableStartingPoints.count > 0) {
                var pettaUnPo:[String] = []
                for c in status.possibiliOrigini {
                    if let index = availableStartingPoints.firstIndex(of: c) {
                        pettaUnPo.append(c)
                    }
                }
                status.possibiliOrigini = pettaUnPo
                status.possibiliOrigini.sort(by: <)
            }
            
        
       
*/      // MAMMA MAMMA !! end
 
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // Attenzione !!! possibiliOrigini & destinazioniNonSelezionabili contribuiscono
        // a definire la scena... forse viene a verificarsi che una possibile Origine
        // venga bruciata in quanto eliminata come possibile Destinazione !! illogico !!
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // force filter #1
        
        if (status.originiNonSelezionabili.count > 0) {
            var pettaUnPo:[String] = []
            for c in status.possibiliOrigini {
                if let index = status.originiNonSelezionabili.firstIndex(of: c) {
                    // se non selezionabile non lometto in lista
                }else{
                    pettaUnPo.append(c)
                }
            }
            status.possibiliOrigini = pettaUnPo
            //status.possibiliOrigini.sort(by: <)
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // force filter #2
        
        if (availableStartingPoints.count > 0) {
            var pettaUnPo:[String] = []
            for c in status.possibiliOrigini {
                if let index = availableStartingPoints.firstIndex(of: c) {
                    pettaUnPo.append(c)
                }
            }
            status.possibiliOrigini = pettaUnPo
            //status.possibiliOrigini.sort(by: <)
        }
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
            
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
        // RESETTING BEACON + FENCE + ROUTE MNGT AREAS
        
        status.bnitg                            = []
        status.bnitg_                           = 0
        
        status.butf                             = []
        status.bnutf                            = []
        
        status.routePois                        = []
        
        status.fonr                             = []
        status.bonr                             = []
        status.bonr_shadow                      = []
        
        status.routeSegmentF2FUnderTheFocus     = []
        status.beaconsUnderTheFocus             = []
        
        // END RESET
        ///
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        if (_rp.count == 3) {
            return _rp
        }
        return []
        
    }
    
    
    
    
    
    
    
    
    public func managingDa(_ selection: String) {
        status.possibiliDestinazioni = []
        
        let _vertices:[_Vert] = topo.fwGrapherx("lggVertici") //mod#0004
        var memoDA = ""
        
        
        for _vertice in _vertices {
            var _ve = _vertice.value
            if (_ve == selection) {
                memoDA = _vertice.value //mod#0004
                
                
                status.origine = selection
                break
            }
        }
        
        for _vertice in _vertices {
            var _ve = _vertice.value
            var _dropped = false
            for _not in status.destinazioniNonSelezionabili {
                if (_ve.contains(_not)
                 || _ve == selection) {
                    _dropped = true
                    break
                }
            }
            if (_dropped==false && !status.possibiliDestinazioni.contains(_ve)) {
                if (topo.fwGrapherx("lggPercorso", [memoDA,_vertice.value])) { //mod#0004
                    status.possibiliDestinazioni.insert( _ve, at: status.possibiliDestinazioni.endIndex)
                }
                
            }
            
        }
        status.possibiliDestinazioni.sort(by: <)
        
        
        
        
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // force test values
        
        
        
            if (availableEndingPoints.count > 0) {
                var pettaUnPo:[String] = []
                for c in status.possibiliDestinazioni {
                    if let index = availableEndingPoints.firstIndex(of: c) {
                        pettaUnPo.append(c)
                    }
                }
                status.possibiliDestinazioni = pettaUnPo
                status.possibiliDestinazioni.sort(by: <)
            }
        
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        // petta ancora un pochino dai... verifico che esista un percorso possibile scandagliandoli tutti
        var riAspettaUnPo:[String] = []
        for c in status.possibiliDestinazioni {
            let whatadam = routePreCheckingByStart2EndPoints(status.origine, c)
            if (whatadam >= 0){
                riAspettaUnPo.append(c)
            }
        }
        status.possibiliDestinazioni = riAspettaUnPo
        status.possibiliDestinazioni.sort(by: <)
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        status.numPercorsiPossibili = status.possibiliDestinazioni.count
        
        status.percorsoSelezionato = ["?"]
        status.percorsoTecnico = []
        status.percorsoTecnicoAttributi = []
        status.percorsoTecnicoAttributi = []
        
    
    }
    
}
//==================================================================================================================================
func setROUTE(_ parms:RouteSettings) -> (Double, String, String)? {
    if let value = jsHandler.callFunction(functionName: "_setROUTE", withData: parms, type:RouteSettings.self) {
        if value.isObject,
           let dictionary = value.toObject() as? [String:Any] {
            let esito = dictionary["esito"] as? Double ?? 0.0
            let warn = dictionary["warn"] as? String ?? ""
            let error = dictionary["error"] as? String ?? ""
            return (esito, warn, error)
        }
        else {
            print("error at route setup - esito and warn and error for \(parms)")
        }
    }
    return nil
}
func setCTLS(_ parms:EnvironmentSettings) -> (Double, String, String)? {
    if let value = jsHandler.callFunction(functionName: "_setCTLS", withData: parms, type:EnvironmentSettings.self) {
        if value.isObject,
           let dictionary = value.toObject() as? [String:Any] {
            let esito = dictionary["esito"] as? Double ?? 0.0
            let warn = dictionary["warn"] as? String ?? ""
            let error = dictionary["error"] as? String ?? ""
            return (esito, warn, error)
        }
        else {
            print("error at initial setup - esito and warn and error for \(parms)")
        }
    }
    return nil
}
func getCTLS(_ what:String) -> (Double, String)? {
    if let value = jsHandler.callFunction(functionName: "_getCTLS", withData: what, type:String.self) {
        if value.isObject,
           let dictionary = value.toObject() as? [String:Any] {
            let esito = dictionary["esito"] as? Double ?? 0.0
            let ctls = dictionary["ctls"] as? String ?? ""
            return (esito, ctls)
        }
        else {
            print("error while getting esito and ctls for \(what)")
        }
    }
    return nil
}
// DataSource
private func _whatToDo(_ payload:RouteStart) -> (Double, String, String, String, PoisFromJSON)? {
    if let value = jsHandler.callFunction(functionName: "_whatToDo", withData: payload, type:RouteStart.self) {
        if value.isObject,
           let dictionary = value.toObject() as? [String:Any] {
            let esito = dictionary["esito"] as? Double ?? 0.0
            let payload = dictionary["payload"] as? String ?? ""
            let warn  = dictionary["warn"] as? String ?? ""
            let error = dictionary["error"] as? String ?? ""
            
            let objpois = dictionary["objpois"] as? String ?? ""
            let datapois = Data(objpois.utf8)
            var objPOIS = PoisFromJSON()
            do {
                objPOIS = try JSONDecoder().decode(PoisFromJSON.self, from: datapois)
                    } catch {
              // handle errors
            }
            
            return (esito, payload, warn, error, objPOIS)
        }
        else {
            print("error while processing whatToDo \(payload)")
        }
    }
    return nil
}
// DataSource
private func _posizione(_ payload:RoutePosition) -> (Double, String, String, String, SignalFromJSON, TargetFromJSON)? {
    if let value = jsHandler.callFunction(functionName: "_posizione", withData: payload, type:RoutePosition.self) {
        if value.isObject,
           let dictionary = value.toObject() as? [String:Any] {
            let esito = dictionary["esito"] as? Double ?? 0.0
            let payload = dictionary["payload"] as? String ?? ""
            let warn  = dictionary["warn"] as? String ?? ""
            let error = dictionary["error"] as? String ?? ""
            
            let objmsg3 = dictionary["msg3payload"] as? String ?? ""
            let datamsg3 = Data(objmsg3.utf8)
            var objMSG3 = SignalFromJSON()
            do {
                objMSG3 = try JSONDecoder().decode(SignalFromJSON.self, from: datamsg3)
                //PTFGIAK-MUTED print("_posizione toarea \(objMSG3.toarea[7..<999])")
                    } catch {
              // handle errors
            }
            let msg3warn = dictionary["msg3warn"] as? String ?? ""
            let msg3error = dictionary["msg3error"] as? String ?? ""
            
            
            if (objMSG3.mpsInpuType == "") {
                var objMSG3bis = EnfOfRouteFromJSON()
                do {
                    objMSG3bis = try JSONDecoder().decode(EnfOfRouteFromJSON.self, from: datamsg3)
                    if (objMSG3.mpsInpuType=="" && objMSG3bis.mpsInpuType=="gps") {
                        objMSG3 = SignalFromJSON(mpsInpuType: objMSG3bis.mpsInpuType, DEVICEID: objMSG3bis.DEVICEID, UNIXTIMESTAMP: objMSG3bis.UNIXTIMESTAMP, LATITUDE: objMSG3bis.LATITUDE, LONGITUDE: objMSG3bis.LONGITUDE, fromarea: objMSG3bis.fromarea, enteringLat: 0.0, enteringLng: 0.0, toarea: objMSG3bis.toarea, distance: objMSG3bis.distance, FLOOR: objMSG3bis.FLOOR, appdata: objMSG3bis.appdata, HEATMAPINDEX: objMSG3bis.HEATMAPINDEX, HEATMAPDEFINITION: objMSG3bis.HEATMAPDEFINITION, statusChanged: objMSG3bis.statusChanged)
                    }
                } catch {
                  // handle errors
                }
            }
            if (objMSG3.statusChanged){
                if (payload == "fuori sequenza") {
                    //print("urka!")
                    let aggols = msg3warn.split(separator: "$")
                    //print("urka urka!")
                }
                print("efesto Status Changed...\(payload)")
            }else{
                if (payload != "") {
                    if (payload == "fuori sequenza") {
                        //print("urka!")
                        let aggols = msg3warn.split(separator: "$")
                        //print("urka urka!")
                    }
                    print("efesto Status Changed...\(payload)")
                }
            }
            
            let objmsg4 = dictionary["msg4payload"] as? String ?? ""
            let datamsg4 = Data(objmsg4.utf8)
            var objMSG4 = TargetFromJSON()
            do {
                objMSG4 = try JSONDecoder().decode(TargetFromJSON.self, from: datamsg4)
            } catch {
              // handle errors
            }
            let msg4warn = dictionary["msg4warn"] as? String ?? ""
            let msg4error = dictionary["msg4error"] as? String ?? ""
            return (esito, payload, warn, error, objMSG3, objMSG4)        }
        else {
            print("error while processing _posizione \(payload)")
        }
    }
    return nil
}
//start mod#0004
// DataSource
private func goGrapher(_ pay:GrapherObj) -> (Double, GraphAttributes, String, String)? {
    if let value = jsHandler.callFunction(functionName: "_grapher", withData: pay, type:GrapherObj.self) {
        if value.isObject,
           let dictionary = value.toObject() as? [String:Any] {
            let esito = dictionary["esito"] as? Double ?? 0.0
            
            //let payload = dictionary["payload"] as? String ?? ""
        
            let objGx = dictionary["payload"] as? String ?? ""
            let dataGx = Data(objGx.utf8)
            var objGX = GraphAttributes()
            do {
                objGX = try JSONDecoder().decode(GraphAttributes.self, from: dataGx)
            } catch {
              // handle errors
            }
            
            let warn  = dictionary["warn"] as? String ?? ""
            let error = dictionary["error"] as? String ?? ""
            
            objGX.trace.append(">\(pay.action)/\(pay.subact)>\(esito)")
            grapherTrace.append(objGX.trace)
            
            if (esito > 0){
                print("_grapher \(pay.action) \(pay.subact) \(pay.nodes) \(esito)")
            }else{
                print("_grapher \(pay.action) \(pay.subact) \(pay.nodes) \(esito)")
            }
            return (esito, objGX, warn, error)
        }
        else {
            print("error while processing _grapher \(pay)")
        }
    }
    return nil
}
//end mod#0004
// DataSource
private func _getFENCE(_ payload:RouteFence) -> (Double, String, FencesFromJSON)? {
    if let value = jsHandler.callFunction(functionName: "_getFENCE", withData: payload, type:RouteFence.self) {
        if value.isObject,
           let dictionary = value.toObject() as? [String:Any] {
            let esito = dictionary["esito"] as? Double ?? 0.0
            let id = dictionary["id"] as? String ?? ""
            let objfence = dictionary["objfence"] as? String ?? ""
            let datafence = Data(objfence.utf8)
            var objFence = FencesFromJSON()
            do {
                objFence = try JSONDecoder().decode(FencesFromJSON.self, from: datafence)
            } catch {
              // handle errors
            }
            return (esito, id, objFence)        }
        else {
            print("error while processing _getFENCE \(payload)")
        }
    }
    return nil
}
// DataSource
private func _setFENCE(_ payload:RouteFence) -> (Double, String, FencesFromJSON)? {
    if let value = jsHandler.callFunction(functionName: "_setFENCE", withData: payload, type:RouteFence.self) {
        if value.isObject,
           let dictionary = value.toObject() as? [String:Any] {
            let esito = dictionary["esito"] as? Double ?? 0.0
            let id = dictionary["id"] as? String ?? ""
            let objfence = dictionary["objfence"] as? String ?? ""
            let datafence = Data(objfence.utf8)
            var objFence = FencesFromJSON()
            do {
                objFence = try JSONDecoder().decode(FencesFromJSON.self, from: datafence)
            } catch {
              // handle errors
            }
            return (esito, id, objFence)        }
        else {
            print("error while processing _setFENCE \(payload)")
        }
    }
    return nil
}
/*?@-@FuncBegin@*/
func addStringToTheArrayBottom(_ s:String,_ a:[[Any]]) -> [[Any]] {
    let tme = Date().toMillisDouble()
    if (s.count == 0) { return a }
    let n = a.count
    let m = s
    if (n>0){
        let t = String(describing: /*reflecting:*/ a[n-1][1])
        if (t.lowercased()==s.lowercased()) {
            return a
        }
    }
    var t = a
    t.append([tme,m])
    return t
}
/*?@-@FuncEnd@*/
func estraiNumero (_ dove: String, _ cosa: String, _ delimiter: String ) -> Float {
    var o1: Int = -1
    if let range1: Range<String.Index> = dove.range(of: cosa) {
        o1 = dove.distance(from: dove.startIndex, to: range1.lowerBound)
    }
    if (o1 < 0) {
       o1 = 0
    }else{
       o1 += cosa.count
    }
    let tmp = dove[o1..<o1+20]
    if (tmp.contains(delimiter)) {
        var o2: Int = 0
        if let range2: Range<String.Index> = tmp.range(of: delimiter) {
            o2 = tmp.distance(from: tmp.startIndex, to: range2.lowerBound)
        }
        let x3 = dove[o1..<o1+o2]
        if (x3=="(null)" || x3=="null" || x3 == "") {
            return Float(0.0)
        }else{
            let o3 = Double(x3)
            //print("step counter (sum) \(String(describing: o3))")
            return Float(o3!)
        }
    }else{
        if (tmp=="(null)" || tmp=="null" || tmp == "") {
            return Float(0.0)
        }else{
            //print("step counter (sum) \(tmp)")
            return Float(tmp)!
        }
    }
}
 func estraiStringa(_ dove: String, _ cosa: String, _ delimiter: String ) -> String {
     var o1: Int = -1
     if let range1: Range<String.Index> = dove.range(of: cosa) {
         o1 = dove.distance(from: dove.startIndex, to: range1.lowerBound)
     }
     if (o1 < 0) {
        o1 = 0
     }else{
        o1 += cosa.count
     }
     let tmp = dove[o1..<o1+512]
     if (tmp.contains(delimiter)) {
         var o2: Int = 0
         if let range2: Range<String.Index> = tmp.range(of: delimiter) {
             o2 = tmp.distance(from: tmp.startIndex, to: range2.lowerBound)
         }
         let x3 = dove[o1..<o1+o2]
         return x3
     }else{
         if (tmp=="(null)" || tmp=="null" || tmp == "") {
             return ""
         }else{
             //print("step counter (sum) \(tmp)")
             return tmp
         }
     }
 }
func updtSuspSignls(_ che:String , _ cosa:String ) {
    if (che.contains("on(")) {
        // remove
        if let index = status.navigatorCockpit.suspSignals.firstIndex(of: cosa) {
            print("attivato \(cosa)")
            status.navigatorCockpit.suspSignals.remove(at: index)
        }
    }else{
        if (che.contains("off(")) {
            // add
            if (!status.navigatorCockpit.suspSignals.contains(cosa)) {
                print("disattivato \(cosa)")
                status.navigatorCockpit.suspSignals.append(cosa)
            }
        }else{
            print("signal kind \(cosa) not suspended nor activated (\(che)")
        }
    }
}
public func checkRouteSegments(_ da:String, _ a:String) -> Int {
    for (i,n) in status.routeSegmentsTuning.enumerated() {
        if (da == n.da && a == n.a) {
            return i
        }
    }
    return -1
}
public func checkBeaconTuning(_ id:String) -> Int {
    for (i,n) in status.beaconsTuning.enumerated() {
        if (id == n.id) {
            return i
        }
    }
    return -1
}
func minComune (_ new:[String], _ base:[String]) -> [String] {
    var mcm:[String] = []
    for n in new {
        for b in base {
            if (n == b){
                mcm.append(n)
                break
            }
        }
    }
    return mcm
}
func fence2beacon(_ rf:String ) -> String {
    
    var beaconUnderTheFence = ""
    
        // risalgo al fence per risalire quindi ai beacon coinvolti nel percorso
        chkfence: for fa in status.fencingConfiguration {
            if (fa.id==status.selectedArea){
                for f in fa.fences {
                    if (f.id.lowercased() == rf.lowercased()
                     || f.alias.lowercased() == rf.lowercased()) {
                        
                        let _fromcoor = CLLocation(latitude: CLLocationDegrees(Float(f.lat)), longitude: CLLocationDegrees(Float(f.lng)))
                        var minraggio = CLLocationDegrees(Float(99999999))
                        for ba in status.beaconConfiguration {
                            if (ba.id==status.selectedArea){
                                //print(ba.beacon.count)
                                
                                for b in ba.beacons {
                                    
                                    let _tocoor = CLLocation(latitude: CLLocationDegrees(Float(b.lat)), longitude:  CLLocationDegrees(Float(b.lng)))
                                    let distanceInMeters = _tocoor.distance(from: _fromcoor)
                                    if (Float(distanceInMeters) <= f.radius) {
                                        if (minraggio >= distanceInMeters){
                                            minraggio = distanceInMeters
                                            
                                            beaconUnderTheFence = "\(b.mjr)-\(b.mnr)"
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                           
                        break chkfence
                    }
                }
            }
        }
    return beaconUnderTheFence
    
}
func geo2beacon(_ geo:CLLocation ) -> String {
    
    var beaconUnderTheGeoCoordinates = ""
    
    var mindistanza = CLLocationDegrees(Float(99999999))
    var fence = ""
    
        // risalgo al fence per risalire quindi ai beacon coinvolti nel percorso
        for fa in status.fencingConfiguration {
            if (fa.id==status.selectedArea){
                for f in fa.fences {
                    
                    let _tofence = CLLocation(latitude: CLLocationDegrees(Float(f.lat)), longitude:  CLLocationDegrees(Float(f.lng)))
                    let distanceInMeters = _tofence.distance(from: geo)
                    if (distanceInMeters <= Double(f.radius)) {
                        if (distanceInMeters < mindistanza) {
                            mindistanza = distanceInMeters
                            fence = f.id
                        }
                        
                    }
                }
                break
            }
        }
    
    if (fence != ""){
        beaconUnderTheGeoCoordinates = fence2beacon( fence )
    }
    return beaconUnderTheGeoCoordinates
    
}
func routePreCheckingByStart2EndPoints(_ inizio:String, _ fine:String) -> Int {
    
    
    var _numTappe = 99999
    var _routeIndex = -1
    for (nipc,ipc) in status.indicazioniPercorsi.enumerated() {
        if (ipc.id==status.selectedArea){
            //print(ipc.indicazioni.count)
            
                
                let inzfn = [inizio,fine]
                var _fnd = false
                for (nip, indicazioniPercorso) in ipc.indicazioni.enumerated() {
                    var _npt = 0
                    var _enclave = ""
                    var _baseOrdinal = 2
                    for (npt, tappa) in inzfn.enumerated() where npt > 0 {
                        // verifico se da-a sono definiti come fence
                        var _da = ""
                        var _a = ""
                        for fc in status.fencingConfiguration {
                            if (fc.id==status.selectedArea){
                                for fence in fc.fences {
                                    if (fence.id.contains(inzfn[npt-1])) {
                                        _da = fence.alias
                                    }
                                    if (fence.id.contains(inzfn[npt])) {
                                        _a = fence.alias
                                    }
                                    if (_da != "" && _a != "") { break }
                                }
                                if (_da != "" && _a != "") { break }
                            }
                            if (_da != "" && _a != "") { break }
                        }
                        // se da-a esistono come fence ... allora ....
                        if (_da != "" && _a != ""){
                            for (nipso,indicazionePercorso) in indicazioniPercorso.enumerated() {
                                if (indicazionePercorso.from == "WILD" && indicazionePercorso.to == "WILD"){
                                    // nothing to do
                                }else{
                                    if (_enclave == ""
                                        && indicazionePercorso.from == "WILD"
                                        && indicazionePercorso.to != "WILD"){
                                        _enclave = indicazionePercorso.to
                                    }else{
                                        if (indicazionePercorso.from == _enclave
                                            && indicazionePercorso.to == _da){
                                            _enclave = "!£$%&/()=?^"  // lo conto solo una volta
                                            _npt += 1
                                        }else{
                                            if (_enclave == "!£$%&/()=?^" &&
                                                indicazionePercorso.to == _a){
                                                
                                                
                                                
                                                _npt += 2
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        _baseOrdinal += (npt * (npt+2))
                        print("route checking \(_npt) \(nip) \(_fnd) \(inizio) \(fine)")
                        if (_npt == 3){
                            _routeIndex = nip
                            _fnd = true
                            break
                        }
                    }
                    if (_fnd){
                        break
                    }
                }
                if (_fnd){
                    break
                }
                
            
        }
    }
    
    print("route checking \(inizio) \(fine) \(_routeIndex)")
    return _routeIndex
    
}
func catchNotificationRoute(notification:Notification) -> Void {
  guard let name = notification.userInfo!["name"] else { return }
    
    //PTFGIAK-MUTED print("xx20 \(name)")
    
    let cms = Date().toMillis()
    if (cms! < status.efestoForcedDelay) {
        return
    }
    
    threadSafeNotificationRoute.lock()
    segnali: do{
    
        status.navigatorCockpit.c.comando = estraiStringa(name as! String, "cmd=", ",")
        if (status.navigatorCockpit.c.comando=="go") {
            status.navigatorCockpit.c.utente = "Mauro"
            status.navigatorCockpit.c.percorso = name as! String
            status.navigatorCockpit.c.ver = "100"
            status.navigatorCockpit.c.ms = 0
            status.navigatorCockpit.c.LATITUDE = 0.0
            status.navigatorCockpit.c.LONGITUDE = 0.0
            status.navigatorCockpit.c._PATH = []
                
            ////////////////////////////////////////////////////////////////////////////
            if (status.navigatorCockpit.c.comando == "go"
             || status.navigatorCockpit.c.comando == "richiamosonoro"
             || status.navigatorCockpit.c.comando == "skip"){
                print("comando: \(status.navigatorCockpit.c.comando)")
                }else{
                    print("comando invalido: \(status.navigatorCockpit.c.comando)")
                    status.navigatorCockpit.c.comando = "skip"
                }
            
            var locapath = estraiStringa(status.navigatorCockpit.c.percorso, ",", ",")
            var mainpath = estraiStringa(status.navigatorCockpit.c.percorso, ">", "@")
            var subpath = estraiStringa(status.navigatorCockpit.c.percorso, "@", "<")
            
            
            
            // ---- **** ---- **** ---- **** ---- **** ---- **** ---- **** ---- **** ---- ****
            
            
            
            
            // ---- **** ---- **** ---- **** ---- **** ---- **** ---- **** ---- **** ---- ****
            
            
            
            if (status.md5js==""){
                // attivazine efesto.js
                if let javascriptUrl = Bundle.main.url(forResource: "efesto", withExtension: "js") {
                    jsHandler.loadSourceFile(atUrl: javascriptUrl, "")
                    /*?@-@FuncBegin@*/
                    status.md5js = "done"
                    /*?@-@FuncEnd@*/
                }
            }
            
            
            
            
            var slogga = "a$b$c"
            
            //let aggols = slogga.replacingOccurrences(of: "$", with: "\n", options: .literal, range: nil)
            let aggols = slogga.split(separator: "$")
            //let aggols = "Line 1 \n Line 2 \n\r"
            //let result = aggols.filter { !$0.isWhitespace }
            
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            
            
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            
            var _numTappe = 99999
            var _routeIndex = 0
            for (nipc,ipc) in status.indicazioniPercorsi.enumerated() {
                if (ipc.id==status.selectedArea){
                    //print(ipc.indicazioni.count)
                    
                        
                        
                    
                        var fnd = false
                        for (nip, indicazioniPercorso) in ipc.indicazioni.enumerated() {
                            var _npt = 0
                            var _enclave = ""
                            var _baseOrdinal = 2
                            for (npt, tappa) in status.percorsoTecnico.enumerated() where npt > 0 {
                                // verifico se da-a sono definiti come fence
                                var _da = ""
                                var _a = ""
                                for fc in status.fencingConfiguration {
                                    if (fc.id==status.selectedArea){
                                        for fence in fc.fences {
                                            if (fence.id.contains(status.percorsoTecnico[npt-1])) {
                                                _da = fence.alias
                                            }
                                            if (fence.id.contains(status.percorsoTecnico[npt])) {
                                                _a = fence.alias
                                            }
                                            if (_da != "" && _a != "") { break }
                                        }
                                        if (_da != "" && _a != "") { break }
                                    }
                                    if (_da != "" && _a != "") { break }
                                }
                                // se da-a esistono come fence ... allora ....
                                if (_da != "" && _a != ""){
                                    for (nipso,indicazionePercorso) in indicazioniPercorso.enumerated() {
                                        if (indicazionePercorso.from == "WILD" && indicazionePercorso.to == "WILD"){
                                            // nothing to do
                                        }else{
                                            if (_enclave == ""
                                                && indicazionePercorso.from == "WILD"
                                                && indicazionePercorso.to != "WILD"){
                                                _enclave = indicazionePercorso.to
                                            }else{
                                                if (indicazionePercorso.from == _enclave
                                                    && indicazionePercorso.to == _da){
                                                    _enclave = "!£$%&/()=?^"  // lo conto solo una volta
                                                    _npt = (npt * nipso)
                                                    //break
                                                }else{
                                                    if (_enclave == "!£$%&/()=?^" &&
                                                        indicazionePercorso.from == _da && indicazionePercorso.to == _a){
                                                        
                                                        //moltiplicare x ordinale >> npt e nipso
                                                        _npt += (npt * nipso)
                                                        break
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                _baseOrdinal += (npt * (npt+2))
                            }
                            print(_baseOrdinal)
                            print(_npt)
                            print(status.percorsoTecnico.count)
                            if (_npt == _baseOrdinal) {
                                
                                print("route found \(_npt) \(nip) \(_numTappe) \(indicazioniPercorso.count)")
                                if (_numTappe > indicazioniPercorso.count){
                                    print("route replaced \(_npt) \(_routeIndex) \(nip) \(_numTappe) \(indicazioniPercorso.count)")
                                    _numTappe = indicazioniPercorso.count
                                    _routeIndex = nip
                                    
                                }
            
                                print("forced route index \(_routeIndex) \(_npt) \(status.percorsoTecnico.count)")
                                fnd = true
                                
                            }else{
                            }
                        }
                        if (!fnd){
                            status.forceExit = 1
                        }
                    
                }
            }
            print("selected route index \(_routeIndex)")
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            
            
            
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            // rework the input
            let area = estraiStringa(status.navigatorCockpit.c.percorso, ",", ",>")
            let da = estraiStringa(status.navigatorCockpit.c.percorso, ">", "@")
            let a = estraiStringa(status.navigatorCockpit.c.percorso, "@", "<")
            // ATTENZIONE !!!!!!!!
            // nel caso venga attuata la definizione automatica dei percorsi vs efesto occorre
            // fare attenzione che il percorso è identificato dall'insieme "da a" separati da BLANK !!!
            status.navigatorCockpit.c.pathInPlace = "\(da) \(a)"
            status.bonr = []
            status.bonr_shadow = []
            
            
            status.navigatorCockpit.c.percorso = "\(area)-\(da)_\(a)"
            print("activating route vs efesto \(status.navigatorCockpit.c.percorso)")
            
            
            var _poi = POI(number: "", id: "", name: "")
            var _poiFence = PoiFence(lat: 0.0, lng: 0.0, radius: 0.0, desc: "")
            var _routeSettings = RouteSettings(what: "set", environmentID: "", enclave: "", routeFromToNames: "", msg000A: "0A mancante", msg000B: "0B mancante", msg999A: "9A mancante", POIs: [_poiFence], routePOIs: [_poi], msgs: [""])
            // TEST ONLY !!!
            //_routeSettings.what = "test"
            // !!!! ATTENTION !!! uncommenting the above instruction the external setting is not in place !!!
            
            _routeSettings.environmentID = status.selectedArea
            _routeSettings.routeFromToNames = "\(da) \(a)"
            _routeSettings.msg999A = "hai raggiunto la destinazione selezionata."
            var _cecarell = false
            for (nipc,ipc) in status.indicazioniPercorsi.enumerated() {
                if (ipc.id==status.selectedArea){
                    //print(ipc.indicazioni[_routeIndex])
                    for indicazionePercorso in ipc.indicazioni[_routeIndex] {
                        print("en \(_routeSettings.enclave) pf \(indicazionePercorso.from) pt \(indicazionePercorso.to)")
                        if (indicazionePercorso.from == "WILD" && indicazionePercorso.to == "WILD"){
                            _routeSettings.msg000A = indicazionePercorso.msg[0].text
                        }else{
                            if (indicazionePercorso.from == "WILD" && indicazionePercorso.to != "WILD"){
                                _routeSettings.msg000B = indicazionePercorso.msg[0].text
                                _routeSettings.enclave = indicazionePercorso.to
                            }else{
                                if (indicazionePercorso.from == _routeSettings.enclave && indicazionePercorso.to != "WILD"){
                                    //none to do here
                                    _cecarell = true
                                    break
                                }else{
                                    //none to do here
                                }
                            }
                        }
                    }
                    if (_cecarell){
                        break
                    }
                }
            }
            
            _routeSettings.POIs = []
            _routeSettings.routePOIs = []
            _routeSettings.msgs = []
            //print(status.percorsoTecnico)
            var progressivo = 0
            var prevAlias = ""
            var _npt = 0
            //print(status.percorsoSelezionato)
            //print(status.percorsoTecnico)
            for (npt, tappa) in status.percorsoTecnico.enumerated() {
                for fc in status.fencingConfiguration {
                    if (fc.id==status.selectedArea){
                        for fence in fc.fences {
                            if (fence.id.contains(tappa)) {
                                _poiFence.lat = fence.lat
                                _poiFence.lng = fence.lng
                                _poiFence.radius = fence.radius
                                _poiFence.desc = fence.alias
                                _routeSettings.POIs.append(_poiFence)
                                _poi.number = String(progressivo)
                                while(_poi.number.count<3) { _poi.number = "0\(_poi.number)" }
                                _poi.id = fence.alias
                                _poi.name = tappa
                                _routeSettings.routePOIs.append(_poi)
                                var added = false
                                var testo = "testo #\(progressivo) mancante"
                                for (nipc,ipc) in status.indicazioniPercorsi.enumerated() {
                                    if (ipc.id==status.selectedArea) {
                                        print("trce 1 route index \(ipc.indicazioni[_routeIndex])")
                                        for indicazionePercorso in ipc.indicazioni[_routeIndex] {
                                            print("trce 2 indicazionePercorso \(indicazionePercorso)")
                                            print("trce 3 _npt \(_npt) indicazionePercorso.from \(indicazionePercorso.from) _routeSettings.enclave \(_routeSettings.enclave) indicazionePercorso.to \(indicazionePercorso.to) fence.alias \(fence.alias)")
                                            if (_npt==0 && indicazionePercorso.from == _routeSettings.enclave && indicazionePercorso.to == fence.alias){
                                                print("trce 3+ _npt \(_npt) indicazionePercorso.from \(indicazionePercorso.from) _routeSettings.enclave \(_routeSettings.enclave) indicazionePercorso.to \(indicazionePercorso.to) fence.alias \(fence.alias)")
                                                testo = indicazionePercorso.msg[0].text
                                                _routeSettings.msgs.append(testo)
                                                _npt += 1
                                                added = true
                                                break
                                            }else{
                                                print("trce 4 _npt \(_npt) prevAlias \(prevAlias) _routeSettings.enclave \(_routeSettings.enclave) indicazionePercorso.to \(indicazionePercorso.to) fence.alias \(fence.alias)")
                                                if (prevAlias == indicazionePercorso.from && indicazionePercorso.to == fence.alias) {
                                                    print("trce 4+ _npt \(_npt) prevAlias \(prevAlias) _routeSettings.enclave \(_routeSettings.enclave) indicazionePercorso.to \(indicazionePercorso.to) fence.alias \(fence.alias)")
                                                    testo = indicazionePercorso.msg[0].text
                                                    _routeSettings.msgs.append(testo)
                                                    _npt += 1
                                                    added = true
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }
                                if (!added) {
                                    _routeSettings.msgs.append(testo)
                                    status.forceExit = 2
                                }
                                prevAlias = fence.alias
                                
                                
                                
                                progressivo += 1
                            }
                        }
                    }
                }
            }
            print("setRouteing \(_routeSettings)")
            let _ap = setROUTE(_routeSettings)
            status.navigatorCockpit.c.esitoCreazionePercorso = Int(_ap!.0)
            status.navigatorCockpit.c.motivoCreazionePercorso = "\(_ap!.1)/\(_ap!.2)"
            
            
            let envSettings = EnvironmentSettings(what:"initialize",environmentID: "UNIPVSP")
            
            let _fc = setCTLS(envSettings)
            
            let _payload = RouteStart(comando: status.navigatorCockpit.c.comando, utente: status.navigatorCockpit.c.utente, percorso: status.navigatorCockpit.c.percorso, ver: status.navigatorCockpit.c.ver )
            let fc = _whatToDo(_payload)
            print(" after _whatToDo \(fc)")
            status.navigatorCockpit.c.esitoAttivazione = Int(fc!.0)
            status.navigatorCockpit.c.motivoAttivazione = "\(fc!.2)/\(fc!.3)"
            
            //status.efestoForcedDelay = Int64(Date().toMillis() + 5000) // delay before next operation
            
            if (status.navigatorCockpit.c.esitoAttivazione == 0){
                print("segnalo esito positivo \(status.navigatorCockpit.c.esitoAttivazione)")
                status.jsRTEhandler = true
                
                status.routePois = fc!.4.poi
                
                for (np,p) in status.routePois.enumerated() {
                    
                    chkfence0: for fa in status.fencingConfiguration {
                        if (fa.id==status.selectedArea){
                            for f in fa.fences {
                                
                                if (f.id.lowercased() == p.lowercased()
                                 || f.alias.lowercased() == p.lowercased()) {
                                    
                                    
                                    status.fonr.append(f.id)
                                    let _fromcoor = CLLocation(latitude: CLLocationDegrees(Float(f.lat)), longitude: CLLocationDegrees(Float(f.lng)))
                                    var minraggio = CLLocationDegrees(Float(99999999))
                                    var beaconUnderTheFence = ""
                                    
                                    // inserisco tutti i beacon che rientrano nel fence target
                                    for ba in status.beaconConfiguration {
                                        if (ba.id==status.selectedArea){
                                            //print(ba.beacon.count)
                                            
                                            for b in ba.beacons {
                                                
                                                let _tocoor = CLLocation(latitude: CLLocationDegrees(Float(b.lat)), longitude:  CLLocationDegrees(Float(b.lng)))
                                                let distanceInMeters = _tocoor.distance(from: _fromcoor)
                                                if (Float(distanceInMeters) <= f.radius) {
                                                    if (minraggio >= distanceInMeters){
                                                        minraggio = distanceInMeters
                                                        
                                                        beaconUnderTheFence = "\(b.mjr)-\(b.mnr)"
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                    }
                                    
                                    if (beaconUnderTheFence=="") {
                                        //print("fence/beacon trovati ma fuori range")
                                    }else{
                                    
                                        
                                        if (np == 0) { // on the first !!!
                                            status.butf.append(beaconUnderTheFence)
                                        }else{
                                            // ex status.bnutf.append(beaconUnderTheFence)
                                            /* ex novo */
                                            if (status.bnutf.firstIndex(of: beaconUnderTheFence) ?? -1 < 0){
                                                if (status.butf.firstIndex(of: beaconUnderTheFence) ?? -1 < 0){
                                                    status.bnutf.append(beaconUnderTheFence)
                                                }
                                            }
                                            /* ex novo */
                                        }
                                        
                                        status.bonr.append(beaconUnderTheFence)
                                        status.bonr_shadow.append("4,99,-100") // prx|near|far|wild + distance + intensity
                                        
                                    }
                                       
                                    break chkfence0
                                }
                            }
                            print("segnalo anomalia #0 fence \(p) not in the fencing configuration profile")
                            status.forceExit = 3
                        }
                    }
                }
            }else{
                print("segnalo esito non positivo \(status.navigatorCockpit.c.esitoAttivazione)")
            }
        
            
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
        }else{
            
            // intended to overcome (temporarely i mean) the unpass generated by efesto at the
            // out-of-sequence event (due to unknown reason so far) and the resulting lockin
            if (status.navigatorCockpit.suspSignals.contains(status.navigatorCockpit.c.comando.lowercased())) {
                print("signal \(status.navigatorCockpit.c.comando) dropped due to suspend status")
                threadSafeNotificationRoute.unlock()
                return
            }
            
            
            
                
                if (status.modalita==NSLocalizedString("pre-simulation", comment: "")) {
                    let now = Date().toMillisDouble()
                    if (status.shakedDevice > 0) {
                        //print("ok avanti savoia")
                        print("Route Signal Notification accepted due to shaked device in Pre-Simulation Mode \(name)")
                    }else{
                        print("Route Signal Notification dropped due to Pre-Simulation Mode \(name)")
                        status.navigatorCockpit.c.testoSegnale = addStringToTheArrayBottom( "ori-msg-M0003", status.navigatorCockpit.c.testoSegnale)
                        break segnali
                    }
                }
                
                
            
            print("show navigatorCockpit.c.comando \(status.navigatorCockpit.c.comando)")
            if (status.navigatorCockpit.c.comando=="PRX") {
                
                status.navigatorCockpit.c.ms = Date().toMillis()
                let mjr = estraiNumero(name as! String, ">", "@1")
                let mnr = estraiNumero(name as! String, "@1", "@2")
                let lat = estraiNumero(name as! String, "@2", "@3")
                let lng = estraiNumero(name as! String, "@3", "@4")
                let floor = estraiNumero(name as! String, "@4", "@5")
                let distance = estraiNumero(name as! String, "@5", "@6")
                let meters = estraiNumero(name as! String, "@6", "@7")
                let intensity = estraiNumero(name as! String, "@7", "@8")
                let distance2 = estraiNumero(name as! String, "@8", "<")
                print("cmd=PRX,UNQKK,>\(mjr)@1\(mnr)@2\(lat)@3\(lng)@4\(floor)@5\(distance)@6\(meters)@7\(intensity)@8\(distance2)<")
                // mjr, mnr,lat,lng,floor,distance,meters,intensity,distance2
                
                let currBeacon = "\(mjr)-\(mnr)"
                status.navigatorCockpit.c.LATITUDE = lat
                status.navigatorCockpit.c.LONGITUDE = lng
                status.navigatorCockpit.c.FLOOR = Int(floor)
                
                let _payload = RoutePosition(USERID: "unknown", DEVICEID: "TESTV01XX", UNIXTIMESTAMP: Date().toMillis(), LATITUDE: status.navigatorCockpit.c.LATITUDE, LONGITUDE : status.navigatorCockpit.c.LONGITUDE, FLOOR: status.navigatorCockpit.c.FLOOR, mpsInpuType: "gps", HEATMAPDEFINITION: 5, HEATMAPINDEX: 12)
                let fc = _posizione(_payload)
                
                // efesto gestisce l'associazione geo coordinate vs fence (ingresso, uscita, permanenza)
                // è quindi efesto che ritorna l'info di quale fence è innescata da una geo posizione (gps, beacon, altrimenti derivata che sia)
                
                let _stat = fc?.4.statusChanged
                
                status.navigatorCockpit.c.esitoSegnale = Int(fc!.0)
                status.navigatorCockpit.c.motivoSegnale = "\(fc!.2)/\(fc!.3)"
                
                if (status.navigatorCockpit.c.esitoSegnale>0){
                    print("hai hai \(status.navigatorCockpit.c.esitoSegnale)")
                }else{
                    if (_stat == false) {
                        var _from = ""
                        if ((fc?.4.fromarea.count)! > 0) {
                            _from = String((fc?.4.fromarea)!)[7..<999]
                        }
                        var _to = ""
                        if ((fc?.4.toarea.count)! > 0) {
                            _to = String((fc?.4.toarea)!)[7..<999]
                        }
                        if (_from != _to){
                            status.routeSegmentF2FUnderTheFocus = [_from,_to]
                        }
                        status.navigatorCockpit.c.testoSegnale = addStringToTheArrayBottom( fc!.1, status.navigatorCockpit.c.testoSegnale)
                    }
                }
                
                dai1: if (_stat == true) {
                    //status.efestoForcedDelay = Int64(Date().toMillis() + 2000) // delay before next operation
                    // step by step advancing until new status change
                    if (status.shakedDevice > 0) {
                        status.shakedDevice += -1
                        AudioServicesPlaySystemSound (codifiedSounds[routeSignalsDroppedDueToManualTuningOn])
                    }
                    
                    if ((fc?.4.fromarea.count)! > 0 && fc?.4.toarea.count == 0) {
                        // fine route !!
                        status.navigatorCockpit.c.esitoSegnale = Int(fc!.0)
                        status.navigatorCockpit.c.testoSegnale = addStringToTheArrayBottom( fc!.1, status.navigatorCockpit.c.testoSegnale)
                        status.navigatorCockpit.c.motivoSegnale = "\(fc!.2)/\(fc!.3)"
                        
                        status.routeSegmentF2FUnderTheFocus = []
                        
                        break dai1
                    }
                    
                    //========================================================================================
                    
                    // tolgo il beacon che ha innescato il cambio di status
                    // per poi eventualmente rimettercelo mai fosse under the current fence
                    if (status.butf.firstIndex(of: currBeacon) ?? -1 >= 0){
                        /*
                        if (currBeacon=="4.0-42.0"){
                            print("\(status.butf)")
                            print("\(status.bnutf)")
                            print("deleted from butf beacon \(currBeacon)")
                        }
                        */
                        status.butf.delete(element: currBeacon)
                        if (status.bnutf.firstIndex(of: currBeacon) ?? -1 < 0){
                            status.bnutf.append(currBeacon)
                        }
                    }
                    
                    //========================================================================================
                    
                    
                    
                    let _from = String((fc?.4.fromarea)!)[7..<999]
                    let _to = String((fc?.4.toarea)!)[7..<999]
                    
                    status.routeSegmentF2FUnderTheFocus = [_from,_to]
                    
                    
                    let _pay3 = RouteFence(id: _to, lat: 0.0, lng: 0.0, type: "fence", radius: 0.0, desc: "zzzz", xid: "123456ABCDEF")
                    let _fc3 = _getFENCE(_pay3)
                    
                    // dal fence risalgo al beacon
                    chkfence1: for fa in status.fencingConfiguration {
                        if (fa.id==status.selectedArea){
                            for f in fa.fences {
                                if (f.id.lowercased() == _to.lowercased()
                                 || f.alias.lowercased() == _to.lowercased()) {
                                    
                                    
                                    let _fromcoor = CLLocation(latitude: CLLocationDegrees(Float(f.lat)), longitude: CLLocationDegrees(Float(f.lng)))
                                    var minraggio = CLLocationDegrees(Float(99999999))
                                    var beaconUnderTheFence = ""
                                    
                                    // inserisco tutti i beacon che rientrano nel fence target
                                    for ba in status.beaconConfiguration {
                                        if (ba.id==status.selectedArea){
                                            //print(ba.beacon.count)
                                            
                                            for b in ba.beacons {
                                                
                                                let _tocoor = CLLocation(latitude: CLLocationDegrees(Float(b.lat)), longitude:  CLLocationDegrees(Float(b.lng)))
                                                let distanceInMeters = _tocoor.distance(from: _fromcoor)
                                                if (Float(distanceInMeters) <= f.radius) {
                                                    if (minraggio >= distanceInMeters){
                                                        minraggio = distanceInMeters
                                                        
                                                        beaconUnderTheFence = "\(b.mjr)-\(b.mnr)"
                                                    }
                                                    
                                                }else{
                                                    //tutti i beacon not under the focus of the next fence are muted !!
                                                    let beaconNOTUnderTheFence = "\(b.mjr)-\(b.mnr)"
                                                    if (status.bnutf.firstIndex(of: beaconNOTUnderTheFence) ?? -1 < 0){
                                                        status.bnutf.append(beaconNOTUnderTheFence)
                                                    }
                                                }
                                                
                                            }
                                            
                                        }
                                    }
                                    
                                    if (beaconUnderTheFence=="") {
                                        //print("fence/beacon trovati ma fuori range")
                                    }else{
                                    
                                        
                                        // declare this beacon under the focus
                                        if (status.butf.firstIndex(of: beaconUnderTheFence) ?? -1 < 0){
                                            status.butf.append(beaconUnderTheFence)
                                        }
                                        if (status.bnutf.firstIndex(of: beaconUnderTheFence) ?? -1 >= 0){
                                            status.bnutf.delete(element: beaconUnderTheFence)
                                        }
                                    }
                                       
                                    break chkfence1
                                }
                            }
                            print("segnalo anomalia #1 fence \(_to) not in the fencing configuration profile")
                            status.forceExit = 4
                        }
                    }
                    
                    //========================================================================================
                    
                    status.navigatorCockpit.c.esitoSegnale = Int(fc!.0)
                    status.navigatorCockpit.c.testoSegnale = addStringToTheArrayBottom( fc!.1, status.navigatorCockpit.c.testoSegnale)
                    status.navigatorCockpit.c.motivoSegnale = "\(fc!.2)/\(fc!.3)"
                    //========================================================================================
                    
                    //========================================================================================
                    
                    // check all fencing swift side to update the scene
                    
                    // attivazione / disattivazine dei segnali a livello di fencing (figata se funziona)
                    chkfence2: for fa in status.fencingConfiguration {
                        if (fa.id==status.selectedArea){
                            for f in fa.fences {
                                if (f.id.lowercased() == _from.lowercased()
                                 || f.alias.lowercased() == _from.lowercased()) {
                                    if (f.ftrsSts.ent.count > 0) {
                                        for x in f.ftrsSts.ent {
                                            if (x.contains("prx")) {
                                                updtSuspSignls(x,"prx")
                                            }else{
                                                
                                                        if (x.contains("shk")) {
                                                            updtSuspSignls(x,"shk")
                                                        }else{
                                                            print("unmanaged feature on entering a fence \(x)")
                                                        }
                                                
                                            }
                                        }
                                    }
                                    break chkfence2
                                }
                            }
                        }
                    }
                    
                    //========================================================================================
                    
                }
                
                // devo anche gestire lato fencing sia verifica e quindi attivo / disattivo features come da eventuali attributi del beacon
            }else{
                
                
                if (
                    status.navigatorCockpit.c.comando=="GEO") {
                    status.navigatorCockpit.c.ms = Date().toMillis()
                    var lat = estraiNumero(name as! String, ">", "@1")
                    var lng = estraiNumero(name as! String, "@1", "<")
                    print("cmd=\(status.navigatorCockpit.c.comando),UNQKK,>\(lat)@\(lng)<")
                    // ptf giak
                    let loc = CLLocation( latitude: CLLocationDegrees(Float(lat)), longitude: CLLocationDegrees(Float(lng)))
                    var currBeacon = geo2beacon(loc) // "x.xx-x.x" // "\(mjr)-\(mnr)" //devo risalire al fence/beacon più prossimo if any
                    
                    status.navigatorCockpit.c.LATITUDE = lat
                    status.navigatorCockpit.c.LONGITUDE = lng
                    status.navigatorCockpit.c.FLOOR = 0
                    
                    
                    let _payload = RoutePosition(USERID: "unknown", DEVICEID: "TESTV01XX", UNIXTIMESTAMP: Date().toMillis(), LATITUDE: status.navigatorCockpit.c.LATITUDE, LONGITUDE : status.navigatorCockpit.c.LONGITUDE, FLOOR: status.navigatorCockpit.c.FLOOR, mpsInpuType: "gps", HEATMAPDEFINITION: 5, HEATMAPINDEX: 12)
                    let fc = _posizione(_payload)
                    
                    
                    
                    let _stat = fc?.4.statusChanged
                    
                    status.navigatorCockpit.c.esitoSegnale = Int(fc!.0)
                    status.navigatorCockpit.c.motivoSegnale = "\(fc!.2)/\(fc!.3)"
                    
                    if (status.navigatorCockpit.c.esitoSegnale>0){
                        print("hai hai \(status.navigatorCockpit.c.esitoSegnale)")
                    }else{
                        if (_stat == false) {
                            var _from = ""
                            if ((fc?.4.fromarea.count)! > 0) {
                                _from = String((fc?.4.fromarea)!)[7..<999]
                            }
                            if (_from != ""){
                                let b = fence2beacon(_from)
                                if (b != "") {
                                    currBeacon = b
                                }
                            }
                            var _to = ""
                            if ((fc?.4.toarea.count)! > 0) {
                                _to = String((fc?.4.toarea)!)[7..<999]
                            }
                            if (_from != _to){
                                status.routeSegmentF2FUnderTheFocus = [_from,_to]
                            }
                            status.navigatorCockpit.c.testoSegnale = addStringToTheArrayBottom( fc!.1, status.navigatorCockpit.c.testoSegnale)
                        }
                    }
                    dai2: if (_stat == true) {
                        //status.efestoForcedDelay = Int64(Date().toMillis() + 2000) // delay before next operation
                        // step by step advancing until new status change
                        if (status.shakedDevice > 0) {
                            status.shakedDevice += -1
                            AudioServicesPlaySystemSound (codifiedSounds[routeSignalsDroppedDueToManualTuningOn])
                        }
                        
                        if ((fc?.4.fromarea.count)! > 0 && fc?.4.toarea.count == 0) {
                            // fine route !!
                            status.navigatorCockpit.c.esitoSegnale = Int(fc!.0)
                            status.navigatorCockpit.c.testoSegnale = addStringToTheArrayBottom( fc!.1, status.navigatorCockpit.c.testoSegnale)
                            status.navigatorCockpit.c.motivoSegnale = "\(fc!.2)/\(fc!.3)"
                            status.routeSegmentF2FUnderTheFocus = []
                            
                            break dai2
                        }
                        
                        //========================================================================================
                        
                        // tolgo il beacon che ha innescato il cambio di status
                        // per poi eventualmente rimettercelo mai fosse under the current fence
                        if (status.butf.firstIndex(of: currBeacon) ?? -1 >= 0){
                            status.butf.delete(element: currBeacon)
                            if (status.bnutf.firstIndex(of: currBeacon) ?? -1 < 0){
                                status.bnutf.append(currBeacon)
                            }
                        }
                        
                        
                        //========================================================================================
                        
                        let _from = String((fc?.4.fromarea)!)[7..<999]
                        let _to = String((fc?.4.toarea)!)[7..<999]
                        
                        status.routeSegmentF2FUnderTheFocus = [_from,_to]
                        
                        
                        let _pay3 = RouteFence(id: _to, lat: 0.0, lng: 0.0, type: "fence", radius: 0.0, desc: "zzzz", xid: "123456ABCDEF")
                        let _fc3 = _getFENCE(_pay3)
                        
                        
                        // risalgo al fence per risalire quindi ai beacon coinvolti nel percorso
                        chkfence2: for fa in status.fencingConfiguration {
                            if (fa.id==status.selectedArea){
                                for f in fa.fences {
                                    if (f.id.lowercased() == _to.lowercased()
                                     || f.alias.lowercased() == _to.lowercased()) {
                                        
                                        
                                        let _fromcoor = CLLocation(latitude: CLLocationDegrees(Float(f.lat)), longitude: CLLocationDegrees(Float(f.lng)))
                                        var minraggio = CLLocationDegrees(Float(99999999))
                                        var beaconUnderTheFence = ""
                                        
                                        // inserisco tutti i beacon che rientrano nel fence target
                                        for ba in status.beaconConfiguration {
                                            if (ba.id==status.selectedArea){
                                                //print(ba.beacon.count)
                                                
                                                for b in ba.beacons {
                                                    
                                                    let _tocoor = CLLocation(latitude: CLLocationDegrees(Float(b.lat)), longitude:  CLLocationDegrees(Float(b.lng)))
                                                    let distanceInMeters = _tocoor.distance(from: _fromcoor)
                                                    if (Float(distanceInMeters) <= f.radius) {
                                                        if (minraggio >= distanceInMeters){
                                                            minraggio = distanceInMeters
                                                            
                                                            beaconUnderTheFence = "\(b.mjr)-\(b.mnr)"
                                                        }
                                                        
                                                    }else{
                                                        //tutti i beacon not under the focus of the next fence are muted !!
                                                        let beaconNOTUnderTheFence = "\(b.mjr)-\(b.mnr)"
                                                        if (status.bnutf.firstIndex(of: beaconNOTUnderTheFence) ?? -1 < 0){
                                                            status.bnutf.append(beaconNOTUnderTheFence)
                                                        }
                                                    }
                                                    
                                                }
                                                
                                            }
                                        }
                                        
                                        if (beaconUnderTheFence=="") {
                                            //print("fence/beacon trovati ma fuori range")
                                        }else{
                                            
                                        
                                            // declare this beacon under the focus
                                            if (status.butf.firstIndex(of: beaconUnderTheFence) ?? -1 < 0){
                                                status.butf.append(beaconUnderTheFence)
                                            }
                                            if (status.bnutf.firstIndex(of: beaconUnderTheFence) ?? -1 >= 0){
                                                status.bnutf.delete(element: beaconUnderTheFence)
                                            }
                                        }
                                           
                                        break chkfence2
                                    }
                                }
                                print("segnalo anomalia #2 fence \(_to) not in the fencing configuration profile")
                                status.forceExit = 5
                            }
                        }
                        //========================================================================================
                        
                        status.navigatorCockpit.c.esitoSegnale = Int(fc!.0)
                        status.navigatorCockpit.c.testoSegnale = addStringToTheArrayBottom( fc!.1, status.navigatorCockpit.c.testoSegnale)
                        status.navigatorCockpit.c.motivoSegnale = "\(fc!.2)/\(fc!.3)"
                        //========================================================================================
                        
                        //========================================================================================
                        
                        
                        // check all fencing swift side to update the scene
                        
                        // attivazione / disattivazine dei segnali a livello di fencing (figata se funziona)
                        chkfence3: for fa in status.fencingConfiguration {
                            if (fa.id==status.selectedArea){
                                for f in fa.fences {
                                    if (f.id.lowercased() == _from.lowercased()
                                     || f.alias.lowercased() == _from.lowercased()) {
                                        if (f.ftrsSts.ent.count > 0) {
                                            for x in f.ftrsSts.ent {
                                                if (x.contains("prx")) {
                                                    updtSuspSignls(x,"prx")
                                                }else{
                                                    
                                                            if (x.contains("shk")) {
                                                                updtSuspSignls(x,"shk")
                                                            }else{
                                                                print("unmanaged feature on entering a fence \(x)")
                                                            }
                                                    
                                                }
                                            }
                                        }
                                        break chkfence3
                                    }
                                }
                            }
                        }
                        
                        //========================================================================================
                    }
                    
                }else{
                    
                    print("di più nin sò")
                }
                
            }
            
        }
        
    }
    threadSafeNotificationRoute.unlock()
    //print("butf \(status.butf)")
    //print("bnutf \(status.bnutf)")
}
func getFenceID( area:String, alias:String ) -> String {
    for fa in status.fencingConfiguration {
        if (fa.id==area){
            for f in fa.fences {
                if (f.alias.lowercased() == alias.lowercased()) {
                    return f.id.replacingOccurrences(of: "\(area) ", with: "")
                }
            }
        }
    }
    return ""
}
func catchNotificationForOrientation(notification:Notification) -> Void {
  guard let name = notification.userInfo!["name"] else { return }
    
    
    //print("My name, \(name) has been passed! 😄");
    // ATTENZIONE ... pay attention .. please !!!
    
    // this routine is invoked directly by the notification emitter and data gathered
    //  are pumped versus the signal processor throught the retrievedDATA area
    // being other data also pumped vs the signal processor the data format is shared
    // among different process/flows ...
    // for this reason pay attention to which source & format you must be in sync
    
    let __oggi = Date()
    let __formatter = DateFormatter()
    __formatter.timeZone = TimeZone.current
    //formatter.dateFormat = "yyyy-MM-dd HH:mm"
    __formatter.dateFormat = "yyyy-MM-dd"
    let __dateString = __formatter.string(from: __oggi)
    //print(__dateString)
    
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSS"
    //formatter.dateFormat = "HH:mm:ss.SSSZ"
    //formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    let timestamp = formatter.string(from: Date())
    
        
        if ((name as AnyObject).contains("CLBeacon ")){
            
            
            if (status.navigatorCockpit.suspSignals.contains("prx")) {
                print("signal prx dropped due to suspend status")
                return }
            
            let newName99 = (name as AnyObject).replacingOccurrences(of: "skahfaksg", with: "")
            let sentdata = "\(timestamp): \(newName99)"
            
            // memo to skip messaggi se beacon estraneo
            
            // estraggo riferimenti minimi del beacon
             
            let uuid = sentdata[29..<65]
            let o1 = estraiNumero( sentdata, " major:", ",")
            let o2 = estraiNumero( sentdata, " minor:", ",")
            
            let kkk = "\(uuid)-\(o1)-\(o2)"
            // fast path
            if (status.bnitg.contains(kkk)){
                status.bnitg_ += 1
                return
            }
            // fast path
            if (status.bitg.contains(kkk)){
                status.bitg_ += 1
                //print("bitg \(kkk)")
            }else{
                var found = false
                loppa: for (nba,ba) in status.beaconConfiguration.enumerated() {
                    if (ba.id==status.selectedArea && ba.uuid == uuid){
                        //print(ba.beacon.count)
                        for (nb,b) in ba.beacons.enumerated() {
                            if (b.mjr == Double(o1) && b.mnr == Double(o2)) {
                                status.bitg.append(kkk)
                                status.bitg_ += 1
                                found = true
                                break loppa
                            }
                        }
                        status.bnitg.append(kkk)
                        status.bnitg_ += 1
                        return
                    }
                }
                if (!found){
                    status.bnitg.append(kkk)
                    status.bnitg_ += 1
                    return
                }
            }
            
            // some beacon not under the focus ? (managed by cockpit route manger)
            let currBeacon = "\(o1)-\(o2)"
            if (status.bnutf.contains(currBeacon)){
                //print(status.butf)
                //print(status.bnutf)
                return
            }
            // some beacons under the focus ? (managed by cockpit route manger)
            if (status.butf.contains(currBeacon)){
                //print(status.butf)
                //print(status.bnutf)
                //
            }else{
                if (status.autoLocation){ // forced auto-location pass-throught ?
                    //print(status.butf)
                    //print(status.bnutf)
                    //
                }else{
                    //print(status.butf)
                    //print(status.bnutf)
                    return
                }
            }
            
            
            threadSafeSignalProcessor.lock()
            status.retrievedData.append(sentdata)
            threadSafeSignalProcessor.unlock()
            status.signalsCounters.beacons += 1
            
            return  // AS IS without any adaptation
            
            
        }else{
            
            
                
                if ((name as AnyObject).contains("shaked")){
                    if (status.navigatorCockpit.suspSignals.contains("shk")) {
                        print("signal shk dropped due to suspend status")
                        return }
                    
                    let newName99 = (name as AnyObject).replacingOccurrences(of: "skahfaksg", with: "")
                    let sentdata = "\(timestamp): \(newName99)"
                    threadSafeSignalProcessor.lock()
                    status.retrievedData.append(sentdata)
                    threadSafeSignalProcessor.unlock()
                    status.signalsCounters.shakes += 1
                    
                    return
                    
                }else{
                    
                    
                        
                        status.signalsCounters.dusts += 1
                        print("what else? \(name)")
                    
                }
            
        }
    
  
    
}
//start mod#0004
class jsGrapher {
    
    var firstRun: Bool
    init(frun: Bool) {
        self.firstRun = true
        
        if (status.md5js==""){
            // attivazine efesto.js
            if let javascriptUrl = Bundle.main.url(forResource: "efesto", withExtension: "js") {
                jsHandler.loadSourceFile(atUrl: javascriptUrl, "")
                /*?@-@FuncBegin@*/
                status.md5js = "done"
                /*?@-@FuncEnd@*/
            }
        }
        
    }
    
    public func fwGrapherx(_ act:String) -> [_Vert] {
        // get vector list
        if (act == "lggVertici"){
            let go = GrapherObj(action: act, subact: "lv", nodes: [], nodesrn: [], num: 0, weight: 0, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
            let x = goGrapher(go)
            var _vert = _Vert(value: "", number: 0, coordinates: [0.0,0.0], inUseFlag: false, floor: 0, links: 0, inside: false, nosteps: false, weight: 0, nodinoBline: 0, nodinoCoordinates: [0.0,0.0], adiacenti: [])
            var t:[_Vert] = []
            for (nn, n) in x!.1.listVertID.enumerated() {
                var _tmp_vert = _vert
                _tmp_vert.value = n
                if (x!.1.listVertRN.count > 0) {
                    _tmp_vert.number = x!.1.listVertRN[nn]
                }
                if (x!.1.listVertCO.count > 0) {
                    _tmp_vert.nodinoCoordinates = x!.1.listVertCO[nn]
                }
                if (x!.1.listVertFL.count > 0) {
                    _tmp_vert.nodinoBline  = x!.1.listVertFL[nn]
                }
                if (x!.1.listVertLN.count > 0) {
                    _tmp_vert.links  = x!.1.listVertLN[nn]
                }
                _tmp_vert.adiacenti = []
                t.append(_tmp_vert)
            }
            return t
        }else{
            return []
        }
        
    }
    
    public func fwGrapherx(_ act:String) -> [_Edge] {
        // get nodino list
        if (act == "lggColleg"){
            let go = GrapherObj(action: act, subact: "lc", nodes: [], nodesrn: [], num: 0, weight: 0, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
            let x = goGrapher(go)
            var _nodino = _Edge(da: 0, a: 0, weight: 0, nosteps: false, inside: false)
            var e:[_Edge] = []
            for (nn, n) in x!.1.listVertEG.enumerated() {
                _nodino.da        = n.da
                _nodino.a         = n.a
                _nodino.weight    = n.weight
                _nodino.nosteps   = n.nosteps
                _nodino.inside    = n.inside
                e.append(_nodino)
            }
            return e
        }else{
            return []
        }
        
    }
    
    
    public func fwGrapherx(_ act:String,_ nodes:[String]) -> Double {
        // get route length by names
        if (act == "lggPercorso"){
            for nd in nodes {
                if (nd == "") {
                    return 0
                }
            }
            
            let go0 = GrapherObj(action: "lggVertici", subact: "lv", nodes: [], nodesrn: [], num: 0, weight: 0, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
            let x0 = goGrapher(go0)
            if (x0!.0 == 0){
                let xx0 = x0!.1
                if (xx0.listVertRN.count > 1){
                    for (nxc,xc) in xx0.listVertID.enumerated() {
                        for (nyc,yc) in xx0.listVertID.enumerated() where nyc > nxc {
                            if (xx0.listVertID[nxc] == xx0.listVertID[nyc]){
                                print("error!")
                                EXIT_FAILURE
                            }
                        }
                    }
                    
                    // https://stackoverflow.com/questions/44440317/check-if-an-array-of-strings-contains-a-substring
                    
                    let da = xx0.listVertID.firstIndex(of: nodes[0])
                    let a  = xx0.listVertID.firstIndex(of: nodes[1])
                    
                    if (da == nil || a == nil){
                        return 0
                    }
                    
                    if (da! >= 0 && a! >= 0 && da! != a!) {
                        let go = GrapherObj(action: act, subact: "grbrn", nodes: [], nodesrn: [xx0.listVertRN[da!],xx0.listVertRN[a!]], num: 0, weight: 0, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
                        let x = goGrapher(go)
                        return x!.1.weight
                        
                    }else{
                        return -1
                    }
                }else{
                    return -1
                }
            }else{
                return -1
            }
        }else{
            return -1
        }
    }
    
    
    public func fwGrapherx(_ act:String,_ nodes:[String]) -> Bool {
        // get route by names
        if (act == "lggPercorso"){
            for nd in nodes {
                if (nd == "") {
                    return false
                }
            }
            
            let go0 = GrapherObj(action: "lggVertici", subact: "lv", nodes: [], nodesrn: [], num: 0, weight: 0, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
            let x0 = goGrapher(go0)
            if (x0!.0 == 0){
                let xx0 = x0!.1
                if (xx0.listVertRN.count > 1){
                    for (nxc,xc) in xx0.listVertID.enumerated() {
                        for (nyc,yc) in xx0.listVertID.enumerated() where nyc > nxc {
                            if (xx0.listVertID[nxc] == xx0.listVertID[nyc]){
                                print("error!")
                                EXIT_FAILURE
                            }
                        }
                    }
                    
                    let da = xx0.listVertID.firstIndex(of: nodes[0])
                    let a  = xx0.listVertID.firstIndex(of: nodes[1])
                    
                    if (da == nil || a == nil){
                        return false
                    }
                    
                    if (da! >= 0 && a! >= 0 && da! != a!) {
                        let go = GrapherObj(action: act, subact: "grbrn", nodes: [], nodesrn: [xx0.listVertRN[da!],xx0.listVertRN[a!]], num: 0, weight: 0, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
                        let x = goGrapher(go)
                        if (x!.1.listVertID.count > 1) {
                            return true
                        }
                        return false
                        
                    }else{
                        return false
                    }
                }else{
                    return false
                }
            }else{
                return false
            }
    
        }else{
            return false
        }
    }
    
    public func fwGrapherx(_ act:String,_ nodes:[String]) -> [_Vert] {
        // get route by names
        if (act == "lggPercorso"){
            for nd in nodes {
                if (nd == "") {
                    return []
                }
            }
            
            let go0 = GrapherObj(action: "lggVertici", subact: "lv", nodes: [], nodesrn: [], num: 0, weight: 0, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
            let x0 = goGrapher(go0)
            if (x0!.0 == 0){
                let xx0 = x0!.1
                if (xx0.listVertRN.count > 1){
                    for (nxc,xc) in xx0.listVertID.enumerated() {
                        for (nyc,yc) in xx0.listVertID.enumerated() where nyc > nxc {
                            if (xx0.listVertID[nxc] == xx0.listVertID[nyc]){
                                print("error!")
                                EXIT_FAILURE
                            }
                        }
                    }
                    
                    // https://stackoverflow.com/questions/44440317/check-if-an-array-of-strings-contains-a-substring
                    
                    let da = xx0.listVertID.firstIndex(of: nodes[0])
                    let a  = xx0.listVertID.firstIndex(of: nodes[1])
                    
                    if (da == nil || a == nil){
                        return []
                    }
                    
                    if (da! >= 0 && a! >= 0 && da! != a!) {
                        let go = GrapherObj(action: act, subact: "grbrn", nodes: [], nodesrn: [xx0.listVertRN[da!],xx0.listVertRN[a!]], num: 0, weight: 0, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
                        let x = goGrapher(go)
                        var _vert = _Vert(value: "", number: 0, coordinates: [0.0,0.0], inUseFlag: false, floor: 0, links: 0, inside: false, nosteps: false, weight: 0, nodinoBline: 0, nodinoCoordinates: [0.0,0.0], adiacenti: [])
                        _vert.number = x!.1.num
                        _vert.coordinates[0] = x!.1.lat
                        _vert.coordinates[1] = x!.1.lng
                        _vert.floor = x!.1.floor
                        _vert.inUseFlag = x!.1.inUse
                        _vert.links = x!.1.links
                        var t:[_Vert] = []
                        for (nn, n) in x!.1.listVertID.enumerated() {
                            var _tmp_vert = _vert
                            _tmp_vert.value = n
                            if (x!.1.listVertRN.count > 0) {
                                _tmp_vert.number = x!.1.listVertRN[nn]
                            }
                            if (x!.1.listVertCO.count > 0) {
                                _tmp_vert.nodinoCoordinates = x!.1.listVertCO[nn]
                            }
                            if (x!.1.listVertFL.count > 0) {
                                _tmp_vert.nodinoBline  = x!.1.listVertFL[nn]
                            }
                            if (x!.1.listVertLN.count > 0) {
                                _tmp_vert.links  = x!.1.listVertLN[nn]
                            }
                            _tmp_vert.adiacenti = []
                            t.append(_tmp_vert)
                        }
                        return t
                        
                    }else{
                        return []
                    }
                }else{
                    return []
                }
            }else{
                return []
            }
    
        }else{
            return []
        }
    }
    
    public func fwGrapherx(_ act:String,_ nodesrn:[Int]) -> [_Vert] {
        // get route by ref number
        if (act == "lggPercorso"){
            let go = GrapherObj(action: act, subact: "grbrn", nodes: [], nodesrn: nodesrn, num: 0, weight: 0, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
            let x = goGrapher(go)
            var _vert = _Vert(value: "", number: 0, coordinates: [0.0,0.0], inUseFlag: false, floor: 0, links: 0, inside: false, nosteps: false, weight: 0, nodinoBline: 0, nodinoCoordinates: [0.0,0.0], adiacenti: [])
            var t:[_Vert] = []
            for (nn, n) in x!.1.listVertID.enumerated() {
                var _tmp_vert = _vert
                _tmp_vert.value = n
                if (x!.1.listVertRN.count > 0) {
                    _tmp_vert.number = x!.1.listVertRN[nn]
                }
                if (x!.1.listVertCO.count > 0) {
                    _tmp_vert.nodinoCoordinates = x!.1.listVertCO[nn]
                }
                if (x!.1.listVertFL.count > 0) {
                    _tmp_vert.nodinoBline  = x!.1.listVertFL[nn]
                }
                if (x!.1.listVertLN.count > 0) {
                    _tmp_vert.links  = x!.1.listVertLN[nn]
                }
                _tmp_vert.adiacenti = []
                t.append(_tmp_vert)
            }
            return t
        }else{
            return []
        }
    }
    
    public func fwGrapher(_ act:String) -> (Double, GraphAttributes, String, String)? {
        // reset
        if (act == "reset"){
            let go = GrapherObj(action: act, subact: "rg", nodes: [], nodesrn: [], num: 0, weight: 0, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
            return goGrapher(go)
        }else{
            return nil
        }
    }
    
    public func fwGrapher(_ act:String, num:Int) -> (Double, GraphAttributes, String, String)? {
        // get vector attributes by ref number
        if (act != "lggVerticeAttributi"){
            return nil
        }
        
        let go = GrapherObj(action: act, subact: "gvabrn", nodes: [], nodesrn: [], num: num, weight: 0, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
        /*
         // setto attributi a livello Vertice
         _vert.number = x!.1.num
         _vert.coordinates[0] = x!.1.lat
         _vert.coordinates[1] = x!.1.lng
         _vert.floor = x!.1.floor
         _vert.inUseFlag = x!.1.inUse
         _vert.links = x!.1.links
         */
        return goGrapher(go)
    }
    public func fwGrapher(_ act:String, _ nodes:[Int], weight:Int ) -> (Double, GraphAttributes, String, String)? {
        // aggSegmento by ref numbers
        if (act != "aggColleg"){
            return nil
        }
        
        let go = GrapherObj(action: act, subact: "aebrn", nodes: [], nodesrn: nodes, num: 0, weight: weight, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
        return goGrapher(go)
    }
    public func fwGrapher(_ act:String, _ nodes:[String]) -> (Double, GraphAttributes, String, String)? {
        // addGropo
        if (act != "aggVertice"){
            return nil
        }
        
        let go = GrapherObj(action: act, subact: "av", nodes: nodes, nodesrn: [], num: 0,weight: 0, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
        return goGrapher(go)
    }
    public func fwGrapher(_ act:String, _ nodes:[String], lat:Float, lng:Float) -> (Double, GraphAttributes, String, String)? {
        // setGropoAttributes coordinates
        if (act != "modVerticeAttributi"){
            return nil
        }
        
        let go = GrapherObj(action: act, subact: "svc", nodes: nodes, nodesrn: [], num: 0, weight: 0, floor: 0, lat: lat, lng: lng, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
        return goGrapher(go)
    }
    public func fwGrapher(_ act:String, _ nodes:[String], floor:Int) -> (Double, GraphAttributes, String, String)? {
        // setGropoAttributes floor
        if (act != "modVerticeAttributi"){
            return nil
        }
        
        let go = GrapherObj(action: act, subact: "svf", nodes: nodes, nodesrn: [], num: 0, weight: 0, floor: floor, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
        return goGrapher(go)
    }
    
    public func fwGrapher(_ act:String, _ nodes:[String], inUse:Bool) -> (Double, GraphAttributes, String, String)? {
        // setGropoAttributes floor
        if (act != "modVerticeAttributi"){
            return nil
        }
        
        let go = GrapherObj(action: act, subact: "sviu", nodes: nodes, nodesrn: [], num: 0, weight: 0, floor: 0, lat: 0.0, lng: 0.0, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
        return goGrapher(go)
    }
    
    public func fwGrapher(_ act:String, _ nodes:[String], weight:Int, floor:Int, lat:Float, lng:Float) -> (Double, GraphAttributes, String, String)? {
        // full node definition
        if (act != "addVerticeConAttributi"){
            return nil
        }
        
        let go = GrapherObj(action: act, subact: "svwa", nodes: nodes, nodesrn: [], num: 0, weight: weight, floor: floor, lat: lat, lng: lng, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
        return goGrapher(go)
    }
    
}
class heavyGrapher: jsGrapher {
    var noiseLevel: Int
    init(name: String, age: Int, noiseLevel: Int) {
        self.noiseLevel = noiseLevel
        super.init(frun: true)
    }
    override func fwGrapher(_ act:String, _ nodes:[String], weight:Int, floor:Int, lat:Float, lng:Float) -> (Double, GraphAttributes, String, String)? {
        // full node definition
        if (act != "addVerticeConAttributi"){
            return nil
        }
        
        let go = GrapherObj(action: act, subact: "shvwa", nodes: nodes, nodesrn: [], num: 0, weight: weight, floor: floor, lat: lat, lng: lng, inUse: false, esito: 0, subcode: 0, payload: "", warn: "", error: "")
        return goGrapher(go)
    }
    
}
//end mod#0004
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    //guard CALayer.position != nil else { return }
    
    
    
    var window: UIWindow?
    
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .phone ? .portrait : .all
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func application(_ application: UIApplication,
                              willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NSLog("App Installing");
        status.secondsFromGMT = TimeZone.current.secondsFromGMT()
        let userName = NSUserName()
        let fullUserName = NSFullUserName()
        let _uuid = UIDevice.current.identifierForVendor!.uuidString
        
        // *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - //
        
        var buildDate: Date {
            if let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
                let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
                let infoDate = infoAttr[.modificationDate] as? Date {
                return infoDate
            }
            return Date()
        }
        
        let bd = buildDate
        
        let dt = Int64(Date().toMillis())-Int64(buildDate.toMillis())
        let vt = Int64(3600*24*60*1000)
        let dd = Float(dt - vt)
        let ddi = Double((dd/(3600*24*1000)).rounded(.down))
        status.days2EOS = "\(ddi)"
        print("dt \(dt) vs \(vt) delta = \(vt-dt) ddi \(ddi)")
        //if ( dt > vt ){
        if (configInPlace.timeBombed && ddi > 0) {
            configInPlace.timeBombed = true         // confermo
        }else{
            configInPlace.timeBombed = false        // disattivo se previsto
        }
        
        // *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - //
        
        //let allLanguages = Locale.preferredLanguages
        //let localLanguage = Locale.preferredLanguages[0]
        let langCode = Locale.current.languageCode ?? ""
        let regionCode = Locale.current.regionCode ?? ""
        status.linguaCorrente = "\(langCode)-\(regionCode)"
        for item in GuidaDataModel.talkedLanguages {
            if (item.starts(with: status.linguaCorrente)) {
                status.linguaCorrente = item
                break
            }
        }
        
        // *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - //
        
        let defaultsDataStore = UserDefaults.standard
        
        if let configurationURL = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyConfigurationURL) {
                  configInPlace.configurationURL = configurationURL;
            }
        if (configInPlace.configurationURL == "") {
        }
        
        //start mod#0002
        //FORZATO XCHE NON DINAMICO
        configInPlace.configurationURL = "https://asphi.it/conf_app/v15/../*.html"
        defaultsDataStore.set(configInPlace.configurationURL, forKey: DefaultsKeysDataStore.keyConfigurationURL)
        defaultsDataStore.set("yes", forKey: DefaultsKeysDataStore.keyConfigurationURLverified)
        configInPlace.configurationURLverified = true
        //end mod#0002
        /* to be removed !!!
        configInPlace.configurationURL = "http://169.254.175.194:1887/ASPHI/v15"
        defaultsDataStore.set(configInPlace.configurationURL, forKey: DefaultsKeysDataStore.keyConfigurationURL)
        defaultsDataStore.set("yes", forKey: DefaultsKeysDataStore.keyConfigurationURLverified)
        configInPlace.configurationURLverified = true
        // to be removed !!! */
                
        // *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - //
                
        var text3_ = ""
        
        
        
        
        var postFix1 = ""
        var fullURL1 = ""
        var tempURL1 = ""
        print(configInPlace.configurationURL)
        if (configInPlace.configurationURL.contains("/../*.html")) {
            tempURL1 = configInPlace.configurationURL.replacingOccurrences(of: "/../*.html", with: "/")
            postFix1 = ".html"
        }else{
            tempURL1 = configInPlace.configurationURL
        }
        if (!tempURL1.hasSuffix("/")) {
            fullURL1 = "\(tempURL1)/Orientamento2020iosConfig"
        }else{
            fullURL1 = "\(tempURL1)Orientamento2020iosConfig"
        }
        if (postFix1.count > 0) {
            fullURL1 += postFix1
        }
                
        
        
        
        
        var wrote = 0
        
        if let _javascriptUrlcloudConfigurer = URL(string:
        
                                                    fullURL1
                                                    )
        {
            let _text = jsDynHandlerConfig.loadSourceFileFromHTML(atUrl: _javascriptUrlcloudConfigurer, text3_)
            if (_text != "" && _text != text3_) {
                
                
                
                
                
            }
        }
        print(GuidaDataModel.sceneDescriptor)
        let _cloudConfigurer = CloudConfigurer(version: status.versione, user: "chiseo", device: "?")
        let _t1 = jsDynamicallyDownloadedConfig(_cloudConfigurer)
        if (_t1 != nil){
            if (_t1?.0 == true && wrote >= 2){ //se scaricato e salvato nuovo config file valuto il forceReset
                status.forceReset = true
            }
            if (_t1?.2 != nil && _t1?.3 != nil && _t1?.4 != nil && _t1?.5 != nil && _t1?.6 != nil && _t1?.7 != nil){
                print(_t1!.2.version)
                status.selectedArea = _t1!.2.area
                let posMod = minComune(_t1!.2.availableModalities,RouteController.possibiliModalita)
                RouteController.possibiliModalita = posMod
                status.possibiliModalita = RouteController.possibiliModalita
                print(status.possibiliModalita)
                let posCri = minComune(_t1!.2.availableCriterias,RouteController.possibiliCriteri)
                RouteController.possibiliCriteri = posCri
                status.possibiliCriteri = RouteController.possibiliCriteri
                print(status.possibiliCriteri)
                let posOMDM = minComune(_t1!.2.operativityModes,GuidaDataModel.operativityModes)
                GuidaDataModel.operativityModes = posOMDM
                print(GuidaDataModel.operativityModes)
                let posFBM = minComune(_t1!.2.feedbackModes,GuidaDataModel.feedbackModes)
                GuidaDataModel.feedbackModes = posFBM
                print(GuidaDataModel.feedbackModes)
                let posPHM = minComune(_t1!.2.phoneModes,GuidaDataModel.phoneModes)
                GuidaDataModel.phoneModes = posPHM
                print(GuidaDataModel.phoneModes)
                let posUCHR = minComune(_t1!.2.userCharacters,GuidaDataModel.userCharacters)
                GuidaDataModel.userCharacters = posUCHR
                print(GuidaDataModel.userCharacters)
                let posVMOD = minComune(_t1!.2.voiceModes,GuidaDataModel.voiceModes)
                GuidaDataModel.voiceModes = posVMOD
                print(GuidaDataModel.voiceModes)
                GuidaDataModel.zRTV = []
                for zrtv in _t1!.2.zRTV {
                    GuidaDataModel.zRTV.append(Float(zrtv))
                }
                status.zRTV = GuidaDataModel.zRTV
                print("status.zRTV \(status.zRTV)")
                if (wrote==0){
                    status.voiceReaderSpeed = Float(_t1!.2.voiceSpeed)
                    print(status.voiceReaderSpeed)
                    status.voiceReaderPaceing = Float(_t1!.2.voicePaceing)
                    print(status.voiceReaderPaceing)
                    status.voiceRepetitions = Float(_t1!.2.voiceRepetitions)
                    print(status.voiceRepetitions)
                }
 
                
                GuidaDataModel.formality = []
                for formalita in _t1!.2.formality {
                    GuidaDataModel.formality.append(TextStatements(language: formalita.language, aboutThisApp: formalita.aboutThisApp, instructions: formalita.instructions, privacy: formalita.privacy, disclaimer: formalita.disclaimer))
                }
                print(GuidaDataModel.formality)
                GuidaDataModel.sceneDescriptor = SceneDescriptor(title: _t1!.2.sceneDescriptor.title, icon1url: _t1!.2.sceneDescriptor.icon1url, icon2url: _t1!.2.sceneDescriptor.icon2url, scene1: _t1!.2.sceneDescriptor.scene1, scene2: _t1!.2.sceneDescriptor.scene2)
                print(GuidaDataModel.sceneDescriptor)
                
                
                let urlString1 = GuidaDataModel.sceneDescriptor.icon1url
                        let url1 = NSURL(string: urlString1)! as URL
                        if let imageData: NSData = NSData(contentsOf: url1) {
                            let imgPNG = UIImage(data: imageData as Data)
                            saveImage(imageName: "icon1url.png",image: imgPNG!)
                            print(imgPNG)
                        }
                GuidaDataModel.scene.icon1 = loadImageFromDiskWith(fileName: "icon1url.png")
                
                
                
                let urlString2 = GuidaDataModel.sceneDescriptor.icon2url
                        let url2 = NSURL(string: urlString2)! as URL
                        if let imageData: NSData = NSData(contentsOf: url2) {
                            let imgPNG = UIImage(data: imageData as Data)
                            saveImage(imageName: "icon2url.png",image: imgPNG!)
                            print(imgPNG)
                        }
                GuidaDataModel.scene.icon2 = loadImageFromDiskWith(fileName: "icon2url.png")
                
                
                
                let urlString3 = GuidaDataModel.sceneDescriptor.scene1.url
                        let url3 = NSURL(string: urlString3)! as URL
                        if let imageData: NSData = NSData(contentsOf: url3) {
                            let imgPNG = UIImage(data: imageData as Data)
                            saveImage(imageName: "scene1.png",image: imgPNG!)
                            print(imgPNG)
                        }
                GuidaDataModel.scene.scene1 = loadImageFromDiskWith(fileName: "scene1.png")
                
                
                let urlString4 = GuidaDataModel.sceneDescriptor.scene2.url
                        let url4 = NSURL(string: urlString4)! as URL
                        if let imageData: NSData = NSData(contentsOf: url4) {
                            let imgPNG = UIImage(data: imageData as Data)
                            saveImage(imageName: "scene2.png",image: imgPNG!)
                            print(imgPNG)
                        }
                GuidaDataModel.scene.scene2 = loadImageFromDiskWith(fileName: "scene2.png")
                
               
                for (nbc,bc) in status.beaconConfiguration.enumerated() {
                    if (bc.id==_t1!.3.id && bc.id==_t1!.2.area && bc.uuid==_t1!.3.uuid){
                        status.beaconConfiguration[nbc].beacons = []
                        
                        for (n, beacon) in _t1!.3.beacons.enumerated() where n <= availableBeacon {
                            status.beaconConfiguration[nbc].beacons.append(BeaconConfig(mjr: Double(beacon.mjr), mnr: Double(beacon.mnr), lat: Float(beacon.lat), lng: Float(beacon.lng), floor: beacon.floor, tme: Double(beacon.tme), tx: Float(beacon.tx), db1m: Float(beacon.db1m), sn: beacon.sn, id: beacon.id, mac: beacon.mac, nm: beacon.nm, qrc: "" /*beacon.qrc*/, inUseFlag: false /*beacon.inUseFlag*/, bRTV: [Float(beacon.bRTV[0]),Float(beacon.bRTV[1]),Float(beacon.bRTV[2])]))
                                print(beacon)
                                print(status.beaconConfiguration[nbc].beacons)
                            }
                    }
                }
                print(status.beaconConfiguration)
                
                if (_t1!.3.id==_t1!.4.id && _t1!.3.uuid==_t1!.4.uuid && _t1!.4.id==_t1!.2.area){
                    for segment in _t1!.4.segmentsTuning {
                        //print(segment)
                        for (nrst,rst) in status.forcedRouteSegmentsTuning.enumerated() {
                            print("rst \(rst)")
                        }
                        let damjr = Double(estraiNumero(segment.da, "@", "-"))
                        let damnr = Double(estraiNumero(segment.da, "-", "@"))
                        let amjr = Double(estraiNumero(segment.a, "@", "-"))
                        let amnr = Double(estraiNumero(segment.a, "-", "@"))
                        let dakey = "\(damjr)-\(damnr)"
                        let akey = "\(amjr)-\(amnr)"
                        let daakey = "\(damjr)-\(damnr)@\(amjr)-\(amnr)"
                        let _rST = RouteSegmentTuning( da: dakey, a: akey, outDa: segment.outDa, inA: segment.inA)
                        status.forcedRouteSegmentsTuning.append(_rST)
                    }
                    for beacon in _t1!.4.beaconsTuning {
                        print(beacon)
                        for (nbt,bt) in status.forcedBeaconsTuning.enumerated() {
                            print("bt \(bt)")
                        }
                        let mjr = Double(estraiNumero(beacon.id, "@", "-"))
                        let mnr = Double(estraiNumero(beacon.id, "-", "@"))
                        let key = "\(mjr)-\(mnr)"
                        let _bT = BeaconTuning( id: key, exiting: beacon.exiting, entering: beacon.entering)
                        status.forcedBeaconsTuning.append(_bT)
                    }
                }
                
                
                
                let letsDefaultsDataStore = UserDefaults.standard
                status.routeSegmentsTuning = status.forcedRouteSegmentsTuning
                // should be merged !!! instead of replaced !!!
                print(status.routeSegmentsTuning)
                var ss = ""
                for (i,n) in status.routeSegmentsTuning.enumerated() {
                    let s = "\(n.da),\(n.a),\(n.outDa[0]),\(n.outDa[1]),\(n.outDa[2]),\(n.inA[0]),\(n.inA[1]),\(n.inA[2])"
                    if (i>0){
                        ss += "%\(s)"
                    }else{
                        ss += "\(s)"
                    }
                }
                letsDefaultsDataStore.set(ss, forKey: DefaultsKeysDataStore.keyRouteSegmentsTuning)
                status.beaconsTuning = status.forcedBeaconsTuning
                // should be merged !!! instead of replaced !!!
                print(status.beaconsTuning)
                ss = ""
                for (i,n) in status.beaconsTuning.enumerated() {
                    let s = "\(n.id),\(n.exiting[0]),\(n.exiting[1]),\(n.exiting[2]),\(n.entering[0]),\(n.entering[1]),\(n.entering[2])"
                    if (i>0){
                        ss += "%\(s)"
                    }else{
                        ss += "\(s)"
                    }
                }
                letsDefaultsDataStore.set(ss, forKey: DefaultsKeysDataStore.keyBeaconsTuning)
                
                for (nfc,fc) in status.fencingConfiguration.enumerated() {
                    if (fc.id==_t1!.5.id && fc.id==_t1!.2.area){
                        status.fencingConfiguration[nfc].fences = []
                        for (ndf,fence) in _t1!.5.fences.enumerated() {
                            if (ndf >= availableFence){
                                break
                            }
                            status.fencingConfiguration[nfc].fences.append(FenceConfig(lat: Float(fence.lat), lng: Float(fence.lng), radius: Float(fence.radius), floor: fence.floor, xid: "" /*fence.xid*/, id: fence.id, alias: fence.alias, qrc: "" /*fence.qrc*/, inUseFlag: false /*fence.inUseFlag*/, ftrsSts: FtrsStatus(ent: fence.ftrsStsEnt,ext: fence.ftrsStsExt)))
                            print(fence)
                            print(status.fencingConfiguration[nfc].fences)
                        }
                    }
                }
                print(status.fencingConfiguration)
                for (nic,ic) in status.indicazioniOrientamento.enumerated() {
                    if (ic.id==_t1!.6.id && ic.id==_t1!.2.area){
                        var _spl1:[String] = []
                        for percorsi in _t1!.6.indicazioni {
                            for indicazione in percorsi {                   // ptf 20210830
                                if (indicazione.from == "WILD" && indicazione.to != "WILD"){
                                    _spl1.append(indicazione.to)
                                    break
                                }
                            }
                        }
                        var _spl2:[String] = []
                        for percorsi in _t1!.6.indicazioni {
                            for indicazione in percorsi {                   // ptf 20210830
                                if (_spl1.contains(indicazione.from) && !_spl2.contains(indicazione.to)){
                                    _spl2.append(indicazione.to)
                                    break
                                }
                            }
                        }
                        status.puntiOrigineDichiarati = _spl2
                        
                        while(status.puntiOrigineDichiarati.count > 0  && status.puntiOrigineDichiarati.count > _t1!.6.indicazioni.count){
                            status.puntiOrigineDichiarati.remove(at: status.puntiOrigineDichiarati.count - 1 )
                        }
                        for (npod,pod) in status.puntiOrigineDichiarati.enumerated() {
                            status.puntiOrigineDichiarati[npod] = pod.replacingOccurrences(of: pod, with: getFenceID(area: ic.id, alias: pod))
                        }
                    }
                }
                        
                for (nic,ic) in status.indicazioniOrientamento.enumerated() {
                    if (ic.id==_t1!.6.id && ic.id==_t1!.2.area){
                        
                        status.vertici = []
                        status.segmenti = []
                        for (ndp,percorsi) in _t1!.6.indicazioni.enumerated() {
                            if (ndp >= availableRoute){
                                break
                            }
                            for indicazione in percorsi {                   // ptf 20210830
                                if (indicazione.to != "WILD"){
                                    var fnd = false
                                    for v in status.vertici {
                                        if (v.id == indicazione.from){
                                            fnd = true
                                            break
                                        }
                                    }
                                    if (!fnd) {
                                        for (nfc,fc) in status.fencingConfiguration.enumerated() {
                                            if (fc.id==_t1!.5.id && fc.id==_t1!.2.area){
                                                for fence in _t1!.5.fences {
                                                    if (indicazione.from == fence.alias){
                                                        let p = "\(status.selectedArea) "
                                                        var t = fence.id
                                                        t = t.replacingOccurrences(of: p, with: "")
                                                        if let doIt = status.vertici.firstIndex(where: {$0.id == t}) {
                                                            // Already Exist !111
                                                            print("ISRT Vertex 1 \(t) skipped due to already inserted")
                                                        }else{
                                                            status.vertici.append(VerticeBase(id:t,alias:fence.alias,lat:fence.lat,lng:fence.lng))
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    fnd = false
                                    for v in status.vertici {
                                        if (v.id == indicazione.to){
                                            fnd = true
                                            break
                                        }
                                    }
                                    if (!fnd) {
                                        for (nfc,fc) in status.fencingConfiguration.enumerated() {
                                            if (fc.id==_t1!.5.id && fc.id==_t1!.2.area){
                                                for fence in _t1!.5.fences {
                                                    if (indicazione.to == fence.alias){
                                                        let p = "\(status.selectedArea) "
                                                        var t = fence.id
                                                        t = t.replacingOccurrences(of: p, with: "")
                                                        if let doIt = status.vertici.firstIndex(where: {$0.id == t}) {
                                                            // Already Exist !111
                                                            print("ISRT Vertex 2 \(t) skipped due to already inserted")
                                                        }else{
                                                            status.vertici.append(VerticeBase(id:t,alias:fence.alias,lat:fence.lat,lng:fence.lng))
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    fnd = false
                                    for s in status.segmenti {
                                        if (s.da == indicazione.from && s.a == indicazione.to){
                                            fnd = true
                                            break
                                        }
                                    }
                                    if (!fnd) {
                                        status.segmenti.append(SegmentoBase(da:indicazione.from,a:indicazione.to))
                                    }
                                }
                            }                                               // ptf 20210830
                        }
                        
                        status.indicazioniOrientamento[nic].indicazioni = []
                        for percorsi in _t1!.6.indicazioni {
                            for indicazione in percorsi {                   // ptf 20210830
                                for indicazionePerLingua in indicazione.msg {
                                    if (status.linguaCorrente.lowercased().starts(with: indicazionePerLingua.lang.lowercased())) {
                                        // non attivo per evitare promisquità varie.. da ripensare?
                                        //status.indicazioniOrientamento[nic].indicazioni.append(_indicazione(id: "\(indicazione.from)+\(indicazione.to)", msg: indicazionePerLingua.text, inUseFlag: false))
                                        print(indicazione)
                                    }
                                }
                            }                                               // ptf 20210830
                        }
                        
                    }
                }
                print(status.indicazioniOrientamento)
                print(status.vertici)
                print(status.segmenti)
                for (nipc,ipc) in status.indicazioniPercorsi.enumerated() {
                    if (ipc.id==_t1!.6.id && ipc.id==_t1!.2.area){
                        status.indicazioniPercorsi[nipc].indicazioni = []
                        var subPath = 0
                        for percorsi in _t1!.6.indicazioni {
                            status.indicazioniPercorsi[nipc].indicazioni.append([])
                            for indicazionePercorso in percorsi {
                                // cerco di inserire un solo messaggio della lingua in uso
                                var tmp1:[TestoIndicazione] = []
                                var tmp2:[TestoIndicazione] = []
                                for indicazionePerLingua in indicazionePercorso.msg {
                                    print("curr \(status.linguaCorrente) vs msg \(indicazionePerLingua.lang)")
                                    if (status.linguaCorrente.lowercased().starts(with: indicazionePerLingua.lang.lowercased())) {
                                        tmp1.append(TestoIndicazione(lang: indicazionePerLingua.lang, text: indicazionePerLingua.text)) // insert at the beginning of the array
                                    }else{
                                        tmp2.append(TestoIndicazione(lang: indicazionePerLingua.lang, text: indicazionePerLingua.text))
                                    }
                                }
                                for t2 in tmp2 {
                                    tmp1.append(t2)
                                }
                                //print(tmp1)
                                status.indicazioniPercorsi[nipc].indicazioni[subPath].append(
                                    IndicazionePercorsoSingoloTratto(from: indicazionePercorso.from, to: indicazionePercorso.to, comment: indicazionePercorso.comment, msg: tmp1, inUseFlag: false))
                                print("add segment to route #\(subPath) \(indicazionePercorso.from) > \(indicazionePercorso.to)")
                            }
                            print("added #\(status.indicazioniPercorsi[nipc].indicazioni[subPath].count) segments to route \(status.indicazioniPercorsi[nipc].indicazioni[subPath])")
                            subPath += 1
                        }
                        print("added #\(status.indicazioniPercorsi[nipc].indicazioni.count) routes \(status.indicazioniPercorsi[nipc].indicazioni)")
                    }
                }
                print(status.indicazioniPercorsi)
                
                status.destinazioniAttivate = []
                for dest in _t1!.7.destinazioni {
                    for (nfc,fc) in status.fencingConfiguration.enumerated() {
                        if (fc.id==_t1!.5.id && fc.id==_t1!.2.area && fc.id==_t1!.7.id){
                            for fence in _t1!.5.fences {
                                if (fence.id == dest) {
                                    status.destinazioniAttivate.append(dest)
                                    print("dest \(dest)")
                                }
                            }
                            if (!status.destinazioniAttivate.contains(dest)){
                                print("destinazione attivata non presente nel modello dati \(dest)")
                            }
                        }
                    }
                    
                }
                print(status.destinazioniAttivate)
                status.originiAttivate = []
                for part in _t1!.8.origini {
                    for (nfc,fc) in status.fencingConfiguration.enumerated() {
                        if (fc.id==_t1!.5.id && fc.id==_t1!.2.area && fc.id==_t1!.7.id){
                            for fence in _t1!.5.fences {
                                if (fence.id == part) {
                                    status.originiAttivate.append(part)
                                    print("part \(part)")
                                }
                            }
                            if (!status.originiAttivate.contains(part)){
                                print("origine attivata non presente nel modello dati \(part)")
                            }
                        }
                    }
                    
                }
                print(status.originiAttivate)
                
                let defaultsDataStore = UserDefaults.standard
                
                defaultsDataStore.set("yes", forKey: DefaultsKeysDataStore.keyConfigurationURLverified)
                configInPlace.configurationURLverified = true
  
            }
        }
        
    
        // *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - //
        
        // force test values
        
        
        
            GuidaDataModel.operativityModes = availableOperativityMode
            GuidaDataModel.userCharacters = availableUserCharacters
            GuidaDataModel.possibiliModalita = availableModalita
            RouteController.possibiliCriteri = availableCriteri
            
            status.possibiliModalita = availableModalita
            status.possibiliCriteri = availableCriteri
            
        
        
        
        // *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - //
        
        
        
        // *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - *** - //
        
        
        
        
        // GuidaDataModel LocalizedString
        
        for item in GuidaDataModel.operativityModes {
            GuidaDataModel.operativityModes[GuidaDataModel.operativityModes.firstIndex(where: {$0 == item})!] = NSLocalizedString(item, comment:"operativityModes")
        }
        
        for item in GuidaDataModel.userCharacters {
            GuidaDataModel.userCharacters[GuidaDataModel.userCharacters.firstIndex(where: {$0 == item})!] = NSLocalizedString(item, comment:"userCharacters")
        }
                
        for item in GuidaDataModel.phoneModes {
            GuidaDataModel.phoneModes[GuidaDataModel.phoneModes.firstIndex(where: {$0 == item})!] = NSLocalizedString(item, comment:"phoneModes")
        }
        
        // status LocalizedString
        
        for item in status.possibiliOriginiBase {
            status.possibiliOriginiBase[status.possibiliOriginiBase.firstIndex(where: {$0 == item})!] = NSLocalizedString(item, comment:"possibiliOriginiBase")
        }
        
        for item in status.possibiliDestinazioniBase {
            status.possibiliDestinazioniBase[status.possibiliDestinazioniBase.firstIndex(where: {$0 == item})!] = NSLocalizedString(item, comment:"possibiliDestinazioniBase")
        }
        
        for item in status.possibiliCriteri {
            status.possibiliCriteri[status.possibiliCriteri.firstIndex(where: {$0 == item})!] = NSLocalizedString(item, comment:"possibiliCriteri")
        }
        
        for item in status.possibiliModalita {
            status.possibiliModalita[status.possibiliModalita.firstIndex(where: {$0 == item})!] = NSLocalizedString(item, comment:"possibiliModalita")
        }
        
        for item in status.ulterioriTermini {
            status.ulterioriTermini[status.ulterioriTermini.firstIndex(where: {$0 == item})!] = NSLocalizedString(item, comment:"ulterioriTermini")
        }
        
        //====================================================================
        
        
        
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool{
        
        
        //status.versione = StatusController.versione
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // If granted comes true you can enabled features based on authorization.
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        
        
        
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        if (!status.forceReset){
            //ripristina ultima configurazione attiva
             do {
                if haskeyDataConfigInPlaceAtleastOnce {
                    guard let configData = UserDefaults.standard.data(forKey: "keyDataConfigInPlace") else { return false }
                     //let decodedData = try JSONDecoder().decode(ConfigInPlace.self, from: configData)
                     configInPlace = try JSONDecoder().decode(ConfigInPlace.self, from: configData)
                     // synchronize is not needed
                    
                    
                }
             } catch {
                print("xxx1 \(error)")
            }
            
            //ripristina statistiche
             do {
                if haskeyDataStatisticsAtleastOnce {
                    guard let configData = UserDefaults.standard.data(forKey: "keyDataStatistics") else { return false }
                     //let decodedData = try JSONDecoder().decode(ConfigInPlace.self, from: configData)
                     statistics = try JSONDecoder().decode(Statistics.self, from: configData)
                     // synchronize is not needed
                    
                    
                }
             } catch {
                print("xxx4 \(error)")
            }
            
            
            
            var _routeSegmentsTuning:[RouteSegmentTuning] = []
            let defaultsDataStore2 = UserDefaults.standard
            if let _tuningData = defaultsDataStore2.string(forKey: DefaultsKeysDataStore.keyRouteSegmentsTuning) {
                let _segments = _tuningData.split(separator: "%")
                for _seg in _segments {
                    let _segData = _seg.split(separator: ",")
                    var _numValsTrimmed:[Float] = []
                    for (_nt,_nvt) in _segData.enumerated() where _nt >= 2 {
                        _numValsTrimmed.append(Float(_nvt)!)
                    }
                    let _rST = RouteSegmentTuning( da: String(_segData[0]), a: String(_segData[1]), outDa: [Double(_numValsTrimmed[0]),Double(_numValsTrimmed[1]),Double(_numValsTrimmed[2])], inA: [Double(_numValsTrimmed[3]),Double(_numValsTrimmed[4]),Double(_numValsTrimmed[5])])
                    _routeSegmentsTuning.append(_rST)
                }
            }
            status.routeSegmentsTuning = _routeSegmentsTuning
            print(status.forcedRouteSegmentsTuning)
            print(status.routeSegmentsTuning)
            forced: for frst in status.forcedRouteSegmentsTuning {
                for (nrst,rst) in status.routeSegmentsTuning.enumerated() {
                    if (frst.da==rst.da && frst.a==rst.a) {
                        //continue forced
                        status.routeSegmentsTuning.remove(at: nrst)
                        break
                    }
                }
                status.routeSegmentsTuning.append(frst)
            }
            print(status.routeSegmentsTuning)
            
            var _beaconsTuning:[BeaconTuning] = []
            let defaultsDataStore3 = UserDefaults.standard
            if let _tuningData = defaultsDataStore3.string(forKey: DefaultsKeysDataStore.keyBeaconsTuning) {
                let _beacons = _tuningData.split(separator: "%")
                for _bea in _beacons {
                    let _beaData = _bea.split(separator: ",")
                    var _numValsTrimmed:[Float] = []
                    for (_nt,_nvt) in _beaData.enumerated() where _nt >= 1 {
                        _numValsTrimmed.append(Float(_nvt)!)
                    }
                    let _rST = BeaconTuning( id: String(_beaData[0]), exiting: [Double(_numValsTrimmed[0]),Double(_numValsTrimmed[1]),Double(_numValsTrimmed[2])], entering: [Double(_numValsTrimmed[3]),Double(_numValsTrimmed[4]),Double(_numValsTrimmed[5])])
                    _beaconsTuning.append(_rST)
                }
            }
            status.beaconsTuning = _beaconsTuning
            
            
            //ripristina status control blocks
             do {
                if haskeyDataStatusAtleastOnce {
                    guard let configData = UserDefaults.standard.data(forKey: "keyDataStatus") else { return false }
                     //let decodedData = try JSONDecoder().decode(ConfigInPlace.self, from: configData)
                     codableStatus = try JSONDecoder().decode(CodableStatus.self, from: configData)
                     // synchronize is not needed
                    
                    
                    
                    status.versioneRunPrecedente = codableStatus.versioneRunPrecedente
      
                    status.selectedArea = codableStatus.selectedArea
                    
                    status.missBeaconsSegmentTuning = codableStatus.missBeaconsSegmentTuning
                    status.missFencesSegmentTuning = codableStatus.missFencesSegmentTuning
                    
                    status.voiceReaderVolume = codableStatus.voiceReaderVolume
                    status.voiceReaderSpeed = codableStatus.voiceReaderSpeed
                    status.voiceReaderPaceing = codableStatus.voiceReaderPaceing
                    status.voiceRepetitions = codableStatus.voiceRepetitions
                    status.voiceReaderCharacter = codableStatus.voiceReaderCharacter
                    
                    
                    
                    status.modalita = codableStatus.modalita
                    status.criterio = codableStatus.criterio
                    
                    /* */
                    
                    
                    
                    
                    
                    status.positioningTechnique = codableStatus.positioningTechnique
                    status.feedbackMode = codableStatus.feedbackMode
                    
                    status.prevOrigine = codableStatus.prevOrigine
                    status.prevDestinazione = codableStatus.prevDestinazione
                    
                    status.zRTV = codableStatus.zRTV
                    
                    
                    
                }
             } catch {
                print("xxx7 \(error)")
            }
            
            
        }
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        let defaultsDataStore = UserDefaults.standard
        
        if let aboutThisAppReaded = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyAboutThisAppReaded) {
        }
        if let instructionsReaded = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyInstructionsReaded) {
        }
        if let privacyAccepted = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyPrivacyAccepted) {
        }
        if let disclamerAccepted = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyDisclaimerAccepted) {
        }
        
        
          
          // Setup AVAudioSession to indicate to the system you how intend to play audio.
          // https://developer.apple.com/documentation/avfaudio/avaudiosession
          // stis step is crucial to have speech synthesizer working in background
          let audioSession = AVAudioSession.sharedInstance()
          do {
              try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
          }
          catch {
              print("An error occured setting the audio session category: \(error)")
          }
          
          // Set the AVAudioSession as active.  This is required so that your application becomes the "Now Playing" app.
          do {
              try audioSession.setActive(true)
          }
          catch {
              print("An Error occured activating the audio session: \(error)")
          }
         
        
        
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        let myNotificationKey = "sensorForOrientation"
        _tknForOri = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: myNotificationKey), object: nil, queue: nil, using:catchNotificationForOrientation)
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        let myRouteNotificationKey = "RouteMGMT"
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: myRouteNotificationKey), object: nil, queue: nil, using:catchNotificationRoute)
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // Arrange the tabbar item sequence in order to be compliant to the model: destination / map / settings
        
        /*
        let storyboard = UIStoryboard(name: "myOneTabBarController", bundle: nil)
        // change "name:" if your storyboard's filename if different.
        let vc1 = storyboard.instantiateViewController(withIdentifier: "vc1")
        let vc2 = storyboard.instantiateViewController(withIdentifier: "vc2")
        let tab = UITabBarController()
        if UIDevice.current.model.lowercased() == "iphone" {
            tab.viewControllers = [vc1, vc2]
        } else {
            tab.viewControllers = [vc2, vc1]
        }
    
        window?.rootViewController = tab
        */
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        NSLog("App Installed");
        
        return true
    }
    
    
    
    var hasKeyDataTest01AtleastOnce: Bool {
        get {
            return UserDefaults.standard.object(forKey: "keyDataTest01") != nil
        }
    }
    var haskeyDataConfigInPlaceAtleastOnce: Bool {
        get {
            return UserDefaults.standard.object(forKey: "keyDataConfigInPlace") != nil
        }
    }
    var haskeyDataStatisticsAtleastOnce: Bool {
        get {
            return UserDefaults.standard.object(forKey: "keyDataStatistics") != nil
        }
    }
    var haskeyDataStatusAtleastOnce: Bool {
        get {
            return UserDefaults.standard.object(forKey: "keyDataStatus") != nil
        }
    }
    
    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("app is resuming")
    }
    func applicationWillTerminate(_ application: UIApplication) {
        
        
        //salva configurazione attiva
        do {
            let configData = try JSONEncoder().encode(configInPlace)
            UserDefaults.standard.set(configData, forKey: "keyDataConfigInPlace")
            // synchronize is not needed
            //print(configData)
        } catch { print("xxx8 \(error)")}
        //salva statistiche
         do {
             let configData = try JSONEncoder().encode(statistics)
             UserDefaults.standard.set(configData, forKey: "keyDataStatistics")
             // synchronize is not needed
             //print(configData)
         } catch { print("xxx9 \(error)")}
        //salva status work areas
         do {
            
            codableStatus.versioneRunPrecedente = status.versione
            codableStatus.destinazione = status.destinazione
            codableStatus.puntiOrigineDichiarati = status.puntiOrigineDichiarati
            codableStatus.originiNonSelezionabili = status.originiNonSelezionabili
            codableStatus.destinazioniNonSelezionabili = status.destinazioniNonSelezionabili
            codableStatus.destinazioniAttivate = status.destinazioniAttivate
            codableStatus.originiAttivate = status.originiAttivate
            codableStatus.selectedArea = status.selectedArea
            codableStatus.missBeaconsSegmentTuning = status.missBeaconsSegmentTuning
            codableStatus.missFencesSegmentTuning = status.missFencesSegmentTuning
            codableStatus.inFlight = status.inFlight
            codableStatus.origine = status.origine
            codableStatus.percorsoSelezionato = status.percorsoSelezionato
            codableStatus.percorsoTecnico = status.percorsoTecnico
            codableStatus.lunghezzaPercorsoSelezionato = status.lunghezzaPercorsoSelezionato
            codableStatus.possibiliCriteri = status.possibiliCriteri
            codableStatus.possibiliDestinazioniBase = status.possibiliDestinazioniBase
            codableStatus.possibiliDestinazioni = status.possibiliDestinazioni
            codableStatus.possibiliModalita = status.possibiliModalita
            codableStatus.modalita = status.modalita
            codableStatus.criterio = status.criterio
            codableStatus.voiceReaderVolume = status.voiceReaderVolume
            codableStatus.voiceReaderSpeed = status.voiceReaderSpeed
            codableStatus.voiceReaderPaceing = status.voiceReaderPaceing
            codableStatus.voiceRepetitions = status.voiceRepetitions
            codableStatus.voiceReaderCharacter = status.voiceReaderCharacter
            
            codableStatus.possibiliOrigini = status.possibiliOrigini
            codableStatus.possibiliOriginiBase = status.possibiliOriginiBase
            codableStatus.positioningTechnique = status.positioningTechnique
            codableStatus.feedbackMode = status.feedbackMode
            
            codableStatus.prevOrigine = status.origine
            codableStatus.prevDestinazione = status.destinazione
            
            codableStatus.zRTV = status.zRTV
        
            
             let configData = try JSONEncoder().encode(codableStatus)
             UserDefaults.standard.set(configData, forKey: "keyDataStatus")
             // synchronize is not needed
             //print(configData)
         } catch { print("xx10 \(error)")}
        print("app forced closing")
        
    }
    
    // Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Orientamento")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    // Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
}
struct AppDelegate_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
struct AppDelegate_Previews_2: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
    

