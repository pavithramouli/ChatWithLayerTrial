//
//  ChatDetailsViewController.swift
//  ChatWithLayerTrial
//
//  Created by Pavithramouli on 19/01/16.
//  Copyright © 2016 Pavithramouli. All rights reserved.
//

import UIKit
import LayerKit
import NVActivityIndicatorView


class ChatDetailsViewController: UIViewController,UITableViewDelegate,UITextViewDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var messagesListTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var typingStatus: UILabel!
    @IBOutlet weak var imageToSend: UIImageView!
    @IBOutlet weak var messageSendButton: UIButton!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var addImageButton: UIButton!

    var messagesCount = 1;
    let LQSKeyboardHeight: CGFloat = 255.0
    let LQSMaxCharacterLimit = 300

    var isMessageFromCurrentUser = true;

    
    override func viewDidLoad() {
        super.viewDidLoad();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleConversationFetch", name:"ConversationFetched", object: nil)
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSuccessfulMessageQueing", name:"MessageQueuedForSend", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleMessageUpdates:", name:"LayerRequiresUIUpdate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleWhenQueryWillChange", name:"queryControllerWillChangeContent", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleWhenQueryDidChange", name:"queryControllerDidChangeContent", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTypingIndicatorUpdates:", name:"NeedsTypingIndicatorChange", object: nil)

        activityIndicator.type = .BallClipRotateMultiple;
        activityIndicator.size = CGSize(width: 100, height: 100);
        activityIndicator.color = UIColor.redColor();
        activityIndicator.hidesWhenStopped = true
        
        messagesListTableView.rowHeight = UITableViewAutomaticDimension
        messagesListTableView.estimatedRowHeight = 60.0
        
        bottomView.layer.cornerRadius = 10
        bottomView.layer.masksToBounds = true

        
        self.view.bringSubviewToFront(activityIndicator);
        
        self.view.bringSubviewToFront(addImageButton);
        activityIndicator.startAnimation();
        
        LayerManager.layerManager.fetchLayerConversation();
        
    }
    
    override func viewWillAppear(animated: Bool) {
        scrollToBottom()
        activityIndicator.stopAnimation();
    }
    
    func handleConversationFetch(){
        activityIndicator.stopAnimation();
        messagesListTableView.reloadData();
    }
    
    func handleSuccessfulMessageQueing(){
        activityIndicator.stopAnimation();
    }
    
    func handleWhenQueryWillChange(){
       // self.messagesListTableView.beginUpdates();
    }
    
    func handleWhenQueryDidChange(){
       // self.messagesListTableView.endUpdates();
        activityIndicator.stopAnimation();
        self.imageToSend.image = UIImage(named: "camera_placeholder.png");
        LayerManager.layerManager.photo = nil;
        self.messagesListTableView.reloadData();
        
    }
    
    func handleMessageUpdates(type:LYRQueryControllerChangeType){
         scrollToBottom();
       // messagesListTableView.insertRowsAtIndexPaths([LayerManager.layerManager.indexPathReference!], withRowAnimation: .Fade);
    }
    
    func handleTypingIndicatorUpdates(dictionary: [String: AnyObject]){
        
        let participantID = dictionary[LYRTypingIndicatorParticipantUserInfoKey] as! String
        let typingIndicator: LYRTypingIndicator = LYRTypingIndicator(rawValue: dictionary[LYRTypingIndicatorValueUserInfoKey] as! UInt)!
        
        if (typingIndicator == LYRTypingIndicator.DidBegin) {
            self.typingStatus.alpha = 1
            self.typingStatus.text = "\(participantID) is typing..."
        } else {
            self.typingStatus.alpha = 0
            self.typingStatus.text = ""
        }
    }
    
    @IBAction func sendMessageAction(sender: UIButton) {
        // Send Message
        self.view.bringSubviewToFront(activityIndicator);
        activityIndicator.startAnimation();
        LayerManager.layerManager.sendMessage(textView.text);
        
        // Lower the keyboard
        moveViewUpToShowKeyboard(false)
        textView.resignFirstResponder()
        textView.text = ""
    }
    
    // MARK: - TableView Delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messagesCount = Int(LayerManager.layerManager.queryControllerDuo!.count());
        //messagesCount = LayerManager.layerManager.numberOfMessages()
        print("\(messagesCount) Messages")
        return messagesCount;
         // return 1;
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = LayerManager.layerManager.queryControllerDuo!.objectAtIndexPath(indexPath) as! LYRMessage?
        if message == nil {
            return UITableViewAutomaticDimension
        }
        let messagePart = message!.parts[0] 
        
        //If it is type image
        if messagePart.MIMEType == "image/png" {
            return 440
        } else {
            return UITableViewAutomaticDimension
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SingleMessageCell", forIndexPath: indexPath) as! SingleMessageTableViewCell
        
        if(messagesCount > 0){
            configureCell(cell, forRowAtIndexPath: indexPath)
        }
        
        if(isMessageFromCurrentUser){
            cell.userIdentifier.textAlignment = .Right
            cell.singleMessageContent.textAlignment = .Right
            cell.statusStamp.textAlignment = .Right
            cell.contentInnerView.backgroundColor = UIColor.init(red: 102/255, green: 205/255, blue: 170/255, alpha: 1.0); //(102,205,170)
            cell.userIdentifier.textColor = UIColor.blueColor();
            cell.singleMessageContent.textColor = UIColor.blueColor();
            cell.statusStamp.textColor = UIColor.blueColor();

        }
        else{
            cell.userIdentifier.textAlignment = .Left
            cell.singleMessageContent.textAlignment = .Left
            cell.statusStamp.textAlignment = .Left
            cell.contentInnerView.backgroundColor = UIColor.init(red: 230/255, green: 230/255, blue: 250/255, alpha: 1.0);//(230,230,250)
            cell.userIdentifier.textColor = UIColor.purpleColor();
            cell.singleMessageContent.textColor = UIColor.purpleColor();
            cell.statusStamp.textColor = UIColor.purpleColor();


        }
        
        cell.contentInnerView.layer.cornerRadius = 10
        cell.contentInnerView.layer.masksToBounds = true
        return cell
    }
    
    func configureCell(cell: SingleMessageTableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Get Message Object from queryController
        let message = LayerManager.layerManager.queryControllerDuo!.objectAtIndexPath(indexPath) as? LYRMessage
        let messagePart: LYRMessagePart = message!.parts[0]
        
        //If it is type image
        if messagePart.MIMEType == "image/png" {
            cell.singleMessageContent.text = "";
            if messagePart.data != nil {
                cell.updateWithImage(UIImage(data: messagePart.data!)!)
                
            }
            
        } else {
            cell.removeImage() //just a safegaurd to ensure  that no image is present
            let textToSet = NSString(data: messagePart.data!, encoding: NSUTF8StringEncoding) as! String
            //textToSet.stringByReplacingOccurrencesOfString("Optional(\"", withString: "")
           // textToSet.stringByReplacingOccurrencesOfString("\")@", withString: " - ")
            cell.assignText(textToSet)
        }
        var timestampText = ""
        
        // If the message was sent by current user, show Receipent Status Indicator
        if message!.sender.userID == LayerManager.layerManager.currentUserID {
            switch message!.recipientStatusForUserID(LayerManager.layerManager.participantUserID) {
            case LYRRecipientStatus.Sent:
                // cell.messageStatus.image = UIImage(named: LQSMessageSentImageName)
                timestampText = "Sent: \(dateFormatter.stringFromDate(message!.sentAt!))"
                
            case LYRRecipientStatus.Delivered:
                // cell.messageStatus.image = UIImage(named: LQSMessageDeliveredImageName)
                timestampText = "Delivered: \(dateFormatter.stringFromDate(message!.sentAt!))"
                
            case LYRRecipientStatus.Read:
                // cell.messageStatus.image = UIImage(named: LQSMessageReadImageName)
                timestampText = "Read: \(dateFormatter.stringFromDate(message!.receivedAt!))"
                
            case LYRRecipientStatus.Invalid:
                print("Participant: Invalid")
                
            default:
                break
            }
            
            isMessageFromCurrentUser = true;
            
        } else {
            do {
                try message!.markAsRead()
            } catch _ {
            }
            timestampText = "Received: \(dateFormatter.stringFromDate(message!.sentAt!))"
            isMessageFromCurrentUser = false;
        }
        
        if message!.sender.userID != nil {
            if isMessageFromCurrentUser{
                cell.assingUser("Me");
            }
            else{
                cell.assingUser("\(message!.sender.userID!)")
            }
        }else {
            cell.assingUser("Platform ")
        }
        cell.assignStatus("\(timestampText)")
        
        
    }
    
    var dateFormatter: NSDateFormatter {
        struct Static {
            static let instance : NSDateFormatter = {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                return formatter
            }()
        }
        return Static.instance
    }
    
    // MARK: - TextView Delegate Methods
    
    func textViewDidBeginEditing(textView: UITextView) {
        // For more information about Typing Indicators, check out https://developer.layer.com/docs/integration/ios#typing-indicator
        
        // Sends a typing indicator event to the given conversation.
        LayerManager.layerManager.conversation!.sendTypingIndicator(LYRTypingIndicator.DidBegin)
        moveViewUpToShowKeyboard(true)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        // Sends a typing indicator event to the given conversation.
       LayerManager.layerManager.conversation!.sendTypingIndicator(LYRTypingIndicator.DidFinish)
    }
    
    // If the user hits Return then dismiss the keyboard and move the view back down
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.textView.resignFirstResponder()
            moveViewUpToShowKeyboard(false)
            return false
        }
        
        let limit: Int = LQSMaxCharacterLimit
        return !(self.textView.text.characters.count > limit && text.characters.count > range.length)
    }
    
    
    // Move up the view when the keyboard is shown
    func moveViewUpToShowKeyboard(movedUp: Bool) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        var rect: CGRect = view.frame
        if movedUp {
            if rect.origin.y == 0 {
                rect.origin.y = view.frame.origin.y - LQSKeyboardHeight
            }
        } else {
            if rect.origin.y < 0 {
                rect.origin.y = view.frame.origin.y + LQSKeyboardHeight
            }
        }
        view.frame = rect
        UIView.commitAnimations()
    }

    
    @IBAction func clearButtonPressed(sender: UIBarButtonItem) {
        let alert: UIAlertView = UIAlertView(title: "Delete messages?",
            message: "This action will clear all your current messages. Are you sure you want to do this?",
            delegate: self,
            cancelButtonTitle: "NO",
            otherButtonTitles: "Yes")
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: NSInteger) {
        if buttonIndex == 1 {
            LayerManager.layerManager.clearMessages()
        }
    }

    
    @IBAction func cameraButtonPressed(sender: UIButton) {
        self.textView.text = ""
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as! UIImage!
        
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as! UIImage!
        }
        LayerManager.layerManager.photo = image
        dismissViewControllerAnimated(true, completion: nil)
        
        self.imageToSend.image = image
        // inputTextView.text = "Press Send to Send Selected Image!"
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("Cancel")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - General Helper Methods
    
    func scrollToBottom() {
       
        let messages: Int = Int(LayerManager.layerManager.queryControllerDuo!.count())
        
        if LayerManager.layerManager.conversation != nil && messages > 0 {
            let numberOfRowsInSection = messagesListTableView.numberOfRowsInSection(0)
            if numberOfRowsInSection > 0 {
                if let ip: NSIndexPath = NSIndexPath(forRow: numberOfRowsInSection - 1, inSection: 0){
                    messagesListTableView.scrollToRowAtIndexPath(ip, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                }
                else{
                    messagesListTableView.scrollToNearestSelectedRowAtScrollPosition(.Bottom, animated: true);
                }
            }
        }

    }
   


}
