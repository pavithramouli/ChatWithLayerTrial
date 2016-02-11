//
//  ViewController.swift
//  ChatWithLayerTrial
//
//  Created by Pavithramouli on 19/01/16.
//  Copyright © 2016 Pavithramouli. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userGreeting: UILabel!
    @IBOutlet weak var loginToChatButton: UIButton!
    @IBOutlet weak var showChatListButton: UIButton!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!

    var isFromAlert : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSuccessfulAuthentication", name:"SuccessfulAuthenticationNotification", object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func iniateLogin(sender: AnyObject) {
        
        if(UserModel.currentUser.isUserAuthenticatedInLayer){
            LayerManager.layerManager.deauthenticateUser();
            LayerManager.layerManager.clearLayerData();
            self.showChatListButton.hidden = true;
            self.loginToChatButton.setTitle("Login to chat", forState: .Normal);
        }
        else{
            let actionSheetController: UIAlertController = UIAlertController(title: "Attention", message: "Confirm user ID", preferredStyle: .Alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                //Do some stuff
            }
            actionSheetController.addAction(cancelAction)
            let nextAction: UIAlertAction = UIAlertAction(title: "Next", style: .Default) { action -> Void in
                
                self.activityIndicator.type = .BallClipRotateMultiple;
                self.activityIndicator.size = CGSize(width: 100, height: 100);
                self.activityIndicator.color = UIColor.redColor();
                self.activityIndicator.hidesWhenStopped = true
                
                self.view.bringSubviewToFront(self.activityIndicator);
                self.activityIndicator.startAnimation();
                
                if(UserModel.currentUser.isUserAuthenticatedInLayer){
                    LayerManager.layerManager.deauthenticateUser();
                }
                LayerManager.layerManager.clearLayerData();

                let textFieldInstance = actionSheetController.textFields![0] as UITextField
                
                LayerManager.layerManager.currentUserID = textFieldInstance.text!;
                print("- New User ID: \(LayerManager.layerManager.currentUserID) --- \(textFieldInstance.text!)");
                
                LayerManager.layerManager.initiateLayerConnection();
            }
            actionSheetController.addAction(nextAction)
            actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
                textField.textColor = UIColor.blueColor()
                textField.text = "TestA11";
            }
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
    }
    
    func handleSuccessfulAuthentication(){
        UserModel.currentUser.isUserAuthenticatedInLayer = true;
        self.loginToChatButton!.setTitle("Logout from chat", forState: UIControlState.Normal);
        self.showChatListButton.enabled = true;
        self.showChatListButton.hidden = false;
        self.activityIndicator.stopAnimation();
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showChatListSegue"){
            
        }
    }

}

