#import <Foundation/Foundation.h>

@protocol SVPullToRefreshViewProtocol;

typedef void (^ActionHandler)(void);

@interface SVPullToRefreshControl : NSObject

@property (nonatomic, assign) BOOL observing;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, strong) UIView <SVPullToRefreshViewProtocol> *pullToRefreshView;

- (id)initWithScrollView:(UIScrollView *)scrollView pullToRefreshView:(UIView <SVPullToRefreshViewProtocol> *)pullToRefreshView actionHandler:(ActionHandler)handler;
- (id)initWithScrollView:(UIScrollView *)scrollView actionHandler:(ActionHandler)handler;

- (void)loadingCompleted;

@end