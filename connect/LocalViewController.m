//
//  LocalViewController.m
//  connect
//
//  Created by Andrew on 10/30/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import "LocalViewController.h"

@interface LocalViewController () {
    
    BOOL isBlueTurn;
    BOOL isAnimating;
    BOOL isShowingHelp;
    BOOL gameOver;
    
    NSMutableArray *circles;
    NSMutableArray *redCircles;
    NSMutableArray *blueCircles;
 
    int dropChipHeight;
    int side;
}

@property (nonatomic) UIDynamicAnimator *animator;
@end

@implementation LocalViewController

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
    gameOver = NO;
    side = self.view.frame.size.width * .25;

    UIView *blueCircle = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-side/2, side, side, side)];
    blueCircle.layer.cornerRadius = side/2;
    blueCircle.layer.borderWidth = side * .09375;
    blueCircle.layer.borderColor = [UIColor whiteColor].CGColor;
    blueCircle.backgroundColor = [UIColor blueColor];
    [self.view addSubview:blueCircle];
    
    UIView *playerIndicator = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-side/4, blueCircle.frame.origin.y+side*1.25, side/2, 6)];
    playerIndicator.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:playerIndicator];
    
    if (self.view.frame.size.width > 350) {
        self.menuButton.frame = CGRectMake(self.menuButton.frame.origin.x, self.menuButton.frame.origin.y, 80,50);
        blueCircle.frame = CGRectMake(CGRectGetMidX(self.view.frame)-side/2, side/4, side, side);
        playerIndicator.frame = CGRectMake(CGRectGetMidX(self.view.frame)-side/4, blueCircle.frame.origin.y+side*1.25, side/2, 12);
    }
    redCircles = [[NSMutableArray alloc]init];
    blueCircles = [[NSMutableArray alloc]init];
    
    isBlueTurn = YES;
   
    
    
    self.view.backgroundColor = [UIColor colorWithRed:0.199478 green:0.199478 blue:0.199478 alpha:1];
	// Do any additional setup after loading the view.
    
    [self loadCirclesWithAnimation:NO forColorBlue:YES];
    
    if (![[NSUserDefaults standardUserDefaults]valueForKey:@"ergwergw"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Saving" message:@"Please note that local games will not be saved" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [[NSUserDefaults standardUserDefaults] setValue:@123124 forKey:@"ergwergw"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) animateForCircle:(CircleView*)circle forColorBlue:(BOOL)blue {
    CGPoint point = circle.frame.origin;
    
    UIView * chip = [[UIView alloc]initWithFrame:CGRectMake(point.x, dropChipHeight, self.view.frame.size.width * .125, self.view.frame.size.width * .125)];
    chip.layer.borderColor = [UIColor whiteColor].CGColor;

    chip.layer.borderWidth = chip.frame.size.width/20;
    chip.layer.cornerRadius = chip.frame.size.width/2;
    [self.view addSubview:chip];
    
    if (blue) {
        chip.backgroundColor = [UIColor blueColor];
    }
    else {
        chip.backgroundColor = [UIColor redColor];
    }
    
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
    }];
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
        if (!gameOver) {
            ((CircleView*)[self circleViewForColumn:circle.column]).layer.borderColor = [UIColor whiteColor].CGColor;
        }
        else {
            ((CircleView*)[self circleViewForColumn:circle.column]).layer.borderColor = [UIColor darkGrayColor].CGColor;
        }
        if (circle.isTaken) {
            circle.layer.borderColor = [UIColor whiteColor].CGColor;
        }
    }
}

- (void)loadAI {
    NSMutableArray *options = [NSMutableArray array];
    for (int i = 1; i <= 6; i++) {
        if ([self circleViewForColumn:i]) {
            [options addObject:[self circleViewForColumn:i]];
        }
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
    [self circleTouched:[CircleAI numberForCircleForArrays:tempRed andArray2:tempBlue withOptions:options]];
}




- (void) circleTouched:(id)sender {
    if (gameOver) {
        return;
    }
    BOOL userTurn = isBlueTurn;
    if (isBlueTurn) {
        isBlueTurn = NO;
        self.view.userInteractionEnabled = NO;
        [NSTimer scheduledTimerWithTimeInterval:1.1 target:self selector:@selector(loadAI) userInfo:nil repeats:NO];
    }
    else {
        isBlueTurn = YES;
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

    chip.layer.borderWidth = chip.frame.size.width/20;
    chip.layer.cornerRadius = chip.frame.size.width/2;
    [self.view addSubview:chip];
    
    if (userTurn) {
        chip.backgroundColor = [UIColor blueColor];
    }
    else {
        chip.backgroundColor = [UIColor redColor];
    }
    
    [UIView animateWithDuration:1 animations:^{
        chip.frame = CGRectMake(point.x, point.y, self.view.frame.size.width * .125, self.view.frame.size.width * .125);
    } completion:^(BOOL finished) {
        if (userTurn) {
            circleView.backgroundColor = [UIColor blueColor];
        }
        else {
            circleView.backgroundColor = [UIColor redColor];
            self.view.userInteractionEnabled = YES;
        }
        [self hideCircles];
        [chip removeFromSuperview];
    }];
    
    
    
    if (userTurn) {
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
        else if (!circleView.isBlue && circleView.isTaken) {
            [reds addObject:circleView];
        }
    }
 
    if ([C4Helper fourConnectedForCircles:blues]) {
        [CSNotificationView showInViewController:self style:CSNotificationViewStyleSuccess message:@"You won this match"];
        gameOver = YES;
    }
    else if ([C4Helper fourConnectedForCircles:reds]) {
        [CSNotificationView showInViewController:self style:CSNotificationViewStyleError message:@"You lost this match"];
        gameOver = YES;
    }
    else if (takenCount == 36) {
        [CSNotificationView showInViewController:self style:CSNotificationViewStyleError message:@"Tied Game"];
        gameOver = YES;
    }
    
    if (gameOver) {
        [self hideCircles];
        self.view.userInteractionEnabled = YES;
    }
}

- (IBAction)menu:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
