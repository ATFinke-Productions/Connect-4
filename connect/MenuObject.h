//
//  MenuObject.h
//  connect
//
//  Created by Andrew on 7/30/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface MenuObject : NSObject

@property (nonatomic) NSString *type;
@property (nonatomic) GKTurnBasedMatch * match;

@end
