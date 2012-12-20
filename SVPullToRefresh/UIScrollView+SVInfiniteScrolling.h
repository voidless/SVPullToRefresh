//
// UIScrollView+SVInfiniteScrolling.h
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <UIKit/UIKit.h>
#import "SVInfiniteScrollingControl.h"

typedef enum {
	SVInfiniteScrollingStateStopped = 0,
    SVInfiniteScrollingStateTriggered,
    SVInfiniteScrollingStateLoading,
    SVInfiniteScrollingStateAll = 10
} SVInfiniteScrollingState;

@class SVInfiniteScrollingControl;

@interface UIScrollView (SVInfiniteScrolling)

- (void)addInfiniteScrollingWithActionHandler:(InfiniteScrollingActionHandler)actionHandler infiniteScrollingView:(UIView <SVInfiniteScrollingViewProtocol> *)infiniteScrollingView;
- (void)removeInfiniteScrolling;


@property (nonatomic, strong, readonly) SVInfiniteScrollingControl *infiniteScrollingControl;
@property (nonatomic, assign) BOOL showsInfiniteScrolling;

@end