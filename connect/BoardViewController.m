//
//  BoardViewController.m
//  connect
//
//  Created by Andrew on 7/30/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import "BoardViewController.h"

@interface BoardViewController () {
    
    BOOL isUserTurn;
    BOOL isAnimating;
    BOOL isBlue;
    BOOL isShowingHelp;
    
    NSMutableArray *circles;
    NSMutableArray *redCircles;
    NSMutableArray *blueCircles;
    NSMutableArray *playerIDs;
    
    UIView *redCircle;
    UIView *blueCircle;
    
    UIView *playerIndicator;
    
    int dropChipHeight;
    int x1;
    int x2;
    int side;
    
    BOOL isLightTheme;
    BOOL isShowingResult;
}

@property (nonatomic) UIDynamicAnimator *animator;
@end

@implementation BoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [GKManager helper].delegate = self;

    side = self.view.frame.size.width * .25;
    
    x1 = 100;
    x2 = 150;
    if (self.view.frame.size.width > 350) {
        x1 = 220;
        x2 = 360;
        self.menuButton.frame = CGRectMake(self.menuButton.frame.origin.x, self.menuButton.frame.origin.y, 80,50);
    }
    
    
	// Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    UIView *screenShotView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];

    int xCord = 15;
    int yCord = 0;
    
    for (int hole = 1; hole < 37; hole ++) {
        
        CircleView *circleView = [[CircleView alloc]initWithFrame:CGRectMake(xCord, yCord, 40, 40)];
        circleView.backgroundColor = [UIColor clearColor];
        circleView.layer.borderColor = [UIColor clearColor].CGColor;
        for (NSNumber *redNumbers in redCircles) {
            if ([redNumbers isEqualToNumber:[NSNumber numberWithInt:hole]]) {
                circleView.backgroundColor = [UIColor redColor];
                circleView.layer.borderColor = [UIColor redColor].CGColor;
                
            }
        }
        for (NSNumber *blueNumbers in blueCircles) {
            if ([blueNumbers isEqualToNumber:[NSNumber numberWithInt:hole]]) {
                circleView.backgroundColor = [UIColor blueColor];
                circleView.layer.borderColor = [UIColor blueColor].CGColor;
                
            }
        }
        
        circleView.layer.borderWidth = 2;
        circleView.layer.cornerRadius = 20;

        
        
        xCord = xCord + 50;
        
        if (hole == 6 || hole == 12 || hole == 18 || hole == 24 || hole == 30) {
            xCord = 15;
            yCord = yCord + 50;
        }
        
        [screenShotView addSubview:circleView];
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[GKManager helper].currentMatch.matchID]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:NULL];
    
    UIGraphicsBeginImageContext(screenShotView.bounds.size);
    [screenShotView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData* data = UIImagePNGRepresentation(image);
    
    if (redCircles.count+blueCircles.count == 0) {
        data = UIImagePNGRepresentation([UIImage imageNamed:@"MenuDefault"]);
    }
    
    [data writeToFile:path atomically:YES];
    
    NSMutableData *imageData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:imageData];
    [archiver encodeObject:image forKey:@"ImageData"];
    [archiver finishEncoding];
    
    [[NSUserDefaults standardUserDefaults]setValue:imageData forKey:path];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


- (void)viewWillAppear:(BOOL)animated {

    if (isShowingHelp) {
        return;
    }

    redCircle = [[UIView alloc]initWithFrame:CGRectMake(x2, 50, side, side)];
    redCircle.layer.cornerRadius = side/2;
    redCircle.layer.borderWidth = side * .09375;
    redCircle.layer.borderColor = [UIColor whiteColor].CGColor;
    redCircle.backgroundColor = [UIColor redColor];
    [self.view addSubview:redCircle];
    
    blueCircle = [[UIView alloc]initWithFrame:CGRectMake(x1, 50, side, side)];
    blueCircle.layer.cornerRadius = side/2;
    blueCircle.layer.borderWidth = side * .09375;
    blueCircle.layer.borderColor = [UIColor whiteColor].CGColor;
    blueCircle.backgroundColor = [UIColor blueColor];
    [self.view addSubview:blueCircle];
    
    playerIndicator = [[UIView alloc]initWithFrame:CGRectMake(0, 0, side/2, 6)];
    playerIndicator.backgroundColor = [UIColor whiteColor];
    playerIndicator.hidden = YES;
    [self.view addSubview:playerIndicator];
    
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"Theme"] isEqualToString:@"D"]) {
        self.view.backgroundColor = [UIColor colorWithRed:0.199478 green:0.199478 blue:0.199478 alpha:1];
        isLightTheme = NO;
    }
    else {
        self.view.backgroundColor = [UIColor whiteColor];
        isLightTheme = YES;
        blueCircle.layer.borderColor = [UIColor lightGrayColor].CGColor;
        redCircle.layer.borderColor = [UIColor lightGrayColor].CGColor;
        playerIndicator.backgroundColor = [UIColor lightGrayColor];
    }
    [[GKManager helper] turnBasedMatchmakerViewController:nil didFindMatch:self.matchToSet];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) newMatch:(GKTurnBasedMatch *)match {
   
    [self loadGameplayArraysFromArray:nil];
    isUserTurn = YES;
    [self loadCirclesWithAnimation:NO forColorBlue:NO];
    isBlue = YES;
    
    playerIndicator.hidden = NO;
    playerIndicator.frame = CGRectMake(x1 + side/4, blueCircle.frame.origin.y + side + 20, side/2, side *.075 );
}

- (void)loadMatch:(GKTurnBasedMatch*)match forTurn:(BOOL)isTurn fromGC:(BOOL)fromGC {
    isUserTurn = isTurn;
    [self loadGameplayArraysFromArray:[self arrayFromData:match.matchData]];
    

    if ([match.participants indexOfObject:match.currentParticipant] == 0) {
        isBlue = YES;
        if (!fromGC) {
            [self loadCirclesWithAnimation:YES forColorBlue:NO];
            [self showCircleForBlue:NO];
        }
        else {
            [self loadCirclesWithAnimation:NO forColorBlue:NO];
        }
    }
    else {
        isBlue = NO;
        if (!fromGC) {
            [self loadCirclesWithAnimation:YES forColorBlue:YES];
            [self showCircleForBlue:YES];
        }
        else {
            [self loadCirclesWithAnimation:NO forColorBlue:YES];
        }
    }
    
    for (GKTurnBasedParticipant *p in match.participants) {
        if (p.matchOutcome == GKTurnBasedMatchOutcomeWon) {
            if ([p isEqual:match.participants[0]]) {
                [self showWinnerViewForBlue:YES];
            }
            else {
                [self showWinnerViewForBlue:NO];
            }
        }
    }
    [self animateToCurrentPlayer];
   // [self changeCircleColorForMatch:match];
}

- (void) changeCircleColorForMatch:(GKTurnBasedMatch*)match {
    
    int index = 0;
    for (GKTurnBasedParticipant *player in match.participants) {
        if (player.matchOutcome == GKTurnBasedMatchOutcomeWon) {
            if (index == 0) {
                blueCircle.layer.borderColor = [UIColor greenColor].CGColor;
            }
            else {
                redCircle.layer.borderColor = [UIColor greenColor].CGColor;
            }
            
        }
        else if (player.matchOutcome == GKTurnBasedMatchOutcomeLost) {
            if (index == 0) {
                blueCircle.layer.borderColor = [UIColor redColor].CGColor;
            }
            else {
                redCircle.layer.borderColor = [UIColor redColor].CGColor;
            }
        }
        else if (player.matchOutcome == GKTurnBasedMatchOutcomeQuit) {
            blueCircle.layer.borderColor = [UIColor redColor].CGColor;
            redCircle.layer.borderColor = [UIColor redColor].CGColor;
    
        }
        
        index++;
    }
    
}





- (void) showCircleForBlue:(BOOL)blue {
    for (CircleView *circle in self.view.subviews) {
        if (circle.tag == 50) {
            if (blue) {
                if ([circle.holeNumber isEqualToNumber:[blueCircles lastObject]]) {
                    [self animateForCircle:circle forColorBlue:YES];
                }
            }
            else {
                if ([circle.holeNumber isEqualToNumber:[redCircles lastObject]]) {
                    [self animateForCircle:circle forColorBlue:NO];
                }
            }
        }
    }
}

- (void) animateForCircle:(CircleView*)circle forColorBlue:(BOOL)blue {
    CGPoint point = circle.frame.origin;
    
    UIView * chip = [[UIView alloc]initWithFrame:CGRectMake(point.x, dropChipHeight, self.view.frame.size.width * .125, self.view.frame.size.width * .125)];
    chip.layer.borderColor = [UIColor whiteColor].CGColor;
    if (isLightTheme) {
        chip.layer.borderColor = [UIColor blackColor].CGColor;
    }
    chip.layer.borderWidth = chip.frame.size.width/20;
    chip.layer.cornerRadius = chip.frame.size.width/2;
    [self.view addSubview:chip];
    
    if (blue) {
        chip.backgroundColor = [UIColor blueColor];
    }
    else {
        chip.backgroundColor = [UIColor redColor];
    }
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:1 animations:^{
        chip.frame = CGRectMake(point.x, point.y, self.view.frame.size.width * .125, self.view.frame.size.width * .125);
    } completion:^(BOOL finished) {
        if (blue) {
            circle.backgroundColor = [UIColor blueColor];
        }
        else {
            circle.backgroundColor = [UIColor redColor];
        }
        [chip removeFromSuperview];
        self.view.userInteractionEnabled = YES;
    }];
}

- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match {
    
}
-(void)recieveEndGame:(GKTurnBasedMatch *)match {
    [self loadMatch:match forTurn:NO fromGC:NO];
}

- (void) animateToCurrentPlayer {
    
    if (isAnimating) {
        return;
    }
    
    isAnimating = YES;
    BOOL isPlayerBlue = NO;
    if ([[GKLocalPlayer localPlayer].playerID isEqualToString:((GKTurnBasedParticipant*)[GKManager helper].currentMatch.participants[0]).playerID]) {
        isPlayerBlue = YES;
    }
    
    if (playerIndicator.hidden) {
        playerIndicator.hidden = NO;
        if (isPlayerBlue) {
            playerIndicator.frame = CGRectMake(x1 + side/4, blueCircle.frame.origin.y + side + 20, side/2, side *.075 );
        }
        else {
            playerIndicator.frame = CGRectMake(x2 + side/4, blueCircle.frame.origin.y + side + 20, side/2, side *.075);
        }
    }
    
    if ([[GKManager helper].currentMatch.participants indexOfObject:[GKManager helper].currentMatch.currentParticipant] == 0) {
        [UIView animateWithDuration:.5 animations:^{
            blueCircle.frame = CGRectMake(x1-side*.625, 50, side, side);
            if (isPlayerBlue) {
                playerIndicator.frame = CGRectMake(playerIndicator.frame.origin.x-side*.625, blueCircle.frame.origin.y + side + 20, side/2, side *.075);
            }
        } completion:^(BOOL finished) {
            [self.view sendSubviewToBack:redCircle];
            [UIView animateWithDuration:.5 animations:^{
                blueCircle.frame = CGRectMake(x1, 50, side, side);
                if (isPlayerBlue) {
                    playerIndicator.frame = CGRectMake(x1 + side/4, blueCircle.frame.origin.y + side + 20, side/2, side *.075);
                }
            } completion:^(BOOL finished) {
                isAnimating = NO;
            }];
        }];
    }
    else {
        [UIView animateWithDuration:.5 animations:^{
            redCircle.frame = CGRectMake(x2+side*.6250, 50, side, side);
            if (!isPlayerBlue) {
                playerIndicator.frame = CGRectMake(playerIndicator.frame.origin.x + side*.625, blueCircle.frame.origin.y + side + 20, side/2, side *.075);
            }
        } completion:^(BOOL finished) {
            [self.view sendSubviewToBack:blueCircle];
            [UIView animateWithDuration:.5 animations:^{
                redCircle.frame = CGRectMake(x2, 50, side, side);
                if (!isPlayerBlue) {
                    playerIndicator.frame = CGRectMake(x2 + side/4, blueCircle.frame.origin.y + side + 20, side/2, side *.075);
                }
            } completion:^(BOOL finished) {
                isAnimating = NO;
            }];
        }];
    }
}


- (void)sendTurnForWin:(BOOL)win{
    
    [self hideCircles];
    isUserTurn = NO;
    GKTurnBasedMatch * match = [GKManager helper].currentMatch;
    
    if (!win) {
        NSUInteger currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
        NSMutableArray *nextParticipants = [NSMutableArray array];
        for (int i = 0; i < [match.participants count]; i++) {
            NSInteger indx = (i + currentPlayerIndex + 1) % [match.participants count];
            GKTurnBasedParticipant *participant = (match.participants)[indx];
            //1
            if (participant.matchOutcome == GKTurnBasedMatchOutcomeNone) {
                [nextParticipants addObject:participant];
            }
        }
        NSData *newData = [self getDataForMatch];
        if (newData) {
            [match endTurnWithNextParticipants:nextParticipants turnTimeout:3600 matchData:[self getDataForMatch] completionHandler:^(NSError *error) {
                NSLog(@"Turn Sent");
                [self animateToCurrentPlayer];
            }];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:@"Looks like something went wrong. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
    else {
        [match endMatchInTurnWithMatchData:[self getDataForMatch] completionHandler:^(NSError *error) {
            NSLog(@"Game Over");
        }];
    }
}

- (NSData *) getDataForMatch {
    
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithObjects:redCircles,blueCircles,playerIDs, nil];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dataArray forKey:@"GameData"];
    [archiver finishEncoding];
    
    return data;
}

- (NSMutableArray *) arrayFromData:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSMutableArray *dataArray = [unarchiver decodeObjectForKey:@"GameData"];
    [unarchiver finishDecoding];
    return dataArray;
}

- (void) loadGameplayArraysFromArray:(NSMutableArray*)dataArray {
    if (dataArray.count == 3) {
        redCircles = dataArray[0];
        blueCircles = dataArray[1];
        playerIDs = dataArray[2];
    }
    if (dataArray.count !=3 || !redCircles) {
        redCircles = [[NSMutableArray alloc]init];
    }
    if (dataArray.count !=3 || !blueCircles) {
        blueCircles = [[NSMutableArray alloc]init];
    }
    if (dataArray.count !=3 || !playerIDs) {
        playerIDs = [[NSMutableArray alloc]init];
    }
    [self addCurrentPlayerToArray:playerIDs];

}


- (void) addCurrentPlayerToArray:(NSMutableArray*)array {
    
    BOOL isIncluded = NO;
    
    for (NSString * playerID in array) {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        if ([playerID isEqualToString:[localPlayer alias]]) {
            isIncluded = YES;
        }
    }
    
    if (!isIncluded) {
        [array addObject:[[GKLocalPlayer localPlayer] alias]];
    }
    
    playerIDs = array;
}

- (void) loadCirclesWithAnimation:(BOOL)animate forColorBlue:(BOOL)blue{
    
    circles = [[NSMutableArray alloc]init];
    
    int xCord = 15;
    int yCord = self.view.frame.size.height - 310;
    if (self.view.frame.size.width * .125 > 50) {
        yCord = self.view.frame.size.height - self.view.frame.size.height * .65;
        xCord = (self.view.frame.size.width - ((self.view.frame.size.width * .125 + 10)*6))/2 + 5;
    }
    
    dropChipHeight = yCord - self.view.frame.size.width * .125 - 10;
    
    int column = 1;
    int row = 1;
    
    
    for (CircleView *circle in self.view.subviews) {
        if (circle.tag == 50) {
            [circle removeFromSuperview];
        }
    }
    
    for (int hole = 1; hole < 37; hole ++) {
        
        CircleView *circleView = [[CircleView alloc]initWithFrame:CGRectMake(xCord, yCord, self.view.frame.size.width * .125, self.view.frame.size.width * .125)];
        circleView.delegate = self;
        
        circleView.tag = 50;
        circleView.column = column;
        circleView.row = row;
        circleView.holeNumber = [NSNumber numberWithInt:hole];
        circleView.holeNumberInt = hole;
        
        circleView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        circleView.layer.borderWidth = circleView.frame.size.height/20;
        circleView.layer.cornerRadius = circleView.frame.size.height/2;
        
        
        for (NSNumber *redNumbers in redCircles) {
            if ([redNumbers isEqualToNumber:[NSNumber numberWithInt:hole]]) {
                circleView.isBlue = NO;
                circleView.isTaken = YES;
                circleView.backgroundColor = [UIColor redColor];
                
                if (animate && !blue) {
                    if ([redNumbers isEqualToNumber:[redCircles lastObject]]) {
                        circleView.backgroundColor = [UIColor clearColor];
                    }
                }
            }
        }
        for (NSNumber *blueNumbers in blueCircles) {
            if ([blueNumbers isEqualToNumber:[NSNumber numberWithInt:hole]]) {
                circleView.isBlue = YES;
                circleView.isTaken = YES;
                circleView.backgroundColor = [UIColor blueColor];
                
                if (animate && blue) {
                    if ([blueNumbers isEqualToNumber:[blueCircles lastObject]]) {
                        circleView.backgroundColor = [UIColor clearColor];
                    }
                }
            }
        }
        
        xCord = xCord + circleView.frame.size.height + 10;
        column++;
        
        if (hole == 6 || hole == 12 || hole == 18 || hole == 24 || hole == 30) {
            xCord = 15;
            if (self.view.frame.size.width * .125 > 50) {
                xCord = (self.view.frame.size.width - ((self.view.frame.size.width * .125 + 10)*6))/2 + 5;
            }
            yCord = yCord + circleView.frame.size.height + 10;
            column = 1;
            row++;
        }
        [self.view addSubview:circleView];
        [circles addObject:circleView];
    }
    [self hideCircles];
}

- (void) hideCircles {
    
    for (CircleView *circle in circles) {
        ((CircleView*)[self circleViewForColumn:circle.column]).layer.borderColor = [UIColor whiteColor].CGColor;
        if (circle.isTaken) {
            circle.layer.borderColor = [UIColor whiteColor].CGColor;
        }
    }
    [self loadAI];
}

- (void)loadAI {
    NSMutableArray *options = [NSMutableArray array];
    for (int i = 1; i <= 6; i++) {
        [options addObject:[self circleViewForColumn:i]];
        
    }
    
    NSMutableArray *tempRed = [NSMutableArray array];
    NSMutableArray *tempBlue = [NSMutableArray array];
    
    for (CircleView *circleView in circles) {
        if (circleView.isBlue) {
            [tempBlue addObject:circleView];
        }
        else if (circleView.isTaken) {
            [tempRed addObject:circleView];
        }
    }
}

- (void) circleTouched:(id)sender {
    
    
    if (!isUserTurn) {
        return;
    }
    

    CircleView * circleView = [self circleViewForColumn:((CircleView*)sender).column];
    
    if (!circleView) {
        return;
    }
    
    circleView.isTaken = YES;

    NSMutableDictionary *circleDic = [[NSMutableDictionary alloc]init];
    [circleDic setObject:[NSNumber numberWithInt:circleView.column] forKey:@"Column"];
    [circleDic setObject:[NSNumber numberWithInt:circleView.row] forKey:@"Row"];
    
    CGPoint point = circleView.frame.origin;
    
    UIView * chip = [[UIView alloc]initWithFrame:CGRectMake(point.x, dropChipHeight, self.view.frame.size.width * .125, self.view.frame.size.width * .125)];
    chip.layer.borderColor = [UIColor whiteColor].CGColor;
    if (isLightTheme) {
        chip.layer.borderColor = [UIColor blackColor].CGColor;
    }
    chip.layer.borderWidth = chip.frame.size.width/20;
    chip.layer.cornerRadius = chip.frame.size.width/2;
    [self.view addSubview:chip];

    if (isBlue) {
        chip.backgroundColor = [UIColor blueColor];
    }
    else {
        chip.backgroundColor = [UIColor redColor];
    }
    
    [UIView animateWithDuration:1 animations:^{
        chip.frame = CGRectMake(point.x, point.y, self.view.frame.size.width * .125, self.view.frame.size.width * .125);
    } completion:^(BOOL finished) {
        if (isBlue) {
            circleView.backgroundColor = [UIColor blueColor];
        }
        else {
            circleView.backgroundColor = [UIColor redColor];
        }
        [chip removeFromSuperview];
    }];
    
    
    
    if (isBlue) {
        circleView.isBlue = YES;
        
        [blueCircles addObject:circleView.holeNumber];
    }
    else {
        circleView.isBlue = NO;
        
        [redCircles addObject:circleView.holeNumber];
    }
    
    [self checkCirclesForWin];
}

- (CircleView *) circleViewForColumn:(int)column {
    
    NSMutableArray * columnCircles = [[NSMutableArray alloc]init];
    
    for (CircleView *circleView in circles) {
        if (circleView.column == column) {
            if (!circleView.isTaken) {
                [columnCircles addObject:circleView];
            }
        }
    }
    
    return [columnCircles lastObject];
}


- (void)checkCirclesForWin {
    
    NSMutableArray *blues = [[NSMutableArray alloc]init];
    NSMutableArray *reds = [[NSMutableArray alloc]init];
    
    int takenCount = 0;
    
    for (CircleView *circleView in circles) {
        if (circleView.isTaken) {
            takenCount++;
        }
        if (circleView.isBlue) {
            [blues addObject:circleView];
        }
        else if (circleView.isTaken) {
            [reds addObject:circleView];
        }
    }
    
  
    
    BOOL winner = NO;
    
    if ([C4Helper fourConnectedForCircles:blues]) {
        
        winner = YES;
        ((GKTurnBasedParticipant*)[GKManager helper].currentMatch.participants[0]).matchOutcome = GKTurnBasedMatchOutcomeWon;
        ((GKTurnBasedParticipant*)[GKManager helper].currentMatch.participants[1]).matchOutcome = GKTurnBasedMatchOutcomeLost;
        [self showWinnerViewForBlue:YES];
    }
    
    if ([C4Helper fourConnectedForCircles:reds]) {
        ((GKTurnBasedParticipant*)[GKManager helper].currentMatch.participants[0]).matchOutcome = GKTurnBasedMatchOutcomeLost;
        ((GKTurnBasedParticipant*)[GKManager helper].currentMatch.participants[1]).matchOutcome = GKTurnBasedMatchOutcomeWon;
        winner = YES;
        [self showWinnerViewForBlue:NO];
    }
    
    if (takenCount == 36) {
        ((GKTurnBasedParticipant*)[GKManager helper].currentMatch.participants[0]).matchOutcome = GKTurnBasedMatchOutcomeTied;
        ((GKTurnBasedParticipant*)[GKManager helper].currentMatch.participants[1]).matchOutcome = GKTurnBasedMatchOutcomeTied;
        winner = YES;
        [CSNotificationView showInViewController:self
                                           style:CSNotificationViewStyleError
                                         message:@"Tied Game"];
    
    }
    
    [self sendTurnForWin:winner];
}

- (void)showWinnerViewForBlue:(BOOL)blue {
    
    if (isShowingResult) {
        return;
    }
    
    
    
    
    
    
    
    BOOL isCurrentPlayerBlue = NO;
    if ([[GKLocalPlayer localPlayer].playerID isEqualToString:((GKTurnBasedParticipant*)[GKManager helper].currentMatch.participants[0]).playerID]) {
        isCurrentPlayerBlue = YES;
    }
    
    
    if (blue && isCurrentPlayerBlue) {
        [CSNotificationView showInViewController:self style:CSNotificationViewStyleSuccess message:@"You won this match"];
    }
    else if (blue && !isCurrentPlayerBlue) {
        [CSNotificationView showInViewController:self style:CSNotificationViewStyleError message:@"You lost this match"];
    }
    else if (!blue && !isCurrentPlayerBlue) {
        [CSNotificationView showInViewController:self style:CSNotificationViewStyleSuccess message:@"You won this match"];
    }
    else if (!blue && isCurrentPlayerBlue) {
        [CSNotificationView showInViewController:self style:CSNotificationViewStyleSuccess message:@"You lost this match"];
    }
    
    
    isShowingResult = YES;

    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(okToShow) userInfo:nil repeats:NO];
}

- (void) okToShow {
    isShowingResult = NO;
}


- (IBAction)menu:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
