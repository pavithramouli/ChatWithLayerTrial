//
//  LayerManager.swift
//  ChatWithLayerTrial
//
//  Created by Pavithramouli on 19/01/16.
//  Copyright © 2016 Pavithramouli. All rights reserved.
//

import UIKit
import LayerKit

//Layer App ID from developer.layer.com
let LQSLayerAppIDString = "ADD_YOUR_LAYER_APP_ID_HERE"

class LayerManager: NSObject,LYRClientDelegate,LYRQueryControllerDelegate {
    
    var layerClient:LYRClient!;
    var conversation: LYRConversation?
    var conversationList : NSOrderedSet?
    var queryControllerUno: LYRQueryController?
    var queryControllerDuo: LYRQueryController?

    
    var currentUserID = "TestA11"
    var participantUserID = "TestB22"
    var participant2UserID = "TestB33"

    var isRequestForAllConversationFetch: Bool = true;
    
    let LQSLogoImageName = "Logo"
    let LQSKeyboardHeight: CGFloat = 255.0
    let LQSMaxCharacterLimit = 66
    let MIMETypeImagePNG = "image/png"
    var photo: UIImage!
    var changeType : LYRQueryControllerChangeType?;
    var indexPathReference: NSIndexPath?;

    static let layerManager = LayerManager();
    
    
    func assignUsers(currentUser: String, firstParticipant: String, secondPartipant: String){
        self.currentUserID = currentUser;
        self.participantUserID = firstParticipant;
        self.participant2UserID = secondPartipant;
    }
    
    func clearLayerData(){
        
        self.layerClient = nil;
        self.conversation = nil;
        self.conversationList = nil;
        self.queryControllerUno = nil;
        self.queryControllerDuo = nil;
        self.isRequestForAllConversationFetch = true;
        self.participantUserID = "";
        self.participant2UserID = "";
        self.currentUserID = "";
    }
    
    // MARK:- Fetching Layer Content
    func initiateLayerConnection(){
        
        if((self.layerClient) == nil){
            
            // Initializes a LYRClient object
            let appID = NSURL(string: LQSLayerAppIDString)

            self.layerClient = LYRClient(appID: appID!)
            self.layerClient.delegate = self

            self.layerClient.connectWithCompletion() { (success: Bool, error: NSError?) in
                if !success {
                    print("Failed to connect to Layer: \(error)")
                } else {
                    self.authenticateLayerWithUserID(self.currentUserID) { (success: Bool, error: NSError?) in
                        if !success {
                            print("Failed Authenticating Layer Client with error:\(error)")
                            UserModel.currentUser.isUserAuthenticatedInLayer = false;
                            NSNotificationCenter.defaultCenter().postNotificationName("UnSuccessfulAuthenticationNotification", object: nil)
                            
                        } else {
                            print("Initial Authentication Succesful")
                            UserModel.currentUser.userLayerID = self.currentUserID;
                            UserModel.currentUser.isUserAuthenticatedInLayer = true;
                            self.setupLayerNotificationObservers();
                            NSNotificationCenter.defaultCenter().postNotificationName("SuccessfulAuthenticationNotification", object: nil)
                            
                        }
                    }
                }
            }
            // Register for push
            registerApplicationForPushNotifications(UIApplication.sharedApplication())
        }
        else{
            print("User already authenticted");
            NSNotificationCenter.defaultCenter().postNotificationName("SuccessfulAuthenticationNotification", object: nil)
        }
    }
    
    func fetchLayerConversation() {
        // Fetches all conversations between the authenticated user and the supplied participant
    
        
        if(UserModel.currentUser.isUserAuthenticatedInLayer){
            
            isRequestForAllConversationFetch = false;
            
            let query: LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
            
            query.predicate = LYRPredicate(property: "participants", predicateOperator: LYRPredicateOperator.IsEqualTo, value: [ currentUserID, participantUserID, participant2UserID ] as AnyObject)
            query.sortDescriptors = [ NSSortDescriptor(key: "createdAt", ascending: false) ]
            
            var error: NSError? = nil
            var conversations: NSOrderedSet?
            do {
                conversations = try layerClient?.executeQuery(query)
            } catch let error1 as NSError {
                error = error1
                conversations = nil
            }
            
            
            if conversations == nil || conversations!.count <= 0 {
                var convError: NSError? = nil
                do {
                    self.conversation = try layerClient!.newConversationWithParticipants(NSSet(array: [participantUserID, participant2UserID]) as! Set<String>, options: nil)
                } catch let error as NSError {
                    convError = error
                    self.conversation = nil
                }
                if self.conversation == nil {
                    print("New Conversation creation failed: \(convError)")
                }
            }
            
            if error == nil {
                print("conversations with participants \([ currentUserID, participantUserID, participant2UserID ])")
            } else {
                print("Query failed with error \(error)")
            }
            
            
            // Retrieve the last conversation
            if (self.conversation != nil || conversations != nil) {
                if(conversations?.count > 0){
                    self.conversation = conversations!.lastObject as! LYRConversation?
                }
                print("Get last conversation object: \(self.conversation!.identifier)")
                // setup query controller with messages from last conversation
                // if queryController == nil {
                setupQueryController()
                // }
            }
        }
        else{
            print("User not authenticated to use chat");
        }
    }
    
    func messagesQueryController(){
        
    }
    
    func setupQueryController() {

        if(isRequestForAllConversationFetch){
            let query: LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
            query.predicate = LYRPredicate(property: "participants", predicateOperator: LYRPredicateOperator.IsIn, value: currentUserID as AnyObject)
            query.sortDescriptors = [ NSSortDescriptor(key: "lastMessage.receivedAt", ascending: true) ]
            
            // Set up query controller
            queryControllerUno = layerClient!.queryControllerWithQuery(query)
            queryControllerUno!.delegate = self
            
            var error: NSError?
            let success: Bool
            do {
                try queryControllerUno!.execute()
                success = true
            } catch let error1 as NSError {
                error = error1
                success = false
            }
            if success {
                print("Query fetched \(queryControllerUno!.numberOfObjectsInSection(0)) conversation objects")
            } else {
                print("Query failed with error: \(error)")
            }
           // queryController = nil
            
            NSNotificationCenter.defaultCenter().postNotificationName("ConversationListFetched", object: nil)

        }
        else{
            // Query for all the messages in conversation sorted by position
            let query: LYRQuery = LYRQuery(queryableClass: LYRMessage.self)
            query.predicate = LYRPredicate(property: "conversation", predicateOperator: LYRPredicateOperator.IsEqualTo, value: self.conversation)
            query.sortDescriptors = [ NSSortDescriptor(key: "position", ascending: true) ]
            
            // Set up query controller
            queryControllerDuo = nil
            queryControllerDuo = layerClient!.queryControllerWithQuery(query)
            queryControllerDuo!.delegate = self
            
            var error: NSError?
            let success: Bool
            do {
                try queryControllerDuo!.execute()
                success = true
            } catch let error1 as NSError {
                error = error1
                success = false
            }
            if success {
                print("Query fetched \(queryControllerDuo!.numberOfObjectsInSection(0)) message objects")
            } else {
                print("Query failed with error: \(error)")
            }
           // queryController = nil
            NSNotificationCenter.defaultCenter().postNotificationName("ConversationFetched", object: nil)
            do {
                try conversation!.markAllMessagesAsRead()
            } catch _ {
            }

        }
    }

    func sendMessage(messageText: String) {
        // Send a Message
        // See "Quick Start - Send a Message" for more details
        // https://developer.layer.com/docs/quick-start/ios#send-a-message
        
        var messagePart: LYRMessagePart?
        
        // If no conversations exist, create a new conversation object with a single participant
        if self.conversation == nil {
            fetchLayerConversation()
        }
        
        //if we are sending an image
        if let imageToSend = self.photo {
            let image: UIImage = imageToSend//get photo
            let imageData: NSData = UIImagePNGRepresentation(image)!
            messagePart = LYRMessagePart(MIMEType: MIMETypeImagePNG, data: imageData)
          //  doesContatinImage = false
        } else {
            //Creates a message part with text/plain MIME Type
            messagePart = LYRMessagePart(text: messageText)
        }
        
        // Creates and returns a new message object with the given conversation and array of message parts
        let pushMessage = "\(layerClient?.authenticatedUserID) says \(messageText)"
        let message: LYRMessage? = try? layerClient!.newMessageWithParts([messagePart!], options: [LYRMessageOptionsPushNotificationAlertKey: pushMessage])
        
        // Sends the specified message
        var error: NSError?
        let success: Bool
        do {
            try conversation!.sendMessage(message!)
            success = true
        } catch let error1 as NSError {
            error = error1
            success = false
        }
        if success {
            // If the message was sent by the participant, show the sentAt time and mark the message as read
            print("Message queued to be sent: \(messageText)")
           // NSNotificationCenter.defaultCenter().postNotificationName("MessageQueuedForSend", object: nil)
            
        } else {
            print("Message send failed: \(error)")
        }
        self.photo = nil
        
        if queryControllerUno == nil {
            setupQueryController()
        }
    }

    
    func fetchAllConversations(){
        
        // Fetches all conversations between the authenticated user and the supplied participant
        
        isRequestForAllConversationFetch = true;
        
        let query: LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
        
        query.predicate = LYRPredicate(property: "participants", predicateOperator: LYRPredicateOperator.IsIn, value: currentUserID as AnyObject)
        query.sortDescriptors = [ NSSortDescriptor(key: "lastMessage.receivedAt", ascending: false) ]
        
        
        var error: NSError? = nil
        
        do {
            conversationList = try layerClient?.executeQuery(query)
        } catch let error1 as NSError {
            error = error1
            conversationList = nil
        }
        
        if(conversationList != nil){
            print(" \(conversationList!.count) Conversations fetched")
            //let oneConvo = LayerManager.layerManager.queryController!.objectAtIndexPath(<#T##indexPath: NSIndexPath##NSIndexPath#>0) as? LYRConversation
            if(conversationList?.count > 0){
                
                for singleConversation in conversationList! {
                    for singleParticipant in singleConversation.participants {
                        print("-----------\(singleParticipant)")
                    }
                }
            }
           // if queryController == nil {
                setupQueryController()
           // }
        }
        else{
            print("No conversations found");
        }
        /*
        
        LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
        query.predicate = [LYRPredicate predicateWithProperty:@"participants" predicateOperator:LYRPredicateOperatorIsIn value:self.layerClient.authenticatedUserID];
        query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.receivedAt" ascending:NO]];
        
        if ([self.dataSource respondsToSelector:@selector(conversationListViewController:willLoadWithQuery:)]) {
        query = [self.dataSource conversationListViewController:self willLoadWithQuery:query];
        if (![query isKindOfClass:[LYRQuery class]]){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Data source must return an `LYRQuery` object." userInfo:nil];
        }
        }
        
        NSError *error;
        self.queryController = [self.layerClient queryControllerWithQuery:query error:&error];
        if (!self.queryController) {
        NSLog(@"LayerKit failed to create a query controller with error: %@", error);
        return;
        }
        self.queryController.delegate = self;
        BOOL success = [self.queryController execute:&error];
        if (!success) {
        NSLog(@"LayerKit failed to execute query with error: %@", error);
        return;
        }


        // Fetches all LYRConversation objects
        LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
        
        NSError *error = nil;
        NSOrderedSet *conversations = [self.client executeQuery:query error:&error];
        if (conversations) {
            NSLog(@"%tu conversations", conversations.count);
        } else {
            NSLog(@"Query failed with error %@", error);
        }

        */
    }

    // MARK: - Push Notification Methods
    func registerApplicationForPushNotifications(application: UIApplication) {
        // Set up push notifications
        // Register device for iOS8
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Send device token to Layer so Layer can send pushes to this device.
        
        var error: NSError?
        let success: Bool
        do {
            try layerClient!.updateRemoteNotificationDeviceToken(deviceToken)
            success = true
        } catch let error1 as NSError {
            error = error1
            success = false
        }
        if (success) {
            print("Application did register for remote notifications: \(deviceToken)")
        } else {
            print("Failed updating device token with error: \(error)")
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // Get Message from Metadata
        // Why never use?        var message: LYRMessage = messageFromRemoteNotification(userInfo)
        
        let success = layerClient!.synchronizeWithRemoteNotification(userInfo, completion: { (changes, error) in
            if (changes != nil) {
                if (changes!.count > 0) {
                    // Why never use?                    message = self.messageFromRemoteNotification(userInfo)
                    completionHandler(UIBackgroundFetchResult.NewData)
                } else {
                    completionHandler(UIBackgroundFetchResult.NoData)
                }
            } else {
                if error != nil {
                    print("Failed processing push notification with error: \(error)")
                    completionHandler(UIBackgroundFetchResult.NoData)
                } else {
                    completionHandler(UIBackgroundFetchResult.Failed)
                }
            }
        })
        
        if (success) {
            print("Application did complete remote notification sync")
        } else {
            completionHandler(UIBackgroundFetchResult.NoData)
        }
    }
    
    func messageFromRemoteNotification(remoteNotification: NSDictionary?) -> LYRMessage {
        let LQSPushMessageIdentifierKeyPath = "layer.message_identifier"
        let LQSPushAnnouncementIdentifierKeyPath = "layer.announcement_identifier"
        
        // Retrieve message URL from Push Notification
        var messageURL = NSURL(string: remoteNotification!.valueForKeyPath(LQSPushMessageIdentifierKeyPath) as! String)
        if messageURL == nil {
            messageURL = NSURL(string: remoteNotification!.valueForKeyPath(LQSPushAnnouncementIdentifierKeyPath) as! String)
        }
        
        // Retrieve LYRMessage from Message URL
        let query: LYRQuery = LYRQuery(queryableClass: LYRMessage.self)
        query.predicate = LYRPredicate(property: "identifier", predicateOperator: LYRPredicateOperator.IsIn, value: NSSet(object: messageURL!))
        
        var error: NSError?
        let messages: NSOrderedSet?
        do {
            messages = try self.layerClient!.executeQuery(query)
        } catch let error1 as NSError {
            error = error1
            messages = nil
        }
        if (error == nil) {
            print("Query contains \(messages!.count) messages")
            let message: LYRMessage = messages!.firstObject as! LYRMessage
            let messagePart: LYRMessagePart = message.parts[0]
            print("Pushed Message Contents: \(NSString(data: messagePart.data!, encoding: NSUTF8StringEncoding))")
        } else {
            print("Query failed with error \(error)")
        }
        
        return messages!.firstObject as! LYRMessage
    }
    
    
    // MARK: - Layer Authentication Methods
    func authenticateLayerWithUserID(userID: String, completion: ((success: Bool, error: NSError?) -> Void)) {
        
        if let layerClient = self.layerClient {
           
            if layerClient.authenticatedUserID != nil{ //if(self.currentUserID == layerClient.authenticatedUserID!)
                print("Layer Authenticated as User \(layerClient.authenticatedUserID)")
                completion(success: true, error: nil)
                return
            }
            
            
            /*
            * 1. Request an authentication Nonce from Layer
            */
            layerClient.requestAuthenticationNonceWithCompletion() { (nonce: String?, error: NSError?) -> Void in
                if nonce!.isEmpty {
                    completion(success: false, error: error)
                    return
                }
                
                /*
                * 2. Acquire identity Token from Layer Identity Service
                */
                self.requestIdentityTokenForUserID(userID, appID: layerClient.appID.absoluteString, nonce: nonce!, completion: { (identityToken, error) in
                    if identityToken.isEmpty {
                        completion(success: false, error: error)
                        return
                    }
                    
                    /*
                    * 3. Submit identity token to Layer for validation
                    */
                    layerClient.authenticateWithIdentityToken(identityToken, completion: { (authenticatedUserID, error) in
                        if !authenticatedUserID!.isEmpty {
                            completion(success: true, error: nil)
                            print("Layer Authenticated as User: \(authenticatedUserID)")
                        } else {
                            completion(success: false, error: error)
                        }
                    })
                })
            }
        }
    }
    
    func requestIdentityTokenForUserID(userID: String, appID: String, nonce: String, completion: ((identityToken: String, error: NSError?) -> Void)) {
        let identityTokenURL = NSURL(string: "https://layer-identity-provider.herokuapp.com/identity_tokens")
        let request = NSMutableURLRequest(URL: identityTokenURL!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let parameters = ["app_id": appID, "user_id": userID, "nonce": nonce]
        let requestBody: NSData? = try? NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        request.HTTPBody = requestBody
        
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration)
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if error != nil {
                completion(identityToken: "", error: error)
                return
            }
            
            // Deserialize the response
            let responseObject: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: [])) as! NSDictionary
            if responseObject.valueForKey("error") == nil {
                let identityToken = responseObject["identity_token"] as! String?
                let token: String = (identityToken != nil) ? identityToken! : ""
                completion(identityToken: token, error: nil);
            } else {
                let domain = "layer-identity-provider.herokuapp.com"
                let code = responseObject["status"] as! Int?
                let userInfo = [ NSLocalizedDescriptionKey: "Layer Identity Provider Returned an Error.",
                    NSLocalizedRecoverySuggestionErrorKey: "There may be a problem with your APPID." ]
                
                let error: NSError = NSError(domain: domain, code: code!, userInfo: userInfo)
                completion(identityToken: "", error: error)
            }
        }).resume()
    }
    
   // MARK: -  LYRClientDelegate Delegate Methods
    func layerClient(client: LYRClient, didReceiveAuthenticationChallengeWithNonce nonce: String) {
        print("Layer Client did recieve authentication challenge with nonce: \(nonce)")
    }
    
    func layerClient(client: LYRClient, didAuthenticateAsUserID userID: String) {
        print("Layer Client did recieve authentication nonce")
    }
    
    func layerClientDidDeauthenticate(client: LYRClient) {
        print("Layer Client did deauthenticate")
    }
    
    //func layerClient(client: LYRClient, didFinishSynchronizationWithChanges changes: [AnyObject]) {
    //  print("Layer Client did finish sychronization")
    // }
    
    func layerClient(client: LYRClient, didFailSynchronizationWithError error: NSError) {
        print("Layer Client did fail synchronization with error: \(error)")
    }
    
    func layerClient(client: LYRClient, willAttemptToConnect attemptNumber: UInt, afterDelay delayInterval: NSTimeInterval, maximumNumberOfAttempts attemptLimit: UInt) {
        print("Layer Client will attempt to connect")
    }
    
    func layerClientDidConnect(client: LYRClient) {
        print("Layer Client did connect")
    }
    
    func layerClient(client: LYRClient, didLoseConnectionWithError error: NSError) {
        print("Layer Client did lose connection with error: \(error)")
    }
    
    func layerClientDidDisconnect(client: LYRClient) {
        print("Layer Client did disconnect")
    }
    
    //MARK:- Local Notification Methods
    func setupLayerNotificationObservers() {
        // Register for Layer object change notifications
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didReceiveLayerObjectsDidChangeNotification:",
            name: LYRClientObjectsDidChangeNotification,
            object: nil)
        
        // Register for typing indicator notifications
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didReceiveTypingIndicator:",
            name: LYRConversationDidReceiveTypingIndicatorNotification,
            object: self.conversation)
        
        // Register for synchronization notifications
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didReceiveLayerClientWillBeginSynchronizationNotification:",
            name: LYRClientWillBeginSynchronizationNotification,
            object: self.layerClient)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didReceiveLayerClientDidFinishSynchronizationNotification:",
            name: LYRClientDidFinishSynchronizationNotification,
            object: self.layerClient)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    func didReceiveTypingIndicator(notification: NSNotification) {
        // For more information about Typing Indicators, check out https://developer.layer.com/docs/integration/ios#typing-indicator
        
        let dictionary: [String: AnyObject] = notification.userInfo as! [String: AnyObject]
        
        NSNotificationCenter.defaultCenter().postNotificationName("NeedsTypingIndicatorChange", object: dictionary)
    }
    
    // MARK:- Query Controller Delegate Methods
    
    func queryControllerWillChangeContent(queryController: LYRQueryController) {
        NSNotificationCenter.defaultCenter().postNotificationName("queryControllerWillChangeContent", object: nil)
    }
    
    func queryController(controller: LYRQueryController, didChangeObject object: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: LYRQueryControllerChangeType, newIndexPath: NSIndexPath?) {
        
        changeType = type;
        indexPathReference = newIndexPath;
        NSNotificationCenter.defaultCenter().postNotificationName("LayerRequiresUIUpdate", object: type as? AnyObject)
        
        /*
        // Automatically update tableview when there are change events
        switch (type) {
        case LYRQueryControllerChangeType.Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        case LYRQueryControllerChangeType.Update:
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        case LYRQueryControllerChangeType.Move:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        case LYRQueryControllerChangeType.Delete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        */
    }
    
    func queryControllerDidChangeContent(queryController: LYRQueryController) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("queryControllerDidChangeContent", object: nil)

        /*
        tableView.endUpdates()
        scrollToBottom()
        */
    }
    
    // MARK: - Layer Sync Notification Handler
    
    func didReceiveLayerClientWillBeginSynchronizationNotification(notification: NSNotification) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didReceiveLayerClientDidFinishSynchronizationNotification(notification: NSNotification) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // MARK: - Layer Object Change Notification Handler
    
    func didReceiveLayerObjectsDidChangeNotification(notification: NSNotification) {
        // Get nav bar colors from conversation metadata
       // setNavbarColorFromConversationMetadata(conversation?.metadata)
     //   fetchLayerConversation()
    }
    

    func numberOfMessages() -> Int {
        let message: LYRQuery = LYRQuery(queryableClass: LYRMessage.self)
        
        let messageList: NSOrderedSet?
        do {
            messageList = try layerClient?.executeQuery(message)
        } catch _ {
            messageList = nil
        }
        
        return messageList != nil ? messageList!.count : 0
    }
    
  
    func deauthenticateUser(){
        self.layerClient.deauthenticateWithCompletion(
            {(success: Bool, error: NSError?) -> Void in
                if !success {
                    NSLog("Failed to deauthenticate user: %@", error!)
                }
                else {
                    NSLog("User was deauthenticated")
                    UserModel.currentUser.isUserAuthenticatedInLayer = false;
                }
            })
    }

    
    
    func clearMessages() {
       /*
        let message: LYRQuery = LYRQuery(queryableClass: LYRMessage.self)
        
        let messageList: NSOrderedSet?
        do {
            messageList = try layerClient!.executeQuery(message)
        } catch _ {
            messageList = nil
        }
        
        if messageList?.count > 0 {
            
            for (var i = 0; i < messageList?.count; i++) {
                let message: LYRMessage = messageList?.objectAtIndex(i) as! LYRMessage
                let success: Bool
                do {
                    try message.delete(LYRDeletionMode.AllParticipants, error: ())
                    success = true
                } catch _ {
                    success = false
                }
                print("Message is: \(message.parts)")
                
                if success {
                    print("The message has been deleted")
                }else {
                    print("Error")
                }
            }
            
        }
        photo = nil
        //sendingImage = false
        */
    }

}
