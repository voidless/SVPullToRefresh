//
// UIScrollView+SVPullToRefresh.m
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import "UIScrollView+SVPullToRefresh.h"
#import <objc/runtime.h>

static char UIScrollViewPullToRefreshControl;

@implementation UIScrollView (SVPullToRefresh)

@dynamic pullToRefreshControl, showsPullToRefresh;

- (void)addPullToRefreshWithActionHandler:(PullToRefreshActionHandler)actionHandler pullToRefreshView:(UIView <SVPullToRefreshViewProtocol> *)pullToRefreshView {
    if(!self.pullToRefreshControl) {
        SVPullToRefreshControl *control = pullToRefreshView ?
                [[SVPullToRefreshControl alloc] initWithScrollView:self pullToRefreshView:pullToRefreshView actionHandler:actionHandler] :
                [[SVPullToRefreshControl alloc] initWithScrollView:self actionHandler:actionHandler];

        self.pullToRefreshControl = control;
        self.showsPullToRefresh = YES;
    }
}

- (void)setPullToRefreshControl:(SVPullToRefreshControl *)pullToRefreshControl {
    objc_setAssociatedObject(self, &UIScrollViewPullToRefreshControl,
                             pullToRefreshControl,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SVPullToRefreshControl *)pullToRefreshControl {
    return objc_getAssociatedObject(self, &UIScrollViewPullToRefreshControl);
}

- (void)setShowsPullToRefresh:(BOOL)showsPullToRefresh {
    self.pullToRefreshControl.hidden = !showsPullToRefresh;
    
    if(!showsPullToRefresh) {
        [self stopObservingPullToRefresh];
    }
    else {
        [self startObservingPullToRefresh];
    }
}

- (void)startObservingPullToRefresh {
    if (!self.pullToRefreshControl.observing) {
        [self addObserver:self.pullToRefreshControl forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self.pullToRefreshControl forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        self.pullToRefreshControl.observing = YES;
    }
}

- (void)stopObservingPullToRefresh {
    if (self.pullToRefreshControl.observing) {
        [self removeObserver:self.pullToRefreshControl forKeyPath:@"contentOffset"];
        [self removeObserver:self.pullToRefreshControl forKeyPath:@"frame"];
        self.pullToRefreshControl.observing = NO;
    }
}

- (BOOL)showsPullToRefresh {
    return self.pullToRefreshControl && !self.pullToRefreshControl.hidden;
}

- (void)removePullToRefresh {
    [self stopObservingPullToRefresh];
    self.pullToRefreshControl = nil;
}

- (void)updatePullToRefresh {
    [self.pullToRefreshControl updateCurrentState];
}

@end
