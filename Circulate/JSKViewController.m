//
//  JSKViewController.m
//  Circulate
//
//  Created by Joshua Kaden on 2/12/14.
//  Copyright (c) 2014 Chadford Software. All rights reserved.
//

#import "JSKViewController.h"
#import "JSKCirculatoryView.h"

CGFloat const kPadding = 47.0;
CGFloat const kPaddingPhone = 10.0;
CGFloat const kAnimationSpeed = 0.5;
CGFloat const kDrawSpeed = 0.004;

@interface JSKViewController () {
    UIView *_framingView;
    UIView *_boundingView;
    JSKCirculatoryView *_circulatoryView;
    UIButton *_startButton;
    NSTimer *_timer;
    BOOL _isDrawing;
    BOOL _shouldPause;
}

- (void)animateForLoad;
- (void)startButtonTapped:(id)sender;
- (void)timerFired:(id)sender;

@end

@implementation JSKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat t_padding = kPadding;
    BOOL t_isPhone = (([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"]) || ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"]));
    if (t_isPhone)
        t_padding = kPaddingPhone;
    
    _framingView = ({
        CGSize t_size = CGSizeMake(self.view.bounds.size.width - (t_padding * 2.0), self.view.bounds.size.height - (t_padding * 2.0));
        CGRect t_frame = CGRectMake(t_padding, t_padding, t_size.width, t_size.height);
        UIView *t_view = [[UIView alloc] initWithFrame:t_frame];
        t_view.backgroundColor = [UIColor darkGrayColor];
        t_view.layer.borderWidth = 1.0;
        t_view.layer.cornerRadius = 10.0;
        t_view.clipsToBounds = YES;
        [self.view addSubview:t_view];
        t_view;
    });
    
    _boundingView = ({
        UIView *t_view = [[UIView alloc] initWithFrame:CGRectMake(5.0, 5.0, _framingView.bounds.size.width - 10.0, _framingView.bounds.size.height - 10.0)];
        t_view.backgroundColor = _framingView.backgroundColor;
        [_framingView addSubview:t_view];
        t_view;
    });
    
    _circulatoryView = ({
        JSKCirculatoryView *t_view = [[JSKCirculatoryView alloc] initWithFrame:_boundingView.bounds];
        t_view.backgroundColor = _boundingView.backgroundColor;
        t_view.pointIndex = 0.0;
        [_boundingView addSubview:t_view];
        t_view;
    });
    
    _startButton = ({
        UIButton *t_button = [UIButton buttonWithType:UIButtonTypeCustom];
        t_button.frame = _boundingView.bounds;
        [t_button addTarget:self action:@selector(startButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_boundingView addSubview:t_button];
        t_button;
    });
    
    [self animateForLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)animateForLoad
{
    UIView *t_view = _framingView;
    CGRect t_frame = t_view.frame;
    
    t_view.frame = CGRectMake(CGRectGetMidX(t_frame), CGRectGetMidY(t_frame), 3.0, 3.0);
    t_view.alpha = 1.0;
    
    [UIView animateWithDuration:kAnimationSpeed animations:^{
        t_view.frame = CGRectMake(CGRectGetMidX(t_frame), CGRectGetMidY(t_frame), 10.0, 10.0);
    } completion:^(BOOL finished){
        
        [UIView animateWithDuration:kAnimationSpeed animations:^{
            t_view.frame = CGRectMake(t_frame.origin.x, t_view.frame.origin.y, t_frame.size.width, 3.0);
        } completion:^(BOOL finished){
            
            [UIView animateWithDuration:kAnimationSpeed animations:^{
                t_view.frame = t_frame;
            } completion:^(BOOL finished){
                
            }];
        }];
    }];
}

- (void)startButtonTapped:(id)sender
{
    if (_isDrawing) {
        _shouldPause = !_shouldPause;
        if (_shouldPause)
            return;
    }
    _isDrawing = YES;
    
    if (_circulatoryView.pointIndex >= _circulatoryView.pointCount - 1)
        _circulatoryView.pointIndex = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:kDrawSpeed target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
}

- (void)timerFired:(id)sender
{
    [_timer invalidate];
    _timer = nil;
    
    if (_shouldPause)
        return;
    
    [UIView animateWithDuration:kAnimationSpeed animations:^{
        _circulatoryView.pointIndex++;
    } completion:^(BOOL finished){
        if (_circulatoryView.pointIndex <= _circulatoryView.pointCount)
            _timer = [NSTimer scheduledTimerWithTimeInterval:kDrawSpeed target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
        else
            _isDrawing = NO;
    }];
}

@end
