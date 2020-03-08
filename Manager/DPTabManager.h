//
//  DPTabManager.h
//  dapai
//
//  Created by ChenGuosheng on 15/6/6.
//  Copyright (c) 2015年 TalkWork. All rights reserved.
//

#import "DPTabView.h"

@class DPTabManager;
@protocol DPTabManagerDataSource <NSObject>
- (UIViewController *)tabManager:(DPTabManager *)tabManager controllerAtIndex:(NSInteger)index;
- (id)tabManager:(DPTabManager *)tabManager titleForState:(UIControlState)state atIndex:(NSInteger)index;
- (UIColor *)tabManager:(DPTabManager *)tabManager titleColorForState:(UIControlState)state atIndex:(NSInteger)index;

@optional
- (void)tabManager:(DPTabManager *)tabManager scrollTo:(NSInteger)index;
- (UIFont *)tabManager:(DPTabManager *)tabManager fontForState:(UIControlState)state atIndex:(NSInteger)index;
@end

@interface DPTabManager : NSObject
- (instancetype)initWithTabView:(DPTabView *)tabView scrollView:(UIScrollView *)scrollView dataSource:(id<DPTabManagerDataSource>)dataSource;
@end
