//
//  CircleView.h
//  connect
//
//  Created by Andrew on 7/30/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CircleViewDelegate <NSObject>
@required
- (void) circleTouched:(id)sender;
@end


@interface CircleView : UIView

@property (nonatomic) id <CircleViewDelegate> delegate;

@property (nonatomic) int row;
@property (nonatomic) int column;
@property (nonatomic) NSNumber *holeNumber;
@property (nonatomic) int holeNumberInt;

@property (nonatomic) BOOL isTaken;
@property (nonatomic) BOOL isBlue;

@end
