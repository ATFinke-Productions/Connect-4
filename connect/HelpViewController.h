//
//  HelpViewController.h
//  connect
//
//  Created by Andrew on 8/3/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HVDelegate
@optional
- (void)HVDone;
@end

@interface HelpViewController : UIViewController
- (IBAction)done:(id)sender;

@property (nonatomic) id <HVDelegate> delegate;

@end
