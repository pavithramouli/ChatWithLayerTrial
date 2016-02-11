//
//  UserModel.swift
//  ChatWithLayerTrial
//
//  Created by Pavithramouli on 19/01/16.
//  Copyright © 2016 Pavithramouli. All rights reserved.
//

import Foundation

class UserModel: NSObject {

    static let currentUser = UserModel()
    
    var userLayerID : String!;
    var isUserAuthenticatedInLayer : Bool = false;
    
    //other details as needed
}
