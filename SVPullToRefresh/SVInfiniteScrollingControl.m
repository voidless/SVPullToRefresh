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
    CGFloat originalBottomInset;
    CGFloat viewHeight;
    InfiniteScrollingActionHandler actionHandler;
}
@synthesize observing;
@synthesize hidden;
@synthesize state;
@synthesize infiniteScrollingView;

- (id)initWithScrollView:(UIScrollView *)_scrollView infiniteScrollingView:(UIView <SVInfiniteScrollingViewProtocol> *)_infiniteScrollingView actionHandler:(InfiniteScrollingActionHandler)_handler {
    if (self = [super init]) {
        scrollView = _scrollView;
        originalBottomInset = _scrollView.contentInset.bottom;
        state = SVInfiniteScrollingStateStopped;
        actionHandler = _handler;

        self.infiniteScrollingView = _infiniteScrollingView;
    }

    return self;
}

- (id)initWithScrollView:(UIScrollView *)_scrollView actionHandler:(InfiniteScrollingActionHandler)_handler {
    UIView <SVInfiniteScrollingViewProtocol> *defaultView = [[SVInfiniteScrollingDefaultView alloc] initWithWidth:_scrollView.bounds.size.width];
    return [self initWithScrollView:_scrollView infiniteScrollingView:defaultView actionHandler:_handler];
}

- (void)loadingCompleted {
    self.state = SVInfiniteScrollingStateStopped;
}

#pragma mark Setters

- (void)setHidden:(BOOL)_hidden {
    hidden = _hidden;
    infiniteScrollingView.hidden = _hidden;
    if (hidden) {
        self.state = SVInfiniteScrollingStateStopped;
        [self resetScrollViewContentInset];
    } else {
        [self setScrollViewContentInsetForInfiniteScrolling];
        [self updateInfiniteScrollingViewFrame];
    }
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
    viewHeight = infiniteScrollingView.bounds.size.height;
    [self updateInfiniteScrollingViewFrame];
    [scrollView addSubview:infiniteScrollingView];
    infiniteScrollingView.state = self.state;
    infiniteScrollingView.hidden = self.hidden;

    if (!self.hidden)
        [self setScrollViewContentInsetForInfiniteScrolling];
}

#pragma mark Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom = originalBottomInset;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForInfiniteScrolling {
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom = originalBottomInset + viewHeight;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
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
    if ([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    else if ([keyPath isEqualToString:@"frame"]) {
        [infiniteScrollingView layoutSubviews];
        [self updateInfiniteScrollingViewFrame];
    }
    else if([keyPath isEqualToString:@"contentSize"]) {
        [infiniteScrollingView layoutSubviews];
        [self updateInfiniteScrollingViewFrame];
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if (self.state != SVInfiniteScrollingStateLoading) {
        CGFloat scrollViewContentHeight = scrollView.contentSize.height;
        CGFloat scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.size.height;

        if (!scrollView.isDragging && self.state == SVInfiniteScrollingStateTriggered && !scrollView.isDragging)
            self.state = SVInfiniteScrollingStateLoading;
        else if (contentOffset.y > scrollOffsetThreshold && self.state == SVInfiniteScrollingStateStopped && scrollView.isDecelerating)
            self.state = SVInfiniteScrollingStateTriggered;
        else if (contentOffset.y < scrollOffsetThreshold && self.state != SVInfiniteScrollingStateStopped)
            self.state = SVInfiniteScrollingStateStopped;
    }
}

- (void)updateInfiniteScrollingViewFrame {
    infiniteScrollingView.frame = CGRectMake(0, scrollView.contentSize.height, infiniteScrollingView.bounds.size.width, viewHeight);
}

@end
