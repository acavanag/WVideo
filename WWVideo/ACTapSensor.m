//
//  ACTapSensor.m
//  PoliticalWall
//
//  Created by Andrew J Cavanagh on 9/16/13.
//  Copyright (c) 2013 Andrew J Cavanagh. All rights reserved.
//

#import "ACTapSensor.h"

@implementation ACTapSensor

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateCancelled;
}

@end
