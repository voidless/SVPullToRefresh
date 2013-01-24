#import "SVInfiniteScrollingControl.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "SVInfiniteScrollingView.h"
#import "SVInfiniteScrollingDefaultView.h"

#define CHANGE_CONTENT_INSET_ANIM_DURATION 0.3

@interface SVInfiniteScrollingControl ()
@property (nonatomic, assign) SVInfiniteScrollingState state;
@end

@implementation SVInfiniteScrollingControl {
    __weak UIScrollView *scrollView;
    CGFloat localBottomInset;
    CGFloat viewHeight;
    InfiniteScrollingActionHandler actionHandler;

    BOOL changingContentInset;
    CGFloat fireHeight;
}
@synthesize observing;
@synthesize hidden;
@synthesize state;
@synthesize infiniteScrollingView;

- (id)initWithScrollView:(UIScrollView *)_scrollView infiniteScrollingView:(UIView <SVInfiniteScrollingViewProtocol> *)_infiniteScrollingView actionHandler:(InfiniteScrollingActionHandler)_handler {
    if (self = [super init]) {
        scrollView = _scrollView;
        state = SVInfiniteScrollingStateStopped;
        actionHandler = _handler;
        hidden = YES;

        self.infiniteScrollingView = _infiniteScrollingView;
    }

    return self;
}

- (id)initWithScrollView:(UIScrollView *)_scrollView actionHandler:(InfiniteScrollingActionHandler)_handler {
    UIView <SVInfiniteScrollingViewProtocol> *defaultView = [[SVInfiniteScrollingDefaultView alloc] initWithWidth:_scrollView.bounds.size.width];
    return [self initWithScrollView:_scrollView infiniteScrollingView:defaultView actionHandler:_handler];
}

- (void)dealloc {
    [self.infiniteScrollingView removeFromSuperview];
}

- (void)loadingCompleted {
    self.state = SVInfiniteScrollingStateStopped;
}

#pragma mark Force updates

- (void)updateCurrentState {
    [self scrollViewDidScroll:scrollView.contentOffset force:YES];
}

#pragma mark Setters

- (void)setHidden:(BOOL)_hidden {
    infiniteScrollingView.hidden = _hidden;
    if (_hidden) {
        self.state = SVInfiniteScrollingStateStopped;
        [self resetScrollViewContentInset];
    } else {
        [self setScrollViewContentInsetForInfiniteScrolling];
        [self updateInfiniteScrollingViewFrame];
    }
    hidden = _hidden;
}

- (void)setState:(SVInfiniteScrollingState)newState {
    if (state == newState)
        return;

    SVInfiniteScrollingState previousState = state;
    state = newState;

    switch (newState) {
        case SVInfiniteScrollingStateStopped:
            break;

        case SVInfiniteScrollingStateTriggered:
            break;

        case SVInfiniteScrollingStateLoading:
            if (previousState == SVInfiniteScrollingStateTriggered && actionHandler)
                actionHandler();

            break;

        default:
            break;
    }

    infiniteScrollingView.state = state;
}

- (void)setInfiniteScrollingView:(UIView <SVInfiniteScrollingViewProtocol> *)_infiniteScrollingView {
    [infiniteScrollingView removeFromSuperview];
    infiniteScrollingView = _infiniteScrollingView;
    infiniteScrollingView.autoresizingMask = UIViewAutoresizingNone;
    viewHeight = infiniteScrollingView.bounds.size.height;
    [self updateInfiniteScrollingViewFrame];
    [scrollView addSubview:infiniteScrollingView];
    infiniteScrollingView.state = self.state;
    infiniteScrollingView.hidden = self.hidden;

    if (!self.hidden)
        [self setScrollViewContentInsetForInfiniteScrolling];
}

- (void)setFireHeight:(CGFloat)height {
    fireHeight = height;
    [self scrollViewDidScroll:scrollView.contentOffset force:YES];
}

#pragma mark Scroll View

- (void)resetScrollViewContentInset {
    if (changingContentInset)
        return;

    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom -= localBottomInset;
    localBottomInset = 0;
    changingContentInset = YES;
    [self setScrollViewContentInset:currentInsets animated:YES];
    changingContentInset = NO;
}

- (void)setScrollViewContentInsetForInfiniteScrolling {
    if (changingContentInset)
        return;

    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom -= localBottomInset;
    localBottomInset = viewHeight;
    currentInsets.bottom += localBottomInset;
    changingContentInset = YES;
    [self setScrollViewContentInset:currentInsets animated:NO];
    changingContentInset = NO;
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset animated:(BOOL)animated {
    if (!animated) {
        scrollView.contentInset = contentInset;
        return;
    }

    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         scrollView.contentInset = contentInset;
                     }
                     completion:NULL];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (changingContentInset)
        return;

    if ([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue] force:NO];
    else if ([keyPath isEqualToString:@"frame"]) {
        [infiniteScrollingView layoutSubviews];
        [self updateInfiniteScrollingViewFrame];
        [self scrollViewDidScroll:scrollView.contentOffset force:YES];
    }
    else if([keyPath isEqualToString:@"contentSize"]) {
        [infiniteScrollingView layoutSubviews];
        [self updateInfiniteScrollingViewFrame];
    }
    else if([keyPath isEqualToString:@"contentInset"]) {
        if (!self.hidden) {
            [self setScrollViewContentInsetForInfiniteScrolling];
        } else {
            [self resetScrollViewContentInset];
        }
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset force:(BOOL)force {
    if (self.state != SVInfiniteScrollingStateLoading) {
        CGFloat scrollViewContentHeight = scrollView.contentSize.height;
        CGFloat scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.size.height - fireHeight;

        if (contentOffset.y > scrollOffsetThreshold && self.state == SVInfiniteScrollingStateStopped && (scrollView.isDecelerating || force))
            self.state = SVInfiniteScrollingStateTriggered;

        if (contentOffset.y < scrollOffsetThreshold && self.state != SVInfiniteScrollingStateStopped)
            self.state = SVInfiniteScrollingStateStopped;

        if ((!scrollView.isDragging || force) && self.state == SVInfiniteScrollingStateTriggered)
            self.state = SVInfiniteScrollingStateLoading;
    }
}

- (void)updateInfiniteScrollingViewFrame {
    infiniteScrollingView.frame = CGRectMake(0, scrollView.contentSize.height, infiniteScrollingView.bounds.size.width, viewHeight);
}

@end
