
//
//  ListTableViewController.m
//  connect
//
//  Created by Andrew on 7/30/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import "ListTableViewController.h"
#import "BoardViewController.h"

@interface ListTableViewController () {
    NSMutableArray *objects;
    NSArray *allMyMatches;
    GKTurnBasedMatch *alertViewMatch;
}

@end

@implementation ListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [GKManager helper].menuDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(matchSelected:) name:@"MatchMakerDismissed" object:nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(loadMatches) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.refreshControl beginRefreshing];
    
    [self loadTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didAuthenticate:(BOOL)authenticated {
    if (authenticated) {
        [self loadMatches];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Login Required" message:@"It is required to be logged into Game Center to play this game." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

- (void) matchUpdate {
    [self loadMatches];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"Theme"] isEqualToString:@"D"]) {
        self.view.backgroundColor = [UIColor colorWithRed:0.199478 green:0.199478 blue:0.199478 alpha:1];
    }
    else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [self loadMatches];
}

- (void) submitWinCount:(int)count {
    GKScore* gkScore = [[GKScore alloc] initWithLeaderboardIdentifier:@"com.atfinkeproductions.connect.wins"];
    gkScore.value = count;
    
    //4: Send the score to Game Center
    [GKScore reportScores:@[gkScore] withCompletionHandler:^(NSError *error) {
        
    }];
}



- (void) loadMatches {
    [GKTurnBasedMatch loadMatchesWithCompletionHandler: ^(NSArray *matches, NSError *error) {
        // 2
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            [self.refreshControl endRefreshing];
        } else {
            // 3
            NSMutableArray *myMatches = [NSMutableArray array];
            NSMutableArray *otherMatches = [NSMutableArray array];
            NSMutableArray *endedMatches = [NSMutableArray array];
            // 4
            for (GKTurnBasedMatch *m in matches) {
                GKTurnBasedMatchOutcome myOutcome;
                for (GKTurnBasedParticipant *par in m.participants) {
                    if ([par.playerID isEqualToString: [GKLocalPlayer localPlayer].playerID]) {
                        myOutcome = par.matchOutcome;
                    }
                }
                // 5
                if (m.status != GKTurnBasedMatchStatusEnded && myOutcome != GKTurnBasedMatchOutcomeQuit) {
                    if ([m.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                        [myMatches addObject:m];
                    } else {
                        [otherMatches addObject:m];
                    }
                } else {
                    [endedMatches addObject:m];
                }
            }
            // 6
            allMyMatches = [[NSArray alloc] initWithObjects:myMatches, otherMatches,endedMatches, nil];
            [self loadTableView];
        }
    }];
}


- (void) loadTableView {

    objects = [[NSMutableArray alloc]init];
    
    [self addCurrentMatchesToArray];
    [self addOldMatchesToArray];
    [self addNewMatchCardToArray];
    [self addNew2MatchCardToArray];
    [self addTutorial];
    [self addAboutCardToArray];
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}


- (void) addNewMatchCardToArray {
    MenuObject *object = [[MenuObject alloc]init];
    object.type = @"Game Center Match";
    [objects addObject:object];
}

- (void) addNew2MatchCardToArray {
    MenuObject *object = [[MenuObject alloc]init];
    object.type = @"Local Match";
    [objects addObject:object];
}

- (void) addAboutCardToArray {
    MenuObject *object = [[MenuObject alloc]init];
    object.type = @"Credits";
    [objects addObject:object];
}

- (void) addTutorial {
    MenuObject *object = [[MenuObject alloc]init];
    object.type = @"Tutorial";
    [objects addObject:object];
}

- (void) addCurrentMatchesToArray {
    NSMutableArray *currentMatches = [[NSMutableArray alloc]init];
    for (GKTurnBasedMatch *match in allMyMatches[0]) {
        [currentMatches addObject:match];
    }
    for (GKTurnBasedMatch *match in allMyMatches[1]) {
        [currentMatches addObject:match];
    }
    for (GKTurnBasedMatch * match in currentMatches) {
        MenuObject *object = [[MenuObject alloc]init];
        object.type = @"Match.C";
        object.match = match;
        [objects addObject:object];
    }
}
- (void) addOldMatchesToArray {
    for (GKTurnBasedMatch * match in allMyMatches[2]) {
        MenuObject *object = [[MenuObject alloc]init];
        object.type = @"Match.O";
        object.match = match;
        [objects addObject:object];
    }
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([((MenuObject*)objects[indexPath.row]).type isEqualToString:@"Game Center Match"]) {
        [[GKManager helper] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self];
    }
    else if ([((MenuObject*)objects[indexPath.row]).type isEqualToString:@"Local Match"]) {
        [self performSegueWithIdentifier:@"showLocal" sender:self];
    }
    else if ([((MenuObject*)objects[indexPath.row]).type isEqualToString:@"Tutorial"]) {
        NSLog(@"tutorial");
    }
    else if ([((MenuObject*)objects[indexPath.row]).type isEqualToString:@"Credits"]) {
        [self performSegueWithIdentifier:@"about" sender:self];
    }
    else if ([((MenuObject*)objects[indexPath.row]).type isEqualToString:@"Match.C"] || [((MenuObject*)objects[indexPath.row]).type isEqualToString:@"Match.O"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MatchMakerDismissed" object:((MenuObject*)objects[indexPath.row]).match];
    }
    else if ([((MenuObject*)objects[indexPath.row]).type isEqualToString:@"Match.C"] || [((MenuObject*)objects[indexPath.row]).type isEqualToString:@"Match.O"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MatchMakerDismissed" object:((MenuObject*)objects[indexPath.row]).match];
    }
}

- (void)matchSelected:(NSNotification *)notification {
    if (notification.object) {
        [self performSegueWithIdentifier:@"showGame" sender:notification.object];
    }
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showGame"]) {
        [[segue destinationViewController] setMatchToSet:(GKTurnBasedMatch*)sender];
    }
}

- (UIImage*)imageForMatch:(GKTurnBasedMatch*)match {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",match.matchID]];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    
    if (!image) {
        NSMutableData *data = [[NSUserDefaults standardUserDefaults]valueForKey:path];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",match.matchID]];
        UIImage* image = [UIImage imageWithContentsOfFile:path];
        image = [UIImage imageWithData:data];
    }
    
    if (!image) {
        image = [UIImage imageNamed:@"MenuDefault"];
    }
    return image;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return objects.count;
}

- (void) matchButtonPressed:(id)sender {
    
    UIButton *senderButton = (UIButton *)sender;
    MenuCell *buttonCell = (MenuCell *)senderButton.superview.superview.superview;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7) {
        buttonCell = (MenuCell *)senderButton.superview.superview;
    }
    
    GKTurnBasedMatch * match = ((MenuObject*)objects[buttonCell.row]).match;
    
    if ([((MenuObject*)objects[buttonCell.row]).type isEqualToString:@"Match.O"]) {
        NSLog(@"remove");
        [match removeWithCompletionHandler:^(NSError *error) {
            NSString  *imagePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.png",match.matchID]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:imagePath error:NULL];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:imagePath];
            [[NSUserDefaults standardUserDefaults]synchronize];
            NSLog(@"remove completed");
            [objects removeObjectAtIndex:buttonCell.row];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:buttonCell.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];

            [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(loadMatches) userInfo:nil repeats:NO];
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Quit Match" message:@"This match is still active. Are you sure you want to quit?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
        alertViewMatch = match;
    }
}

- (void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        if ([alertViewMatch.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            NSLog(@"quit");
            [self quitMatch:alertViewMatch];
        } else {
            NSLog(@"quit");
            [alertViewMatch participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                }
                else {
                    [self loadMatches];
                    NSLog(@"quit completed");
                }
            }];
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    MenuObject * menuObject = (MenuObject*)objects[indexPath.row];
    cell.itemLabel.text = menuObject.type;
    
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"Theme"] isEqualToString:@"D"]) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.199478 green:0.199478 blue:0.199478 alpha:1];
        cell.itemLabel.textColor = [UIColor whiteColor];
        cell.playerLabel.textColor = [UIColor whiteColor];
        cell.statusLabel.textColor = [UIColor whiteColor];
    }
    else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.itemLabel.textColor = [UIColor darkGrayColor];
        cell.playerLabel.textColor = [UIColor darkGrayColor];
        cell.statusLabel.textColor = [UIColor darkGrayColor];
    }
    
    if ([menuObject.type isEqualToString:@"Match.C"] || [menuObject.type isEqualToString:@"Match.O"]) {
       
        cell.whiteView.hidden = NO;
      /*  if ([menuObject.type isEqualToString:@"Match.C"]) {
            cell.matchButton.titleLabel.text = @"Quit Match";
        }
        else {
           cell.matchButton.titleLabel.text = @"Remove Match"; 
        }*/
        cell.matchButton.hidden = NO;
        [cell.matchButton addTarget:self action:@selector(matchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.itemLabel.hidden = YES;
        cell.playerLabel.hidden = NO;
        cell.statusLabel.hidden = NO;
        cell.matchButton.hidden = NO;
        
        cell.row = indexPath.row;
        
        if ([self isLocalPlayerTurnInMatch:menuObject.match]) {
            cell.playerLabel.text = @"Your Turn";
        }
        else {
            cell.playerLabel.text = @"Their Turn";
        }
        
        cell.statusLabel.text = [NSString stringWithFormat:@"%@",[self otherPlayerAliasForMatch:menuObject.match]];
        cell.previewImageView.image = [self imageForMatch:menuObject.match];
        cell.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        for (GKTurnBasedParticipant *par in menuObject.match.participants) {
            if ([par.playerID isEqualToString: [GKLocalPlayer localPlayer].playerID]) {
                switch (par.matchOutcome) {
                    case 1:
                        cell.playerLabel.text = @"Quit Match";
                        break;
                    case 2:
                        cell.playerLabel.text = @"Won Match";
                        [self checkAndSubmitScoreForMatch:menuObject.match forWin:YES];
                        break;
                    case 3:
                        cell.playerLabel.text = @"Lost Match";
                        [self checkAndSubmitScoreForMatch:menuObject.match forWin:NO];
                        break;
                    case 4:
                        cell.playerLabel.text = @"Tied Match";
                        break;
                    default:
                        break;
                }
            }
        }
    }
    else {
        cell.whiteView.hidden = YES;
        cell.itemLabel.hidden = NO;
        cell.playerLabel.hidden = YES;
        cell.statusLabel.hidden = YES;
        cell.matchButton.hidden = YES;
        
        if ([menuObject.type isEqualToString:@"Game Center Match"]) {
            cell.previewImageView.image = [UIImage imageNamed:@"AddMatch"];
            cell.previewImageView.contentMode = UIViewContentModeCenter;
        }
        else if ([menuObject.type isEqualToString:@"Local Match"]){
            cell.previewImageView.image = [UIImage imageNamed:@"local"];
            cell.previewImageView.contentMode = UIViewContentModeCenter;
        }
        else if ([menuObject.type isEqualToString:@"Credits"]){
            cell.previewImageView.image = [UIImage imageNamed:@"About"];
            cell.previewImageView.contentMode = UIViewContentModeCenter;
        }
        else if ([menuObject.type isEqualToString:@"Tutorial"]) {
            cell.previewImageView.image = [UIImage imageNamed:@"HelpButton-iPhone"];
            cell.previewImageView.contentMode = UIViewContentModeCenter;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void) checkAndSubmitScoreForMatch:(GKTurnBasedMatch*)match forWin:(BOOL)win{
    NSUserDefaults *defualts = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *trackedMatches = [[defualts valueForKey:@"matches"] mutableCopy];
    if (!trackedMatches) {
        trackedMatches = [[NSMutableArray alloc]init];
    }
    
    BOOL shouldCount = YES;
    
    for (NSString *matchID in trackedMatches) {
        if ([matchID isEqualToString:match.matchID]) {
            shouldCount = NO;
        }
    }
    
    if (shouldCount) {
        int wins = [[defualts valueForKey:@"wins"]intValue];
        int losses = [[defualts valueForKey:@"losses"]intValue];
        
        if (win) {
            wins++;
            [self submitWinCount:wins];
            [defualts setValue:[NSNumber numberWithInt:wins] forKey:@"wins"];
        }
        else {
            losses++;
            [defualts setValue:[NSNumber numberWithInt:losses] forKey:@"losses"];
        }
        
        [trackedMatches addObject:match.matchID];
        [defualts setValue:trackedMatches forKey:@"matches"];
        [defualts synchronize];
 
    }
}

- (BOOL) isLocalPlayerTurnInMatch:(GKTurnBasedMatch*)match {
    if ([[GKLocalPlayer localPlayer].playerID isEqualToString:((GKTurnBasedParticipant*)match.currentParticipant).playerID]) {
        return YES;
    }
    return NO;
}

- (NSString*)otherPlayerAliasForMatch:(GKTurnBasedMatch*)match {
    if (match.matchData.length > 5) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:match.matchData];
        NSMutableArray *gameData = [unarchiver decodeObjectForKey:@"GameData"];
        [unarchiver finishDecoding];
        int index = 0;
        for (GKTurnBasedParticipant *player in match.participants) {
            if (![[GKLocalPlayer localPlayer].playerID isEqualToString:player.playerID]) {
                NSArray *playerIDS = gameData[2];
                if (playerIDS.count == 2) {
                    return playerIDS[index];
                }
            }
            index++;
        }
    }
    return @"Auto-Match Player";
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


- (void)quitMatch:(GKTurnBasedMatch*)match {
    GKTurnBasedParticipant *part;
    if ([match.participants indexOfObject:match.currentParticipant] == 0) {
        part = match.participants[1];
    }
    else {
        part = match.participants[0];
    }
    [match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit nextParticipants:@[part] turnTimeout:600 matchData:match.matchData completionHandler:^(NSError *error) {
        [self loadMatches];
        NSLog(@"quit completed");

    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
