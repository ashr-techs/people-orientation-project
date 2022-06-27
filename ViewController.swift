
//
//  ViewController.swift
//  Orientamento
//  Created by Mauro Antonio Giacomello on 07/05/21.
//
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
class ViewController: UIViewController {
    @IBOutlet var changeIconSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the saved switch state
        let savedState = UserDefaults.standard.bool(forKey: "switch_state")
        savedState ? (changeIconSwitch.isOn = true) : (changeIconSwitch.isOn = false)
    }
    @IBAction func changeIconAction(_ sender: UISwitch) {
        // Check if the system allows you to change the icon
        if UIApplication.shared.supportsAlternateIcons {
            if sender.isOn {
                // Show alternative app icon (Magenta Logo)
                UIApplication.shared.setAlternateIconName("MagentaLogo") { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("App Icon changed!")
                    }
                }
            } else {
                // Show default app icon (Red Logo)
                UIApplication.shared.setAlternateIconName(nil)
            }
        }
        // Save the switch state
        UserDefaults.standard.set(sender.isOn, forKey: "switch_state")
    }
}

