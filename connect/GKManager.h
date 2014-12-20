//
//  GKManager.h
//  CAH
//
//  Created by Andrew on 7/11/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GKManagerDelegate
@optional
- (void)newMatch:(GKTurnBasedMatch*)match;
- (void)loadMatch:(GKTurnBasedMatch*)match forTurn:(BOOL)isTurn fromGC:(BOOL)fromGC;
- (void)recieveEndGame:(GKTurnBasedMatch *)match;
- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match;
@end

@protocol GKManagerMenuDelegate
@required
- (void)didAuthenticate:(BOOL)authenticated;
- (void)matchUpdate;
@end

@interface GKManager : NSObject <GKTurnBasedMatchmakerViewControllerDelegate, GKTurnBasedEventHandlerDelegate> {
    BOOL userAuthenticated;
    UIViewController *presentingViewController;
}

@property (strong) GKTurnBasedMatch *alternateMatch;
@property (strong) GKTurnBasedMatch *currentMatch;

@property (nonatomic, assign) id <GKManagerDelegate> delegate;
@property (nonatomic, assign) id <GKManagerMenuDelegate> menuDelegate;

+ (GKManager *)helper;

- (void)authenticate;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController;

@end
