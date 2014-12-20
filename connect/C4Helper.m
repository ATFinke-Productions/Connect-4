//
//  C4Helper.m
//  connect
//
//  Created by Andrew on 7/30/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import "C4Helper.h"
#import "CircleView.h"

@implementation C4Helper


+ (BOOL) fourConnectedForCircles:(NSMutableArray *)coloredHoles {
    for (CircleView*cir in coloredHoles) {
        NSLog(@"%i,%i",cir.row,cir.column);
    }
    for (CircleView * firstView in coloredHoles) {
        for (CircleView * secondView in coloredHoles) {
            if (firstView.holeNumberInt == secondView.holeNumberInt + 6 && firstView.column == secondView.column) {
                for (CircleView * thirdView in coloredHoles) {
                    if (secondView.holeNumberInt == thirdView.holeNumberInt + 6 && secondView.column == thirdView.column) {
                        for (CircleView * fourthView in coloredHoles) {
                            if (thirdView.holeNumberInt == fourthView.holeNumberInt + 6 && thirdView.column == fourthView.column) {
                                NSLog(@"Yes1");
                                return YES;
                            }
                        }
                    }
                }
            }
        }
    }
    for (CircleView * firstView in coloredHoles) {
        for (CircleView * secondView in coloredHoles) {
            if (firstView.holeNumberInt == secondView.holeNumberInt + 1 && firstView.row == secondView.row) {
                for (CircleView * thirdView in coloredHoles) {
                    if (secondView.holeNumberInt == thirdView.holeNumberInt + 1 && secondView.row == thirdView.row) {
                        for (CircleView * fourthView in coloredHoles) {
                            if (thirdView.holeNumberInt == fourthView.holeNumberInt + 1 && thirdView.row == fourthView.row) {
                                NSLog(@"Yes2");
                                return YES;
                            }
                        }
                    }
                }
            }
        }
    }
    for (CircleView * firstView in coloredHoles) {
        for (CircleView * secondView in coloredHoles) {
            if (secondView.column != firstView.column && secondView.row != firstView.row) {
                for (CircleView * thirdView in coloredHoles) {
                    if (thirdView.column != secondView.column && thirdView.column != firstView.column && thirdView.row != secondView.row && thirdView.row != firstView.row) {
                        for (CircleView * fourthView in coloredHoles) {
                            if (fourthView.column != thirdView.column && fourthView.column != secondView.column && fourthView.column != firstView.column && fourthView.row != thirdView.row && fourthView.row != secondView.row && fourthView.row != firstView.row) {
                                if (firstView.column == secondView.column + 1 && firstView.column == thirdView.column + 2 && firstView.column == fourthView.column + 3) {
                                    if ((firstView.row == secondView.row + 1 && firstView.row == thirdView.row + 2 && firstView.row == fourthView.row + 3) || (firstView.row == secondView.row - 1 && firstView.row == thirdView.row - 2 && firstView.row == fourthView.row - 3)) {
                                        NSLog(@"Yes3 1:%i,%i 2:%i,%i 3:%i,%i 4:%i,%i",firstView.row,firstView.column,secondView.row,secondView.column,thirdView.row,thirdView.column,fourthView.row,fourthView.column);
                                        return YES;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return NO;
}

+ (BOOL) threeConnectedForCircles:(NSMutableArray *)coloredHoles {
    for (CircleView * firstView in coloredHoles) {
        for (CircleView * secondView in coloredHoles) {
            if (firstView.holeNumberInt == secondView.holeNumberInt + 6 && firstView.column == secondView.column) {
                for (CircleView * thirdView in coloredHoles) {
                    if (secondView.holeNumberInt == thirdView.holeNumberInt + 6 && secondView.column == thirdView.column) {
                         return YES;
                    }
                }
            }
        }
    }
    for (CircleView * firstView in coloredHoles) {
        for (CircleView * secondView in coloredHoles) {
            if (firstView.holeNumberInt == secondView.holeNumberInt + 1 && firstView.row == secondView.row) {
                for (CircleView * thirdView in coloredHoles) {
                    if (secondView.holeNumberInt == thirdView.holeNumberInt + 1 && secondView.row == thirdView.row) {
                         return YES;
                    }
                }
            }
        }
    }
    for (CircleView * firstView in coloredHoles) {
        for (CircleView * secondView in coloredHoles) {
            if (secondView.column != firstView.column && secondView.row != firstView.row) {
                for (CircleView * thirdView in coloredHoles) {
                    if (thirdView.column != secondView.column && thirdView.column != firstView.column && thirdView.row != secondView.row && thirdView.row != firstView.row) {
                        if (firstView.column == secondView.column + 1 && firstView.column == thirdView.column + 2) {
                            if ((firstView.row == secondView.row + 1 && firstView.row == thirdView.row + 2) || (firstView.row == secondView.row - 1 && firstView.row == thirdView.row - 2)) {
                                return YES;
                            }
                        }
                    }
                }
            }
        }
    }
    return NO;
}

+ (BOOL) twoConnectedForCircles:(NSMutableArray *)coloredHoles {
    for (CircleView * firstView in coloredHoles) {
        for (CircleView * secondView in coloredHoles) {
            if (firstView.holeNumberInt == secondView.holeNumberInt + 6 && firstView.column == secondView.column) {
                return YES;
            }
        }
    }
    for (CircleView * firstView in coloredHoles) {
        for (CircleView * secondView in coloredHoles) {
            if (firstView.holeNumberInt == secondView.holeNumberInt + 1 && firstView.row == secondView.row) {
                return YES;
            }
        }
    }
    for (CircleView * firstView in coloredHoles) {
        for (CircleView * secondView in coloredHoles) {
            if (secondView.column != firstView.column && secondView.row != firstView.row) {
                if (firstView.column == secondView.column + 1) {
                    if ((firstView.row == secondView.row + 1) || (firstView.row == secondView.row - 1)) {
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

@end
