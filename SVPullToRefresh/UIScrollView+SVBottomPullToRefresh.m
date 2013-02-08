//
// UIScrollView+SVPullToRefresh.m
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import "UIScrollView+SVBottomPullToRefresh.h"
#import <objc/runtime.h>

static char UIScrollViewBottomPullToRefreshControl;

@implementation UIScrollView (SVBottomPullToRefresh)

@dynamic bottomPullToRefreshControl, showsBottomPullToRefresh;

- (void)addBottomPullToRefreshWithActionHandler:(PullToRefreshActionHandler)actionHandler pullToRefreshView:(UIView <SVPullToRefreshViewProtocol> *)pullToRefreshView {
    if(!self.bottomPullToRefreshControl) {
        SVBottomPullToRefreshControl *control = pullToRefreshView ?
                [[SVBottomPullToRefreshControl alloc] initWithScrollView:self pullToRefreshView:pullToRefreshView actionHandler:actionHandler] :
                [[SVBottomPullToRefreshControl alloc] initWithScrollView:self actionHandler:actionHandler];

        self.bottomPullToRefreshControl = control;
        self.showsBottomPullToRefresh = YES;
    }
}

- (void)setBottomPullToRefreshControl:(SVBottomPullToRefreshControl *)bottomPullToRefreshControl {
    objc_setAssociatedObject(self, &UIScrollViewBottomPullToRefreshControl,
                             bottomPullToRefreshControl,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SVBottomPullToRefreshControl *)bottomPullToRefreshControl {
    return objc_getAssociatedObject(self, &UIScrollViewBottomPullToRefreshControl);
}

- (void)setShowsBottomPullToRefresh:(BOOL)showsBottomPullToRefresh {
    self.bottomPullToRefreshControl.hidden = !showsBottomPullToRefresh;
    
    if(!showsBottomPullToRefresh) {
        [self stopObservingBottomPullToRefresh];
    }
    else {
        [self startObservingBottomPullToRefresh];
    }
}

- (void)startObservingBottomPullToRefresh {
    if (!self.bottomPullToRefreshControl.observing) {
        [self addObserver:self.bottomPullToRefreshControl forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self.bottomPullToRefreshControl forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self.bottomPullToRefreshControl forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        self.bottomPullToRefreshControl.observing = YES;
    }
}

- (void)stopObservingBottomPullToRefresh {
    if (self.bottomPullToRefreshControl.observing) {
        [self removeObserver:self.bottomPullToRefreshControl forKeyPath:@"contentOffset"];
        [self removeObserver:self.bottomPullToRefreshControl forKeyPath:@"contentSize"];
        [self removeObserver:self.bottomPullToRefreshControl forKeyPath:@"frame"];
        self.bottomPullToRefreshControl.observing = NO;
    }
}

- (BOOL)showsBottomPullToRefresh {
    return self.bottomPullToRefreshControl && !self.bottomPullToRefreshControl.hidden;
}

- (void)removeBottomPullToRefresh {
    [self stopObservingBottomPullToRefresh];
    self.bottomPullToRefreshControl = nil;
}

- (void)updateBottomPullToRefresh {
    [self.bottomPullToRefreshControl updateCurrentState];
}

@end
