//
//  DPTabButton.m
//  dapai
//
//  Created by ChenGuosheng on 15/5/1.
//  Copyright (c) 2015年 TalkWork. All rights reserved.
//

#import "DPTabButton.h"

@implementation DPTabButton

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        self.titleLabel.numberOfLines = 0;
    }
    return self;
}

@end
