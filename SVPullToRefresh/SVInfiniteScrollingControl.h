#import <Foundation/Foundation.h>

@protocol SVInfiniteScrollingViewProtocol;

typedef void (^InfiniteScrollingActionHandler)(void);

@interface SVInfiniteScrollingControl : NSObject

@property (nonatomic, assign) BOOL observing;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, strong) UIView <SVInfiniteScrollingViewProtocol> *infiniteScrollingView;

- (id)initWithScrollView:(UIScrollView *)scrollView infiniteScrollingView:(UIView <SVInfiniteScrollingViewProtocol> *)infiniteScrollingView actionHandler:(InfiniteScrollingActionHandler)handler;
- (id)initWithScrollView:(UIScrollView *)scrollView actionHandler:(InfiniteScrollingActionHandler)handler;

- (void)loadingCompleted;
- (void)updateCurrentState;

@end