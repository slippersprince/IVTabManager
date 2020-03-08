//
//  UIViewController+DPAdditions.m
//  xhmall
//
//  Created by 马镇荣 on 2020/3/8.
//  Copyright © 2020 romy. All rights reserved.
//

#import "UIViewController+DPAdditions.h"
#import <objc/runtime.h>

static NSString *forceKey = @"forceKey";

@implementation UIViewController (DPAdditions)

@dynamic forceScrollsToTop;

- (void)setForceScrollsToTop:(BOOL)forceScrollsToTop {
    NSNumber *number = [NSNumber numberWithBool: forceScrollsToTop];
    objc_setAssociatedObject(self, &forceKey, number, OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)forceScrollsToTop {
    return [objc_getAssociatedObject(self, &forceKey) boolValue];
}

@end
