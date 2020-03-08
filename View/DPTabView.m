//
//  DPTabView.m
//  dapai
//
//  Created by ChenGuosheng on 15/5/1.
//  Copyright (c) 2015年 TalkWork. All rights reserved.
//

#import "DPTabView.h"
#import "UIView+DPAdditions.h"

@interface DPTabView() {
    NSMutableArray *_btns;
}
//@property (strong, nonatomic) NSMutableArray *btns;
@property (nonatomic, weak) UIView *selectedBar;
@end

@implementation DPTabView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        UIView *selectedBar = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, 0.0, 2.0)];
        selectedBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        selectedBar.backgroundColor = [UIColor colorWithWhite: 45/256 alpha: 1.0];
        [self addSubview: selectedBar];
        self.selectedBar = selectedBar;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    if (self.needFullParentWidth) {
        [super setFrame: CGRectMake(0.0, frame.origin.y, self.superview.frame.size.width, frame.size.height)];
    } else {
        [super setFrame: frame];
    }
}

- (void)setBarColor:(UIColor *)barColor {
    self.selectedBar.backgroundColor = barColor;
}

- (UIColor *)barColor {
    return self.selectedBar.backgroundColor;
}

- (void)setNumOfTabs:(NSUInteger)numOfTabs {
    [self willChangeValueForKey: @"numOfTabs"];
    _numOfTabs = numOfTabs;

    [self setUp];
    [self didChangeValueForKey: @"numOfTabs"];
}

- (void)reloadData {
    [self setNumOfTabs: self.numOfTabs];
}

- (void)setNoBar:(BOOL)noBar {
    _noBar = noBar;
    self.selectedBar.hidden = noBar;
}

- (void)setUp {
    [_btns enumerateObjectsUsingBlock:^(DPTabButton *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    NSMutableArray *btns = [NSMutableArray array];
    _btns = btns;
    CGFloat avgWidth = self.frame.size.width / self.numOfTabs;
    for (NSUInteger i = 0; i < self.numOfTabs; i ++) {
        DPTabButton *btn = [[DPTabButton alloc] initWithFrame: CGRectMake(avgWidth * i, 0.0, avgWidth, self.frame.size.height)];
        btn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [btn addTarget: self action: @selector(clickButton:) forControlEvents: UIControlEventTouchUpInside];
        if (self.dataSource) {
            [self.dataSource tabView: self configureButton: btn AtIndex: i];
        }
        [self.btns addObject: btn];
        [self addSubview: btn];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];

    self.selectedIndex = _selectedIndex;
}

- (void)clickButton:(id)sender
{
    [self setButtonSelected: [self.btns indexOfObject: sender] manual: YES];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setButtonSelected: selectedIndex manual: NO];
}

- (void)setButtonSelected:(NSUInteger)selectedIndex manual:(BOOL)manual
{
    DPTabButton *tabButton = nil;
    for (NSUInteger i = 0; i < self.numOfTabs; i ++) {
        tabButton = [self.btns objectAtIndex: i];
        [tabButton setSelected: selectedIndex == i];
        if (i == 0) {
            tabButton.tag = 101;
        }
    }

    BOOL layoutSelectedBar = YES;
    if (self.delegate) {
        layoutSelectedBar = [self.delegate tabView: self selected: selectedIndex oldIndex: _selectedIndex manual: manual];
    }

    _selectedIndex = selectedIndex;
    
    if (layoutSelectedBar) {
        [self layoutSelectedBar];
    }
}

- (BOOL)barWidthByTitle {
    return YES;
}

- (void)layoutSelectedBar {
    DPTabButton *tabButton = (DPTabButton *)[self.btns objectAtIndex: self.selectedIndex];
    if (tabButton) {
        if (self.barWidthByTitle) {
            CGRect rect = [tabButton.titleLabel convertRect: tabButton.titleLabel.bounds toView: self];
            self.selectedBar.frame = CGRectMake(rect.origin.x, self.height - self.selectedBar.height, rect.size.width, self.selectedBar.height);
        } else {
            CGRect rect = [tabButton convertRect: tabButton.bounds toView: self];
            self.selectedBar.frame = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - self.selectedBar.height, rect.size.width, self.selectedBar.height);
        }
        [self bringSubviewToFront: self.selectedBar];
    } else {
        self.selectedBar.left = - self.selectedBar.width;
    }
}

- (void)setBarPosition:(CGFloat)position {
    NSInteger left = floor(position);
    NSInteger right = ceil(position);
    CGFloat xPercent = position - (CGFloat)left;
    DPTabButton *tabButtonLeft = (DPTabButton *)[self.btns objectAtIndex: left];
    DPTabButton *tabButtonRight = (DPTabButton *)[self.btns objectAtIndex: right];
    if (self.barWidthByTitle) {
        CGRect rectLeft = [tabButtonLeft.titleLabel convertRect: tabButtonLeft.titleLabel.bounds toView: self];
        CGRect rectRight = [tabButtonRight.titleLabel convertRect: tabButtonRight.titleLabel.bounds toView: self];
        self.selectedBar.frame = CGRectMake(rectLeft.origin.x + (rectRight.origin.x - rectLeft.origin.x) * xPercent, self.height - self.selectedBar.height, rectLeft.size.width + (rectRight.size.width - rectLeft.size.width) * xPercent, self.selectedBar.height);
    } else {
        CGRect rectLeft = [tabButtonLeft convertRect: tabButtonLeft.bounds toView: self];
        CGRect rectRight = [tabButtonRight convertRect: tabButtonRight.bounds toView: self];
        self.selectedBar.frame = CGRectMake(rectLeft.origin.x + (rectRight.origin.x - rectLeft.origin.x) * xPercent, rectLeft.origin.y + rectLeft.size.height - self.selectedBar.height, rectLeft.size.width + (rectRight.size.width - rectLeft.size.width) * xPercent, self.selectedBar.height);
    }
}

@end
