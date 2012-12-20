#import <Foundation/Foundation.h>

@protocol SVInfiniteScrollingViewProtocol;

@interface SVInfiniteScrollingDefaultView : UIView <SVInfiniteScrollingViewProtocol>

@property (nonatomic, readwrite) UIActivityIndicatorViewStyle activityIndicatorViewStyle;

- (id)initWithWidth:(CGFloat)width;

- (void)setCustomView:(UIView *)view forState:(SVInfiniteScrollingState)state;

@end