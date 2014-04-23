//
// UIScrollView+SVPullToRefresh.h
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <UIKit/UIKit.h>
#import "SVPullToRefreshControl.h"

@class SVPullToRefreshControl;

@interface UIScrollView (SVPullToRefresh)

- (void)addPullToRefreshWithActionHandler:(PullToRefreshActionHandler)actionHandler pullToRefreshView:(UIView <SVPullToRefreshViewProtocol> *)pullToRefreshView;
- (void)removePullToRefresh;
- (void)updatePullToRefresh;

@property (nonatomic, strong, readonly) SVPullToRefreshControl *pullToRefreshControl;
@property (nonatomic, assign) BOOL showsPullToRefresh;

@end
