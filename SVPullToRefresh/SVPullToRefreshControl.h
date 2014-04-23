#import <Foundation/Foundation.h>


typedef enum {
    SVPullToRefreshStateStopped = 0,
    SVPullToRefreshStateTriggered,
    SVPullToRefreshStateLoading,
    SVPullToRefreshStateAll = 10
} SVPullToRefreshState;


@protocol SVPullToRefreshViewProtocol;

typedef void (^PullToRefreshActionHandler)(void);

@interface SVPullToRefreshControl : NSObject

@property (nonatomic, assign) BOOL observing;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) SVPullToRefreshState state;
@property (nonatomic, strong) UIView <SVPullToRefreshViewProtocol> *pullToRefreshView;

- (id)initWithScrollView:(UIScrollView *)scrollView pullToRefreshView:(UIView <SVPullToRefreshViewProtocol> *)pullToRefreshView actionHandler:(PullToRefreshActionHandler)handler;
- (id)initWithScrollView:(UIScrollView *)scrollView actionHandler:(PullToRefreshActionHandler)handler;

- (void)loadingCompleted;
- (void)updateCurrentState;

@end