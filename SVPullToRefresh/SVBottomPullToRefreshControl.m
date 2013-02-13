#import "SVBottomPullToRefreshControl.h"
#import "SVPullToRefreshDefaultView.h"

#define CHANGE_CONTENT_INSET_ANIM_DURATION 0.3

@interface SVBottomPullToRefreshControl ()
@property (nonatomic, assign) SVPullToRefreshState state;
@end

@implementation SVBottomPullToRefreshControl {
    __weak UIScrollView *scrollView;
    CGFloat localBottomInset;
    CGFloat viewHeight;
    PullToRefreshActionHandler actionHandler;
}
@synthesize observing;
@synthesize hidden;
@synthesize state;
@synthesize pullToRefreshView;
@synthesize bottomInset;
@synthesize nowLoading;

- (id)initWithScrollView:(UIScrollView *)_scrollView pullToRefreshView:(UIView <SVPullToRefreshViewProtocol> *)_pullToRefreshView actionHandler:(PullToRefreshActionHandler)_handler {
    if (self = [super init]) {
        scrollView = _scrollView;
        state = SVPullToRefreshStateStopped;
        actionHandler = _handler;
        hidden = YES;

        self.pullToRefreshView = _pullToRefreshView;
    }

    return self;
}

- (id)initWithScrollView:(UIScrollView *)_scrollView actionHandler:(PullToRefreshActionHandler)_handler {
    UIView <SVPullToRefreshViewProtocol> *defaultView = [[SVPullToRefreshDefaultView alloc] initWithWidth:_scrollView.bounds.size.width];
    return [self initWithScrollView:_scrollView pullToRefreshView:defaultView actionHandler:_handler];
}

- (void)dealloc {
    [self.pullToRefreshView removeFromSuperview];
}

- (void)loadingCompleted {
    self.state = SVPullToRefreshStateStopped;
}

#pragma mark Force updates

- (void)updateCurrentState {
    [self scrollViewDidScroll:scrollView.contentOffset];
}

#pragma mark Setters

- (void)setHidden:(BOOL)_hidden {
    hidden = _hidden;
    pullToRefreshView.hidden = hidden;
    if (hidden)
        self.state = SVPullToRefreshStateStopped;
}

- (void)setState:(SVPullToRefreshState)newState {
    if (state == newState)
        return;

    SVPullToRefreshState previousState = state;
    state = newState;

    switch (newState) {
        case SVPullToRefreshStateStopped:
            nowLoading = NO;
            [self resetScrollViewContentInset:YES];
            break;

        case SVPullToRefreshStateTriggered:
            nowLoading = NO;
            break;

        case SVPullToRefreshStateLoading:
            nowLoading = YES;
            [self setScrollViewContentInsetForLoading:YES];

            if (previousState == SVPullToRefreshStateTriggered && actionHandler)
                actionHandler();

            break;

        default:
            nowLoading = NO;
            break;
    }

    pullToRefreshView.state = state;
}

- (void)setPullToRefreshView:(UIView <SVPullToRefreshViewProtocol> *)_pullToRefreshView {
    [pullToRefreshView removeFromSuperview];
    pullToRefreshView = _pullToRefreshView;
    pullToRefreshView.autoresizingMask = UIViewAutoresizingNone;
    viewHeight = pullToRefreshView.bounds.size.height;
    [self updatePullToRefreshViewFrame];
    [scrollView addSubview:pullToRefreshView];
    pullToRefreshView.state = self.state;

    if (!self.hidden && self.state == SVPullToRefreshStateLoading)
        [self setScrollViewContentInsetForLoading:NO];
}

- (void)setBottomInset:(CGFloat)newBottomInset {
    bottomInset = newBottomInset;
    [self updatePullToRefreshViewFrame];
}

- (void)updatePullToRefreshViewFrame {
    pullToRefreshView.frame = CGRectMake(0, scrollView.contentSize.height - bottomInset, CGRectGetWidth(scrollView.bounds), viewHeight);
}

#pragma mark Scroll View

- (void)resetScrollViewContentInset:(BOOL)animated {
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom -= localBottomInset;
    localBottomInset = 0;
    [self setScrollViewContentInset:currentInsets animated:animated];
}

- (void)setScrollViewContentInsetForLoading:(BOOL)animated {
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom -= localBottomInset;
    localBottomInset = viewHeight;
    currentInsets.bottom += localBottomInset;
    [self setScrollViewContentInset:currentInsets animated:animated];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset animated:(BOOL)animated {
    if (!animated) {
        scrollView.contentInset = contentInset;
        return;
    }

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
    else if ([keyPath isEqualToString:@"frame"]) {
        [pullToRefreshView layoutSubviews];
        [self updatePullToRefreshViewFrame];
    }
    else if ([keyPath isEqualToString:@"contentSize"])
        [self updatePullToRefreshViewFrame];
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if (self.state != SVPullToRefreshStateLoading) {
        CGFloat scrollOffsetThreshold = pullToRefreshView.frame.size.height + scrollView.contentSize.height - (scrollView.bounds.size.height - scrollView.contentInset.bottom + localBottomInset);

        if (!scrollView.isDragging && self.state == SVPullToRefreshStateTriggered)
            self.state = SVPullToRefreshStateLoading;
        else if (contentOffset.y > scrollOffsetThreshold && scrollView.isDragging && self.state == SVPullToRefreshStateStopped)
            self.state = SVPullToRefreshStateTriggered;
        else if (contentOffset.y <= scrollOffsetThreshold && self.state != SVPullToRefreshStateStopped)
            self.state = SVPullToRefreshStateStopped;
    }
}

@end
