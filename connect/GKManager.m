//
//  GKManager.m
//  CAH
//
//  Created by Andrew on 7/11/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import "GKManager.h"

@implementation GKManager

#pragma mark Initialization

+ (GKManager *) helper {
    static GKManager *sharedHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[GKManager alloc] init];
    });
    
    return sharedHelper;
}

-(id)init {
    return self;
}

-(void)authenticationChanged {
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        userAuthenticated = YES;
        NSLog(@"Authentication changed: player authenticated.");
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        userAuthenticated = NO;
        NSLog(@"Authentication changed: player not authenticated");
    }
}

-(void)deleteAllMatches {
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:
     ^(NSArray *matches, NSError *error){
         for (GKTurnBasedMatch *match in matches) {
             NSLog(@"%@", match.matchID);
             [match removeWithCompletionHandler:^(NSError *error) {
                 NSLog(@"%@", error);
             }];
         }

     }];
}

#pragma mark User functions
-(void)authenticate {
    
    NSLog(@"Authenticating local user . . .");
    UIViewController *rootViewController = nil;
    id appDelegate = [[UIApplication sharedApplication] delegate];
    if (!rootViewController && [appDelegate respondsToSelector:@selector(window)])
    {
        UIWindow *window = [appDelegate valueForKey:@"window"];
        rootViewController = window.rootViewController;
    }
    if (!rootViewController)
    {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        rootViewController = window.rootViewController;
    }
    if (!rootViewController)
    {
        NSLog(@"couldn't find root view controller");
    }
    presentingViewController = rootViewController;
    
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    __weak GKLocalPlayer *blockLocalPlayer = localPlayer;

    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        if (viewController) {
            [presentingViewController presentViewController:viewController animated:YES completion:^{
                userAuthenticated = YES;
                GKTurnBasedEventHandler *ev = [GKTurnBasedEventHandler sharedTurnBasedEventHandler];
                ev.delegate = self;
            }];
        } else if (blockLocalPlayer.authenticated) {
            userAuthenticated = YES;
            GKTurnBasedEventHandler *ev = [GKTurnBasedEventHandler sharedTurnBasedEventHandler];
            ev.delegate = self;
            
        } else {
            userAuthenticated = NO;
            NSLog(@"Error with Game Center %@", error);
            
        }
        [self.menuDelegate didAuthenticate:userAuthenticated];
    };
    
    
}



- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController: (UIViewController *)viewController{
    
    presentingViewController = viewController;
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = self;
    mmvc.showExistingMatches = NO;
    
    
    [presentingViewController presentViewController:mmvc animated:YES completion:nil];
}

#pragma mark GKTurnBasedMatchmakerViewControllerDelegate
-(void)turnBasedMatchmakerViewController: (GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match {
    
    
    [presentingViewController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MatchMakerDismissed" object:match];
    }];
    self.currentMatch = match;
    
    NSMutableArray *stillPlaying = [NSMutableArray array];
    for (GKTurnBasedParticipant *p in match.participants) {
        if (p.matchOutcome == GKTurnBasedMatchOutcomeNone) {
            [stillPlaying addObject:p];
        }
    }
 
    if ([stillPlaying count] < 2 && [match.participants count] <= 2) {
        //There's only one player left
       
        for (GKTurnBasedParticipant *part in stillPlaying) {
            part.matchOutcome = GKTurnBasedMatchOutcomeTied;
        }
        if (match.matchData) {
            [match endMatchInTurnWithMatchData:match.matchData completionHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"Error Ending Match %@", error);
                }
                
                [self.delegate loadMatch:match forTurn:NO fromGC:YES];
            }];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:@"Looks like something went wrong. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }

        
        
    }

    GKTurnBasedParticipant *firstParticipant = (match.participants)[0];
    if (firstParticipant.lastTurnDate == NULL) {
        //It's a new game
        [self.delegate newMatch:match];
    } else {
        if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            //It's your turn
            [self.delegate loadMatch:match forTurn:YES fromGC:YES];
        } else {
            //Someone else's turn
            [self.delegate loadMatch:match forTurn:NO fromGC:YES];
        }
    }

    
}

-(void)turnBasedMatchmakerViewControllerWasCancelled: (GKTurnBasedMatchmakerViewController *)viewController {
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"has cancelled");
}

-(void)turnBasedMatchmakerViewController: (GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

-(void)turnBasedMatchmakerViewController: (GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match {
    NSUInteger currentIndex = [match.participants indexOfObject:match.currentParticipant];
    GKTurnBasedParticipant *part;
    
    NSMutableArray *nextParticipants = [NSMutableArray array];
    for (int i = 0; i < [match.participants count]; i++) {
        part = (match.participants)[(currentIndex + 1 + i) % match.participants.count];
        if (part.matchOutcome == GKTurnBasedMatchOutcomeNone) {
            [nextParticipants addObject:part];
        }
    }
    
    [match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit nextParticipants:nextParticipants turnTimeout:600 matchData:match.matchData completionHandler:nil];
    
    NSLog(@"playerquitforMatch, %@, %@", match, match.currentParticipant);
}

#pragma mark GKTurnBasedEventHandlerDelegate

-(void)handleInviteFromGameCenter:(NSArray *)playersToInvite {
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    
    request.playersToInvite = playersToInvite;
    request.maxPlayers = 12;
    request.minPlayers = 2;
    
    GKTurnBasedMatchmakerViewController *viewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    
    viewController.showExistingMatches = YES;
    viewController.turnBasedMatchmakerDelegate = self;
    [presentingViewController presentViewController:viewController animated:YES completion:nil];
}


-(void)handleTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive {
    NSLog(@"Turn has happened");
    if ([match.matchID isEqualToString:self.currentMatch.matchID]) {
        if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // it's the current match and it's our turn now
            self.currentMatch = match;
            [self.delegate loadMatch:match forTurn:YES fromGC:NO];
        } else {
            // it's the current match, but it's someone else's turn
            self.currentMatch = match;
           [self.delegate loadMatch:match forTurn:NO fromGC:NO];
        }
    } else {
        if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // it's not the current match and it's our turn now
            [self.delegate sendNotice:@"It's your turn for another match" forMatch:match];
        } else {
            // it's the not current match, and it's someone else's
            // turn
        }
    }
    [self.menuDelegate matchUpdate];
}

-(void)handleMatchEnded:(GKTurnBasedMatch *)match {
    if ([match.matchID isEqualToString:self.currentMatch.matchID]) {
        [self.delegate recieveEndGame:match];
    } else {
        [self.delegate sendNotice:@"Another Game Ended!" forMatch:match];
    }
    [self.menuDelegate matchUpdate];
}


@end
