//
//  ChatListViewController.swift
//  ChatWithLayerTrial
//
//  Created by Pavithramouli on 19/01/16.
//  Copyright © 2016 Pavithramouli. All rights reserved.
//

import Foundation
import UIKit
import LayerKit
import NVActivityIndicatorView

class ChatListViewController:UIViewController, UITableViewDelegate, UITabBarDelegate{
    
    @IBOutlet weak var chatListTableView: UITableView!
    @IBOutlet weak var topBar: UITabBar!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet var createNewConversation: UIView!

    var currentSelectedTab = 0;
    var numberOfItemsInSection = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleConversationsFetch", name:"ConversationListFetched", object: nil)
        self.activityIndicator.type = .BallClipRotateMultiple;
        self.activityIndicator.size = CGSize(width: 100, height: 100);
        self.activityIndicator.color = UIColor.redColor();
        self.activityIndicator.hidesWhenStopped = true
        self.view.bringSubviewToFront(self.activityIndicator);
        self.activityIndicator.startAnimation();

    }
    
    
    override func viewDidAppear(animated: Bool) {
        activityIndicator.type = .BallClipRotateMultiple;
        activityIndicator.size = CGSize(width: 100, height: 100);
        activityIndicator.color = UIColor.redColor();
        activityIndicator.hidesWhenStopped = true
        
        self.view.bringSubviewToFront(activityIndicator);
        activityIndicator.startAnimation();

        LayerManager.layerManager.fetchAllConversations();
    }
    
    @IBAction func createConversation(sender: AnyObject) {
       
        let actionSheetController: UIAlertController = UIAlertController(title: "Enter Participant IDs", message: "", preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            return;
        }
        actionSheetController.addAction(cancelAction)
        let nextAction: UIAlertAction = UIAlertAction(title: "Next", style: .Default) { action -> Void in
            let textFieldInstance = actionSheetController.textFields![0] as UITextField
            let secondTextFieldInstance = actionSheetController.textFields![1] as UITextField
            
            LayerManager.layerManager.assignUsers(LayerManager.layerManager.currentUserID, firstParticipant: textFieldInstance.text!, secondPartipant: secondTextFieldInstance.text!);
            
            print("- Participant IDs: \(LayerManager.layerManager.currentUserID) --- \(LayerManager.layerManager.participantUserID) ---- \(LayerManager.layerManager.participant2UserID)");
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let chatDetailsViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ChatDetails") as! ChatDetailsViewController
            self.navigationController?.pushViewController(chatDetailsViewController, animated: true);

        }
        actionSheetController.addAction(nextAction)
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            textField.textColor = UIColor.blueColor()
            textField.text = "Test_A";
        }
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            textField.textColor = UIColor.blueColor()
            textField.text = "Test_B";
        }
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
                //LayerManager.layerManager.fetchLayerConversation();
    }
    
    @IBAction func didEnableEditing(sender: AnyObject) {
        if(chatListTableView.editing == false){
            chatListTableView.editing = true;
            editButton.title = "Done";
        } else{
            chatListTableView.editing = false;
            editButton.title = "Edit";
        }
       
    }
    
    func handleConversationsFetch(){
        numberOfItemsInSection = LayerManager.layerManager.conversationList!.count;
        activityIndicator.stopAnimation();
        chatListTableView.reloadData();
    }
    
    
    
    // MARK: - TableView Delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItemsInSection
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       /*
        if(section == 0)
        {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 150));
            label.text = "Favorites"
            return label;
        }
        else{
            let label = UILabel.init();
            label.text = "Others"
            return label;
        }
        */
        let label = UILabel.init();
        label.text = "Recent"
        return label;
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SingleChatCell", forIndexPath: indexPath) as! SingleChatTableViewCell
        configureCell(cell, forRowAtIndexPath: indexPath)
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        return cell
    }
    
    
    func configureCell(cell: SingleChatTableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Get Message Object from queryController
        
        
        let conversation = LayerManager.layerManager.queryControllerUno!.objectAtIndexPath(indexPath) as? LYRConversation
        
        var participantText: String = "";
        
        for singleParticipant in conversation!.participants {
            print("-----------\(singleParticipant)")
            participantText.appendContentsOf(singleParticipant + "   ");
        }
        
        let timeStamp: String = "Last message: \(dateFormatter.stringFromDate((conversation?.lastMessage?.receivedAt!)!))";
        
        participantText = participantText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet());
        cell.assignParticipants(participantText);
        cell.assingLastMessageTime(timeStamp);
            
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


    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
      /*
        let movedObject = self.data[sourceIndexPath.row]
        data.removeAtIndex(sourceIndexPath.row)
        data.insert(movedObject, atIndex: destinationIndexPath.row)
        NSLog("%@", "\(sourceIndexPath.row) => \(destinationIndexPath.row) \(data)")
        // To check for correctness enable: self.tableView.reloadData()
        */
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
          //  numberOfItemsInSection--;
          //  chatListTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
          //  chatListTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        //manged by segue
    }
    
    // MARK: - Tabbar Delegates
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem)
    {
        //if(currentSelectedTab == 0){
           // chatListTableView.reloadData();
        //}
      //  else{
            LayerManager.layerManager.fetchAllConversations();
       // }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "SegueForChatContents"){
            let selectedCell = sender as! SingleChatTableViewCell;
            var tempTuple = selectedCell.participants();
            let index=tempTuple.indexOf(LayerManager.layerManager.currentUserID);
            tempTuple.removeAtIndex(index!);
            LayerManager.layerManager.assignUsers(LayerManager.layerManager.currentUserID, firstParticipant:tempTuple[0],secondPartipant:tempTuple[1]);
        }
    }
    
    
}