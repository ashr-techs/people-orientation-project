
//
//  DisclaimerViewController.swift
//  Orientamento
//
//  Created by Mauro Antonio Giacomello on 19/02/2020.
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
class DisclaimerViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
        
    @IBOutlet weak var bannerIconView: UIImageView!
    
    @IBOutlet weak var disclaimerTextScrolling: UITextView!
    
    @IBOutlet weak var disclaimerButtonView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        bannerIconView.frame = CGRect(x: bannerIconView.frame.minX - (bannerIconView.frame.width / 2) , y: bannerIconView.frame.minY - (bannerIconView.frame.height / 2), width: bannerIconView.frame.width * 2, height: bannerIconView.frame.height * 2)
        
        navigationController?.delegate = self as? UINavigationControllerDelegate
        
        disclaimerTextScrolling.delegate = self
        disclaimerTextScrolling.isEditable = false
        disclaimerTextScrolling.isScrollEnabled = true
        
        for cerco in GuidaDataModel.formality {
            if (status.linguaCorrente.lowercased().starts(with: cerco.language.lowercased())) {
                disclaimerTextScrolling.text = cerco.disclaimer
            }
        }
        
        
        let scrollViewHeight = disclaimerTextScrolling.frame.size.height;
        let scrollContentSizeHeight = disclaimerTextScrolling.contentSize.height;
        let scrollOffset = disclaimerTextScrolling.contentOffset.y;
        if (scrollViewHeight >= scrollContentSizeHeight)
        {
            disclaimerButtonView.isEnabled = true
        }else{
            disclaimerButtonView.isEnabled = false
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height;
        let scrollContentSizeHeight = scrollView.contentSize.height;
        let scrollOffset = scrollView.contentOffset.y;
        if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
        {
            disclaimerButtonView.isEnabled = true
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView)
     {
        if (textView.scrollsToTop) {
            print("top")
        }
        
        
        /*
         if textView.contentSize.height >= self.messageTextViewMaxHeight
         {
             textView.scrollEnabled = true
         }
         else
             {
             textView.frame.size.height = textView.contentSize.height
             textView.scrollEnabled = false // textView.isScrollEnabled = false for swift 4.0
         }
 */
     }
    
    @IBAction func returnButtomPressed(_ sender: Any) {
        // Setting
        let defaultsDataStore = UserDefaults.standard
        
        if let disclamerAccepted = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyDisclaimerAccepted) {
            //print(disclamerAccepted) // Some String Value
        }
        defaultsDataStore.set("yes", forKey: DefaultsKeysDataStore.keyDisclaimerAccepted)
        /*
         https://stackoverflow.com/questions/34972287/reload-and-not-reload-if-press-back-from-different-view-controllers-swift
         
        if let viewControllers = app.window?.rootViewController?.childViewControllers {
            viewControllers.forEach {
                ($0 as? FirstViewController)?.tableView.reloadData()
            }
        }
         
        navigationController?.viewControllers.forEach {
            ($0 as? FirstViewController)?.tableView.reloadData()
        }
        */
        
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("disclamerAccepted"), object: nil)
        self.dismiss(animated: true, completion: nil)
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

