
//
//  instructionsViewController.swift
//  Orientamento
//
//  Created by Mauro Antonio Giacomello on 06/03/2020.
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
extension String {
var utfData: Data? {
        return self.data(using: .utf8)
    }
    var htmlAttributedString: NSAttributedString? {
        guard let data = self.utfData else {
            return nil
        }
        do {
            return try NSAttributedString(data: data,
                                          options: [
                                            .documentType: NSAttributedString.DocumentType.html,
                                            .characterEncoding: String.Encoding.utf8.rawValue
                ], documentAttributes: nil)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    var htmlString: String {
        return htmlAttributedString?.string ?? self
    }
}
/*----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----*/
class instructionsViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var bannerIconview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerIconview.frame = CGRect(x: bannerIconview.frame.minX - (bannerIconview.frame.width / 2) , y: bannerIconview.frame.minY - (bannerIconview.frame.height / 2), width: bannerIconview.frame.width * 2, height: bannerIconview.frame.height * 2)
        // Do any additional setup after loading the view.
        
        instructionTextScrolling.delegate = self
        instructionTextScrolling.isEditable = false
        instructionTextScrolling.isScrollEnabled = true
        
        for cerco in GuidaDataModel.formality {
            if (status.linguaCorrente.lowercased().starts(with: cerco.language.lowercased())) {
                instructionTextScrolling.text = cerco.instructions
                instructionTextScrolling.text = cerco.instructions.htmlString
            }
        }
        
        let scrollViewHeight = instructionTextScrolling.frame.size.height;
        let scrollContentSizeHeight = instructionTextScrolling.contentSize.height;
        let scrollOffset = instructionTextScrolling.contentOffset.y;
        if (scrollViewHeight >= scrollContentSizeHeight)
        {
            instructionButtonView.isEnabled = true
        }else{
            instructionButtonView.isEnabled = false
        }
    }
    
    @IBOutlet weak var instructionsTextView: UITextView!
    
    @IBOutlet weak var instructionButtonView: UIButton!
    @IBOutlet weak var instructionTextScrolling: UITextView!
    
    @IBAction func returnButtonPressed(_ sender: Any) {
           
            let defaultsDataStore = UserDefaults.standard
             
             if let instructionsReaded = defaultsDataStore.string(forKey: DefaultsKeysDataStore.keyInstructionsReaded) {
             }
             defaultsDataStore.set("yes", forKey: DefaultsKeysDataStore.keyInstructionsReaded)
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("instructionsReaded"), object: nil)
            self.dismiss(animated: true, completion: nil)
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height;
        let scrollContentSizeHeight = scrollView.contentSize.height;
        let scrollOffset = scrollView.contentOffset.y;
        if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
        {
            instructionButtonView.isEnabled = true
        }
    }
}

