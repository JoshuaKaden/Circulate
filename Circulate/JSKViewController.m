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
CGFloat const kAnimationSpeed = 0.4;
CGFloat const kDrawSpeed = 0.01;

typedef enum {
    JSKMenuButtonLabels,
    JSKMenuButtonAbout,
    JSKMenuButtonAnimate,
    JSKMenuButton_MaxValue
} JSKMenuButton;

@interface JSKViewController () {
    UIView *_framingView;
    UIView *_boundingView;
    JSKCirculatoryView *_circulatoryView;
    UIButton *_startButton;
    UIView *_menuView;
    UIView *_translucentView;
    UIView *_aboutView;
}

- (void)animateForLoad;
- (void)startButtonTapped:(id)sender;
- (void)menuViewButtonTouched:(UIButton *)sender;

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
        UIView *t_view = [[UIView alloc] initWithFrame:CGRectMake(5.0, 20.0, _framingView.bounds.size.width - 10.0, _framingView.bounds.size.height - 10.0)];
        t_view.backgroundColor = _framingView.backgroundColor;
        [_framingView addSubview:t_view];
        t_view;
    });
    
    _circulatoryView = ({
        JSKCirculatoryView *t_view = [[JSKCirculatoryView alloc] initWithFrame:_boundingView.bounds];
        t_view.backgroundColor = _boundingView.backgroundColor;
        [_boundingView addSubview:t_view];
        t_view;
    });
    
    _translucentView = ({
        UIView *t_view = [[UIView alloc] initWithFrame:_framingView.bounds];
        t_view.backgroundColor = [UIColor grayColor];
        t_view.alpha = 0.0;
        [_framingView addSubview:t_view];
        t_view;
    });
    
    _aboutView = ({
        UIView *t_view = [[UIView alloc] initWithFrame:_framingView.bounds];
        t_view.backgroundColor = [UIColor lightGrayColor];
        t_view.layer.borderWidth = 1.0;
        t_view.layer.cornerRadius = 10.0;
        t_view.clipsToBounds = YES;
        t_view.alpha = 0.0;
        [_framingView addSubview:t_view];
        t_view;
    });
    
    _startButton = ({
        UIButton *t_button = [UIButton buttonWithType:UIButtonTypeCustom];
        t_button.frame = _framingView.bounds;
        [t_button addTarget:self action:@selector(startButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_framingView addSubview:t_button];
        t_button;
    });
    
    _menuView = ({
        UIFont *t_font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:26];
        CGSize t_buttonSize = CGSizeMake(150.0, 45.0);
        UIView *t_view = [[UIView alloc] initWithFrame:CGRectMake(_framingView.bounds.size.width - 180, 22, t_buttonSize.width, t_buttonSize.height * 3)];
        
        UIButton *t_menuButton = ({
            UIButton *t_button = [UIButton buttonWithType:UIButtonTypeCustom];
            [t_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            t_button.titleLabel.font = t_font;
            t_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            t_button.frame = CGRectMake(0.0, 0.0, t_buttonSize.width, t_buttonSize.height);
            [t_button addTarget:self action:@selector(menuViewButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            t_button.tag = JSKMenuButtonLabels;
            [t_button setTitle:NSLocalizedString(@"Labels", @"Labels") forState:UIControlStateNormal];
            [t_view addSubview:t_button];
            t_button;
        });
        
        t_menuButton = ({
            UIButton *t_button = [UIButton buttonWithType:UIButtonTypeCustom];
            [t_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            t_button.titleLabel.font = t_font;
            t_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            t_button.frame = CGRectMake(0.0, 40.0, t_buttonSize.width, t_buttonSize.height);
            [t_button addTarget:self action:@selector(menuViewButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            t_button.tag = JSKMenuButtonAnimate;
            [t_button setTitle:NSLocalizedString(@"Animate", @"Animate") forState:UIControlStateNormal];
            [t_view addSubview:t_button];
            t_button;
        });

        t_menuButton = ({
            UIButton *t_button = [UIButton buttonWithType:UIButtonTypeCustom];
            [t_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            t_button.titleLabel.font = t_font;
            t_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            t_button.frame = CGRectMake(0.0, 80.0, t_buttonSize.width, t_buttonSize.height);
            [t_button addTarget:self action:@selector(menuViewButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            t_button.tag = JSKMenuButtonAbout;
            [t_button setTitle:NSLocalizedString(@"About", @"About") forState:UIControlStateNormal];
            [t_view addSubview:t_button];
            t_button;
        });

        t_view.alpha = 0.0;
        [_framingView addSubview:t_view];
        t_view;
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
    [UIView animateWithDuration:0.5 animations:^{
        if (_aboutView.alpha == 1.0) {
            _aboutView.alpha = 0.0;
        }
        else if (_menuView.alpha == 0.0) {
            _menuView.alpha = 1.0;
            _translucentView.alpha = 0.8;
        }
        else {
            _menuView.alpha = 0.0;
            _translucentView.alpha = 0.0;
        }
    }];
}

- (void)menuViewButtonTouched:(UIButton *)sender
{
    JSKMenuButton t_type = (JSKMenuButton)sender.tag;
    
    [UIView animateWithDuration:0.2 animations:^ {
        _menuView.alpha = 0.0;
        _translucentView.alpha = 0.0;
    } completion:^(BOOL finished){
        
        [UIView animateWithDuration:0.5 animations:^{
            switch (t_type) {
                case JSKMenuButtonAbout:
                    _aboutView.alpha = 1.0;
                    break;
                case JSKMenuButtonLabels:
                    _circulatoryView.labelsHidden = !_circulatoryView.labelsHidden;
                    break;
                case JSKMenuButtonAnimate:
                    if (_circulatoryView.isAnimating)
                        [_circulatoryView stopAnimating];
                    else
                        [_circulatoryView startAnimating];
                    break;
                case JSKMenuButton_MaxValue:
                    break;
            }
        }];
    }];
}

@end
