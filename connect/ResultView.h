//
//  ResultView.h
//  connect
//
//  Created by Andrew on 8/25/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ResultViewDelegate <NSObject>
@required
- (void) resultViewTouched:(id)sender;
@end


@interface ResultView : UIView

@property (nonatomic) id <ResultViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *playerChip;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
- (IBAction)dismiss:(id)sender;

@end
