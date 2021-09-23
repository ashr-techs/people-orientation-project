
//
//  PrivacyViewController.swift
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
class PrivacyViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var bannerIconView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerIconView.frame = CGRect(x: bannerIconView.frame.minX - (bannerIconView.frame.width / 2) , y: bannerIconView.frame.minY - (bannerIconView.frame.height / 2), width: bannerIconView.frame.width * 2, height: bannerIconView.frame.height * 2)
        
        privacyTextScrolling.delegate = self
        privacyTextScrolling.isEditable = false
        privacyTextScrolling.isScrollEnabled = true
        
        for cerco in GuidaDataModel.formality {
            if (status.linguaCorrente.lowercased().starts(with: cerco.language.lowercased())) {
                privacyTextScrolling.text = cerco.privacy
            }
        }
        
        let scrollViewHeight = privacyTextScrolling.frame.size.height;
        let scrollContentSizeHeight = privacyTextScrolling.contentSize.height;
        let scrollOffset = privacyTextScrolling.contentOffset.y;
        if (scrollViewHeight >= scrollContentSizeHeight)
        {
            privacyButtonView.isEnabled = true
        }else{
            privacyButtonView.isEnabled = false
        }
    }
    @IBOutlet weak var privacyTextScrolling: UITextView!
    
    @IBOutlet weak var privacyButtonView: UIButton!
    @IBAction func returnButtomPressed(_ sender: Any) {
        let defaultsDataStore = UserDefaults.standard
         
         if let privacyAccepted = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyPrivacyAccepted) {
             //print(privacyAccepted) // Some String Value
         }
         defaultsDataStore.set("yes", forKey: DefaultsKeysDataStore.keyPrivacyAccepted)
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("privacyAccepted"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height;
        let scrollContentSizeHeight = scrollView.contentSize.height;
        let scrollOffset = scrollView.contentOffset.y;
        if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
        {
            privacyButtonView.isEnabled = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

