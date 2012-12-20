#import <Foundation/Foundation.h>

@protocol SVPullToRefreshViewProtocol;

typedef void (^PullToRefreshActionHandler)(void);

@interface SVPullToRefreshControl : NSObject

@property (nonatomic, assign) BOOL observing;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, strong) UIView <SVPullToRefreshViewProtocol> *pullToRefreshView;

- (id)initWithScrollView:(UIScrollView *)scrollView pullToRefreshView:(UIView <SVPullToRefreshViewProtocol> *)pullToRefreshView actionHandler:(PullToRefreshActionHandler)handler;
- (id)initWithScrollView:(UIScrollView *)scrollView actionHandler:(PullToRefreshActionHandler)handler;

- (void)loadingCompleted;

@end