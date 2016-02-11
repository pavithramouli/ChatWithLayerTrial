//
//  SingleMessageTableViewCell.swift
//  ChatWithLayerTrial
//
//  Created by Pavithramouli on 20/01/16.
//  Copyright © 2016 Pavithramouli. All rights reserved.
//

import UIKit

class SingleMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var userIdentifier: UILabel!
    @IBOutlet weak var singleMessageContent: UILabel!
    var singleMessageImageView: UIImageView!
    @IBOutlet weak var contentInnerView: UIView!
    @IBOutlet weak var statusStamp: UILabel!
    @IBOutlet weak var verticalSpacingMessageAndStatus: NSLayoutConstraint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        singleMessageImageView = UIImageView()
        singleMessageImageView.tag = 1
        singleMessageImageView.frame = CGRectMake(50, 50, 300, 350)
        addSubview(self.singleMessageImageView!)
       
    }
    
    func updateWithImage(image: UIImage) {
        singleMessageImageView.image = image
        /*
        for subview in self.contentInnerView.subviews{
            for existing in subview.constraints{
                removeConstraint(existing)
            }
          //  subview.translatesAutoresizingMaskIntoConstraints = true;
        }
        for existing in self.constraints{
            removeConstraint(existing)
        }
        //translatesAutoresizingMaskIntoConstraints = true;
        //translatesAutoresizingMaskIntoConstraints = true;
        
        userIdentifier.frame = CGRectMake(8, 8, 525, 30);
        singleMessageContent.frame = CGRectMake(8, 45, 525, 420);
        singleMessageImageView.frame = CGRectMake(8, 45, 400, 400);
        statusStamp.frame = CGRectMake(8, 450, 525, 20);
        
        
        self.contentInnerView.frame = CGRectMake(0, 0 ,540, 500);
        self.contentView.frame = self.contentInnerView.frame;
        self.frame = self.contentInnerView.frame;
        
        setNeedsLayout()

        layoutIfNeeded()
 */
        
        /*
        singleMessageImageView.translatesAutoresizingMaskIntoConstraints = false;
        
        removeConstraint(verticalSpacingMessageAndStatus!);
        
        let con1:NSLayoutConstraint = NSLayoutConstraint.init(item: singleMessageImageView!, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 100);
        //let con2:NSLayoutConstraint = NSLayoutConstraint.init(item: singleMessageImageView!, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -100);
        addConstraint(con1);
        //addConstraint(con2);
        
        let con3:NSLayoutConstraint = NSLayoutConstraint.init(item: singleMessageImageView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 120);
        let con4:NSLayoutConstraint = NSLayoutConstraint.init(item: singleMessageImageView!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 120);
        singleMessageImageView.addConstraint(con3)
        singleMessageImageView.addConstraint(con4)

        addConstraint(NSLayoutConstraint(item: singleMessageContent!, attribute: .Bottom, relatedBy: .Equal, toItem: singleMessageImageView!, attribute: .Top, multiplier: 1, constant: 8));
        addConstraint(NSLayoutConstraint(item: singleMessageImageView!, attribute: .Bottom, relatedBy: .Equal, toItem: statusStamp!, attribute: .Top, multiplier: 1, constant: 8));
        
        //setNeedsUpdateConstraints();
        setNeedsLayout();
        //updateConstraints();

        */
    }
    
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if(self.subviews.contains(singleMessageImageView!))
        {
            userIdentifier.frame = CGRectMake(8, 8, 525, 30);
            singleMessageContent.frame = CGRectMake(8, 45, 525, 420);
            singleMessageImageView.frame = CGRectMake(8, 45, 400, 400);
            statusStamp.frame = CGRectMake(8, 450, 525, 20);
        }
        
        
        
    }
    */
    func removeImage() {
        if singleMessageImageView.image != nil {
            singleMessageImageView.image = nil
        }
    }
    
    func assignText(text: String) {
        self.singleMessageContent.text = text;
    }

    func assingUser(userIdentifier: String){
        self.userIdentifier.text = userIdentifier;
    }
    
    func assignStatus(text: String){
        self.statusStamp.text = text;
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
