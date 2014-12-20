//
//  ResultView.m
//  connect
//
//  Created by Andrew on 8/25/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import "ResultView.h"

@implementation ResultView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)dismiss:(id)sender {
    [self.delegate resultViewTouched:self];
}
@end
