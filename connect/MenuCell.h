//
//  MenuCell.h
//  connect
//
//  Created by Andrew on 7/30/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuCell : UITableViewCell

@property (nonatomic) IBOutlet UIView *whiteView;
@property (nonatomic) IBOutlet UILabel *itemLabel;
@property (nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) IBOutlet UILabel *playerLabel;
@property (nonatomic) IBOutlet UIImageView *previewImageView;
@property (nonatomic) IBOutlet UIButton *matchButton;
@property (nonatomic) int row;

@end
