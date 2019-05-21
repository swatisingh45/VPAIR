//
//  ViewController.swift
//  MyVPAIRFinal
//
//  Created by Swati Singh on 04/10/18.
//  Copyright © 2018 Swati Singh. All rights reserved.
//

import UIKit

import FirebaseAuth


class ViewController: UIViewController {
    
    var signUpMode = true
    
    @IBOutlet var backgroundImage: UIImageView!
    
    @IBOutlet var customerLabel: UILabel!
    
    
    @IBOutlet var mechanicLabel: UILabel!
    
    
    
    @IBOutlet var emailTextField: UITextField!
    
    
    @IBOutlet var passwordTextField: UITextField!
    
    
    @IBOutlet var phoneNumberTextField: UITextField!
    
    @IBOutlet var switchUsers: UISwitch!
    
    
    @IBOutlet var topButton: UIButton!
    
    @IBOutlet var bottomButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if   segue.identifier == "customerSegue" {
            
            Constants.mobileNumber = phoneNumberTextField.text!
            
        }
    }
    
    
    
    
    @IBAction func topFunc(_ sender: Any) {
        
        if emailTextField.text == " " || passwordTextField.text == " "{
            displayAlert(title: "Missing information", message: "You must provide both email and password")
            
        }else {
            
            
            if let email = emailTextField.text {
                if let password = passwordTextField.text {
               
                        if signUpMode {
                            //SIGN UP
                            
                            
                            
                            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                                
                                if error != nil {
                                    
                                    self.displayAlert(title: "Error", message: error!.localizedDescription )
                                    
                                } else {
                                    print("Sign Up Success")
                                    
                                    if self.switchUsers.isOn {
                                        //They are mechanic
                                        
                                        let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                        
                                        req?.displayName = "Mechanic"
                                        req?.commitChanges(completion: nil)
                                        self.performSegue(withIdentifier: "mechanicSegue", sender: nil)
                                        
                                    }else {
                                        let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                        
                                        req?.displayName = "Customer"
                                        req?.commitChanges(completion: nil)
                                        
                                        
                                        // They are customers
                                        self.performSegue(withIdentifier: "customerSegue", sender: nil)
                                        
                                        
                                        
                                    }
                                    
                                }
                                
                            })
                            
                            
                        } else {
                            
                            // LOG IN
                            
                            Auth.auth().signIn(withEmail: email, password: password, completion: { (result, error) in
                                
                                if error != nil {
                                    
                                    self.displayAlert(title: "Error", message: error!.localizedDescription )
                                    
                                } else {
                                    //to check whether customer or mechanic
                                    // For Mechanic
                                    // This statement uset?.displayName has been changed to more descriptive name to result
                                    // Also change this in the baove Auth function
                                    
                                    
                                    if result?.user.displayName == "Mechanic"{
                                        
                                        print("Mechanic")
                                        self.performSegue(withIdentifier: "mechanicSegue", sender: nil)
                                        
                                    }else {
                                        
                                        // For Customer
                                        
                                        print("Log In Success")
                                        self.performSegue(withIdentifier: "customerSegue", sender: nil)
                                        
                                    }
                                }
                                
                            })
                        }
                        
                    }
                }
            }
    }
    
    
    
    //Our own function
    
    func displayAlert(title : String ,message : String){
        
        let alertController = UIAlertController(title:  title, message: message, preferredStyle: .alert )
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alertController, animated: true)
        
        
        
    }
    
    
    @IBAction func bottomFunc(_ sender: Any) {
        
        
        if signUpMode {
            
            topButton.setTitle( "Log in", for: .normal)
            bottomButton.setTitle("Switch to sign up", for: .normal)
            // Hide those things
            
            mechanicLabel.isHidden = true
            customerLabel.isHidden = true
            switchUsers.isHidden = true
            signUpMode = false
            phoneNumberTextField.isHidden = true
            
        } else {
            
            // Just thte reverse of the above function .
            // Top should say "Sing up" and the bottom should say "Log in"
            
            topButton.setTitle( "Sign Up ", for: .normal)
            bottomButton.setTitle("Switch to Log in ", for: .normal)
            // Unhide those things
            
            mechanicLabel.isHidden = false
            customerLabel.isHidden = false
            switchUsers.isHidden = false
            signUpMode = true
            phoneNumberTextField.isHidden = false
            
            
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


