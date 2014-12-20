//
//  CircleAI.m
//  connect
//
//  Created by Andrew on 10/30/13.
//  Copyright (c) 2013 ATFinke Productions Incorperated. All rights reserved.
//

#import "CircleAI.h"
#import "C4Helper.h"

@implementation CircleAI

+ (CircleView*)numberForCircleForArrays:(NSMutableArray *)reds andArray2:(NSMutableArray *)blues withOptions:(NSMutableArray *)options{
    
    for (int x = 0; x < [options count]; x++) {
        int randInt = (arc4random() % ([options count] - x)) + x;
        [options exchangeObjectAtIndex:x withObjectAtIndex:randInt];
    }
    
    //pls work oh god what am I doing
    
    //cpu is always red, check reds for win
    
    for (CircleView *circleView in options) {
        NSMutableArray *tempArray = [reds mutableCopy];
        [tempArray addObject:circleView];
        if ([C4Helper fourConnectedForCircles:tempArray]) {
            NSLog(@"%i %i = FTW",circleView.row,circleView.column);
            return circleView;
        }
    }
    //check if blue is about to win, execute block
    
    for (CircleView *circleView in options) {
        NSMutableArray *tempArray = [blues mutableCopy];
        [tempArray addObject:circleView];
        if ([C4Helper fourConnectedForCircles:tempArray]) {
            NSLog(@"%i %i = BLOCK",circleView.row,circleView.column);
            return circleView;
        }
    }
    //TIME TO WRITE NEW COUNT CODE, BRB
    
    //i hope this new stuff works
    
    for (CircleView *circleView in options) {
        NSMutableArray *tempArray = [reds mutableCopy];
        [tempArray addObject:circleView];
        if ([C4Helper threeConnectedForCircles:tempArray]) {
            if ([CircleAI circleView:circleView okAgainstBlue:blues withOptions:options]) {
                NSLog(@"Three");
                return circleView;
            }
        }
    }
    
    for (CircleView *circleView in options) {
        NSMutableArray *tempArray = [reds mutableCopy];
        [tempArray addObject:circleView];
        if ([C4Helper twoConnectedForCircles:tempArray]) {
            if ([CircleAI circleView:circleView okAgainstBlue:blues withOptions:options]) {
                NSLog(@"Meh");
                return circleView;
            }
        }
    }
    
    NSLog(@"No Options");
    // it got this far, im good right?
    CircleView *circleView =(CircleView*)options[arc4random() % options.count];
    return circleView;
}




+ (BOOL) circleView:(CircleView *)circleView okAgainstBlue:(NSMutableArray *)blues withOptions:(NSMutableArray *)options {
    
    if (circleView.row == 1) {
        return YES;
    }
    NSMutableArray *newOptions = [options mutableCopy];
    for (CircleView *circleOptionView in options) {
        if ([circleOptionView isEqual:circleView]) {
            circleOptionView.row = circleOptionView.row-1;
        }
    }
    for (CircleView *circleView in newOptions) {
        NSMutableArray *tempArray = [blues mutableCopy];
        [tempArray addObject:circleView];
        if ([C4Helper fourConnectedForCircles:tempArray]) {
            NSLog(@"would give up game if went %i %i",circleView.row-1,circleView.column);
            return NO;
        }
    }
    return YES;
}






@end
