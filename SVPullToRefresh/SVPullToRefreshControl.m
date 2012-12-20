#import "SVPullToRefreshControl.h"
#import "SVPullToRefresh.h"
#import "SVPullToRefreshDefaultView.h"

#define CHANGE_CONTENT_INSET_ANIM_DURATION 0.3

@interface SVPullToRefreshControl ()
@property (nonatomic, assign) SVPullToRefreshState state;
@end

@implementation SVPullToRefreshControl {
    __weak UIScrollView *scrollView;
    CGFloat originalTopInset;
    CGFloat viewHeight;
    ActionHandler actionHandler;
}
@synthesize observing;
@synthesize hidden;
@synthesize state;
@synthesize pullToRefreshView;

- (id)initWithScrollView:(UIScrollView *)_scrollView pullToRefreshView:(UIView <SVPullToRefreshViewProtocol> *)_pullToRefreshView actionHandler:(ActionHandler)_handler {
    if (self = [super init]) {
        scrollView = _scrollView;
        originalTopInset = _scrollView.contentInset.top;
        state = SVPullToRefreshStateStopped;
        actionHandler = _handler;

        self.pullToRefreshView = _pullToRefreshView;
    }

    return self;
}

- (id)initWithScrollView:(UIScrollView *)_scrollView actionHandler:(ActionHandler)_handler {
    UIView <SVPullToRefreshViewProtocol> *defaultView = [[SVPullToRefreshDefaultView alloc] initWithWidth:_scrollView.bounds.size.width];
    return [self initWithScrollView:_scrollView pullToRefreshView:defaultView actionHandler:_handler];
}

- (void)loadingCompleted {
    self.state = SVPullToRefreshStateStopped;
}

#pragma mark Setters

- (void)setHidden:(BOOL)_hidden {
    hidden = _hidden;
    self.state = SVPullToRefreshStateStopped;
}

- (void)setState:(SVPullToRefreshState)newState {
    if (state == newState)
        return;

    SVPullToRefreshState previousState = state;
    state = newState;

    switch (newState) {
        case SVPullToRefreshStateStopped:
            [self resetScrollViewContentInset];
            break;

        case SVPullToRefreshStateTriggered:
            break;

        case SVPullToRefreshStateLoading:
            [self setScrollViewContentInsetForLoading];

            if (previousState == SVPullToRefreshStateTriggered && actionHandler)
                actionHandler();

            break;

        default:
            break;
    }

    pullToRefreshView.state = state;
}

- (void)setPullToRefreshView:(UIView <SVPullToRefreshViewProtocol> *)_pullToRefreshView {
    [pullToRefreshView removeFromSuperview];
    pullToRefreshView = _pullToRefreshView;
    viewHeight = pullToRefreshView.bounds.size.height;
    pullToRefreshView.frame = CGRectMake(0, -viewHeight, _pullToRefreshView.bounds.size.width, viewHeight);
    [scrollView addSubview:pullToRefreshView];
    pullToRefreshView.state = self.state;
}

#pragma mark Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.top = originalTopInset;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForLoading {
    CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.top = MIN(offset, originalTopInset + viewHeight);
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:CHANGE_CONTENT_INSET_ANIM_DURATION delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         scrollView.contentInset = contentInset;
                     }
                     completion:NULL];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    else if ([keyPath isEqualToString:@"frame"])
        [pullToRefreshView layoutSubviews];
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if (self.state != SVPullToRefreshStateLoading) {
        CGFloat scrollOffsetThreshold = pullToRefreshView.frame.origin.y - originalTopInset;

        if (!scrollView.isDragging && self.state == SVPullToRefreshStateTriggered)
            self.state = SVPullToRefreshStateLoading;
        else if (contentOffset.y < scrollOffsetThreshold && scrollView.isDragging && self.state == SVPullToRefreshStateStopped)
            self.state = SVPullToRefreshStateTriggered;
        else if (contentOffset.y >= scrollOffsetThreshold && self.state != SVPullToRefreshStateStopped)
            self.state = SVPullToRefreshStateStopped;
    } else {
        if (scrollView.contentOffset.y >= -originalTopInset) {
            [self resetScrollViewContentInset];
        } else {
            [self setScrollViewContentInsetForLoading];
        }
    }
}

@end
