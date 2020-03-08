//
//  DPTabManager.m
//  dapai
//
//  Created by ChenGuosheng on 15/6/6.
//  Copyright (c) 2015年 TalkWork. All rights reserved.
//

#import "DPTabManager.h"
#import "UIView+DPAdditions.h"
#import "UIViewController+DPAdditions.h"

@interface DPTabManager() <UIScrollViewDelegate,
                           DPTabViewDataSource,
                           DPTabViewDelegate>
@property (nonatomic, strong) DPTabView *tabView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) id<DPTabManagerDataSource> dataSource;
@end

@implementation DPTabManager
- (instancetype)initWithTabView:(DPTabView *)tabView scrollView:(UIScrollView *)scrollView dataSource:(id<DPTabManagerDataSource>)dataSource
{
    if (self = [super init]) {
        self.tabView = tabView;
        self.scrollView = scrollView;
        self.dataSource = dataSource;

        tabView.dataSource = self;
        tabView.delegate = self;
        tabView.numOfTabs = tabView.numOfTabs;

        scrollView.pagingEnabled = YES;
        scrollView.contentSize = CGSizeMake(scrollView.width * tabView.numOfTabs, scrollView.height);
        scrollView.bounces = NO;
        scrollView.delegate = self;
        
        [scrollView addObserver: self forKeyPath: @"frame" options: NSKeyValueObservingOptionNew context: nil];
        [tabView addObserver: self forKeyPath: @"numOfTabs" options: NSKeyValueObservingOptionNew context: nil];
    }
    return self;
}

- (void)dealloc
{
    [self.tabView removeObserver: self forKeyPath: @"numOfTabs"];
    [self.scrollView removeObserver: self forKeyPath: @"frame"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat page = (scrollView.contentOffset.x / scrollView.width);
    NSInteger pageInt = floor(page);
    if (fabs(page - pageInt) < 0.01) {
        [self.tabView setSelectedIndex: pageInt];
    } else {
        [self.tabView setBarPosition: page];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.tabView) {
        if ([keyPath isEqualToString: @"numOfTabs"]) {
            NSUInteger numOfTabs = [[change objectForKey: NSKeyValueChangeNewKey] unsignedIntegerValue];
            self.scrollView.contentSize = CGSizeMake(self.scrollView.width * numOfTabs, self.scrollView.height);
        }
    } else if (object == self.scrollView) {
        if ([keyPath isEqualToString: @"frame"]) {
            CGRect newFrame = [[change objectForKey: NSKeyValueChangeNewKey] CGRectValue];
            CGSize size = self.scrollView.contentSize;
            size.height = newFrame.size.height;
            self.scrollView.contentSize = size;
        }
    }
}

- (void)tabView:(DPTabView *)tabView configureButton:(DPTabButton *)button AtIndex:(NSUInteger)index
{
    if (!self.dataSource) {
        return;
    }
    if ([self.dataSource respondsToSelector: @selector(tabManager:fontForState:atIndex:)]) {
        button.titleLabel.font = [self.dataSource tabManager: self fontForState: UIControlStateNormal atIndex: index];
    }
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitleColor: [self.dataSource tabManager: self titleColorForState: UIControlStateNormal atIndex: index] forState: UIControlStateNormal];
    [button setTitleColor: [self.dataSource tabManager: self titleColorForState: UIControlStateSelected atIndex: index] forState: UIControlStateSelected];
    
    id string = [self.dataSource tabManager: self titleForState: UIControlStateNormal atIndex: index];
    if ([string isKindOfClass: [NSString class]]) {
        [button setTitle: string forState:UIControlStateNormal];
    } else if ([string isKindOfClass: [NSAttributedString class]]){
        [button setAttributedTitle: string forState: UIControlStateNormal];
    }
    string = [self.dataSource tabManager: self titleForState: UIControlStateSelected atIndex: index];
    if ([string isKindOfClass: [NSString class]]) {
        [button setTitle: string forState:UIControlStateSelected];
    } else if ([string isKindOfClass: [NSAttributedString class]]){
        [button setAttributedTitle: string forState: UIControlStateSelected];
    }
}

- (BOOL)tabView:(DPTabView *)tabView selected:(NSUInteger)index oldIndex:(NSUInteger)oldIndex manual:(BOOL)manual
{
    if (!self.dataSource) {
        return YES;
    }
    
    if ([self.dataSource respondsToSelector: @selector(tabManager:fontForState:atIndex:)]) {
        DPTabButton *oldTab = [tabView.btns objectAtIndex: oldIndex];
        DPTabButton *newTab = [tabView.btns objectAtIndex: index];
        oldTab.titleLabel.font = [self.dataSource tabManager: self fontForState: UIControlStateNormal atIndex: oldIndex];
        newTab.titleLabel.font = [self.dataSource tabManager: self fontForState: UIControlStateSelected atIndex: index];
    }

    UIViewController *oldController = [self.dataSource tabManager: self controllerAtIndex: oldIndex];
    [self controller: oldController firstScrollViewScrollsToTop: NO recurring: NO];

    UIViewController *controller = [self.dataSource tabManager: self controllerAtIndex: index];
    [self controller: controller firstScrollViewScrollsToTop: YES recurring: NO];
    if (controller.view.superview != self.scrollView) {
        controller.view.frame = CGRectMake(self.scrollView.width * index, 0.0, self.scrollView.width, self.scrollView.height);
        [self.scrollView addSubview: controller.view];
    }
    
//    NSLog(@"暂时忽略 DPTabManager.m L126");
//    [DPUtil hideKeyBoard];
    
    if (oldIndex != index) {
        [controller viewWillAppear: YES];
        
        if ([self.dataSource respondsToSelector: @selector(tabManager:scrollTo:)]) {
            [self.dataSource tabManager: self scrollTo: index];
        }
    }

    if (manual) {
        if (oldIndex == -1) {
            [self.scrollView setContentOffset: CGPointMake(self.scrollView.width * index - 1, 0.0) animated: NO];
        }
        [self.scrollView setContentOffset: CGPointMake(self.scrollView.width * index, 0.0) animated: YES];
        return NO;
    }
    
    return YES;
}

- (void)controller:(UIViewController *)controller firstScrollViewScrollsToTop:(BOOL)scrollsToTop recurring:(BOOL)recurring
{
    if (!recurring) {
        [controller.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass: [UIScrollView class]]) {
                [(UIScrollView *)obj setScrollsToTop: controller.forceScrollsToTop ? (controller.forceScrollsToTop == 1 ? NO : YES) : scrollsToTop];
                *stop = YES;
            }
        }];
    } else {
        [controller.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass: [UIScrollView class]]) {
                UIScrollView *c = (UIScrollView *)obj;
                [c setScrollsToTop: controller.forceScrollsToTop ? (controller.forceScrollsToTop == 1 ? NO : YES) : scrollsToTop];
                [c.subviews enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop) {
                    if ([subView isKindOfClass: [UICollectionView class]] || [subView isKindOfClass: [UITableView class]]) {
                        return;
                    }

                    [subView.subviews enumerateObjectsUsingBlock:^(id sobj, NSUInteger idx, BOOL *stop) {
                        if ([sobj isKindOfClass: [UIScrollView class]]) {
                            [(UIScrollView *)sobj setScrollsToTop: scrollsToTop];
                        }
                    }];
                }];
                *stop = YES;
            }
        }];
    }
}


@end
