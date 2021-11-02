
//
//  FirstViewController.swift
//  Orientamento
//
//  Created by Mauro Antonio Giacomello on 18/02/2020.
//  The name of MAURO ANTONIO GIACOMELLO may not be used to endorse or promote
//  products derived from this software without specific prior written permission.
/*******************************************************************************
* Copyright (c) 2020, 2021  Mauro Antonio Giacomello
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
import Speech
import AVFoundation
import MediaPlayer
import MapKit
// non funziona private let π = Double.pi // pi greco
private let 𝛌 = 0.0 //MATHEMATICAL BOLD SMALL LAMDA   U+1D6CC
private let 𝛗 = 0.0 //MATHEMATICAL BOLD SMALL PHI     U+1D6D7
private let 𝛿 = 0.0  //MATHEMATICAL ITALIC SMALL DELTA U+1D6FF
private let Integral = "∫" // Integrale (U+222B INTEGRAL)
private let ϰ = 0.0 // Kappa
//Add image view properties like this(This is one of the way to add properties).
extension UIImageView {
    //If you want only round corners
    func imgViewCorners() {
        layer.cornerRadius = 10
        layer.borderWidth = 1.0
        layer.masksToBounds = true
    }
}
//****************************************************************************************************//
//****************************************************************************************************//
private let rFIV:CGFloat = -19.0 // it was -19 for iphone 7
private var trimmingSession = 0
private var trimmingSessionTime:Int64 = 0
private var trimmingSessionTitleLabelColor:UIColor? = nil
private let __wildGEOcoord:[[Float]] = [[45.187765,9.157728]]
private let __stackGEOcoord:[[Float]] = [
        [45.186864,9.157828]        // UNIPV09pt 1 obbligatorio
    
                            ]
private var __cliccanum = 0
private var tuneMode = false
struct  _Stroke {
    let startPoint : CGPoint
    let endPoint : CGPoint
    let strokeColor : CGColor
    let lineWidth : CGFloat
}
struct TalkedText {
    var text:String
    var rep:Int
    var time:Double     // millisecs
    var windowtime:Double   // millisecs
}
private var strokes1 = [_Stroke]()  // framework rendering around the image (a square w/ 4 angles)
private var strokes2 = [_Stroke]()  // route rendering (more lines connecting together POIs)
private var _cprx = 0
private var _crds:[Float] = [0,-1,-1]
private var _currentViewHeight:Double = 0
private var _currentViewWidth:Double = 0
private var _angs:[Int] = [-1,-1]
private var _stps:[Int] = [-1,-1]
private var _talkedText:[TalkedText] = []
private var __mSTRtBL_shadow:[String] = []
private var __mSTRtBL:[[Double]] = []
private var __mSTRtBL_ts:[[Double]] = []
private var __mSTRtBL_flag:[Bool] = []
private var __mSTRtBL_signals:[[Any]] = []
extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }
    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}
extension BinaryInteger {
    var degreesToRadians: CGFloat { CGFloat(self) * .pi / 180 }
    var radiansToDegrees: CGFloat { CGFloat(self) * 180 / .pi }
}
extension Decimal {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
extension CGFloat {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
extension CLLocation {
    func movedBy(latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) -> CLLocation {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: abs(latitudinalMeters), longitudinalMeters: abs(longitudinalMeters))
        let latitudeDelta = region.span.latitudeDelta
        let longitudeDelta = region.span.longitudeDelta
        let latitudialSign = CLLocationDistance(latitudinalMeters.sign == .minus ? -1 : 1)
        let longitudialSign = CLLocationDistance(longitudinalMeters.sign == .minus ? -1 : 1)
        let newLatitude = coordinate.latitude + latitudialSign * latitudeDelta
        let newLongitude = coordinate.longitude + longitudialSign * longitudeDelta
        let newCoordinate = CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
        let newLocation = CLLocation(coordinate: newCoordinate, altitude: altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy, course: course, speed: speed, timestamp: Date())
        return newLocation
    }
}
class matchFinderBeaconLvlsVsFence {
    
    private(set) var fenceDa: String
    private(set) var beaconDa: String
    private(set) var lvlsDa: [Double]
    private(set) var fenceA: String
    private(set) var beaconA: String
    private(set) var lvlsA: [Double]
    private(set) var beacon1: [Float]
    private(set) var beacon2: [Float]
    
    init(){
        fenceDa = ""
        beaconDa = ""
        lvlsDa = []
        fenceA = ""
        beaconA = ""
        lvlsA = []
        beacon1 = []
        beacon2 = []
    }
     
    func setMatchFinder(_ fenceDa:String, _ beaconDa:String, _ lvlsDa:[Double], _ fenceA:String, _ beaconA:String, _ lvlsA:[Double], _ beacon:[Float]) {
        self.fenceDa = fenceDa
        self.beaconDa = beaconDa
        self.lvlsDa = lvlsDa
        self.fenceA = fenceA
        self.beaconA = beaconA
        self.lvlsA = lvlsA
        self.beacon1 = beacon
        
        
    }
        
    func counterMatchFinder(_ beacon:[Float]) {
        self.beacon2 = beacon
        
        
    }
    
    func matchFinder() -> Bool {
        if (self.beacon1.count == 0 || self.beacon2.count == 0) {
            
            return false
        }
        
        if ("\(self.beacon1[0])-\(self.beacon1[1])" == self.beaconDa
         && "\(self.beacon2[0])-\(self.beacon2[1])" == self.beaconA) {
            
            
            print("\(self.fenceDa)")
            print("\(self.beaconDa)")
            //print(self.lvlsDa)
            print("\(self.fenceA)")
            print("\(self.beaconA)")
            //print(self.lvlsA)
            //print(self.beacon1)
            //print(self.beacon2)
            
            // beacon in allontanamento minore di ...
            if (self.beacon1[4] <= Float(self.lvlsDa[1])) {
                // beacon in avvicinamento maggiore di ...
                if (self.beacon2[4] >= Float(self.lvlsA[1])) {
                    print("ecce")
                }
            }
            
        }
        
        
        return false
    }
    
}
private var signalsPerDeviceSimple:[[Any]] = []
private func updatePointsSimple(_ beacons:[String],_ maxDepth:Int) -> ([[CGPoint]],[String]) {
    var defIntensity:Float = -70.0
    bscanning: for b in beacons {
        var xx = b.replacingOccurrences(of: "][", with: ",")
        xx = xx.replacingOccurrences(of: "[", with: "")
        xx = xx.replacingOccurrences(of: "]", with: "")
        xx = xx.replacingOccurrences(of: "0-", with: "0,")
        let yy:[String.SubSequence] = xx.split(separator: ",")
        //print(yy)
        defIntensity = Float(yy[4])!
        var done = false
        for (n,d) in signalsPerDeviceSimple.enumerated() {
            if ((d[0] as! String) == "\(String(yy[0]) as String)-\(String(yy[1]) as String)") {
                let nv = signalsPerDeviceSimple[n].count
                let d = nv - (maxDepth+1)
                if (d>0) {
                    for i in 0..<d {
                        signalsPerDeviceSimple[n].remove(at: 1) // number 0 is the label !!
                    }
                }
                signalsPerDeviceSimple[n].append(Float(yy[4]) as Any)
                done = true
            }else{
                let nv = signalsPerDeviceSimple[n].count
                let d = nv - (maxDepth+1)
                if (d>0) {
                    for i in 0..<d {
                        signalsPerDeviceSimple[n].remove(at: 1) // number 0 is the label !!
                    }
                }
            }
        }
        if (!done) {
            signalsPerDeviceSimple.append(["\(String(yy[0]) as String)-\(String(yy[1]) as String)",Float(yy[4]) as Any])
        }
        
    }
    
    
    var MinMax:[Float] = [-0.0,-100.0]
    for vs in signalsPerDeviceSimple  {
        for (n,v) in vs.enumerated() where n > 0 {
            if ((v as! Float) < MinMax[0]) {
                MinMax[0] = v as! Float
            }
            if ((v as! Float) > MinMax[1]) {
                MinMax[1] = v as! Float
            }
        }
    }
    
    var qq:[String] = []
    var tt:[[CGPoint]] = []
    for (i,n) in signalsPerDeviceSimple.enumerated() {
        qq.append(n[0] as! String)
        tt.append([])
        tt[i].append(CGPoint(x: 0, y: Int(MinMax[0]) )) // MIN VALUE
        tt[i].append(CGPoint(x: 0, y: Int(MinMax[1]) )) // MAX VALUE
        for (ii,nn) in n.enumerated() where ii > 0 {
            tt[i].append(CGPoint(x: ii-1, y: Int(nn as! Float) ))
        }
    }
    
    return (tt,qq)
}
class FirstViewController: UIViewController, SFSpeechRecognizerDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate {
    var virtualCoordinate = SetUpTheVirtualCoordinateSystem()
    @IBOutlet weak var titleLabelView: UILabel!
    
    @IBOutlet weak var guidaImageView: UIImageView!
    
    
    
    let player = AVAudioPlayer()
   
    @IBOutlet weak var selectorIcon: UIImageView!
    
    //let slider = UISlider()
    //*mauro*/let slider = UISlider(frame: CGRect(x: 100, y: 0, width: 200, height: 31))
    //let slider = UISlider(frame: CGRect (x: 45,y: 200,width: 310,height: 31))
    
    //let stepper = UIStepper()
    //*mauro*/let stepper = UIStepper(frame: CGRect(x: 0, y: 0, width: 40, height: 12))
   
    
    
    
    
    //@IBOutlet weak var mainMapView: UIImageView!
    
    static let synthesizer = AVSpeechSynthesizer()
    static var saySomethingAgain = true
    static var utterance = AVSpeechUtterance(string: "")
    
    
    func showMessageResetApp(){
        
            let exitAppAlert = UIAlertController(title: NSLocalizedString("frc-exit-001",comment: "forceexit"), message: NSLocalizedString("frc-exit-002",comment: "forceexit"), preferredStyle: .alert)
            let resetApp = UIAlertAction(title: NSLocalizedString("frc-exit-003", comment: "forceexit"), style: .destructive) {
                (alert) -> Void in
                    // home button pressed programmatically - to thorw app to background
                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                    // terminaing app in background
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        exit(EXIT_SUCCESS)
                    })
            }
            
            let laterAction = UIAlertAction(title: NSLocalizedString("frc-exit-004",comment: "forceexit"), style: .cancel) {
                (alert) -> Void in
                //self.dismiss(animated: true, completion: nil)
            }
            
            exitAppAlert.addAction(resetApp)
            exitAppAlert.addAction(laterAction)
            present(exitAppAlert, animated: true, completion: nil)
    }
 
    
    
    override func viewDidLoad() {
       super.viewDidLoad()
        
        selectorIcon.frame = CGRect(x: selectorIcon.frame.minX - (selectorIcon.frame.width / 2) , y: selectorIcon.frame.minY - (selectorIcon.frame.height / 2), width: selectorIcon.frame.width * 2, height: selectorIcon.frame.height * 2)
        
        
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        someImageView.accessibilityElementsHidden = true
        view.addSubview(someImageView) //This add it the view controller without constraints
        
        
        //Create image view simply like this.
        
        let currentWidth = self.view.frame.size.width
        let currentHeight = self.view.frame.size.height
        status._currentWidth = currentWidth
        status._currentHeight = currentHeight
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        let circle = UIView(frame: CGRect(x: (currentWidth-1-80)+20.0, y: 60+20.0, width: 5.0, height: 5.0))
        //circle.center = self.view.center
        circle.layer.cornerRadius = 3
        circle.backgroundColor = UIColor.red
        circle.clipsToBounds = true
        view.addSubview(circle)//Add image to our view
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
         ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
      
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // RemoteCommandCenter ....
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
 
        
        guidaImageView.image = GuidaDataModel.scene.scene1 // ptf giak main scene1
        
        
        
        // to create a new image with something drawn on top
        //guidaImageView.image = createLinesImage(size: guidaImageView.frame.size)
        UIImageView.animate(withDuration: 0.05, delay: 0, options: .curveLinear, animations: {
                // this will change Y position of your imageView center
                // by 1 every time you press button
                self.guidaImageView.center.y -= 0 // !!!
                self.guidaImageView.center.x += 0 // !!!
            }, completion: nil)
        
        
        
        
        
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        let tapMethod = UITapGestureRecognizer(target: self, action: #selector(imageTappedGuida))
        tapMethod.numberOfTapsRequired = 2
        guidaImageView.addGestureRecognizer(tapMethod)
        guidaImageView.isUserInteractionEnabled = true
        
        
        
        
        
        
        /**/
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        _currentViewHeight = virtualCoordinate.getViewHeight()
        _currentViewWidth = virtualCoordinate.getViewWidht()
        
        status.signalProcessor = true
        if (status.fireTimingSignalProcessor == 0) {
            status.fireTimingSignalProcessor = 1
            _ = Timer.scheduledTimer(timeInterval: 0.9, target: self, selector: #selector(FireTimingSignalProcessor), userInfo: nil, repeats: true)
        }else{
            EXIT_FAILURE
        }
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        status.navigatorCockpit.status = true
        if (status.fireTimingNavigatorCockpit == 0) {
            status.fireTimingNavigatorCockpit = 1
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(FireTimingNavigatorCockpit), userInfo: nil, repeats: true)
        }else{
            EXIT_FAILURE
        }
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        if (status.modalita==NSLocalizedString("on-premise", comment: "")
         ) {
            
            
        }
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        /* ?????
         --- Accessibility how to Override the default actions to erogate the right messages ---
        guidaImageView.isAccessibilityElement = true
        guidaImageView.accessibilityTraits = .image
        guidaImageView.accessibilityLabel = "some text i want read aloud"
         ????? */
         
    }
    
    deinit {
       NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func rotatedview() {
        if UIDevice.current.orientation.isLandscape {
            status.rotatedFirstView = true
        } else {
            status.rotatedFirstView = false
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
        
        
        
        if (!status.orentationMapInitialized) {
            if (status.virtualCoordinateActivated==false) {
                virtualCoordinate.setBasicImageReferences( guidaImageView: guidaImageView )
                status.virtualCoordinateActivated = true
            }
            
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            // disegno un cerchio sullo schermo
            
            //circle.center = self.view.center
            let ABCD = virtualCoordinate.getBasicImageReferences( Double(guidaImageView.frame.size.width), Double(guidaImageView.frame.size.height) )
            var nn = 0
            var circles:[UIView] = []
            for cc in ABCD {
                print("ABCD \(cc)")
                circles.append(UIView(frame: CGRect(x: Double(cc[0]), y: Double(cc[1]), width: 5, height: 5)))
                circles[nn].layer.cornerRadius = 3
                circles[nn].backgroundColor = UIColor.black
                circles[nn].clipsToBounds = true
                circles[nn].accessibilityElementsHidden = true
                guidaImageView.addSubview(circles[nn])
                //Add image to our view
                nn += 1
            }
            
            
     
            var CircleLayer   = CAShapeLayer()
            let center = CGPoint (x: guidaImageView.frame.size.width / 2, y: guidaImageView.frame.size.height / 2)
            let circleRadius = guidaImageView.frame.size.width / 2
            let circlePath = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi * 4), clockwise: true)
            CircleLayer.path = circlePath.cgPath
            CircleLayer.strokeColor = UIColor.red.cgColor
            CircleLayer.fillColor = UIColor.red.cgColor
            CircleLayer.lineWidth = 2
            CircleLayer.opacity = 0.05
            CircleLayer.strokeStart = 0
            CircleLayer.strokeEnd  = 1
            guidaImageView.layer.addSublayer(CircleLayer)
     
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            // let square = guidaImageView.fra
            
            strokes1 = []
            
            for subview in guidaImageView.subviews {
                if (subview.tag == 100) {
                    subview.removeFromSuperview()
                }
            }
     
            /// SET IMAGE FRAMES N/S/W/E..NW/NE/SW/SE
            
            
            
            // This would be your mapView, here I am just using a random image
            let lineView1 = LineView1(frame: view.frame)
            lineView1.tag = 100
            guidaImageView.addSubview(lineView1)
            guidaImageView.bringSubviewToFront(lineView1)
            
            print("frame size \(guidaImageView.frame.size)")
            status.orentationMapInitialized = true
            
        }
        
        status.signalProcessorRendering = true
        
        
        
        
    }
    
    /*
    // set the condition to get control after the viewWillLoad
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: "OnAppBecameActive", name: UIApplication.didBecomeActiveNotification, object: nil)
    //refreshView()
    func refreshView()
    {
        //all the code goes here
        print("hey")
    }
    func OnAppBecameActive()
    {
        // Add logic here to check if need to call refresh view method
        //if needToRefreshView
        //{
          refreshView()
        //}
    }
    */
    
    override public func viewWillAppear(_ animated: Bool) {
        // bla bla bla
        // ptf giak giak giak
        
        if (status.forceQuit) {
            showMessageResetApp()
        }
        
        // ====================================================================
        
        if (status.virtualCoordinateActivated==false) {
            virtualCoordinate.setBasicImageReferences( guidaImageView: guidaImageView )
            status.virtualCoordinateActivated = true
        }
                
        print("percorso tecnico counter \(status.percorsoTecnico.count)")
            
        strokes2 = []
        
        for subview in guidaImageView.subviews {
            if (subview.tag == 200) {
                subview.removeFromSuperview()
            }
        }
    
        //let geo:[Float] = virtualCoordinate.getGeoCoordinate(x: 5, y: 7)
        var nn = 0
        var tmpVertice:[Float] = []
        var strokeColor = UIColor.blue.cgColor
        for vertice in status.percorsoTecnicoCoordinate {
            if (nn==0){
                tmpVertice = vertice
            }else{
                
                var _Da: CGPoint = CGPoint( x: 0, y: 0)
                var _A: CGPoint  = CGPoint( x: 0, y: 0)
                
                // procedo via geo coordinate
                
                let xyDa = virtualCoordinate.getPictureOffset(latitude: tmpVertice[0], longitude: tmpVertice[1])
                let xyDaView = virtualCoordinate.getViewOffset(x: xyDa[0], y: xyDa[1])
                _Da = CGPoint( x: xyDaView[0], y: xyDaView[1])
                let xyA = virtualCoordinate.getPictureOffset(latitude: vertice[0], longitude: vertice[1])
                let xyAView = virtualCoordinate.getViewOffset(x: xyA[0], y: xyA[1])
                _A = CGPoint(  x: xyAView[0], y: xyAView[1])
                
                if (status.percorsoTecnicoAttributi[nn-1][0] == status.percorsoTecnicoAttributi[nn][0]) {
                    if (status.percorsoTecnicoAttributi[nn][0]==0) {
                        strokeColor = UIColor.green.cgColor
                    }else{
                        strokeColor = UIColor.blue.cgColor
                    }
                }else{
                    strokeColor = UIColor.red.cgColor
                }
  
                let tappa = _Stroke(startPoint: _Da, endPoint: _A, strokeColor: strokeColor, lineWidth: 2)
                strokes2.append(tappa)
                tmpVertice = vertice
            }
            nn += 1
        }
        
        
        // This would be your mapView, here I am just using a random image
        let lineView2 = LineView2(frame: view.frame)
        lineView2.tag = 200
        guidaImageView.addSubview(lineView2)
        guidaImageView.bringSubviewToFront(lineView2)
        
        
        // update navigator cockpit status
        
        status.navigatorCockpit.suspended = false
        
        
    }
 
    override public func viewWillDisappear(_ animated: Bool) {
        // bla bla bla
        // ptf giak giak giak
        
        status.signalProcessorRendering = false
        
        status.navigatorCockpit.suspended = true
        
        
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        status._touches.append(contentsOf: touches)
        if let touch = touches.first {
            status._touchesLocations.insert(touch.preciseLocation(in: view), at: 0)
            print("touch bgnn \(String.init(describing: touch))")
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {
            let index = status._touches.firstIndex(of: $0)
            print("touch mvdd \(String.init(describing: index))")
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {
            let index = status._touches.firstIndex(of: $0)
            print("touch endd \(String.init(describing: index))")
        }
    }
    
    class LineView1 : UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        override func draw(_ rect: CGRect) {
            for stroke in strokes1 {
                if let context = UIGraphicsGetCurrentContext() {
                    context.setStrokeColor(stroke.strokeColor) //UIColor.blue.cgColor)
                    context.setLineWidth(stroke.lineWidth)
                    context.beginPath()
                    context.move(to: CGPoint(x: stroke.startPoint.x, y: stroke.startPoint.y)) // This would be oldX, oldY
                    context.addLine(to: CGPoint(x: stroke.endPoint.x, y: stroke.endPoint.y)) // This would be newX, newY
                    context.strokePath()
                }
            }
        }
    }
    
    @objc func sliderChanged() {
        //*mauro*/print("oki \(slider.value)")
    }
        
    @objc func stepperChanged() {
        //*mauro*/print("oki \(stepper.value)")
    }
    
    class LineView2 : UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        override func draw(_ rect: CGRect) {
            for stroke in strokes2 {
                if let context = UIGraphicsGetCurrentContext() {
                    context.setStrokeColor(stroke.strokeColor) //UIColor.blue.cgColor)
                    context.setLineWidth(stroke.lineWidth)
                    context.beginPath()
                    context.move(to: CGPoint(x: stroke.startPoint.x, y: stroke.startPoint.y)) // This would be oldX, oldY
                    context.addLine(to: CGPoint(x: stroke.endPoint.x, y: stroke.endPoint.y)) // This would be newX, newY
                    context.strokePath()
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    @objc func imageTappedGuida(sender: UITapGestureRecognizer) {
        let coord: CGPoint = sender.location(in: self.guidaImageView)
        
        
        
            let _x = coord.x
            let _y = coord.y
   
        
            
            if (status.modalita==NSLocalizedString("pre-simulation", comment: "")) {
                // double tap at pre-simulation time mean "plase go on !"
                status.shakedDevice += 1  // by convention this will enable next step
                
                if (status.routeSegmentF2FUnderTheFocus.count > 0) {
                    if (status.routeSegmentF2FUnderTheFocus.count > 1) {
                        chkfence2: for fa in status.fencingConfiguration {
                            if (fa.id==status.selectedArea){
                                for f in fa.fences {
                                    if (f.id.lowercased() == status.routeSegmentF2FUnderTheFocus[1].lowercased()
                                     || f.alias.lowercased() == status.routeSegmentF2FUnderTheFocus[1].lowercased()) {
                                        
                                        //status.percorsoTecnico
                                        //status.percorsoTecnicoCoordinate
                                        
                                        let xyA = virtualCoordinate.getPictureOffset(latitude: f.lat, longitude: f.lng)
                                        let xyAView = virtualCoordinate.getViewOffset(x: xyA[0], y: xyA[1])
                                        let thisBuble = UIImageView(frame: CGRect(x: xyAView[0]-6, y: xyAView[1]-6, width: 12, height: 12))
                                        thisBuble.image = UIImage(named: "redtarget")
                                        guidaImageView.addSubview(thisBuble)
                                        print("image view counter A \(guidaImageView.subviews.count)")
                                        
                                        break chkfence2
                                        
                                    }
                                }
                            }
                        }
                    }else{
                        chkfence1: for fa in status.fencingConfiguration {
                            if (fa.id==status.selectedArea){
                                for f in fa.fences {
                                    if (f.id.lowercased() == status.routeSegmentF2FUnderTheFocus[0].lowercased()
                                     || f.alias.lowercased() == status.routeSegmentF2FUnderTheFocus[0].lowercased()) {
                                        
                                        //status.percorsoTecnico
                                        //status.percorsoTecnicoCoordinate
                                        
                                        let xyA = virtualCoordinate.getPictureOffset(latitude: f.lat, longitude: f.lng)
                                        let xyAView = virtualCoordinate.getViewOffset(x: xyA[0], y: xyA[1])
                                        let thisBuble = UIImageView(frame: CGRect(x: xyAView[0]-6, y: xyAView[1]-6, width: 12, height: 12))
                                        thisBuble.image = UIImage(named: "redtarget")
                                        guidaImageView.addSubview(thisBuble)
                                        print("image view counter B \(guidaImageView.subviews.count)")
                                        
                                        break chkfence1
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                
            }else{
            
        
                
                
            
            }
            
        
            // mark the position inside the image to give the perception of an reaction to the user
            
            let thisBuble = UIImageView(frame: CGRect(x: _x /*coord.x*/, y: _y /*coord.y*/, width: 9, height: 9))
            thisBuble.image = UIImage(named: "pinkmarker")
            guidaImageView.addSubview(thisBuble)
            print("image view counter C \(guidaImageView.subviews.count)")
        
    }
   
    
    
    
    
    let someImageView: UIImageView = {
        let theImageView = UIImageView()
        theImageView.image = GuidaDataModel.scene.scene1
        
        theImageView.translatesAutoresizingMaskIntoConstraints = false
        return theImageView
     }()
    
    
    
    
    
    
    @objc func FireTimingNavigatorCockpit() {
        status.fireTimingNavigatorCockpit += 1
        
        
        if (status.inFlight == false || status.OTResetRequest) {
            if (status.OTResetRequest) { status.OTResetRequest = false }
            status.navigatorCockpit.houseKeeping = false
            
            aGranVoce("ori-msg-SERVSTOP", 15.00, toErase: "all" ) // operating
            aGranVoce("", 00.00, toErase: "dropAllPendingWords" ) // purge synthesizer
            return
        }
        
        
        
        if (status.navigatorCockpit.houseKeeping==false){
            // first call
            /* PTF GIAK
            aGranVoce("ori-msg-FIRSTRUN", 15.00, toErase: "" )
             */
            status.navigatorCockpit.houseKeeping = true
        }else{
            /* next call
            aGranVoce("ori-msg-LASTRUN", 15.00, toErase: "" )
            */
            
            
            let _o = Double(rowsCol1Order.firstIndex(of: "inst" /*"path"*/ )!) + 1
            let _oo = Double(guidaImageView.frame.width - 10) /* it was 120, then 300*/
            for subview in guidaImageView.subviews {
                if (subview.tag == (400+(Int(_o)*10))) {
                    subview.removeFromSuperview()
                }
            }
            let lab5 = UILabel(frame: CGRect(x: 1, y: _currentViewHeight-2-(8*_o), width: _oo, height: 9))
            lab5.text = String("rc:\(Int(status.navigatorCockpit.c.esitoAttivazione))")
            lab5.textColor = _textDynamicColor // UIColor.black
            lab5.font = UIFont(name:"chalkboard SE", size: 8)
            lab5.tintColor = .red
            lab5.layer.cornerRadius = 0
            lab5.layer.borderWidth = 1
            lab5.layer.borderColor = UIColor.gray.cgColor
            lab5.tag = (400+(Int(_o)*10))
            lab5.isEnabled = false
            lab5.accessibilityElementsHidden = true
            guidaImageView.addSubview(lab5)
        
            let _o2 = Double(rowsCol2Order.firstIndex(of: "wrer" )!) + 1
            for subview in guidaImageView.subviews {
                if (subview.tag == (400+((Int(_o2)*10)+1))) {
                    subview.removeFromSuperview()
                }
            }
            let lab52 = UILabel(frame: CGRect(x: rowsCol1Width[Int(_o2) - 1], y: _currentViewHeight-2-(8*_o2), width: rowsCol2Width[Int(_o2) - 1], height: 9))
            lab52.text = String("\(status.navigatorCockpit.c.motivoAttivazione)")
            lab52.textColor = _textDynamicColor // UIColor.black
            lab52.font = UIFont(name:"chalkboard SE", size: 6)
            lab52.tintColor = .red
            lab52.layer.cornerRadius = 0
            lab52.layer.borderWidth = 1
            lab52.layer.borderColor = UIColor.gray.cgColor
            lab52.tag = (400+((Int(_o2)*10)+1))
            lab52.isEnabled = false
            lab52.accessibilityElementsHidden = true
            guidaImageView.addSubview(lab52)
            if (status.navigatorCockpit.c.testoSegnale.count > 0){
                for subview in guidaImageView.subviews {
                    if (subview.tag == (400+(Int(_o)*10))) {
                        subview.removeFromSuperview()
                    }
                }
                let _o = Double(rowsCol1Order.firstIndex(of: "inst")!) + 1
                let _oo = Double(guidaImageView.frame.width - 10) /* it was 120, then 300*/
                let lab6 = UILabel(frame: CGRect(x: 1, y: _currentViewHeight-2-(8*_o), width: _oo, height: 9))
                lab6.text = String("rc:\(Int(status.navigatorCockpit.c.esitoAttivazione))/\(Int(status.navigatorCockpit.c.esitoSegnale))-\(status.navigatorCockpit.c.testoSegnale[status.navigatorCockpit.c.testoSegnale.count - 1])")
                lab6.textColor = _textDynamicColor // UIColor.black
                lab6.font = UIFont(name:"chalkboard SE", size: 8)
                lab6.tintColor = .red
                lab6.layer.cornerRadius = 0
                lab6.layer.borderWidth = 1
                lab6.layer.borderColor = UIColor.gray.cgColor
                lab6.tag = (400+(Int(_o)*10))
                lab6.isEnabled = false
                lab6.accessibilityElementsHidden = true
                guidaImageView.addSubview(lab6)
                
                let _o2 = Double(rowsCol2Order.firstIndex(of: "wrer" )!) + 1
                for subview in guidaImageView.subviews {
                    if (subview.tag == (400+((Int(_o2)*10)+1))) {
                        subview.removeFromSuperview()
                    }
                }
                let lab62 = UILabel(frame: CGRect(x: rowsCol1Width[Int(_o2) - 1], y: _currentViewHeight-2-(8*_o2), width: rowsCol2Width[Int(_o2) - 1], height: 9))
                lab62.text = String("\(status.navigatorCockpit.c.motivoSegnale)")
                lab62.textColor = _textDynamicColor // UIColor.black
                lab62.font = UIFont(name:"chalkboard SE", size: 6)
                lab62.tintColor = .red
                lab62.layer.cornerRadius = 0
                lab62.layer.borderWidth = 1
                lab62.layer.borderColor = UIColor.gray.cgColor
                lab62.tag = (400+((Int(_o2)*10)+1))
                lab62.isEnabled = false
                lab62.accessibilityElementsHidden = true
                guidaImageView.addSubview(lab62)
                aGranVoce(status.navigatorCockpit.c.testoSegnale[status.navigatorCockpit.c.testoSegnale.count - 1][1] as! String, 15.0, toErase: "")
            }
    
            if (status.routeSegmentF2FUnderTheFocus.count > 0) {
                status.beaconsUnderTheFocus = beaconsUnderTheRouteSegment(status.routeSegmentF2FUnderTheFocus)
                if (status.beaconsUnderTheFocus.count > 0) {
                    let _o21 = Double(rowsCol1Order.firstIndex(of: "bda" )!) + 1
                    for subview in guidaImageView.subviews {
                        if (subview.tag == (400+(Int(_o21)*10))) {
                            subview.removeFromSuperview()
                        }
                    }
                    let lab51 = UILabel(frame: CGRect(x: 1, y: _currentViewHeight-2-(8*_o21), width: rowsCol1Width[Int(_o21) - 1], height: 9))
                    lab51.text = String("\(status.beaconsUnderTheFocus[0])")
                    
                        lab51.textColor = _textDynamicColor // UIColor.black
                    
                    lab51.font = UIFont(name:"chalkboard SE", size: 7)
                    lab51.tintColor = .red
                    lab51.layer.cornerRadius = 0
                    
                        lab51.layer.borderColor = UIColor.gray.cgColor
                        lab51.layer.borderWidth = 1
                    
                    lab51.tag = (400+(Int(_o21)*10))
                    lab51.isEnabled = false
                    lab51.accessibilityElementsHidden = true
                    guidaImageView.addSubview(lab51)
                    if (status.beaconsUnderTheFocus.count > 1) {
                        let _o22 = Double(rowsCol2Order.firstIndex(of: "ba" )!) + 1
                        for subview in guidaImageView.subviews {
                            if (subview.tag == (400+((Int(_o22)*10)+1))) {
                                subview.removeFromSuperview()
                            }
                        }
                        let lab52_ = UILabel(frame: CGRect(x: rowsCol1Width[Int(_o22) - 1], y: _currentViewHeight-2-(8*_o22), width: rowsCol2Width[Int(_o22) - 1], height: 9))
                        lab52_.text = String("\(status.beaconsUnderTheFocus [1])")
                        
                            lab52_.textColor = _textDynamicColor // UIColor.black
                        
                        lab52_.font = UIFont(name:"chalkboard SE", size: 7)
                        lab52_.tintColor = .red
                        lab52_.layer.cornerRadius = 0
                        
                            lab52_.layer.borderColor = UIColor.gray.cgColor
                            lab52_.layer.borderWidth = 1
                        
                        lab52_.tag = (400+((Int(_o22)*10)+1))
                        lab52_.isEnabled = false
                        lab52_.accessibilityElementsHidden = true
                        guidaImageView.addSubview(lab52_)
                    }
                    
                }
                
                let _o23 = Double(rowsCol1Order.firstIndex(of: "from" )!) + 1
                for subview in guidaImageView.subviews {
                    if (subview.tag == (400+(Int(_o23)*10))) {
                        subview.removeFromSuperview()
                    }
                }
                let lab53 = UILabel(frame: CGRect(x: 1, y: _currentViewHeight-2-(8*_o23), width: rowsCol1Width[Int(_o23) - 1], height: 9))
                lab53.text = String("\(status.routeSegmentF2FUnderTheFocus[0])")
                lab53.textColor = _textDynamicColor // UIColor.black
                lab53.font = UIFont(name:"chalkboard SE", size: 7)
                lab53.tintColor = .red
                lab53.layer.cornerRadius = 0
                lab53.layer.borderWidth = 1
                lab53.layer.borderColor = UIColor.gray.cgColor
                lab53.tag = (400+(Int(_o23)*10))
                lab53.isEnabled = false
                lab53.accessibilityElementsHidden = true
                guidaImageView.addSubview(lab53)
            }
            
            
            if (status.routeSegmentF2FUnderTheFocus.count > 1) {
                let _o24 = Double(rowsCol2Order.firstIndex(of: "to" )!) + 1
                for subview in guidaImageView.subviews {
                    if (subview.tag == (400+((Int(_o24)*10)+1))) {
                        subview.removeFromSuperview()
                    }
                }
                let lab54 = UILabel(frame: CGRect(x: rowsCol1Width[Int(_o24) - 1], y: _currentViewHeight-2-(8*_o24), width: rowsCol2Width[Int(_o24) - 1], height: 9))
                lab54.text = String("\(status.routeSegmentF2FUnderTheFocus[1])")
                lab54.textColor = _textDynamicColor // UIColor.black
                lab54.font = UIFont(name:"chalkboard SE", size: 7)
                lab54.tintColor = .red
                lab54.layer.cornerRadius = 0
                lab54.layer.borderWidth = 1
                lab54.layer.borderColor = UIColor.gray.cgColor
                lab54.tag = (400+((Int(_o24)*10)+1))
                lab54.isEnabled = false
                lab54.accessibilityElementsHidden = true
                guidaImageView.addSubview(lab54)
            }
            
        }
        
        if (status.navigatorCockpit.suspended == false) {
            // operating (Orientation panel displayed)
            /* PTF GIAK
            aGranVoce("ori-msg-M0001", 30.00, toErase: "ori-msg-M0002" ) // operating
            */
            
            //*////////////////////////////////////////////////////////////////////////////////////////
            
            threadSafeNavigatorCockpit.lock()
            // segnale beacon proveniente da uno dei beacon
            //          presenti nell'area selezionata ?
            //          coinvolti nel percorso ?
            //
            // BOHHH ??? dovrei verificare meglio
            //
            // per ora verifico che beacon sia appartenente all'area selezionata
            //
            // in seguito verificherò che appartenga al percorso selezionato (dovrebbe già essere così)
            //
            
            //PTFGIAK-MUTED print("xx30 \(status.navigatorCockpit.beaconInProximity.count)|\(status.navigatorCockpit.beaconInRange.count)|\(status.navigatorCockpit.beaconAtTheHorizon.count)")
            // applicabile il picking dei segnali diretti ai beacon sotto osservazione ??????
            if (status.routeSegmentF2FUnderTheFocus.count > 0) {
                var bt = ""
                if (status.routeSegmentF2FUnderTheFocus.count > 1) {
                    bt = fence2beacon(status.routeSegmentF2FUnderTheFocus[1])
                }else{
                    bt = fence2beacon(status.routeSegmentF2FUnderTheFocus[0])
                }
                if (bt != "") {
                    var tmp:[[Float]] = [[],[],[],]
                    // pickup (if any) the beacon subtended by the fence in place (target) to speedup the process
                    for b in status.navigatorCockpit.beaconInProximity {
                        let k = "\(b[0])-\(b[1])"
                        if (k == bt) {  // found !!!
                            // elimino tutti rimanenti beacon dalla lista/liste
                            tmp[0] = b
                            break
                        }
                    }
                    if (tmp[0].count == 0) {
                        for b in status.navigatorCockpit.beaconInRange {
                            let k = "\(b[0])-\(b[1])"
                            if (k == bt) {  // found !!!
                                // elimino tutti rimanenti beacon dalla lista/liste
                                tmp[1] = b
                                break
                            }
                        }
                    }
                    if (tmp[0].count == 0 && tmp[1].count == 0) {
                        for b in status.navigatorCockpit.beaconAtTheHorizon {
                            let k = "\(b[0])-\(b[1])"
                            if (k == bt) {  // found !!!
                                // elimino tutti rimanenti beacon dalla lista/liste
                                tmp[2] = b
                                break
                            }
                        }
                    }
                    // se alla fine ho trovato almeno un beacon sotteso dal fence target allora elimino gli altri segnali sicchè da contenere entropia (efesto si incazza se riceve segnali scoposto o fuori sequenza
                    if (tmp[0].count > 0 || tmp[1].count > 0 || tmp[2].count > 0) {
                        status.navigatorCockpit.beaconInProximity = []
                        status.navigatorCockpit.beaconInRange = []
                        status.navigatorCockpit.beaconAtTheHorizon = []
                        if (tmp[0].count > 0) {
                            status.navigatorCockpit.beaconInProximity.append(tmp[0])
                        }
                        if (tmp[1].count > 0) {
                            status.navigatorCockpit.beaconInRange.append(tmp[1])
                        }
                        if (tmp[2].count > 0) {
                            status.navigatorCockpit.beaconAtTheHorizon.append(tmp[2])
                        }
                    }
                }
            }
            
            
            var alreadySignaled = false
            
            
            //*////////////////////////////////////////////////////////////////////////////////////////
            
            loppaIP: for (nb, b) in status.navigatorCockpit.beaconInProximity.enumerated() where alreadySignaled == false {
                for (nba,ba) in status.beaconConfiguration.enumerated() {
                    if (ba.id==status.selectedArea){
                        //print(ba.beacon.count)
                        for (nbe,be) in ba.beacons.enumerated() {
                            
                            //PTFGIAK-MUTED print("mjr \(b[0]) mnr \(be.mjr) mjr \(b[1]) mnr \(be.mnr)")
                            if (Float(b[0])==Float(be.mjr) && Float(b[1])==Float(be.mnr)) {
                                aGranVoce("beacon \(Int(b[0]))-\(Int(b[1])) in proximity", 5.00, toErase: "" ) // operating
                                status.navigatorCockpit.lastSignaledBeacon = b
                                
                                let fire = "cmd=PRX,UNQKK,>\(b[0])@1\(b[1])@2\(be.lat)@3\(be.lng)@4\(be.floor)@5\(b[2])@6\(b[3])@7\(b[4])@8\(b[5])<"
                                let myRouteNotificationKey = "RouteMGMT"
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: myRouteNotificationKey), object: nil, userInfo: ["name":fire])
                                // mjr, mnr,lat,lng,floor,distance,meters,intensity,distance2
                                
                                
                                alreadySignaled = true
                                
                                break loppaIP
                                
                            }
                            
                        }
                    }
                }
     
            }
            status.navigatorCockpit.beaconInProximity = []
            
            //*////////////////////////////////////////////////////////////////////////////////////////
            
            loppaIR: for (nb, b) in status.navigatorCockpit.beaconInRange.enumerated() where alreadySignaled == false {
                for (nba,ba) in status.beaconConfiguration.enumerated() {
                    if (ba.id==status.selectedArea){
                        //print(ba.beacon.count)
                        for (nbe,be) in ba.beacons.enumerated() {
                            
                            //PTFGIAK-MUTED print("mjr \(b[0]) mnr \(be.mjr) mjr \(b[1]) mnr \(be.mnr)")
                            if (Float(b[0])==Float(be.mjr) && Float(b[1])==Float(be.mnr)) {
                                aGranVoce("beacon \(Int(b[0]))-\(Int(b[1])) in range", 5.00, toErase: "" ) // operating
                                status.navigatorCockpit.lastSignaledBeacon = b
                                
                                let fire = "cmd=PRX,UNQKK,>\(b[0])@1\(b[1])@2\(be.lat)@3\(be.lng)@4\(be.floor)@5\(b[2])@6\(b[3])@7\(b[4])@8\(b[5])<"
                                let myRouteNotificationKey = "RouteMGMT"
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: myRouteNotificationKey), object: nil, userInfo: ["name":fire])
                                // mjr, mnr,lat,lng,floor,distance,meters,intensity,distance2
                                
                                
                                alreadySignaled = true
                                
                                break loppaIR
                                
                            }
                            
                        }
                    }
                }
     
            }
            status.navigatorCockpit.beaconInRange = []
            
            //*////////////////////////////////////////////////////////////////////////////////////////
  
            alreadySignaled = true // non segnalo i beacon at the orizion
            
            loppaATO: for (nb, b) in status.navigatorCockpit.beaconAtTheHorizon.enumerated() where alreadySignaled == false {
                for (nba,ba) in status.beaconConfiguration.enumerated() {
                    if (ba.id==status.selectedArea){
                        //print(ba.beacon.count)
                        for (nbe,be) in ba.beacons.enumerated() {
                            
                            //PTFGIAK-MUTED print("mjr \(b[0]) mnr \(be.mjr) mjr \(b[1]) mnr \(be.mnr)")
                            if (Float(b[0])==Float(be.mjr) && Float(b[1])==Float(be.mnr)) {
                                aGranVoce("beacon \(Int(b[0]))-\(Int(b[1])) at the horizon", 5.00, toErase: "" ) // operating
                                status.navigatorCockpit.lastSignaledBeacon = b
                                
                                let fire = "cmd=PRX,UNQKK,>\(b[0])@1\(b[1])@2\(be.lat)@3\(be.lng)@4\(be.floor)@5\(b[2])@6\(b[3])@7\(b[4])@8\(b[5])<"
                                let myRouteNotificationKey = "RouteMGMT"
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: myRouteNotificationKey), object: nil, userInfo: ["name":fire])
                                // mjr, mnr,lat,lng,floor,distance,meters,intensity,distance2
                                
                                
                                alreadySignaled = true
                                
                                break loppaATO
                                
                            }
                            
                        }
                    }
                }
     
            }
            status.navigatorCockpit.beaconAtTheHorizon = []
            
            
            
            //*////////////////////////////////////////////////////////////////////////////////////////
  
            if (status.navigatorCockpit.geoSignal.count > 0) {
                aGranVoce("GPS coordinates", 5.00, toErase: "" ) // operating
                let fire = "cmd=GPS,UNQKK,>\(status.navigatorCockpit.geoSignal[1])@1\(status.navigatorCockpit.geoSignal[2])<"
                let myRouteNotificationKey = "RouteMGMT"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: myRouteNotificationKey), object: nil, userInfo: ["name":fire])
     
            }
            status.navigatorCockpit.geoSignal = []
            
            //*////////////////////////////////////////////////////////////////////////////////////////
  
            if (status.navigatorCockpit.forcedGEOsignal.count > 0) {
                aGranVoce("forced GEO coordinates", 5.00, toErase: "" ) // operating
                let fire = "cmd=GEO,UNQKK,>\(status.navigatorCockpit.forcedGEOsignal[0])@1\(status.navigatorCockpit.forcedGEOsignal[1])<"
                let myRouteNotificationKey = "RouteMGMT"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: myRouteNotificationKey), object: nil, userInfo: ["name":fire])
     
            }
            status.navigatorCockpit.forcedGEOsignal = []
            
            //*////////////////////////////////////////////////////////////////////////////////////////
            
            
  
            threadSafeNavigatorCockpit.unlock()
            
        }else{
            
            // mot operating (Orientation panel not displayed)
            /* PTF GIAK
            aGranVoce("ori-msg-M0002", 60.00, toErase: "ori-msg-M0001") // not operating
            */
            
        }
    
    }
    
    /*
    func getPiranhaConfig(_ configFileURL:URL) throws -> PiranhaConfig {
        let config = try PiranhaConfigProviderDefaultImpl().config(fromFileURL: configFileURL)
        return config
    }
    */
    
    
    @objc func FireTimingSignalProcessor()
    {
        
        status.fireTimingSignalProcessor += 1
            
        // routine di rendering dei dati presenti nell'array retrievedData
        // caricato in memoria dalla procedura di lettura del file di log
        // al fin della visualizzazione dei dati loggati i fase di sniffing dalla funzione sniffer"
        
        threadSafeSignalProcessor.lock()
        
        var _ctl_rendering_BEACON = false
    
        if (status.signalProcessor && status.signalProcessorRendering) {
            for (index, segnale) in status.retrievedData.enumerated() where index >= Int(status.lastSignalProcessed.generic) {
                
                
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
                                print("hai hai forced signal strength to -100 [A]")
                                o5 = -100
                            }
                            
                            //print("beacon: \(uuid) \(o1) \(o2) \(o3) \(o4) \(o5) \(o6)")
                            status.signalsBEACONdata.append([tme,uuid,o1,o2,o3,o4,o5,o6])
                            
                            status.lastSignalProcessed.beacons = Double(index)
                            _ctl_rendering_BEACON = true
                            
                        }else{
                            
                            
                                
                                if (segnale.contains("device shaked")){
                                    // setup step by step advancing
                                    //status.shakedDevice = Date().toMillisDouble()
                                    status.shakedDevice += 1
                                }else{
                                    status.lastSignalProcessed.others = Double(index)
                                    print("segnale \(segnale)")
                                }
                                
                            
                            
                        }
                        
                    
                    
                
                
            }
            
            status.lastSignalProcessed.generic = Double(status.retrievedData.count)
            // !!! LOOP !!!! status.retrievedData.append("01:02:03.444: acc non pisco nulla") // test
            
            
            if (_ctl_rendering_BEACON) {
                _ctl_rendering_BEACON = false
                
                renderingOfSignalProcessed("prx", false)
            }
            
        }
        
        var min = Double(999999999)
        if (status.lastSignalProcessed.beacons > 0 &&
                status.lastSignalProcessed.beacons < min) {
                min = status.lastSignalProcessed.beacons
            }
        if (status.lastSignalProcessed.dusts > 0 &&
                status.lastSignalProcessed.dusts < min) {
                min = status.lastSignalProcessed.dusts
            }
        if (status.lastSignalProcessed.generic > 0 &&
                status.lastSignalProcessed.generic < min) {
                min = status.lastSignalProcessed.generic
            }
        
        if (status.lastSignalProcessed.others > 0 &&
                status.lastSignalProcessed.others < min) {
                min = status.lastSignalProcessed.others
            }
        if (min<999999999){
            if (min > 14){
                min -= 7
            }else{
                min = 0
            }
            
            if (status.lastSignalProcessed.beacons > 0){
                status.lastSignalProcessed.beacons -= min
                }
            if (status.lastSignalProcessed.dusts > 0) {
                status.lastSignalProcessed.dusts -= min
                }
            if (status.lastSignalProcessed.generic > 0) {
                status.lastSignalProcessed.generic -= min
                }
            
            if (status.lastSignalProcessed.others > 0) {
                status.lastSignalProcessed.others -= min
                }
            for i in 0..<Int(min) {
                status.retrievedData.remove(at: 0)
            }
        }
        
        threadSafeSignalProcessor.unlock()
    }
    
    func angleDifference(_ _a1: Float,_ _a2: Float) -> Float {
        var a1 = _a1
        var a2 = _a2
        
        /*
        if (a1>180) {
            a1 = ( a1 - 180 ) * (-1)
        }
        if (a2>180) {
            a2 = ( a2 - 180 ) * (-1)
        }
 */
        
          let diff = (a2 - a1).truncatingRemainder(dividingBy: 360)
          if diff < -180.0 {
            return 360.0 + diff
          } else if diff > 180.0 {
            return -360.0 + diff
          } else {
            return diff
          }
             
    }
    
    
    func renderingOfSignalProcessed (_ type: String, _ reset: Bool) {
        
        
        
        
        
        
        if (type == "prx"){
            _cprx += 1
            
            var beaconSignalsToBeNotified:[[Float]] = []
            
            //print("number of signaled beacons \(status.signalsBEACONdata.count)")
            
            for (n,f) in __mSTRtBL_flag.enumerated() {
                __mSTRtBL_flag[n] = false
            }
            for b in status.signalsBEACONdata {
                let k = "\(b[2] as! Float)-\(b[3] as! Float)"
                if let i = __mSTRtBL_shadow.firstIndex(where: {$0 == k}) {
                    __mSTRtBL[i].append( Double( b[6] as! Float ) )
                    __mSTRtBL_ts[i].append( Double( b[0] as! Double ) )
                    __mSTRtBL_flag[i] = true
                    __mSTRtBL_signals[i] = b
                }else{
                    __mSTRtBL_shadow.append(k)
                    __mSTRtBL.append([Double( b[6] as! Float )])
                    __mSTRtBL_ts.append([Double( b[0] as! Double )])
                    __mSTRtBL_flag.append(true)
                    __mSTRtBL_signals.append(b)
                }
            }
            
            let ts:Int64 = Date().toMillis()
            nextbeacon: for (n,k) in __mSTRtBL_shadow.enumerated().reversed() {
                // rimuovo slot non utilizzati
                if (__mSTRtBL[n].count == 0) {
                    __mSTRtBL_shadow.remove(at: n)
                    __mSTRtBL.remove(at: n)
                    __mSTRtBL_ts.remove(at: n)
                    __mSTRtBL_flag.remove(at: n)
                    __mSTRtBL_signals.remove(at: n)
                    continue nextbeacon
                }else{
                    // rimuovo tutto ciò che è più vecchio di 15 secs
                    //print("tstmp \(ts) tstmp \(__mSTRtBL_ts[n][0]) delta \(Double(ts)-__mSTRtBL_ts[n][0])")
                    while(Double(Double(ts) - __mSTRtBL_ts[n][0]) > 15000) {
                        __mSTRtBL[n].remove(at: 0)
                        __mSTRtBL_ts[n].remove(at: 0)
                        if (__mSTRtBL[n].count == 0) {
                            __mSTRtBL_shadow.remove(at: n)
                            __mSTRtBL.remove(at: n)
                            __mSTRtBL_ts.remove(at: n)
                            __mSTRtBL_flag.remove(at: n)
                            __mSTRtBL_signals.remove(at: n)
                            continue nextbeacon
                        }
                    }
                }
                //print("number of survived signaled beacons \(status.signalsBEACONdata.count)")
                // ri-calcolo
                if (__mSTRtBL_flag[n] == true) {
                        
                        __mSTRtBL_signals[n][6] = Float(__mSTRtBL[n][__mSTRtBL[n].count - 1])
                    
                }
            }
            status.signalsBEACONdata = __mSTRtBL_signals
            
            /*
             test
             */
            if (status.signalsBEACONdata.count > 0){
                if let r = status.signalsBEACONdata.firstIndex(where: {$0[2] as! Float == Float(4.0) && $0[3] as! Float == Float(18.0) }) {
                    if (status.signalsBEACONdata[r][6] as! Float >= Float(-75.0)) {
                        print("io sono qui \(status.signalsBEACONdata[r])")
                    }
                }
            }
            
            //***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-***-
            
            var _idx = status.signalsBEACONdata.count
            
            _idx = 0
            for (idx, beacon) in status.signalsBEACONdata.enumerated() where idx >= _idx {
                for (nba,ba) in status.beaconConfiguration.enumerated() {
                    if (ba.id==status.selectedArea){
                        //print(ba.beacon.count)
                        for (nb,b) in ba.beacons.enumerated() {
                            
                            if (Float(b.mjr)==beacon[2] as! Float && Float(b.mnr)==beacon[3] as! Float){
                                var done = false
                                for (i,bcn) in beaconSignalsToBeNotified.enumerated() {
                                    if ((bcn[0] == beacon[2] as! Float)
                                     && (bcn[1] == beacon[3] as! Float)) {
                                        beaconSignalsToBeNotified[i][2] = beacon[4] as! Float
                                        beaconSignalsToBeNotified[i][3] = beacon[5] as! Float
                                        beaconSignalsToBeNotified[i][4] = beacon[6] as! Float
                                        beaconSignalsToBeNotified[i][5] = beacon[7] as! Float
                                        done = true
                                        break
                                    }
                                }
                                if (done==false){
                                    beaconSignalsToBeNotified.append([beacon[2] as! Float, beacon[3] as! Float, beacon[4] as! Float, beacon[5] as! Float, beacon[6] as! Float, beacon[7] as! Float])
                                }
                                break
                            }
                        }
                    }
                }
            }
                
            //print("beacon signal to be notified \(beaconSignalsToBeNotified)")
            beaconSignalsToBeNotified.sort(by: {$0[4]>$1[4]}) // ordine per intensità (utile?)
            threadSafeNavigatorCockpit.lock()
            status.navigatorCockpit.beaconInProximity = []
            status.navigatorCockpit.beaconInRange = []
            status.navigatorCockpit.beaconAtTheHorizon = []
            threadSafeNavigatorCockpit.unlock()
            
            
            var sensitivityLevelDa0  = 0.0 // "right here"
            var sensitivityLevelDa1  = 0.0 // "near"
            var sensitivityLevelDa2  = 0.0 // "far"
            var sensitivityBeaconDaID = ""
            
            var sensitivityLevelA0  = 0.0 // "right here"
            var sensitivityLevelA1  = 0.0 // "near"
            var sensitivityLevelA2  = 0.0 // "far"
            var sensitivityBeaconAID = ""
            
            var sensitivityLevelS0  = 0.0 // "right here"
            var sensitivityLevelS1  = 0.0 // "near"
            var sensitivityLevelS2  = 0.0 // "far"
            var sensitivityBeaconSID = ""
            
            var displayForcedBeacon = ""
            
            let matcher = matchFinderBeaconLvlsVsFence()
            for bea in beaconSignalsToBeNotified {
                
                if ("\(bea[0])-\(bea[1])" == "4.0-10.0"
                 || "\(bea[0])-\(bea[1])" == "4.0-50.0"
                ){
                    print("bea bea chesta beaconasa ... \(bea)")
                }
                
                
                if ("\(bea[0])-\(bea[1])" == sensitivityBeaconDaID
                 || "\(bea[0])-\(bea[1])" == sensitivityBeaconAID
                 || "\(bea[0])-\(bea[1])" == sensitivityBeaconSID){
                    // non già identificato in un giro precedente del loop
                    // strano modo di gestire il tutto ma va bene basta che funzioni
                }else{
                    // partendo dai fence coinvolti arrivo ai beacon
                    trovato: if (status.routeSegmentF2FUnderTheFocus.count > 0) {
                        var bDa = ""
                        var bA = ""
                        if (status.routeSegmentF2FUnderTheFocus.count > 1) {
                            // due fence > due beacon, caso Da -> A ottimo
                            // vediamo se esiste tuning segnali a livello segmento
                            bDa = fence2beacon(status.routeSegmentF2FUnderTheFocus[0])
                            bA = fence2beacon(status.routeSegmentF2FUnderTheFocus[1])
                            if (bA == "" && bDa != "") {
                                bA = bDa
                            }
                            // scandisco elenco dei tuning da-a effettuati
                            for rst in status.routeSegmentsTuning {
                                if (rst.da==bDa && rst.a==bA){
                                    // trovato tuning per coppia beacon da-a
                                    
                                    sensitivityLevelDa0 = rst.outDa[0]
                                    sensitivityLevelDa1 = rst.outDa[1]
                                    sensitivityLevelDa2 = rst.outDa[2]
                                    sensitivityBeaconDaID = bDa
                                   
                                    sensitivityLevelA0 = rst.inA[0]
                                    sensitivityLevelA1 = rst.inA[1]
                                    sensitivityLevelA2 = rst.inA[2]
                                    sensitivityBeaconAID = bA
                                    
                                    displayForcedBeacon = bA
                                    
                                    
                                    
                                    matcher.setMatchFinder( status.routeSegmentF2FUnderTheFocus[0],
                                                       bDa,
                                                       rst.outDa,
                                                       status.routeSegmentF2FUnderTheFocus[1],
                                                       bA,
                                                       rst.inA,
                                                       bea)
                                    
                                    break trovato
                                }
                            }
                            // for further optimizations...
                            if (bDa != "" && bA != "" && bDa != bA) {
                                let k = "\(bDa)@\(bA)"
                                if let kr = status.missBeaconsSegmentTuning.firstIndex(where: {$0 == k}) {
                                    // ok already inserted
                                    status.missFencesSegmentTuning[kr] = "\(status.routeSegmentF2FUnderTheFocus[0])-\(status.routeSegmentF2FUnderTheFocus[1])"
                                }else{
                                    status.missBeaconsSegmentTuning.append(k)
                                    status.missFencesSegmentTuning.append("\(status.routeSegmentF2FUnderTheFocus[0])@\(status.routeSegmentF2FUnderTheFocus[1])")
                                }
                            }
                        }else{
                            // un solo beacon, caso particolare
                            bA = fence2beacon(status.routeSegmentF2FUnderTheFocus[0])
                        }
                        
                        
                        
                        if let row = status.beaconsTuning.firstIndex(where: {$0.id == bA}) {
                            sensitivityLevelS0 = status.beaconsTuning[row].entering[0]
                            sensitivityLevelS1 = status.beaconsTuning[row].entering[1]
                            sensitivityLevelS2 = status.beaconsTuning[row].entering[2]
                            sensitivityBeaconSID = bA
                            
                            
                            break trovato
                            
                        }
                        
                        
                        // .. poi nella stessa status.beaconConfiguration
                        
                        let mJR = Float(estraiStringa(bA, "[", "-"))
                        let mNR = Float(estraiStringa(bA, "-", "]"))
                        stopSearch: for (nba,ba) in status.beaconConfiguration.enumerated() {
                            if (ba.id==status.selectedArea){
                                //print(ba.beacon.count)
                                for (nb,b) in ba.beacons.enumerated() {
                                    if (Float(b.mjr) == mJR && Float(b.mnr) == mNR){
                                        // PTFGIAK-MUTED print("tuned beacon \(b)")
                                        if (b.bRTV[0] != 0.0 || b.bRTV[1] != 0.0 || b.bRTV[2] != 0.0){
                                            // tuning override sounds good
                                            sensitivityLevelS0 = Double(b.bRTV[0])
                                            sensitivityLevelS1 = Double(b.bRTV[1])
                                            sensitivityLevelS2 = Double(b.bRTV[2])
                                            sensitivityBeaconSID = "\(b.mjr)-\(b.mnr)"
                                            
                            
                                            break stopSearch
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                matcher.counterMatchFinder(bea)
                var sensitivityLevel0  = 0.0 // "right here"
                var sensitivityLevel1  = 0.0 // "near"
                var sensitivityLevel2  = 0.0 // "far"
                var sensitivityBeaconID = ""
                
                if ("\(bea[0])-\(bea[1])" == sensitivityBeaconAID) {
                    sensitivityBeaconID = sensitivityBeaconAID
                    sensitivityLevel0  = sensitivityLevelA0 // "right here"
                    sensitivityLevel1  = sensitivityLevelA1 // "near"
                    sensitivityLevel2  = sensitivityLevelA2 // "far"
                    sensitivityBeaconAID = ""
                }
                if ("\(bea[0])-\(bea[1])" == sensitivityBeaconDaID) {
                    sensitivityBeaconID = sensitivityBeaconDaID
                    sensitivityLevel0  = sensitivityLevelDa0 // "right here"
                    sensitivityLevel1  = sensitivityLevelDa1 // "near"
                    sensitivityLevel2  = sensitivityLevelDa2 // "far"
                    sensitivityBeaconDaID = ""
                }
                if ("\(bea[0])-\(bea[1])" == sensitivityBeaconSID) {
                    sensitivityBeaconID = sensitivityBeaconSID
                    sensitivityLevel0  = sensitivityLevelS0 // "right here"
                    sensitivityLevel1  = sensitivityLevelS1 // "near"
                    sensitivityLevel2  = sensitivityLevelS2 // "far"
                    sensitivityBeaconSID = ""
                }
                
                
                
                
            
                if ("\(bea[0])-\(bea[1])" == sensitivityBeaconID){
                    if (bea[4] >= Float(sensitivityLevel0)) { // intensity
                        threadSafeNavigatorCockpit.lock()
                        status.navigatorCockpit.beaconInProximity.append(bea)
                        threadSafeNavigatorCockpit.unlock()
                    }
                    else{
                        if (bea[4] >= Float(sensitivityLevel1)) { // intensity
                            threadSafeNavigatorCockpit.lock()
                            status.navigatorCockpit.beaconInRange.append(bea)
                            threadSafeNavigatorCockpit.unlock()
                        }else{
                            if (bea[4] >= Float(sensitivityLevel2)) { // intensity
                                threadSafeNavigatorCockpit.lock()
                                status.navigatorCockpit.beaconAtTheHorizon.append(bea)
                                threadSafeNavigatorCockpit.unlock()
                            }else{
                                status.navigatorCockpit.beaconInTheMist += 1
                            }
                            
                        }
                    }
                }
                else //=========================================================================
                {
                
                    if (bea[4] >= status.zRTV[0]) { // intensity
                        threadSafeNavigatorCockpit.lock()
                        status.navigatorCockpit.beaconInProximity.append(bea)
                        threadSafeNavigatorCockpit.unlock()
                        
                    }else{
                    
                        if (bea[4] >= status.zRTV[1]) { // intensity
                            threadSafeNavigatorCockpit.lock()
                            status.navigatorCockpit.beaconInRange.append(bea)
                            threadSafeNavigatorCockpit.unlock()
                            
                        }else{
                        
                            if (bea[4] >= status.zRTV[2]) { // intensity
                                threadSafeNavigatorCockpit.lock()
                                status.navigatorCockpit.beaconAtTheHorizon.append(bea)
                                threadSafeNavigatorCockpit.unlock()
                                
                            }else{
                                
                                status.navigatorCockpit.beaconInTheMist += 1
                            
                            }
                        }
                    }
                }
            }
            
            
            
            let what = matcher.matchFinder()
            // rendering on the screen of the scenario
            
            var wb:[Float] = []
            cosapresento: if (displayForcedBeacon != "") {
                for n in status.navigatorCockpit.beaconInProximity {
                    if ("\(n[0])-\(n[1])" == displayForcedBeacon) {
                        wb = n
                        break cosapresento
                    }
                }
                for n in status.navigatorCockpit.beaconInRange {
                    if ("\(n[0])-\(n[1])" == displayForcedBeacon) {
                        wb = n
                        break cosapresento
                    }
                }
                for n in status.navigatorCockpit.beaconAtTheHorizon {
                    if ("\(n[0])-\(n[1])" == displayForcedBeacon) {
                        wb = n
                        break cosapresento
                    }
                }
            }
            if (wb.count == 0) {
                var n = status.navigatorCockpit.beaconInProximity.count
                if (n>0) {
                    wb = status.navigatorCockpit.beaconInProximity[n-1]
                }else{
                    n = status.navigatorCockpit.beaconInRange.count
                    if (n>0){
                        wb = status.navigatorCockpit.beaconInRange[n-1]
                    }else{
                        n = status.navigatorCockpit.beaconAtTheHorizon.count
                        if (n>0){
                            wb = status.navigatorCockpit.beaconAtTheHorizon[n-1]
                        }
                    }
                }
            }
            
            if (wb.count>0){
                let _o = Double(rowsCol1Order.firstIndex(of: "prx")!) + 1
                for subview in guidaImageView.subviews {
                    if (subview.tag == (400+(Int(_o)*10))) {
                        subview.removeFromSuperview()
                    }
                }
                var text4:String = ""
                let x1:Int = Int(wb[0])
                let x2:Int = Int(wb[1])
                let x3:Int = Int(wb[2])
                let x4:Float = wb[3]
                let x5:Int = Int(wb[4])
                let x6:Int = Int(wb[5])
                text4 = String("prx:(\(x1)/\(x2)),\(x3),\(x4),\(x5),\(x6)")
                let lab4 = UILabel(frame: CGRect(x: 1, y: _currentViewHeight-2-(8*_o), width: rowsCol1Width[Int(_o) - 1], height: 9))
                lab4.text = text4
                lab4.textColor = _textDynamicColor // UIColor.black
                lab4.font = UIFont(name:"chalkboard SE", size: 8)
                lab4.tintColor = .red
                lab4.layer.cornerRadius = 0
                lab4.layer.borderWidth = 1
                lab4.layer.borderColor = UIColor.gray.cgColor
                lab4.tag = (400+(Int(_o)*10))
                lab4.isEnabled = false
                lab4.accessibilityElementsHidden = true
                guidaImageView.addSubview(lab4)
            }
        
            
            //print("beacon \(beacon)")
            
        }
          
    }
    
    
    func aGranVoce(_ daGridare: String, _ nonRepeatitionWindow: Float, toErase: String){
        if (toErase == "dropAllPendingWords"){
            FirstViewController.synthesizer.stopSpeaking(at: AVSpeechBoundary.word /*.immediate*/)
            return
        }
        
        var __nonRepeatitionWindow = 0.0
        
        var multiplier:Float = 0.0
        if (status.voiceReaderPaceing > 0.5){
            multiplier = 1.0 + (status.voiceReaderPaceing - 0.5)
        }else{
            multiplier = 1.0 + (status.voiceReaderPaceing - 0.5)
        }
        if (multiplier<0.3) { multiplier = 0.3 }
        else{
            if (multiplier>1.7) { multiplier = 1.700 }
        }
        __nonRepeatitionWindow = Double(nonRepeatitionWindow * multiplier)
        
        let droppedKeywords = [["beacon","proximity"],  // inibisce "beacon xxx in the proximity"
                               ["beacon","range"],      // inibisce "beacon xxx in the range"
                               ["beacon","horizon"],    // inibisce "beacon xxx at the horizon"
                               ["gps","coordinate"],    // inibisce "gps coordinates"
                               ["geo","coordinate"],    // inibisce "geo coordinates"
                               ["fuori","sequenza"],    // inibisce "fuori sequenza"
                               ["mantieni","calma"]     // inibisce "mantieni la calma"
        ]
        
        let letBeeps = [["ori-msg-M0003",codifiedSounds[achievedNextFenceSound],true]]
        
        
        
        // converto in suoni alcuni messaggi
        
        // elimino frasi che contengano tutte le keyword di un gruppo di keyword
        for dks in droppedKeywords {
            var dropped = 0
            for dk in dks {
                if (daGridare.lowercased().contains(dk.lowercased())) {
                    dropped += 1
                }
            }
            if (dropped==dks.count) {
                return
            }
        }
        
        var urlaUrlaCheTiPassa = daGridare
        
        
        
        
        
        var cosaDire = urlaUrlaCheTiPassa
        var parteFissa = urlaUrlaCheTiPassa
        
        
        
        if (toErase.count>0){
            if (toErase.lowercased()=="all".lowercased()){
                _talkedText = []
                return
            }
            for (idx,w) in _talkedText.enumerated() {
                if (w.text.lowercased()==toErase.lowercased()){
                    _talkedText[idx].windowtime = Double(0)
                    break
                }
            }
        }
        
        if (__nonRepeatitionWindow>0){
            let UNIXtime = NSDate().timeIntervalSince1970  // seconds and fractions of second
            let myTimeInterval = TimeInterval(UNIXtime)
            let cUnixTime = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
            //print(cUnixTime)  // UmixTime > GMT+0
            var done = false
            for (idx,w) in _talkedText.enumerated() {
                if (w.text.lowercased()==parteFissa.lowercased()){
                    if (w.time + w.windowtime >= UNIXtime) {
                        return // at this time simply return (nop)
                    }
                    var mrn = 0
                    let anyMxRptNmbr = status.voiceRepetitions
                    if (anyMxRptNmbr == 0) {
                        return
                    }else{
                        let mRN = anyMxRptNmbr
                        let dMRN:Double = Double(String(format:"%.1f", mRN))!
                        if (dMRN >= 1.0) {
                            mrn = 5
                        }else{
                            if (dMRN >= 0.8) {
                                mrn = 4
                            }else{
                                if (dMRN >= 0.6) {
                                    mrn = 3
                                }else{
                                    if (dMRN >= 0.4) {
                                        mrn = 2
                                    }else{
                                        mrn = 1
                                    }
                                }
                            }
                        }
                    }
                    if (_talkedText[idx].rep >= mrn){
                        return
                    }
                    _talkedText[idx].time = UNIXtime
                    _talkedText[idx].rep = _talkedText[idx].rep + 1
                    _talkedText[idx].windowtime = Double(__nonRepeatitionWindow)
                    done = true
                }
            }
            if (done==false){
                _talkedText.append(TalkedText(text: parteFissa, rep: 0, time: UNIXtime, windowtime: Double(__nonRepeatitionWindow)))
            }
            
        }
        
        var progressiveDelay = 0.0
        let frasi = cosaDire.split(separator: "^") // was "."
        let ntf = frasi.count
        for (nf,frase) in frasi.enumerated() {
            FirstViewController.utterance = AVSpeechUtterance(string: NSLocalizedString(String(frase),comment: "orienting"))
            FirstViewController.utterance.voice = AVSpeechSynthesisVoice(language: status.linguaCorrente/*"it-IT"*/)
            FirstViewController.utterance.rate = status.voiceReaderSpeed // 0.50 // 0.66
            FirstViewController.utterance.volume = status.voiceReaderVolume // 0.75
            
            
            
            // tento sostituzione messaggi vocali con suoni systemSoundiD or beep
            var beeppato = false
            for beep in letBeeps {
                var dropped = 0
                if (daGridare.lowercased().contains((beep[0] as! String).lowercased())) {
                    AudioServicesPlaySystemSound (beep[1] as! SystemSoundID)
                    if (beep[2] as! Bool){
                        beeppato = true
                    }
                    break
                }
            }
            if (!beeppato){
                //========================================================================================
                /*?@-@FuncBegin@*/
                //========================================================================================
                
                var tts = 0.0
                
                /*?@-@FuncEnd@*/
                //========================================================================================
                
                DispatchQueue.main.asyncAfter(deadline: .now() + progressiveDelay) {
                    // post-pongo di un secondo per prova
                    FirstViewController.synthesizer.speak(FirstViewController.utterance)
                }
                progressiveDelay += tts
                
                if (ntf > (nf + 1)) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + progressiveDelay) {
                        AudioServicesPlaySystemSound (codifiedBeeps[delayBypased] as! SystemSoundID)
                    }
                }
                
                progressiveDelay += 3.0
                
            }else{
                
                progressiveDelay += 1.0
                
            }
             
        }
        
        
        let _o = Double(rowsCol1Order.firstIndex(of: "voce" )!) + 1
        let _oo = Double(120) /* Double(guidaImageView.frame.width - 10) */
        for subview in guidaImageView.subviews {
            if (subview.tag == (400+(Int(_o)*10))) {
                subview.removeFromSuperview()
            }
        }
        let lab = UILabel(frame: CGRect(x: 1, y: _currentViewHeight-2-(8*_o), width: _oo, height: 9))
        lab.text = String("\(cosaDire)")
        lab.textColor = _textDynamicColor // UIColor.black
        lab.font = UIFont(name:"chalkboard SE", size: 8)
        lab.tintColor = .red
        lab.layer.cornerRadius = 0
        lab.layer.borderWidth = 1
        lab.layer.borderColor = UIColor.gray.cgColor
        lab.tag = (400+(Int(_o)*10))
        lab.isEnabled = false
        lab.accessibilityElementsHidden = true
        guidaImageView.addSubview(lab)
    }
    
    
        
    /**
     Arabic (Saudi Arabia) - ar-SA
     Chinese (China) - zh-CN
     Chinese (Hong Kong SAR China) - zh-HK
     Chinese (Taiwan) - zh-TW
     Czech (Czech Republic) - cs-CZ
     Danish (Denmark) - da-DK
     Dutch (Belgium) - nl-BE
     Dutch (Netherlands) - nl-NL
     English (Australia) - en-AU
     English (Ireland) - en-IE
     English (South Africa) - en-ZA
     English (United Kingdom) - en-GB
     English (United States) - en-US
     Finnish (Finland) - fi-FI
     French (Canada) - fr-CA
     French (France) - fr-FR
     German (Germany) - de-DE
     Greek (Greece) - el-GR
     Hebrew (Israel) - he-IL
     Hindi (India) - hi-IN
     Hungarian (Hungary) - hu-HU
     Indonesian (Indonesia) - id-ID
     Italian (Italy) - it-IT
     Japanese (Japan) - ja-JP
     Korean (South Korea) - ko-KR
     Norwegian (Norway) - no-NO
     Polish (Poland) - pl-PL
     Portuguese (Brazil) - pt-BR
     Portuguese (Portugal) - pt-PT
     Romanian (Romania) - ro-RO
     Russian (Russia) - ru-RU
     Slovak (Slovakia) - sk-SK
     Spanish (Mexico) - es-MX
     Spanish (Spain) - es-ES
     Swedish (Sweden) - sv-SE
     Thai (Thailand) - th-TH
     Turkish (Turkey) - tr-TR
     **/
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // nothing to do
    
    
    
    
    
    func popUpAlertMsg() {
        let refreshAlert = UIAlertController(title: "pass code please", message: "Enter the pass code to enter the supervisor mode.", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        refreshAlert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    
    
}

