
//
//  personalSettingsViewController.swift
//  Orientamento
//
//  Created by Mauro Antonio Giacomello on 14/04/2021.
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
let lista = ["femminile","maschile"]
import UIKit
import Speech
class personalSettingsViewController: UIViewController, SFSpeechRecognizerDelegate, AVAudioPlayerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var voiceCharacterLbaleView: UILabel!
    @IBOutlet weak var voiceCharactersPickerView: UIPickerView!
             
    @IBOutlet weak var bannerIconView: UIImageView!
    
    @IBOutlet weak var voiceReaderVolumeStepper: UIStepper!
    @IBOutlet weak var voiceReaderSpeedStepper: UIStepper!
    @IBOutlet weak var voiceReaderPaceingStepper: UIStepper!
    @IBOutlet weak var voiceRepetitionsStepper: UIStepper!
    
    @IBOutlet weak var voiceReadVolumeSlideView: UIProgressView!
    @IBOutlet weak var voiceReaderSpeedSliderView: UIProgressView!
    @IBOutlet weak var voiceReaderPaceingSliderView: UIProgressView!
    @IBOutlet weak var voiceRepetitionsSliderView: UIProgressView!
    
    
    static let synthesizer = AVSpeechSynthesizer()
    static var utterance = AVSpeechUtterance(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        bannerIconView.frame = CGRect(x: bannerIconView.frame.minX - (bannerIconView.frame.width / 2) , y: bannerIconView.frame.minY - (bannerIconView.frame.height / 2), width: bannerIconView.frame.width * 2, height: bannerIconView.frame.height * 2)
        // Set dataSource and delegate to this class (self).
        self.voiceCharactersPickerView.dataSource = self
        self.voiceCharactersPickerView.delegate = self
        
        voiceCharacterLbaleView.isHidden = true
        voiceCharactersPickerView.isUserInteractionEnabled = false
        voiceCharactersPickerView.isHidden = true
        // Do any additional setup after loading the view.
        
        voiceReadVolumeSlideView.progress = status.voiceReaderVolume
        voiceReaderSpeedSliderView.progress = status.voiceReaderSpeed
        voiceReaderPaceingSliderView.progress = status.voiceReaderPaceing
        voiceRepetitionsSliderView.progress = status.voiceRepetitions
        
        voiceReaderVolumeStepper.minimumValue = 0.0
        voiceReaderVolumeStepper.maximumValue = 1.0
        voiceReaderVolumeStepper.value = Double(status.voiceReaderVolume)
        voiceReaderVolumeStepper.autorepeat = true
        voiceReaderVolumeStepper.accessibilityLabel = "ciao"
        voiceReaderVolumeStepper.accessibilityHint = "aumento o dimininuisci il volume"
        
        voiceReaderSpeedStepper.minimumValue = 0.0
        voiceReaderSpeedStepper.maximumValue = 1.0
        voiceReaderSpeedStepper.value = Double(status.voiceReaderSpeed)
        voiceReaderSpeedStepper.autorepeat = true
        
        voiceReaderPaceingStepper.minimumValue = 0.0
        voiceReaderPaceingStepper.maximumValue = 1.0
        voiceReaderPaceingStepper.value = Double(status.voiceReaderPaceing)
        voiceReaderPaceingStepper.autorepeat = true
        
        
        voiceRepetitionsStepper.minimumValue = 0.0
        voiceRepetitionsStepper.maximumValue = 1.0
        voiceRepetitionsStepper.value = Double(status.voiceRepetitions)
        voiceRepetitionsStepper.autorepeat = true
        
        
    }
    
    @IBAction func voiceReadVolumeController(_ sender: Any) {
        var text = ""
        switch voiceReaderVolumeStepper.value {
            case 1.0:
                // add your item here
                if (status.voiceReaderVolume < 1.0) {
                    status.voiceReaderVolume += 0.1
                }
                if (status.voiceReaderVolume < 1.0) {
                    voiceReaderVolumeStepper.value = 0.5
                }else{
                    voiceReaderVolumeStepper.value = 1.0
                }
                text = NSLocalizedString("vce-ut01-a01",comment: "voiceSetting")
            default:
                // remove your item here
                if (status.voiceReaderVolume > 0.0) {
                    status.voiceReaderVolume += -0.1
                }
                if (status.voiceReaderVolume > 0.0) {
                    voiceReaderVolumeStepper.value = 0.5
                }else{
                    voiceReaderVolumeStepper.value = 0.0
                }
                text = NSLocalizedString("vce-ut01-a02",comment: "voiceSetting")
        }
        voiceReadVolumeSlideView.progress = status.voiceReaderVolume
        
        let isVoiceOverRunning = (UIAccessibility.isVoiceOverRunning ? 1 : 0)
        let isSwitchControlRunning = (UIAccessibility.isSwitchControlRunning ? 1 : 0)
        
        if (isVoiceOverRunning == 1){
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                personalSettingsViewController.utterance = AVSpeechUtterance(string: String(format:"%.1f \(text)", status.voiceReaderVolume) /*NSLocalizedString("vce-ut01-a01",comment: "voiceSetting")*/ )
                personalSettingsViewController.utterance.voice = AVSpeechSynthesisVoice(language: status.linguaCorrente/*"it-IT"*/)
                personalSettingsViewController.utterance.rate = status.voiceReaderSpeed // 0.45
                personalSettingsViewController.utterance.volume = status.voiceReaderVolume // 1.0
                personalSettingsViewController.synthesizer.speak(personalSettingsViewController.utterance)
            }
        }
        
    }
    
    @IBAction func voiceReaderSpeedController(_ sender: Any) {
        var text = ""
       switch voiceReaderSpeedStepper.value {
            case 1.0:
                // add your item here
                if (status.voiceReaderSpeed < 1.0) {
                    status.voiceReaderSpeed += 0.1
                }
                if (status.voiceReaderSpeed < 1.0) {
                    voiceReaderSpeedStepper.value = 0.5
                }else{
                    voiceReaderSpeedStepper.value = 1.0
                }
                text = NSLocalizedString("vce-ut02-a01",comment: "voiceSetting")
            default:
                // remove your item here
                if (status.voiceReaderSpeed > 0.0) {
                    status.voiceReaderSpeed += -0.1
                }
                if (status.voiceReaderSpeed > 0.0) {
                    voiceReaderSpeedStepper.value = 0.5
                }else{
                    voiceReaderSpeedStepper.value = 0.0
                }
                text = NSLocalizedString("vce-ut02-a02",comment: "voiceSetting")
        }
        voiceReaderSpeedSliderView.progress = status.voiceReaderSpeed
        
        let isVoiceOverRunning = (UIAccessibility.isVoiceOverRunning ? 1 : 0)
        let isSwitchControlRunning = (UIAccessibility.isSwitchControlRunning ? 1 : 0)
        
        if (isVoiceOverRunning == 1){
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                personalSettingsViewController.utterance = AVSpeechUtterance(string: String(format:"%.1f \(text)", status.voiceReaderSpeed)  /*NSLocalizedString("vce-ut02-a01",comment: "voiceSetting")*/ )
                personalSettingsViewController.utterance.voice = AVSpeechSynthesisVoice(language: status.linguaCorrente/*"it-IT"*/)
                personalSettingsViewController.utterance.rate = status.voiceReaderSpeed // 0.45
                personalSettingsViewController.utterance.volume = status.voiceReaderVolume // 1.0
                personalSettingsViewController.synthesizer.speak(personalSettingsViewController.utterance)
            }
        }
    }
    
    @IBAction func voiceReaderPaceingController(_ sender: Any) {
        var text = ""
        switch voiceReaderPaceingStepper.value {
             case 1.0:
                 // add your item here
                 if (status.voiceReaderPaceing < 1.0) {
                     status.voiceReaderPaceing += 0.1
                 }
                 if (status.voiceReaderPaceing < 1.0) {
                    voiceReaderPaceingStepper.value = 0.5
                 }else{
                    voiceReaderPaceingStepper.value = 1.0
                 }
                text = NSLocalizedString("vce-ut03-a01",comment: "voiceSetting")
             default:
                 // remove your item here
                 if (status.voiceReaderPaceing > 0.0) {
                     status.voiceReaderPaceing += -0.1
                 }
                 if (status.voiceReaderPaceing > 0.0) {
                    voiceReaderPaceingStepper.value = 0.5
                 }else{
                    voiceReaderPaceingStepper.value = 0.0
                 }
                text = NSLocalizedString("vce-ut03-a02",comment: "voiceSetting")
         }
        voiceReaderPaceingSliderView.progress = status.voiceReaderPaceing
        
        let isVoiceOverRunning = (UIAccessibility.isVoiceOverRunning ? 1 : 0)
        let isSwitchControlRunning = (UIAccessibility.isSwitchControlRunning ? 1 : 0)
        
        if (isVoiceOverRunning == 1){
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                personalSettingsViewController.utterance = AVSpeechUtterance(string: String(format:"%.1f \(text)", status.voiceReaderPaceing) /*NSLocalizedString("vce-ut03-a01",comment: "voiceSetting")*/ )
                personalSettingsViewController.utterance.voice = AVSpeechSynthesisVoice(language: status.linguaCorrente/*"it-IT"*/)
                personalSettingsViewController.utterance.rate = status.voiceReaderSpeed // 0.45
                personalSettingsViewController.utterance.volume = status.voiceReaderVolume // 1.0
                personalSettingsViewController.synthesizer.speak(personalSettingsViewController.utterance)
            }
        }
    }
    
    @IBAction func voiceRepetitionsController(_ sender: Any) {
         switch voiceRepetitionsStepper.value {
             case 1.0:
                 // add your item here
                 if (status.voiceRepetitions < 1.0) {
                     status.voiceRepetitions += 0.2
                 }
                 if (status.voiceRepetitions < 1.0) {
                    voiceRepetitionsStepper.value = 0.5
                 }else{
                    voiceRepetitionsStepper.value = 1.0
                 }
             default:
                 // remove your item here
                 if (status.voiceRepetitions > 0.0) {
                     status.voiceRepetitions += -0.2
                 }
                 if (status.voiceRepetitions > 0.0) {
                    voiceRepetitionsStepper.value = 0.5
                 }else{
                    voiceRepetitionsStepper.value = 0.0
                 }
         }
        voiceRepetitionsSliderView.progress = status.voiceRepetitions
        let tt = Double(String(format:"%.1f", status.voiceRepetitions))
        print("tt \(tt)")
        
        let isVoiceOverRunning = (UIAccessibility.isVoiceOverRunning ? 1 : 0)
        let isSwitchControlRunning = (UIAccessibility.isSwitchControlRunning ? 1 : 0)
        
        if (isVoiceOverRunning == 1){
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                var vrn = ""
                if (tt == 0) {
                    vrn = "0"
                    status.voiceRepetitions = 0
                }else{
                    let mRN = tt
                    let dMRN:Double = Double(String(format:"%.1f", mRN as! CVarArg))!
                    if (dMRN >= 1.0) {
                        vrn = "5"
                    }else{
                        if (dMRN >= 0.8) {
                            vrn = "4"
                        }else{
                            if (dMRN >= 0.6) {
                                vrn = "3"
                            }else{
                                if (dMRN >= 0.4) {
                                    vrn = "2"
                                }else{
                                    vrn = "1"
                                }
                            }
                        }
                    }
                }
                personalSettingsViewController.utterance = AVSpeechUtterance(string: "\(vrn)  \(NSLocalizedString("vce-ut04-a01",comment: "voiceSetting"))" )
                personalSettingsViewController.utterance.voice = AVSpeechSynthesisVoice(language: status.linguaCorrente/*"it-IT"*/)
                personalSettingsViewController.utterance.rate = status.voiceReaderSpeed // 0.45
                personalSettingsViewController.utterance.volume = status.voiceReaderVolume // 1.0
                personalSettingsViewController.synthesizer.speak(personalSettingsViewController.utterance)
            }
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lista.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String? {
        return lista[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        status.voiceReaderCharacter = lista[row] as String
        
    }
               
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

