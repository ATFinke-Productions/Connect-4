//
//  LocalViewController.h
//  connect
//
//  Created by Andrew on 10/30/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleView.h"
#import "C4Helper.h"
#import "CSNotificationView.h"
#import "CircleAI.h"

@interface LocalViewController : UIViewController <CircleViewDelegate>

- (IBAction)menu:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@end
