
//
//  NewDestinationViewController.swift
//  Orientamento
//
//  Created by Mauro Antonio Giacomello on 05/03/2022.
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
import Foundation
import CoreLocation
import AVFoundation
import Speech
// https://stackoverflow.com/questions/43387312/drop-down-list-menu-programmatically-in-swift-xcode
//let networka = zzzNavigatore<String>()  // if-then
var topo = jsGrapher(frun: true) //mod#0004
let dc = DestinationClass()
var _ftSIRD = Timer()
var __lastSignalProcessed = 0
var __signalsGPSCoordinate:[[Any]] = []
var __signalsBEACONdata:[[Any]] = []
var __minRaggio = CLLocationDegrees(Float(99999999))
var __minFence  = ""
var __last_shakered_times = 0
var originFlag = false                        //mod#0006//added
var destinationFlag = false                          //mod#0006//added
class NewDestinationViewController: UIViewController, SFSpeechRecognizerDelegate, AVAudioPlayerDelegate, UITabBarDelegate, UIScrollViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    func showMessageForceExit(_ msgHeader:String?, _ msgBody:String?){
           let exitAppAlert = UIAlertController(title: NSLocalizedString(msgHeader!, comment: "forceexit"), message: NSLocalizedString(msgBody!, comment: "forceexit"), preferredStyle: .alert)
            let resetApp = UIAlertAction(title: NSLocalizedString("frc-exit-003", comment: "forceexit"), style: .destructive) {
                (alert) -> Void in
                    // home button pressed programmatically - to thorw app to background
                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                    // terminaing app in background
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        exit(EXIT_SUCCESS)
                    })
            }
            exitAppAlert.addAction(resetApp)
            present(exitAppAlert, animated: true, completion: nil)
    }
    
    
    func showMessageResetApp(_ msgHeader:String?, _ msgBody:String?){
        if (msgHeader != nil && msgBody != nil) {
            let exitAppAlert = UIAlertController(title: NSLocalizedString(msgHeader!, comment: "forceexit"), message: NSLocalizedString(msgBody!, comment: "forceexit"), preferredStyle: .alert)
            let resetApp = UIAlertAction(title: NSLocalizedString("frc-exit-003", comment: "forceexit"), style: .destructive) {
                (alert) -> Void in
                    // home button pressed programmatically - to thorw app to background
                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                    // terminaing app in background
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        exit(EXIT_SUCCESS)
                    })
            }
            
            let laterAction = UIAlertAction(title: NSLocalizedString("frc-exit-005",comment: "forceexit"), style: .cancel) {_ in
                //(alert) -> Void in
                //self.dismiss(animated: true, completion: nil)
            }
            
            exitAppAlert.addAction(resetApp)
            exitAppAlert.addAction(laterAction)
            present(exitAppAlert, animated: true, completion: nil)
        }else{
        
        
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
                self.dismiss(animated: true, completion: nil)
            }
            
            exitAppAlert.addAction(resetApp)
            exitAppAlert.addAction(laterAction)
            present(exitAppAlert, animated: true, completion: nil)
        }
        
    }
    
    func showWarningMessage(_ msgHeader:String?, _ msgBody:String?){
        if (msgHeader != nil && msgBody != nil) {
            let exitAppAlert = UIAlertController(title: NSLocalizedString(msgHeader!, comment: "warningexit"), message: NSLocalizedString(msgBody!, comment: "warningexit"), preferredStyle: .alert)
            let laterAction = UIAlertAction(title: NSLocalizedString("war-exit-005",comment: "warningexit"), style: .cancel) {_ in
                //(alert) -> Void in
                //self.dismiss(animated: true, completion: nil)
            }
            
            exitAppAlert.addAction(laterAction)
            present(exitAppAlert, animated: true, completion: nil)
        }
        
    }
    
    func _inizializzaPercorsi(){
        let _rp = dc.inizializzaPercorsi()
        if (_rp.count == 3 && _rp.max() ?? 0 > 0) {
            /*
            var rp_ = _rp.sorted(){
                $0 > $1
            }
            let (_rp_minimum, _rp_maximum) = _rp.reduce((Int.max, Int.min)) {
                (min($0.0, $1), max($0.1, $1))
            }
             */
            
            showMessageResetApp(NSLocalizedString("config ctrl", comment:"configurationCheck"), "\(NSLocalizedString("dropped", comment:"configurationCheck")) \(_rp[0])|\(_rp[1]) \(NSLocalizedString("origins | destinations out of", comment:"configurationCheck")) \(_rp[2])")
        }
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        startButton.isEnabled = false
        startButton.isOpaque = true
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                
    }
    
    static let synthesizer = AVSpeechSynthesizer()
    static var utterance = AVSpeechUtterance(string: "")
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var stopResetButton: UIButton!
    
    @IBOutlet weak var bannerIconView: UIImageView!
    
    @IBOutlet weak var availableRoutesTextView: UITextField!
    
    @IBOutlet weak var lengthTextView: UITextField!
    
    @IBOutlet weak var routeStepsTextView: UITextField!
        
    func fROMreload() {
        availableRoutesTextView.text = String(format: "%.\(0)i",status.numPercorsiPossibili)
    }
    
    func tOreload() {
        availableRoutesTextView.text = String(format: "%.\(0)i",status.numPercorsiPossibili)
        lengthTextView.text = String(format: "%.\(0)f", status.lunghezzaPercorsoSelezionato)
        routeStepsTextView.text = String(format: "%.\(0)i", status.percorsoSelezionato.count)
    }
    func rOUTEreload() {
        routeStepsTextView.text = String(format: "%.\(0)i", status.percorsoSelezionato.count)
    }
    @IBOutlet weak var btnFROM: UIButton!
    @IBOutlet weak var btnTO: UIButton!
    @IBOutlet weak var btnCRITERIA: UIButton!
    @IBOutlet weak var btnMODALITY: UIButton!
    @IBOutlet weak var btnROUTE: UIButton!
    
    @IBAction func startButtonPressed(_ sender: Any) {
        
        
        // drop sniiffer for auto-location
        __lastSignalProcessed = 0
        __signalsBEACONdata = []
        __signalsGPSCoordinate = []
        _ftSIRD.invalidate()
        status.autoLocation = false
        
        status.inFlight = true
        status.OTResetRequest = true
        
        threadSafeSignalProcessor.lock()
        status.retrievedData = []
        threadSafeSignalProcessor.unlock()
        
        startButton.isEnabled = false                           // una volta attivato non è re-start-able
        startButton.isOpaque = true
        startButton.isUserInteractionEnabled = false
        
        tabBarController?.selectedIndex = 1 // index=0 >> destinazioni, index=1 >> Map/Mappa
        
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        if (
         
            status.modalita==NSLocalizedString("pre-simulation", comment: "")
         
         ) {
            let myNotificationKey = "sensorForOrientation"
            //NotificationCenter.default.removeObserver(catchNotificationForOrientation)
            NotificationCenter.default.removeObserver(_tknForOri)
            if (status.modalita==NSLocalizedString("pre-simulation", comment: "")) {
                if (status.fireTimingPreSimulator == 0) {
                    status.fireTimingPreSimulator = 1
                    _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(FireTimingPreSimulator), userInfo: nil, repeats: true)
                }else{
                    EXIT_FAILURE
                }
            }
        }
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        status.navigatorCockpit = NavigatorCockpit(status: false, suspended: false, houseKeeping: false, beaconInProximity: [], beaconInRange: [], beaconAtTheHorizon: [], beaconInTheMist: 0, fenceInPlace: [], percorsoInPlace: PercorsoInPlace(percorsoSelezionato: status.percorsoSelezionato, percorsoTecnico: status.percorsoTecnico, percorsoTecnicoAttributi: status.percorsoTecnicoAttributi, percorsoTecnicoCoordinate: status.percorsoTecnicoCoordinate), lastSignaledBeacon: [], suspSignals: [], geoSignal: [], forcedGEOsignal: [], c: _C(comando: "", utente: "", percorso: "", ver: "100", ms: 0, LATITUDE: 0.0, LONGITUDE: 0.0, FLOOR: 0, _PATH: [], esitoCreazionePercorso: 0, motivoCreazionePercorso: "", esitoAttivazione: 0, motivoAttivazione: "", pathInPlace: "", esitoSegnale: 0, testoSegnale: [], motivoSegnale: "", timeToSpeechSegnale: [], waitBeforeSpeechSegnale: []))
        
        
        let myRouteNotificationKey = "RouteMGMT"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: myRouteNotificationKey), object: nil, userInfo: ["name":"cmd=go,UNQKK,>\(status.percorsoSelezionato[0])@\(status.percorsoSelezionato[status.percorsoSelezionato.count-1])<"])
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
    }
    
    
    @IBAction func stopResetButtonPressed(_ sender: Any) {
        status.inFlight = false
        
        startButton.isEnabled = true
        startButton.isOpaque = false
        
        originFlag = false                    //mod#0006//added
        destinationFlag = false                      //mod#0006//added
        
        startButton.isUserInteractionEnabled = true
        
       
        _inizializzaPercorsi()
        // re-start the sniffer for auto-location
        
        __lastSignalProcessed = 0
        __signalsBEACONdata = []
        __signalsGPSCoordinate = []
        _ftSIRD.invalidate()
        status.autoLocation = false
        
        if (status.fireTimingSniffInsideRetrievedData == 0) {
            status.fireTimingSniffInsideRetrievedData = 1
            _ftSIRD = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(FireTimingSniffInsideRetrievedData), userInfo: nil, repeats: true)
        }else{
            //EXIT_FAILURE
        }
        
        self.viewWillAppear(true)
    }
          
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _inizializzaPercorsi() // inserita per ovviare diversa sequenza attivazione iOS
                                // in caso di assenza della classe DestionationViewController
        
        // disabilito editing dei field
        
       
        
        bannerIconView.frame = CGRect(x: bannerIconView.frame.minX - (bannerIconView.frame.width / 2) , y: bannerIconView.frame.minY - (bannerIconView.frame.height / 2), width: bannerIconView.frame.width * 2, height: bannerIconView.frame.height * 2)
        
  
        
        //possibiliOrigini.sort(by: <)
        //startButton.backgroundColor = .clear
        startButton.layer.cornerRadius = 5
        startButton.layer.borderWidth = 2
        startButton.layer.borderColor = UIColor.black.cgColor
        
        //stopResetButton.backgroundColor = .clear
        stopResetButton.layer.cornerRadius = 5
        stopResetButton.layer.borderWidth = 2
        stopResetButton.layer.borderColor = UIColor.black.cgColor
        
        
        startButton.layer.borderColor = UIColor.invert(color: .black ).cgColor
        stopResetButton.layer.borderColor = UIColor.invert(color: .black ).cgColor
        if (status.inFlight == true) {
            startButton.isEnabled = false
            startButton.isOpaque = true
            stopResetButton.isEnabled = true
            stopResetButton.isOpaque = false
        }else{
            
            
            
        }
        
        // Do any additional setup after loading the view.
        
        if (status.fireTimingMonitorForIssues == 0) {
            status.fireTimingMonitorForIssues = 1
            _ftSIRD = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(FireTimingMonitorForIssues), userInfo: nil, repeats: true)
        }else{
            EXIT_FAILURE
        }
        
        if (status.fireTimingSniffInsideRetrievedData == 0) {
            status.fireTimingSniffInsideRetrievedData = 1
            _ftSIRD = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(FireTimingSniffInsideRetrievedData), userInfo: nil, repeats: true)
        }else{
            EXIT_FAILURE
        }
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        
        btnFROM.setTitle(NSLocalizedString("tap for origins list",comment: "dropdownmenu"), for: .normal)
        
        btnTO.setTitle(NSLocalizedString("tap for destinations list",comment: "dropdownmenu"), for: .normal)
        
        // pre-imposto i selettori con l'ultima selezione operata
        if let row = status.possibiliModalita.firstIndex(where: {$0 == status.modalita}) {
            btnMODALITY.setTitle(status.modalita, for: .normal)
        }
        if let row = status.possibiliCriteri.firstIndex(where: {$0 == status.criterio}) {
            btnCRITERIA.setTitle(status.criterio, for: .normal)
        }
        
        btnROUTE.setTitle(NSLocalizedString("tap for route details",comment: "dropdownmenu"), for: .normal)
        
        btnFROM.isUserInteractionEnabled = true
        btnTO.isUserInteractionEnabled = false
        btnCRITERIA.isUserInteractionEnabled = true
        btnMODALITY.isUserInteractionEnabled = true
        btnROUTE.isUserInteractionEnabled = true
        
    }
    
    override func viewWillAppear(_ sender: Bool) {
         self.view.layoutIfNeeded()
     }
    
    /*
    @objc func didTapTopItem() {
        fROM.show()
    }
    */
    
    private func _managingDa(_ selection: String) {
        
        dc.managingDa(selection)
        
        tOreload()
        
        originFlag = true                             //mod#0006//added
        if (originFlag && destinationFlag){                   //mod#0006//added
            startButton.isEnabled = true            //mod#0006//added
            startButton.isOpaque = false            //mod#0006//added
        }
        
        rOUTEreload()
                
    }
    
    
    
    
    @objc func FireTimingPreSimulator()
    {
        dc.FireTimingPreSimulator()
    }
    
    
    @objc func FireTimingMonitorForIssues()
    {
        if (status.forceExit != 0){
            showMessageForceExit("Custom unrecoverable Error # \(status.forceExit)","Please contact your technical support")
        }
    }
    
    @objc func FireTimingSniffInsideRetrievedData()
    {
        
        dc.FireTimingSniffInsideRetrievedData()
        
        // force auto-located in the destination menu (not reversible without an app reset or restart)
        if (status.autoLocation && __minFence != "" && __minFence != status.possibiliOrigini[0]) {
            
            AudioServicesPlaySystemSound (codifiedBeeps[autoLocationResolved])
            // present just the first outcome of the first run of the auto-location algorithm
            status.possibiliOrigini = [__minFence]
            fROMreload()
            //mod#0006//patch sucessiva al test con Roobi per semplificare utilizzo dei selettori
            
            if (status.possibiliDestinazioni.count > 0){                            //mod#0006//added
                status.possibiliDestinazioni.remove(at: 0)
            }                                                                       //mod#0006//added
            
            _managingDa(__minFence) // a fronte dell'origine aggiorno destinazioni   //mod#0006//added
            //status.possibiliDestinazioni.append(status.ulterioriTermini[0])       //mod#0006//disabled
            tOreload()
            
            //mod#0006//patch sucessiva al test con Roobi per semplificare utilizzo dei selettori
            
            NewDestinationViewController.utterance = AVSpeechUtterance(string: "\(__minFence) \(NSLocalizedString("vce-ut10-b01",comment: "autoDetectionPosition"))" )    //mod#0006//added
            NewDestinationViewController.utterance.voice = AVSpeechSynthesisVoice(language: status.linguaCorrente/*"it-IT"*/)                                           //mod#0006//added
            NewDestinationViewController.utterance.rate = status.voiceReaderSpeed // 0.45 //mod#0006//added
            NewDestinationViewController.utterance.volume = status.voiceReaderVolume // 1.0 //mod#0006//added
            NewDestinationViewController.synthesizer.speak(NewDestinationViewController.utterance) //mod#0006//added
            status.autoLocation = false
             
        }
    }
    
    let transpView = UIView()
    let tableView = UITableView()
    var selectedButton = UIButton()
    
    var dataSource = [String]()
    
    func addTranspView(frames: CGRect) {
        let window = UIApplication.shared.keyWindow
        transpView.frame = window?.frame ?? self.view.frame
        self.view.addSubview((transpView))
        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        transpView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        let tapgest = UITapGestureRecognizer(target: self, action: #selector(removeTranspView))
        transpView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
            self.transpView.alpha = 0.5
            var hei:CGFloat = 5 * 30
            if (self.dataSource.count < 5){
                hei = CGFloat(self.dataSource.count * 30)
            }
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width + 5, height: hei)
        }, completion: nil )
        transpView.addGestureRecognizer(tapgest)
    }
    
    @objc func removeTranspView() {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn, animations: {
            self.transpView.alpha = 0.0
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil )
    }
    
    @IBAction func onClickFROM(_ sender: Any) {
        dataSource = status.possibiliOrigini
        selectedButton = btnFROM
        addTranspView(frames: btnFROM.frame)
    }
    
    @IBAction func onClickTO(_ sender: Any) {
        dataSource = status.possibiliDestinazioni
        selectedButton = btnTO
        addTranspView(frames: btnTO.frame)
    }
    
    @IBAction func onClickCRITERIA(_ sender: Any) {
        dataSource = status.possibiliCriteri
        selectedButton = btnCRITERIA
        addTranspView(frames: btnCRITERIA.frame)
    }
    
    @IBAction func onClickMODALITY(_ sender: Any) {
        dataSource = status.possibiliModalita
        selectedButton = btnMODALITY
        addTranspView(frames: btnMODALITY.frame)
    }
    
    @IBAction func onClickROUTE(_ sender: Any) {
        dataSource = status.percorsoSelezionato
        selectedButton = btnROUTE
        addTranspView(frames: btnROUTE.frame)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("drop down selected item \(dataSource[indexPath.row])")
        if (selectedButton != btnROUTE){
            selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
        }
        removeTranspView()
        
        //print(tableView)
        
        if (selectedButton == btnFROM){
            _managingDa(dataSource[indexPath.row])
            destinationFlag = true
            btnTO.isUserInteractionEnabled = true
            startButton.isEnabled = false            //mod#0006//added
            startButton.isOpaque  = true             //mod#0006//added
        }else{
            if (selectedButton == btnTO){
                dc.workingAroundTheSelectedDestination(dataSource[indexPath.row])
                
                destinationFlag = true                               //mod#0006//added
                if (originFlag && destinationFlag){                    //mod#0006//added
                    startButton.isEnabled = true            //mod#0006//added
                    startButton.isOpaque = false            //mod#0006//added
                }
            }else{
                if (selectedButton == btnCRITERIA){
                    status.criterio = dataSource[indexPath.row]
                }else{
                    if (selectedButton == btnMODALITY){
                        if (status.modalita != dataSource[indexPath.row]){
                            startButton.isEnabled = false
                            showWarningMessage("war-exit-001","war-exit-002") // becouse it will force underground behaves
                        }
                        status.modalita = dataSource[indexPath.row]
                    }else{
                        if (selectedButton == btnROUTE){
                        }else{
                            print("&!%&£&/& !!! error: illogic")
                        }
                    }
                }
                
            }
        }
        
        
    }
 
}
class CellClass: UITableViewCell {
    let a = "x"
}

