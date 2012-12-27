//
// UIScrollView+SVInfiniteScrolling.m
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVInfiniteScrolling
//

#import "UIScrollView+SVInfiniteScrolling.h"
#import "SVInfiniteScrollingControl.h"
#import <objc/runtime.h>

static char UIScrollViewInfiniteScrollingControl;

@implementation UIScrollView (SVInfiniteScrolling)

@dynamic infiniteScrollingControl, showsInfiniteScrolling;

- (void)addInfiniteScrollingWithActionHandler:(InfiniteScrollingActionHandler)actionHandler infiniteScrollingView:(UIView <SVInfiniteScrollingViewProtocol> *)infiniteScrollingView {
    if(!self.infiniteScrollingControl) {
        SVInfiniteScrollingControl *control = infiniteScrollingView ?
                [[SVInfiniteScrollingControl alloc] initWithScrollView:self infiniteScrollingView:infiniteScrollingView actionHandler:actionHandler] :
                [[SVInfiniteScrollingControl alloc] initWithScrollView:self actionHandler:actionHandler];

        self.infiniteScrollingControl = control;
        self.showsInfiniteScrolling = YES;
    }
}

- (void)setInfiniteScrollingControl:(SVInfiniteScrollingControl *)infiniteScrollingControl {
    objc_setAssociatedObject(self, &UIScrollViewInfiniteScrollingControl,
            infiniteScrollingControl,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SVInfiniteScrollingControl *)infiniteScrollingControl {
    return objc_getAssociatedObject(self, &UIScrollViewInfiniteScrollingControl);
}

- (void)setShowsInfiniteScrolling:(BOOL)showsInfiniteScrolling {
    self.infiniteScrollingControl.hidden = !showsInfiniteScrolling;

    if(!showsInfiniteScrolling) {
        [self stopObservingInfiniteScrolling];
    }
    else {
        [self startObservingInfiniteScrolling];
    }
}

- (void)startObservingInfiniteScrolling {
    if (!self.infiniteScrollingControl.observing) {
        [self addObserver:self.infiniteScrollingControl forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self.infiniteScrollingControl forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self.infiniteScrollingControl forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self.infiniteScrollingControl forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        self.infiniteScrollingControl.observing = YES;
    }
}

- (void)stopObservingInfiniteScrolling {
    if (self.infiniteScrollingControl.observing) {
        [self removeObserver:self.infiniteScrollingControl forKeyPath:@"contentInset"];
        [self removeObserver:self.infiniteScrollingControl forKeyPath:@"contentOffset"];
        [self removeObserver:self.infiniteScrollingControl forKeyPath:@"contentSize"];
        [self removeObserver:self.infiniteScrollingControl forKeyPath:@"frame"];
        self.infiniteScrollingControl.observing = NO;
    }
}

- (BOOL)showsInfiniteScrolling {
    return !self.infiniteScrollingControl.hidden;
}

- (void)removeInfiniteScrolling {
    [self stopObservingInfiniteScrolling];
    self.infiniteScrollingControl = nil;
}

- (void)updateInfiniteScrolling {
    [self.infiniteScrollingControl updateCurrentState];
}

@end
