//
//  SingleChatTableViewCell.swift
//  ChatWithLayerTrial
//
//  Created by Pavithramouli on 27/01/16.
//  Copyright © 2016 Pavithramouli. All rights reserved.
//

import UIKit

class SingleChatTableViewCell: UITableViewCell {

    @IBOutlet weak var participantsText: UILabel!
    @IBOutlet weak var lastMessageText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func assignParticipants(text: String){
        self.participantsText.text = text;
    }
    
    func assingLastMessageTime(text: String){
        self.lastMessageText.text = text;
    }
    
    func participants() -> ([String]){
        
        let arrayOfParticipants = self.participantsText.text?.componentsSeparatedByString("   ");
        
        return(arrayOfParticipants!);
    }

}
