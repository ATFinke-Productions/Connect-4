//
//  C4Helper.h
//  connect
//
//  Created by Andrew on 7/30/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface C4Helper : NSObject

+ (BOOL) fourConnectedForCircles:(NSMutableArray *)coloredHoles;
+ (BOOL) threeConnectedForCircles:(NSMutableArray *)coloredHoles;
+ (BOOL) twoConnectedForCircles:(NSMutableArray *)coloredHoles;
@end
