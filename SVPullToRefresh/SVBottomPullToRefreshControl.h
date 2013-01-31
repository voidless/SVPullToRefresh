#import <Foundation/Foundation.h>
#import "SVPullToRefreshControl.h"

@protocol SVPullToRefreshViewProtocol;

@interface SVBottomPullToRefreshControl : NSObject

@property (nonatomic, assign) BOOL observing;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) CGFloat bottomInset;
@property (nonatomic, strong) UIView <SVPullToRefreshViewProtocol> *pullToRefreshView;
@property (nonatomic, assign) BOOL nowLoading;

- (id)initWithScrollView:(UIScrollView *)scrollView pullToRefreshView:(UIView <SVPullToRefreshViewProtocol> *)pullToRefreshView actionHandler:(PullToRefreshActionHandler)handler;
- (id)initWithScrollView:(UIScrollView *)scrollView actionHandler:(PullToRefreshActionHandler)handler;

- (void)loadingCompleted;
- (void)updateCurrentState;

@end