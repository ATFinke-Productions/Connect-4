//
//  CircleAI.h
//  connect
//
//  Created by Andrew on 10/30/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CircleView.h"

@interface CircleAI : NSObject

+ (CircleView*)numberForCircleForArrays:(NSMutableArray*)reds andArray2:(NSMutableArray*)blues withOptions:(NSMutableArray*)options;
+ (BOOL)circleView:(CircleView*)circleView okAgainstBlue:(NSMutableArray*)blues withOptions:(NSMutableArray*)options;
@end
