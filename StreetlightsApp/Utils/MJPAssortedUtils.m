//
//  MJPAssortedUtils.m
//  Around
//
//  Created by Matt on 1/13/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import "MJPAssortedUtils.h"

@implementation MJPAssortedUtils

+ (NSString*)stringForRemainingTime:(NSInteger)numberOfMinutes {
    if (numberOfMinutes < 60) {
        return [NSString stringWithFormat:@"%dm", numberOfMinutes];
    } else {
        return [NSString stringWithFormat:@"%dh", numberOfMinutes / 60];
    }
}

@end
