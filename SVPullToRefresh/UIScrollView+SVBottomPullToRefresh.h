//
// UIScrollView+SVPullToRefresh.h
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <UIKit/UIKit.h>
#import "SVBottomPullToRefreshControl.h"

@class SVBottomPullToRefreshControl;

@interface UIScrollView (SVBottomPullToRefresh)

- (void)addBottomPullToRefreshWithActionHandler:(PullToRefreshActionHandler)actionHandler pullToRefreshView:(UIView <SVPullToRefreshViewProtocol> *)pullToRefreshView;
- (void)removeBottomPullToRefresh;
- (void)updateBottomPullToRefresh;

@property (nonatomic, strong, readonly) SVBottomPullToRefreshControl *bottomPullToRefreshControl;
@property (nonatomic, assign) BOOL showsBottomPullToRefresh;

@end
