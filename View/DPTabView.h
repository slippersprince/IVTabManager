//
//  DPTabView.h
//  dapai
//
//  Created by ChenGuosheng on 15/5/1.
//  Copyright (c) 2015年 TalkWork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPTabButton.h"

@class DPTabView;
@protocol DPTabViewDataSource <NSObject>
- (void)tabView:(DPTabView *)tabView configureButton:(DPTabButton *)button AtIndex:(NSUInteger)index;
@end

@protocol DPTabViewDelegate <NSObject>
- (BOOL)tabView:(DPTabView *)tabView selected:(NSUInteger)index oldIndex:(NSUInteger)oldIndex manual:(BOOL)manual;
@end

@interface DPTabView : UIView
@property (nonatomic, strong, readonly) NSMutableArray *btns;
@property (nonatomic) NSUInteger numOfTabs;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) BOOL barWidthByTitle;
@property (nonatomic) BOOL needFullParentWidth;
@property (nonatomic) BOOL noBar;
@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic, weak) id<DPTabViewDataSource>dataSource;
@property (nonatomic, weak) id<DPTabViewDelegate>delegate;

- (void)setBarPosition:(CGFloat)position;

- (void)reloadData;
@end
