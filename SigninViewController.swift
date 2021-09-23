
//
//  SigninViewController.swift
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
import CoreLocation
import AudioToolbox
import Dispatch
extension CGFloat {
  var toRadians: CGFloat { return self * .pi / 180 }
  var toDegrees: CGFloat { return self * 180 / .pi }
}
extension Date {
    func dateBeforeOrAfterFromToday(numberOfDays :Int?) -> Date {
        let resultDate = Calendar.current.date(byAdding: .day, value: numberOfDays!, to: Date())!
        return resultDate
    }
}
extension Array where Element: Equatable  {
        mutating func delete(element: Iterator.Element) {
                self = self.filter{$0 != element }
        }
    }
// more items for each picker.
class SigninViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var bannerIconView: UIImageView!
    @IBOutlet weak var titleTextView: UILabel!
    @IBOutlet weak var bannerIcon2View: UIImageView!
    
    @IBOutlet weak var configURLTextView: UITextField!
    @IBOutlet weak var instructionsButtonView: UIButton!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var characterPickerView: UIPickerView!
    @IBOutlet weak var modesPickerView: UIPickerView!
    @IBOutlet weak var privacyCheckImageView: UIImageView!
    @IBOutlet weak var privacyButtomView: UIButton!
    @IBOutlet weak var disclaimerCheckImageView: UIImageView!;
    @IBOutlet weak var disclaimerButtomView: UIButton!
    @IBOutlet weak var privacyButtonPressed: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBAction func disclaimerButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var aboutThisAppCheckImageView: UIImageView!
    
    @IBOutlet weak var instructionsCheckImageView: UIImageView!
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    var tmpUserCharacter = ""
    var tmpOperationalMode = ""
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    var locationManager: CLLocationManager?
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func showMessageResetApp(_ msgHeader:String?, _ msgBody:String?){
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // keyboard controlling
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        configURLTextView.isUserInteractionEnabled = false
        configURLTextView.isEnabled = false
        configURLTextView.backgroundColor = UIColor.invert(color: .white)
        configURLTextView.textColor = UIColor.invert(color: .red)
        configURLTextView.adjustsFontSizeToFitWidth = false
        configURLTextView.textAlignment = .left
        configURLTextView.accessibilityHint = NSLocalizedString("hint-configURL", comment: "accessibility hint")
        // keyboard controlling
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(taped))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
                
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        bannerIconView.image = GuidaDataModel.scene.icon1
        titleTextView.text = GuidaDataModel.sceneDescriptor.title // ptf giak scene management
        bannerIcon2View.image = GuidaDataModel.scene.icon2
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        
        
        locationManager?.distanceFilter = kCLDistanceFilterNone
        //locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.startUpdatingLocation()
        locationManager?.startMonitoringSignificantLocationChanges()
        
        locationManager?.startUpdatingHeading()
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // Set dataSource and delegate to this class (self).
        self.modesPickerView.dataSource = self
        self.modesPickerView.delegate = self
        // Set dataSource and delegate to this class (self).
        self.characterPickerView.dataSource = self
        self.characterPickerView.delegate = self
        
        
        
        bannerIconView.frame = CGRect(x: bannerIconView.frame.minX - (bannerIconView.frame.width / 2) , y: bannerIconView.frame.minY - (bannerIconView.frame.height / 2), width: bannerIconView.frame.width * 2, height: bannerIconView.frame.height * 2)
        //signinButton.backgroundColor = .clear
        signinButton.layer.cornerRadius = 5
        signinButton.layer.borderWidth = 2
        //signinButton.layer.borderColor = UIColor.black.cgColor
        signinButton.layer.borderColor = UIColor.invert(color: .black ).cgColor
        //disable the signin button waiting to verify that all actions have been taken
        signinButton.isEnabled = false
        
        //resetButton.backgroundColor = .clear
         resetButton.layer.cornerRadius = 5
         resetButton.layer.borderWidth = 2
         //resetButton.layer.borderColor = UIColor.black.cgColor
         resetButton.layer.borderColor = UIColor.invert(color: .black ).cgColor
        // Do any additional setup after loading the view.
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(instructionsReaded), name: Notification.Name("instructionsReaded"), object: nil)
        nc.addObserver(self, selector: #selector(privacyAccepted), name: Notification.Name("privacyAccepted"), object: nil)
        nc.addObserver(self, selector: #selector(disclamerAccepted), name: Notification.Name("disclamerAccepted"), object: nil)
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(clockFireTiming), userInfo: nil, repeats: true)
       ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
                
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        setUserControlFlags()
        updateConfigurationInPlace()
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
    }
    
    
    override func viewWillAppear(_ sender: Bool) {
        // explicitly called by resetButton action to refresh the view
        
        setUserControlFlags()
        updateConfigurationInPlace()
        
     }
    
    /*
    override func viewDidAppear(_ sender: Bool) {
        setUserControlFlags()
        
        updateConfigurationInPlace()
        
    }
    */
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    @objc func clockFireTiming()
    {
        //AudioServicesPlaySystemSound(1306)
    }
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func configURLchanged(_ sender: Any) {
        let defaultsDataStore = UserDefaults.standard
        
        if (sender as! NSObject == configURLTextView){
            print(sender)
            
            defaultsDataStore.set("no", forKey: DefaultsKeysDataStore.keyConfigurationURLverified)
            let currentInput = configURLTextView.text ?? ""
            
            if (configInPlace.configurationURL != currentInput) {
                configInPlace.configurationURL = currentInput
            
                if (configInPlace.configurationURL != "") {
                    defaultsDataStore.set(configInPlace.configurationURL, forKey: DefaultsKeysDataStore.keyConfigurationURL)
                }
                
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                // here the app must be restarted to re-run the initialization phases .....
                print("here the app must be restarted to re-do, re-run the initialization phases...")
                showMessageResetApp(NSLocalizedString("config ctrl", comment:"configurationSetup"), "\(NSLocalizedString("configuration URL changed to value: ", comment:"configurationSetup")) \(configInPlace.configurationURL) \(NSLocalizedString("Forced restart. Close and Restart the App.", comment:"configurationSetup"))")
                
            }
                
        }
        
    }
    
}
extension SigninViewController {  // ViewController
    
    func updateConfigurationInPlace() {
                let defaultsDataStore = UserDefaults.standard
        
        
        //
        //forceing functioning reduction to the max/min/max available for this versione of the App
                
                if let firstTimeRunnCode = defaultsDataStore.string(forKey: "keyFirstTimeRunnCode") {
                     // ok already done
                    print("minimal setting to operate in place")
                }else{
                    //defaultsDataStore.set("prx&gps", forKey: DefaultsKeysDataStore.keyPositioningTechnique)
                    defaultsDataStore.set("prx",     forKey: DefaultsKeysDataStore.keyPositioningTechnique)
                    defaultsDataStore.set("dressed", forKey: DefaultsKeysDataStore.keyUserPosture)
                    defaultsDataStore.set("shake",   forKey: DefaultsKeysDataStore.keyFeedbackMode)
                    
                    defaultsDataStore.set("PREMISE", forKey: DefaultsKeysDataStore.keyManagedArea)
                    
                    
                    
                    defaultsDataStore.set("yes",     forKey: DefaultsKeysDataStore.keyBeaconOperationalMode)
                    defaultsDataStore.set("yes",     forKey: DefaultsKeysDataStore.keyShakerOperationalMode)
                    defaultsDataStore.set("yes",     forKey: DefaultsKeysDataStore.keyText2SpeechMode)
                    
                    
                    print("forced minimal setting to operate")
                    defaultsDataStore.set("done",    forKey: "keyFirstTimeRunnCode")
                }
        //end forcing functioning
        //
        
        
        
        
                configInPlace.aboutThisApp = false
                if let aboutThisApp = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyAboutThisAppReaded) {
                     if let index = GuidaDataModel.aboutThisAppModes.firstIndex(of: aboutThisApp) {
                         if (index==1) { configInPlace.aboutThisApp = true}
                     }
                 }
        
                 configInPlace.instructions = false
                 if let instructions = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyInstructionsReaded) {
                      if let index = GuidaDataModel.instructionsModes.firstIndex(of: instructions) {
                          if (index==1) { configInPlace.instructions = true}
                      }
                  }
        
                configInPlace.privacy = false
                 if let privacy = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyPrivacyAccepted) {
                      if let index = GuidaDataModel.privacyModes.firstIndex(of: privacy) {
                          if (index==1) { configInPlace.privacy = true}
                      }
                  }
                configInPlace.disclaimer = false
                if let disclaimer = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyDisclaimerAccepted) {
                     if let index = GuidaDataModel.disclaimerModes.firstIndex(of: disclaimer) {
                         if (index==1) { configInPlace.disclaimer = true}
                     }
                 }
                     
                    if let operationalMode = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyOperativityMode) {
                         if let index = GuidaDataModel.operativityModes.firstIndex(of: operationalMode) {
                             configInPlace.operativityMode[0] = index;
                         }else{
                             configInPlace.operativityMode[0] = configInPlace.operativityMode[1];
                         }
                       }else{
                           configInPlace.operativityMode[0] = configInPlace.operativityMode[2];
                       }
        
                    if let configurationURL = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyConfigurationURL) {
                              configInPlace.configurationURL = configurationURL;
                        }
                    configInPlace.configurationURLverified = false
                    if let configurationURLverified = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyConfigurationURLverified) {
                        if (configurationURLverified == "yes") {
                            configInPlace.configurationURLverified = true
                        }
                    }
                    if let userCharacter = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyUserCharacter) {
                          if let index = GuidaDataModel.userCharacters.firstIndex(of: userCharacter) {
                              configInPlace.userCharacterMode[0] = index;
                          }else{
                              configInPlace.userCharacterMode[0] = configInPlace.userCharacterMode[1];
                          }
                        }else{
                            configInPlace.userCharacterMode[0] = configInPlace.userCharacterMode[2];
                        }
                configInPlace.positioningTechnique[0] = configInPlace.positioningTechnique[1];
                if let tecnica = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyPositioningTechnique) {
                    if let index = GuidaDataModel.positioningTechniques.firstIndex(of: tecnica) {
                        if (index>=0) { configInPlace.positioningTechnique[0] = GuidaDataModel.positioningTechniques.index(after: index)
                        }
                    }
                    status.positioningTechnique = tecnica
                }
        
        
        
                configInPlace.userPosture[0] = configInPlace.userPosture[1];
        
        
        
                /*   quì c'è un errore !!! ??? */
                configInPlace.phoneMode[0] = configInPlace.phoneMode[1];
                if let phone = defaultsDataStore.string(forKey:
                    DefaultsKeysDataStore.keyUserPosture) {
                    if let index = GuidaDataModel.phoneModes.firstIndex(of: phone) {
                        if (index>=0) { configInPlace.phoneMode[0] = GuidaDataModel.phoneModes.index(after: index)
                        }
                    }
                }
        
                configInPlace.voiceMode[0] = configInPlace.voiceMode[1];
        
        
                
                configInPlace.feedbackMode[0] = configInPlace.feedbackMode[1];
                if let feed = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyFeedbackMode) {
                    if let index = GuidaDataModel.feedbackModes.firstIndex(of: feed) {
                        if (index>=0) { configInPlace.feedbackMode[0] = GuidaDataModel.feedbackModes.index(after: index)
                        }
                    }
                    status.feedbackMode = feed
                }
                
                configInPlace.selectedArea[0] = configInPlace.selectedArea[1];
                if let area = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyManagedArea) {
                    if let index = GuidaDataModel.managedAreas.firstIndex(of: area) {
                        if (index>=0) { configInPlace.selectedArea[0] = GuidaDataModel.managedAreas.index(after: index)
                            //PTF GIAK 2021/2/7 ???
                            status.selectedArea = area // !!! to be verified !!!
                        }
                    }
                }
                
                
                configInPlace.beacon = false
                if let beacon = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyBeaconOperationalMode) {
                    if let index = GuidaDataModel.beaconModes.firstIndex(of: beacon) {
                        if (index==1) { configInPlace.beacon = true}
                    }
                }
        
                
                configInPlace.shaker = false
                if let shaker = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyShakerOperationalMode) {
                    if let index = GuidaDataModel.shakerModes.firstIndex(of: shaker) {
                        if (index==1) { configInPlace.shaker = true}
                    }
                }
        
                configInPlace.t2s = false
                if let t2s = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyText2SpeechMode) {
                    if let index = GuidaDataModel.t2sModes.firstIndex(of: t2s) {
                        if (index==1) { configInPlace.t2s = true}
                    }
                }
                
                
        
        // configurationURL
        if (configInPlace.instructions
         || configInPlace.disclaimer
         || configInPlace.privacy) {
            if (configInPlace.configurationURL != "" && !configInPlace.configurationURLverified){
                let testo = "configuratin URL not provided or nor valid. force reset to restart."
                let alert = UIAlertController(title: "Orientamento ver "+String(configInPlace.versions[0]), message: testo, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                configURLTextView.isUserInteractionEnabled = false
                configURLTextView.isEnabled = false
            }
        }else{
            configURLTextView.isUserInteractionEnabled = true
            configURLTextView.isEnabled = true
        }
        
        
        //enable signin button if all actions have been taken
          if (configInPlace.configurationURLverified
           && configInPlace.aboutThisApp
           && configInPlace.instructions
           && configInPlace.disclaimer
           && configInPlace.privacy) {
              signinButton.isEnabled = true
          }else{
            signinButton.isEnabled = false
        }
        
        
    }
    
    
    func changeIconAction(_ state: Bool) {
        print(UIApplication.shared.alternateIconName ?? "Primary")
        if UIApplication.shared.supportsAlternateIcons {
            // let the user choose a new icon
            print("authorized)")
            UIApplication.shared.setAlternateIconName("PREMISE")
        }
                
        return
        
        // Check if the system allows you to change the icon
        if UIApplication.shared.supportsAlternateIcons {
            if (state==true) {
                // Show alternative app icon
                
                
                
                UIApplication.shared.setAlternateIconName("AppIcon-2") { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("App Icon changed!")
                    }
                }
            } else {
                print("App Icon reversed to default!")
                // Show default app icon (Red Logo)
                //UIApplication.shared.setAlternateIconName(nil)
                UIApplication.shared.setAlternateIconName("PREMISEpurple")
            }
        }
    }
    
    @IBAction func signinButtonPressed(_ sender: Any) {
        if (configInPlace.timeBombed == true){
            
            
            let alertMsg = "App disribution controller. Trial period expired. Call your technical support."
            let alert = UIAlertController(title: "Orientamento ver "+String(configInPlace.versions[0]), message: alertMsg, preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            exit(EXIT_SUCCESS)
        }
  
                
        let defaultsDataStore = UserDefaults.standard
        
        //enable signin button if all actions have been taken
          if (!configInPlace.aboutThisApp
           || !configInPlace.instructions
           || !configInPlace.disclaimer
           || !configInPlace.privacy) {
              NSLog("error acceptance process not properly managed");
            if (sender as! NSObject==signinButton){
                signinButton.accessibilityHint = NSLocalizedString("hint-signinButton", comment: "accessibility hint")
            }
          }
        
             if let operationalMode = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyOperativityMode) {
                 //print(operationalMode) // Some String Value
                 
                 if (operationalMode != tmpOperationalMode && tmpOperationalMode != "")
                 {
                     NSLog("error Operational Mode not properly managed");
                 }
             }else{
                 defaultsDataStore.set(tmpOperationalMode, forKey: DefaultsKeysDataStore.keyOperativityMode)
             }
             
              if let userCharacter = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyUserCharacter) {
                  //print(userCharacter) // Some String Value
                  
                  if (userCharacter != tmpUserCharacter && tmpUserCharacter != "")
                  {
                      NSLog("error User Character not properly managed");
                  }
              }else{
                  defaultsDataStore.set(tmpUserCharacter, forKey: DefaultsKeysDataStore.keyUserCharacter)
              }
        
            changeIconAction(true)
        }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
         let defaultsDataStore = UserDefaults.standard
        
        defaultsDataStore.set("no", forKey: DefaultsKeysDataStore.keyAboutThisAppReaded)
        defaultsDataStore.set("no", forKey: DefaultsKeysDataStore.keyInstructionsReaded)
        defaultsDataStore.set("no", forKey: DefaultsKeysDataStore.keyPrivacyAccepted)
        defaultsDataStore.set("no", forKey: DefaultsKeysDataStore.keyDisclaimerAccepted)
        defaultsDataStore.set("no", forKey: DefaultsKeysDataStore.keyOperativityMode)
        defaultsDataStore.set("no", forKey: DefaultsKeysDataStore.keyUserCharacter)
        
        changeIconAction(false)
        configURLTextView.isUserInteractionEnabled = true
        configURLTextView.isEnabled = true
        
        self.viewWillAppear(true)
     }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView==characterPickerView {
            return 1;
        }else{
            if pickerView==modesPickerView {
                return 1;
            }else{
                return 0;
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView==characterPickerView {
             return GuidaDataModel.userCharacters.count;
         }else{
             if pickerView==modesPickerView {
                 return GuidaDataModel.operativityModes.count;
             }else{
                 return 0;
             }
         }
    }
    // in this case replaced by attributedTitleForRow....
    func pickerView(_ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String? {
        // Return a string from the array for this row.
        if pickerView==characterPickerView {
             return GuidaDataModel.userCharacters[row]
         }else{
             if pickerView==modesPickerView {
                 return GuidaDataModel.operativityModes[row]
             }else{
                 return "!";
             }
         }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        if pickerView==characterPickerView {
            let userCharacterSelected = GuidaDataModel.userCharacters[row] as String
            
            let defaultsDataStore = UserDefaults.standard
             
             if let userCharacterSelected = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyUserCharacter) {
                 //print(operationalMode) // Some String Value
                tmpUserCharacter = userCharacterSelected
             }else{
                    defaultsDataStore.set(userCharacterSelected, forKey: DefaultsKeysDataStore.keyUserCharacter)
            }
         }else{
             if pickerView==modesPickerView {
                 let operationalModeSelected = GuidaDataModel.operativityModes[row] as String
                 //print(operationalModeSelected)
                 let defaultsDataStore = UserDefaults.standard
                  
                  if let operationalMode = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyOperativityMode) {
                      //print(operationalMode) // Some String Value
                     tmpOperationalMode = operationalModeSelected
                  }else{
                         defaultsDataStore.set(operationalModeSelected, forKey: DefaultsKeysDataStore.keyOperativityMode)
                 }
             }
         }
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var myTitle:NSAttributedString
        let titleData:String
        if pickerView==characterPickerView {
             titleData = GuidaDataModel.userCharacters[row]
        }else{
             if pickerView==modesPickerView {
                 titleData = GuidaDataModel.operativityModes[row]
             }else{
                 titleData = "!";
             }
        }
        myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 20.0)!,NSAttributedString.Key.foregroundColor:UIColor.red])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView  {
         let pickerLabel = UILabel()
         let titleData:String
         if pickerView==characterPickerView {
              titleData = GuidaDataModel.userCharacters[row]
         }else{
              if pickerView==modesPickerView {
                  titleData = GuidaDataModel.operativityModes[row]
              }else{
                  titleData = "!";
              }
         }
         let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 20.0)!,NSAttributedString.Key.foregroundColor:UIColor.red])
         pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .center //.right
        return pickerLabel
    }
    
    
    
    
    
    // keyboard controlling
    
    @objc func taped(){
        self.view.endEditing(true)
    }
    @objc func KeyboardWillShow(sender: NSNotification){
        let keyboardSize : CGSize = ((sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    @objc func KeyboardWillHide(sender : NSNotification){
        let keyboardSize : CGSize = ((sender.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size)!
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    
}
extension SigninViewController {    // ViewController
    
    @objc func aboutThisAppReaded(){
         setUserControlFlags()
        updateConfigurationInPlace()
         
     }
    
    @objc func instructionsReaded(){
         setUserControlFlags()
        updateConfigurationInPlace()
         
     }
         
    
    @objc func privacyAccepted(){
          setUserControlFlags()
        updateConfigurationInPlace()
          
      }
      
      @objc func disclamerAccepted(){
         setUserControlFlags()
        updateConfigurationInPlace()
      }
      
     
  func setUserControlFlags(){
        let defaultsDataStore = UserDefaults.standard
    
        if let aboutThisAppReaded = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyAboutThisAppReaded) {
             if aboutThisAppReaded == "yes" {
                aboutThisAppCheckImageView.isHidden = false
                aboutThisAppCheckImageView.isAccessibilityElement = true
             }else{
                aboutThisAppCheckImageView.isHidden = true
                aboutThisAppCheckImageView.isAccessibilityElement = false
             }
         }else{
             defaultsDataStore.set("no", forKey: DefaultsKeysDataStore.keyAboutThisAppReaded)
             aboutThisAppCheckImageView.isHidden = true
             aboutThisAppCheckImageView.isAccessibilityElement = false
         }
        if let instructionsReaded = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyInstructionsReaded) {
             if instructionsReaded == "yes" {
                instructionsCheckImageView.isHidden = false
                instructionsCheckImageView.isAccessibilityElement = true
                //forse meglio così//instructionsButtonView.isHidden = true
             }else{
                instructionsCheckImageView.isHidden = true
                instructionsCheckImageView.isAccessibilityElement = false
                instructionsButtonView.isHidden = false
                modesPickerView.isUserInteractionEnabled = true
                characterPickerView.isUserInteractionEnabled = true
             }
         }else{
             defaultsDataStore.set("no", forKey: DefaultsKeysDataStore.keyPrivacyAccepted)
             instructionsCheckImageView.isHidden = true
             instructionsCheckImageView.isAccessibilityElement = false
             instructionsButtonView.isHidden = false
             modesPickerView.isUserInteractionEnabled = true
             characterPickerView.isUserInteractionEnabled = true
         }
    
        if let privacyAccepted = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyPrivacyAccepted) {
             if privacyAccepted == "yes" {
                privacyCheckImageView.isHidden = false
                privacyCheckImageView.isAccessibilityElement = true
                //forse meglio così//privacyButtomView.isHidden = true
                modesPickerView.isUserInteractionEnabled = false
                characterPickerView.isUserInteractionEnabled = false
                
             }else{
                privacyCheckImageView.isHidden = true
                privacyCheckImageView.isAccessibilityElement = false
                privacyButtomView.isHidden = false
                modesPickerView.isUserInteractionEnabled = true
                characterPickerView.isUserInteractionEnabled = true
             }
         }else{
             defaultsDataStore.set("no", forKey: DefaultsKeysDataStore.keyPrivacyAccepted)
             privacyCheckImageView.isHidden = true
             privacyCheckImageView.isAccessibilityElement = false
             privacyButtomView.isHidden = false
             modesPickerView.isUserInteractionEnabled = true
             characterPickerView.isUserInteractionEnabled = true
         }
        
        if let disclamerAccepted = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyDisclaimerAccepted) {
              if disclamerAccepted == "yes" {
                disclaimerCheckImageView.isHidden = false
                disclaimerCheckImageView.isAccessibilityElement = true
                  //forse meglio così//disclaimerButtomView.isHidden = true
                modesPickerView.isUserInteractionEnabled = false
                characterPickerView.isUserInteractionEnabled = false
                
              }else{
                  disclaimerCheckImageView.isHidden = true
                  disclaimerCheckImageView.isAccessibilityElement = false
                  disclaimerButtomView.isHidden = false
                  modesPickerView.isUserInteractionEnabled = true
                  characterPickerView.isUserInteractionEnabled = true
              }
          }else{
              defaultsDataStore.set("no", forKey: DefaultsKeysDataStore.keyDisclaimerAccepted)
              disclaimerCheckImageView.isHidden = true
              disclaimerCheckImageView.isAccessibilityElement = false
              disclaimerButtomView.isHidden = false
              modesPickerView.isUserInteractionEnabled = true
              characterPickerView.isUserInteractionEnabled = true
          }
     
        
        
        if let operationalMode = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyOperativityMode) {
              //print(operationalMode) // Some String Value
            if let index = GuidaDataModel.operativityModes.firstIndex(of: operationalMode) {
                //print(index)
                modesPickerView.selectRow(index, inComponent: 0, animated: true)
            }else{
                defaultsDataStore.removeObject(forKey: DefaultsKeysDataStore.keyOperativityMode)
                modesPickerView.selectRow(0, inComponent: 0, animated: true)
            }
          }else{
              modesPickerView.selectRow(0, inComponent: 0, animated: true)
          }
    
    
        if let userCharacter = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyUserCharacter) {
              //print(userCharacter) // Some String Value
            if let index = GuidaDataModel.userCharacters.firstIndex(of: userCharacter) {
                //print(index)
                characterPickerView.selectRow(index, inComponent: 0, animated: true)
            }else{
                defaultsDataStore.removeObject(forKey: DefaultsKeysDataStore.keyUserCharacter)
                characterPickerView.selectRow(0, inComponent: 0, animated: true)
            }
          }else{
              characterPickerView.selectRow(0, inComponent: 0, animated: true)
          }
    
    
    
        // configurationURL
    
        if let configurationURL = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyConfigurationURL) {
                  configInPlace.configurationURL = configurationURL;
            configURLTextView.text = configInPlace.configurationURL
            }else{
                configInPlace.configurationURL = ""
                configURLTextView.text = "enter a URL"
                defaultsDataStore.set(configInPlace.configurationURL, forKey: DefaultsKeysDataStore.keyConfigurationURL)
            }
    
        if let configurationURLverified = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyConfigurationURLverified) {
            if (configurationURLverified == "yes") {
                configInPlace.configurationURLverified = true
            }else{
                configInPlace.configurationURLverified = false
            }
        }else{
            defaultsDataStore.set("no", forKey: DefaultsKeysDataStore.keyConfigurationURLverified)
            configInPlace.configurationURLverified = false
        }
        
        
        
    }
    
}
extension SigninViewController {    // bussola
    
    
    
    
}
extension SigninViewController {   // shakeing gesture
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            
            print("Device was shaken")
            if (configInPlace.shaker==true){
                statistics.shaker += 1
                
                //AudioServicesPlaySystemSound(1209) //plays a beep tone
                let myNotificationKey = "sensorLocated"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: myNotificationKey), object: nil, userInfo: ["name":"device shaked"])
                if (status.feedbackMode.contains("shake")){
                    let myNotificationKey = "sensorForOrientation"
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: myNotificationKey), object: nil, userInfo: ["name":"device shaked"])
                }
                
                AudioServicesPlaySystemSound (codifiedBeeps[shakedDeviceBeep])
            }else{ statistics.missedShaker += 1 }
            
        }
        
    }
     
     override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
            
        if motion == .motionShake {
            
            print("Device is shaking!")
            if (configInPlace.shaker==true){
                statistics.shaker += 1
                
                //AudioServicesPlaySystemSound(1200) //plays a beep tone
                let myNotificationKey = "sensorLocated"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: myNotificationKey), object: nil, userInfo: ["name":"device shaking"])
            }else{ statistics.missedShaker += 1 }
            
        }
        
     }
    
}
extension SigninViewController {  // gps and beacon location manager
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                    startScanning()
                }
            }
        }
        
    }
    
    func startScanning() {
        /**/
        //let uuid = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        /**/
        
        if (status.selectedArea=="") {
            status.selectedArea = status.beaconConfiguration[0].id
        }
        guard let indx = status.managedAreas.firstIndex(of: status.selectedArea) else { return }
        let uuid = UUID(uuidString: status.beaconConfiguration[indx].uuid)!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: status.beaconConfiguration[indx].id)
        
        
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyEntryStateOnDisplay = true
        beaconRegion.notifyOnExit = true
        
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let content = UNMutableNotificationContent()
        let request = UNNotificationRequest(identifier: "entered", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let content = UNMutableNotificationContent()
        let request = UNNotificationRequest(identifier: "exited", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       if let error = error as? CLError, error.code == .denied {
          // Location updates are not authorized.
          manager.stopUpdatingLocation()
          return
       }
       // Notify the user of any errors.
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        //AudioServicesPlaySystemSound(1306) //plays a beep tone
        threadSafeEnforcementBeacon.lock();
        for beacon in beacons {
            
            if (configInPlace.beacon==true){
                statistics.beacon += 1
                
                var _uuid = beacon.uuid.uuidString
                var __uuid = ""
                while(__uuid != _uuid){
                    if (__uuid != "") { _uuid = __uuid }
                    __uuid = _uuid.replacingOccurrences(of: "00-", with: "0-", options: .regularExpression)
                }
                _uuid = ""
                while(__uuid != _uuid){
                    if (_uuid != "") { __uuid = _uuid }
                    _uuid = __uuid.replacingOccurrences(of: "-00", with: "-0", options: .regularExpression)
                }
                _uuid = _uuid + "+" + beacon.major.stringValue + "+" + beacon.minor.stringValue
                
                //print(beacon)
                var done = false
                var n = 0
                
                //for each beacon in entities.beaconDATA {
                for bd in entities.beaconDATA {
                    
                    if (bd.xid == _uuid){
                        //print(bd)
                        let m = entities.beaconDATA[n].signals.count
                        if m>=entities.BeaconDepth {
                            entities.beaconDATA[n].signals.remove(at: m-1)
                        }
                        entities.beaconDATA[n].signals.insert(
                                (
                                    rssi: Double(beacon.rssi),
                                    distance: beacon.accuracy,
                                    timestamp: Date().toMillis()
                                )
                            ,
                            at: 0)
                        done = true
                        
                        break
                        
                    }else{
                        
                    }
                    
                    n += 1
                    
                }
 
                if (done==false){
                    var _uuid = beacon.uuid.uuidString
                    var __uuid = ""
                    while(__uuid != _uuid){
                        if (__uuid != "") { _uuid = __uuid }
                        __uuid = _uuid.replacingOccurrences(of: "00-", with: "0-", options: .regularExpression)
                    }
                    _uuid = ""
                    while(__uuid != _uuid){
                        if (_uuid != "") { __uuid = _uuid }
                        _uuid = __uuid.replacingOccurrences(of: "-00", with: "-0", options: .regularExpression)
                    }
                    _uuid = _uuid + "+" + beacon.major.stringValue + "+" + beacon.minor.stringValue
                    
                    entities.beaconDATA.insert(
                        (xid: _uuid,
                         signals: [
                                    (
                                        rssi: Double(beacon.rssi),
                                        distance: beacon.accuracy,
                                        timestamp: Date().toMillis()
                                    )
                                ]
                        ),
                        at: 0)
                    
                }
                
                let nc = NotificationCenter.default
                //nc.post(name: Notification.Name("beaconLocated"), object: nil)
                let myNotificationKey = "sensorLocated"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: myNotificationKey), object: nil, userInfo: ["name":beacon.description])
                if (status.positioningTechnique.contains("prx")){
                    let myNotificationKey = "sensorForOrientation"
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: myNotificationKey), object: nil, userInfo: ["name":beacon.description+">>"+getLocatedBeaconPosition(bea: beacon)+"<<"])
                }
                
            }else{ statistics.missedBeacon += 1 }
            
        }
        
        entities.beaconsWeighed = pesaEordina( kk: entities.beaconDATA)
        threadSafeEnforcementBeacon.unlock();
        /*
        for ent in entities.beaconDATA {
            print("beacon \(ent)")
        }
 */
        
    }
    
    func getLocatedBeaconPosition(bea: CLBeacon) -> String {
        let distance = bea.proximity
        //UIView.animate(withDuration: 0.8) {
            switch distance {
            case .far:
                //NSLog("FAR \(distance)");
                return "far";
            case .near:
                //NSLog("NEAR \(distance)");
                return "near";
            case .immediate:
                //NSLog("RIGHT HERE \(distance)");
                return "right here";
            default:
                //NSLog("UNKNOWN \(distance)");
                return "unknown";
            }
        //}
    }
    
    func standardDeviation(arr : [Double]) -> Double
    {
        let length = Double(arr.count)
        let avg = arr.reduce(0, {$0 + $1}) / length
        let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
    
    
    
    func pesaEordina( kk: [(xid: String, signals: [(rssi: Double, distance: Double, timestamp: Int64)])] ) -> [(xid: String, signals: [(rssi: Double, distance: Double, timestamp: Int64)])] {
        var tobeweighed: [(xid: String, signals: [(rssi: Double, distance: Double, timestamp: Int64)])] = kk
        var tbrmtrx:[(xid: Int, xoff: [Int])] = [] // entries to be removed matrix
        var scan = 0;
        for beacon in tobeweighed {
            tbrmtrx.insert( (xid: scan, xoff: []), at: scan)
            var tbr = 0;
            for signal in beacon.signals {
                if ((Date().toMillis() - signal.timestamp) <= entities.TimeFrame) {
                    //print(signal)
                }else{
                    tbrmtrx[ scan ].xoff.insert( tbr, at: 0 )
                }
                tbr += 1
            }
            scan += 1
        }
        for etbr in tbrmtrx {
            for sign in etbr.xoff {
                tobeweighed[ etbr.xid ].signals.remove (at: sign)
            }
        }
    
        var weighed: [(xid: String, signals: [(rssi: Double, distance: Double, timestamp: Int64)])] = []
        for one in tobeweighed {
            
            var done = false
            if (one.signals.count >= entities.MinNumberOfSignals) {
                var tmpArrayRSSI:[Double] = []
                var tmpArrayDIST:[Double] = []
                for n in 0..<one.signals.count {
                    if (one.signals[n].rssi <= 0 && one.signals[n].rssi >= -200) {
                        tmpArrayRSSI.insert( one.signals[n].rssi, at: tmpArrayRSSI.endIndex )
                        tmpArrayDIST.insert( one.signals[n].distance, at: tmpArrayDIST.endIndex )
                    }
                }
                if (tmpArrayRSSI.count >= 2) {
                    let stdDevRSSI = standardDeviation(arr: tmpArrayRSSI)
                    let stdDevDIST = standardDeviation(arr: tmpArrayDIST)
                    if (tmpArrayRSSI[0] > (tmpArrayRSSI[1]+stdDevRSSI)) {
                        weighed.insert( (xid: one.xid, signals: [(rssi: (tmpArrayRSSI[0]-stdDevRSSI), distance: (tmpArrayDIST[0]-stdDevDIST), timestamp: one.signals[0].timestamp)]), at: weighed.endIndex)
                        done = true
                    }else{
                        if (tmpArrayRSSI[0] < (tmpArrayRSSI[1]-stdDevRSSI)) {
                            weighed.insert( (xid: one.xid, signals: [(rssi: (tmpArrayRSSI[0]+stdDevRSSI), distance: (tmpArrayDIST[0]+stdDevDIST), timestamp: one.signals[0].timestamp)]), at: weighed.endIndex)
                            done = true
                        }
                    }
                }
            }
            if done==false {
                if (one.signals.count>0) {
                    weighed.insert( (xid: one.xid, signals: [(rssi: one.signals[0].rssi, distance: one.signals[0].distance, timestamp: one.signals[0].timestamp)]), at: weighed.endIndex)
                }
            }
            
        }
        
        // sort keeping stronghest signals to the top of the matrix
        var run = true
        while(run){
            run = false;
            if (weighed.count>1) {
                for curr in 0..<((weighed.count)-1) {
                    if weighed[curr].signals[0].rssi < weighed[curr+1].signals[0].rssi {
                        let tmp = weighed[curr]
                        weighed[curr] = weighed[curr+1]
                        weighed[curr+1] = tmp
                        run = true;
                        //break;
                    }
                }
            }
        }
        
        return weighed
    }
    
}
 
extension SigninViewController { // accelerometro
    
    
    
}
extension SigninViewController {  // pedometer
    
    
    
    
    
    
    
    
    private func on(error: Error) {
        //handle error
    }
    
    
    
    
    
    
    
    
    
    @IBAction func aboutButton(_ sender: Any) {
        let defaultsDataStore = UserDefaults.standard
        if let aboutThisAppReaded = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyAboutThisAppReaded) {
        }
        defaultsDataStore.set("yes", forKey: DefaultsKeysDataStore.keyAboutThisAppReaded)
        aboutThisAppReaded()
        
        
        var alertMsgPart1 = "\n\nSection/Statement Not yet provided by the publisher of this App.\nHerein below the default Statement provided by the Developer.\n\n"
        for cerco in GuidaDataModel.formality {
            if (status.linguaCorrente.lowercased().starts(with: cerco.language.lowercased())) {
                alertMsgPart1 = cerco.aboutThisApp
                break
            }
        }
        let alertMsg = "\(alertMsgPart1)\n\n\(NSLocalizedString("o2-ir1-aa3", comment: "aboutThisApp"))"
        let alert = UIAlertController(title: "Orientamento ver "+String(configInPlace.versions[0])+",tb[\(status.days2EOS)]", message: alertMsg, preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    
    }
    
    
}

