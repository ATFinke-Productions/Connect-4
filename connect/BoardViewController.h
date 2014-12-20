//
//  BoardViewController.h
//  connect
//
//  Created by Andrew on 7/30/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleView.h"
#import "GKManager.h"
#import "C4Helper.h"
#import "CSNotificationView.h"

@interface BoardViewController : UIViewController <CircleViewDelegate,GKManagerDelegate>

@property (nonatomic) GKTurnBasedMatch * matchToSet;

- (IBAction)menu:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@end
