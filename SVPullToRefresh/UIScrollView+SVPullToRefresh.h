//
// UIScrollView+SVPullToRefresh.h
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>
#import "SVPullToRefreshControl.h"

typedef enum {
    SVPullToRefreshStateStopped = 0,
    SVPullToRefreshStateTriggered,
    SVPullToRefreshStateLoading,
    SVPullToRefreshStateAll = 10
} SVPullToRefreshState;

@class SVPullToRefreshControl;

@interface UIScrollView (SVPullToRefresh)

- (void)addPullToRefreshWithActionHandler:(ActionHandler)actionHandler pullToRefreshView:(UIView <SVPullToRefreshViewProtocol> *)pullToRefreshView;

@property (nonatomic, strong, readonly) SVPullToRefreshControl *pullToRefreshControl;
@property (nonatomic, assign) BOOL showsPullToRefresh;


@end
