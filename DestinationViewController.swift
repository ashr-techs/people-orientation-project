
//
//  DestinationViewController.swift
//  Orientamento
//
//  Created by Mauro Antonio Giacomello on 05/03/2020.
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
import CoreLocation
import AVFoundation
//let networka = zzzNavigatore<String>()  // if-then
var topo = jsGrapher(frun: true) //mod#0004
var _ftSIRD = Timer()
var daPicker = false                        //mode#001//added
var aPicker = false                         //mode#001//added
var __lastSignalProcessed = 0
var __signalsGPSCoordinate:[[Any]] = []
var __signalsBEACONdata:[[Any]] = []
var __minRaggio = CLLocationDegrees(Float(99999999))
var __minFence  = ""
var __last_shakered_times = 0
class DestinationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITabBarDelegate {
    @IBOutlet weak var bannerIconView: UIImageView!
    
    @IBOutlet weak var routeStepsTextView: UITextField!
    
    
    
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
    private func inizializzaPercorsi() {
        
        
        
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
                        status.forceQuit = true
                        
                    
                    
                
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
            showMessageResetApp(NSLocalizedString("config ctrl", comment:"configurationCheck"), "\(NSLocalizedString("dropped", comment:"configurationCheck")) \(droppedOriginsCounter)|\(droppedDestinationsCounter) \(NSLocalizedString("origins | destinations out of", comment:"configurationCheck")) \(gvts1.count)")
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
        print(biu)
        for b in biu {
            //PTFGIAK-MUTED print("beacon in use \(b)")
        }
        print(bniu)
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
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        startButton.isEnabled = false
        startButton.isOpaque = true
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        daPickerView.reloadAllComponents()
        aPickerView.reloadAllComponents()
        criteriaPickerView.reloadAllComponents()
        modalitaPickerView.reloadAllComponents()
        percorsoPickedView.reloadAllComponents()
    }
    
    
    
    
    
    @IBOutlet weak var daPickerView: UIPickerView!
    
    @IBOutlet weak var aPickerView: UIPickerView!
    
    @IBOutlet weak var criteriaPickerView: UIPickerView!
    
    @IBOutlet weak var modalitaPickerView: UIPickerView!
    
    @IBOutlet weak var lengthTextView: UITextField!
    
    @IBAction func lengthTextView(_ sender: Any) {
    }
    
    @IBAction func availableRoutes(_ sender: Any) {
    }
    
    @IBAction func stopResetButtonPressed(_ sender: Any) {
        status.inFlight = false
        
        startButton.isEnabled = true
        startButton.isOpaque = false
        
        daPicker = false                    //mode#001//added
        aPicker = false                     //mode#001//added
        
        startButton.isUserInteractionEnabled = true
        
        daPickerView.isUserInteractionEnabled = true
        aPickerView.isUserInteractionEnabled = true
        criteriaPickerView.isUserInteractionEnabled = true
        modalitaPickerView.isUserInteractionEnabled = true
        percorsoPickedView.isUserInteractionEnabled = true
        
        inizializzaPercorsi()
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
    @IBOutlet weak var stopResetButton: UIButton!
    
    @IBAction func startButtonPressed(_ sender: Any) {
        
        
        // drop sniiffer for auto-location
        __lastSignalProcessed = 0
        __signalsBEACONdata = []
        __signalsGPSCoordinate = []
        _ftSIRD.invalidate()
        status.autoLocation = false
        
        status.inFlight = true
        threadSafeSignalProcessor.lock()
        status.retrievedData = []
        threadSafeSignalProcessor.unlock()
        daPickerView.isUserInteractionEnabled = false
        aPickerView.isUserInteractionEnabled = false
        criteriaPickerView.isUserInteractionEnabled = false
        modalitaPickerView.isUserInteractionEnabled = false
        percorsoPickedView.isUserInteractionEnabled = false
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
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var percorsoPickedView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Set dataSource and delegate to this class (self).
        self.daPickerView.dataSource = self
        self.daPickerView.delegate = self
        
        self.aPickerView.dataSource = self
        self.aPickerView.delegate = self
        
        self.criteriaPickerView.dataSource = self
        self.criteriaPickerView.delegate = self
        
        self.modalitaPickerView.dataSource = self
        self.modalitaPickerView.delegate = self
        
        self.percorsoPickedView.dataSource = self
        self.percorsoPickedView.delegate = self
        
        
        // temporaneamente disabilitati -ma non funziona !!!
        criteriaPickerView.isAccessibilityElement = false
        modalitaPickerView.isAccessibilityElement = false
        percorsoPickedView.isAccessibilityElement = false
        
        // pre-imposto i selettori con l'ultima selezione operata
        if let row = status.possibiliModalita.firstIndex(where: {$0 == status.modalita}) {
            modalitaPickerView.selectRow(row, inComponent: 0, animated: true)
        }
        if let row = status.possibiliCriteri.firstIndex(where: {$0 == status.criterio}) {
            criteriaPickerView.selectRow(row, inComponent: 0, animated: true)
        }
        
        
        
        startButton.layer.borderColor = UIColor.invert(color: .black ).cgColor
        stopResetButton.layer.borderColor = UIColor.invert(color: .black ).cgColor
        if (status.inFlight == true) {
            startButton.isEnabled = false
            startButton.isOpaque = true
            stopResetButton.isEnabled = true
            stopResetButton.isOpaque = false
        }else{
            inizializzaPercorsi()
        }
        
        // Do any additional setup after loading the view.
        
        if (status.fireTimingSniffInsideRetrievedData == 0) {
            status.fireTimingSniffInsideRetrievedData = 1
            _ftSIRD = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(FireTimingSniffInsideRetrievedData), userInfo: nil, repeats: true)
        }else{
            EXIT_FAILURE
        }
        
    }
    
    override func viewWillAppear(_ sender: Bool) {
         self.view.layoutIfNeeded()
     }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var availableRoutes: UITextField!
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView==daPickerView){
            return status.possibiliOrigini.count;
        }else{
            if (pickerView==aPickerView){
                return status.possibiliDestinazioni.count;
            }else{
                if (pickerView==criteriaPickerView){
                    return status.possibiliCriteri.count;
                }else{
                    if (pickerView==modalitaPickerView){
                        return status.possibiliModalita.count;
                    }else{
                        if (pickerView==percorsoPickedView){
                            availableRoutes.text = String(format: "%.\(0)i",status.numPercorsiPossibili)
                            lengthTextView.text = String(format: "%.\(0)f", status.lunghezzaPercorsoSelezionato)
                            routeStepsTextView.text = String(format: "%.\(0)i", status.percorsoSelezionato.count)
                            return status.percorsoSelezionato.count;
                        }
                    }
                }
            }
        }
        return 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if (pickerView==daPickerView){
            return 1;
        }else{
            if (pickerView==aPickerView){
                return 1;
            }else{
                if (pickerView==criteriaPickerView){
                    return 1;
                }else{
                    if (pickerView==modalitaPickerView){
                        return 1;
                    }else{
                        if (pickerView==percorsoPickedView){
                            return 1;
                        }
                    }
                }
            }
        }
        return 1;
    }
    
    // ptf giak to check why doesn't work/be-invoked
    func pickerView(_ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String? {
        if (pickerView==daPickerView){
            return status.possibiliOrigini[row]
        }else{
            if (pickerView==aPickerView){
                return status.possibiliDestinazioni[row]
            }else{
                if (pickerView==criteriaPickerView){
                    return status.possibiliCriteri[row]
                }else{
                    if (pickerView==modalitaPickerView){
                        return status.possibiliModalita[row]
                    }else{
                        if (pickerView==percorsoPickedView){
                            return status.percorsoSelezionato[row]
                        }
                    }
                }
            }
        }
        
        return ""
    }
    
    private func managingDa(_ selection: String) {
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
        
        
        status.numPercorsiPossibili = status.possibiliDestinazioni.count
        
        aPickerView.reloadAllComponents()
        status.percorsoSelezionato = ["?"]
        status.percorsoTecnico = []
        status.percorsoTecnicoAttributi = []
        status.percorsoTecnicoAttributi = []
        
        daPicker = true                             //mode#001//added
        if (daPicker && aPicker){                   //mode#001//added
            startButton.isEnabled = true            //mode#001//added
            startButton.isOpaque = false            //mode#001//added
        }
        percorsoPickedView.reloadAllComponents()
        //startButton.isEnabled = true              //mode#001//removed
        //startButton.isOpaque = false              //mode#001//removed
        
    
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        var selection:String = ""
        
        if (pickerView==daPickerView){
            if (row >= status.possibiliOrigini.count){
                return
            }
            
            selection = status.possibiliOrigini[row] as String
            
            //mod#0001//changed
            
            managingDa(selection)
        }else{
            if (pickerView==aPickerView){
                if (row >= status.possibiliDestinazioni.count){
                    return
                }
                
                selection = status.possibiliDestinazioni[row] as String
                
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
                aPicker = true                              //mode#001//added
                if (daPicker && aPicker){                   //mode#001//added
                    startButton.isEnabled = true            //mode#001//added
                    startButton.isOpaque = false            //mode#001//added
                }                                           //mode#001//added
                
                percorsoPickedView.reloadAllComponents()
                
            }else{
                if (pickerView==criteriaPickerView){
                    selection = status.possibiliCriteri[row] as String
                }else{
                    if (pickerView==modalitaPickerView){
                        selection = status.possibiliModalita[row] as String
                        status.modalita = selection
                    }else{
                        if (pickerView==percorsoPickedView){
                            if (row >= status.percorsoSelezionato.count){
                                return
                            }
                            
                            selection = status.percorsoSelezionato[row] as String
                            
                        }else{
                            selection = "!"
                        }
                    }
                }
            }
        }
    }
        
    
    // ptf giak to check why this piece of code is not invoked
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var myTitle:NSAttributedString
        var titleData:String
        if (pickerView==daPickerView){
            titleData = status.possibiliOrigini[row]
        }else{
            if (pickerView==aPickerView){
                titleData = status.possibiliDestinazioni[row]
            }else{
                if (pickerView==criteriaPickerView){
                    titleData = status.possibiliCriteri[row]
                }else{
                    if (pickerView==modalitaPickerView){
                        titleData = status.possibiliModalita[row]
                    }else{
                        if (pickerView==percorsoPickedView){
                            titleData = status.percorsoSelezionato[row]
                        }else{
                            titleData = "!"
                        }
                    }
                }
            }
        }
        
        /*
        let label = UILabel()
        label.textColor = Style.Colors.label
        */
        
        
        myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 20.0)!,NSAttributedString.Key.foregroundColor:UIColor.red])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView  {
         let pickerLabel = UILabel()
         let titleData:String
        if (pickerView==daPickerView){
            titleData = status.possibiliOrigini[row]
        }else{
            if (pickerView==aPickerView){
                titleData = status.possibiliDestinazioni[row]
            }else{
                if (pickerView==criteriaPickerView){
                    titleData = status.possibiliCriteri[row]
                }else{
                    if (pickerView==modalitaPickerView){
                        titleData = status.possibiliModalita[row]
                    }else{
                        if (pickerView==percorsoPickedView){
                            titleData = status.percorsoSelezionato[row]
                        }else{
                            titleData = "!"
                        }
                    }
                }
            }
        }
         let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 20.0)!,NSAttributedString.Key.foregroundColor:UIColor.red])
         pickerLabel.attributedText = myTitle
         pickerLabel.textAlignment = .right
        
        let lightModeColor = UIColor.blue // UIColor.blue
        let darkModeColor = UIColor.white  // UIColor.red
        let dynamicColor = lightModeColor | darkModeColor
        
        pickerLabel.font = UIFont(name: "Ropa Sans", size: 18)
        pickerLabel.textColor = dynamicColor //UIColor.blue
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
    }
    
    
    @objc func FireTimingPreSimulator()
    {
        
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
    
    
    @objc func FireTimingSniffInsideRetrievedData()
    {
        
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
        
        // force auto-located in the destination menu (not reversible without an app reset or restart)
        if (__minFence != "" && __minFence != status.possibiliOrigini[0]) {
            
            AudioServicesPlaySystemSound (codifiedBeeps[autoLocationResolved])
            // present just the first outcome of the first run of the auto-location algorithm
            status.possibiliOrigini = [__minFence]
            daPickerView.reloadAllComponents()
            //mod#0001//patch sucessiva al test con Roobi per semplificare utilizzo dei selettori
            
            if (status.possibiliDestinazioni.count > 0){                            //mod#0001//added
                status.possibiliDestinazioni.remove(at: 0) 
            }                                                                       //mod#0001//added
            
            managingDa(__minFence) // a fronte dell'origine aggiorno destinazioni   //mod#0001//added
            //status.possibiliDestinazioni.append(status.ulterioriTermini[0])       //mod#0001//disabled
            aPickerView.reloadAllComponents()
            
            //mod#0001//patch sucessiva al test con Roobi per semplificare utilizzo dei selettori
            
            personalSettingsViewController.utterance = AVSpeechUtterance(string: "\(__minFence) \(NSLocalizedString("vce-ut10-b01",comment: "autoDetectionPosition"))" )    //mod#0001//added
            personalSettingsViewController.utterance.voice = AVSpeechSynthesisVoice(language: status.linguaCorrente/*"it-IT"*/)                                           //mod#0001//added
            personalSettingsViewController.utterance.rate = status.voiceReaderSpeed // 0.45 //mod#0001//added
            personalSettingsViewController.utterance.volume = status.voiceReaderVolume // 1.0 //mod#0001//added
            personalSettingsViewController.synthesizer.speak(personalSettingsViewController.utterance) //mod#0001//added
        }
    }
    
    
}

