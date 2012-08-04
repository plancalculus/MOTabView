//
//  MOTabContentView.m
//  MOTabView
//
//  Created by Jan Christiansen on 6/20/12.
//  Copyright (c) 2012, Monoid - Development and Consulting - Jan Christiansen
//
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above
//  copyright notice, this list of conditions and the following
//  disclaimer in the documentation and/or other materials provided
//  with the distribution.
//
//  * Neither the name of Monoid - Development and Consulting - 
//  Jan Christiansen nor the names of other
//  contributors may be used to endorse or promote products derived
//  from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
//  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
//  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <QuartzCore/QuartzCore.h>
#import "MOTabContentView.h"


static const float kDeselectedScale = 0.6;
static const float kDeselectedTranslation = 20;


@implementation MOTabContentView {

    UIView *_contentView;
    UIView *_overlayView;

    UIButton *_deleteButton;

    BOOL _deletable;
}


@synthesize delegate = _delegate;
@synthesize isSelected = _isSelected;
@synthesize visibility = _visibility;


#pragma mark - add designated initializer

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        // a container which is scaled
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_contentView];

        _contentView.layer.shadowOffset = CGSizeMake(1, 8);
        _contentView.layer.shadowRadius = 5;
        _contentView.layer.shadowOpacity = 0.3;
        CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:_contentView.layer.bounds].CGPath;
        _contentView.layer.shadowPath = shadowPath;

        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(handleTap)];
        [_contentView addGestureRecognizer:tapRecognizer];
    }
    return self;
}


- (BOOL)deletable {

    return _deletable;
}

- (void)setDeletable:(BOOL)deleteable {

    [self setDeletable:deleteable animated:NO];
}

- (void)setDeletable:(BOOL)deleteable animated:(BOOL)animated {

    // if view was not deletable and has become deletable
    if (!_deletable && deleteable) {

        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(0, 0, 30, 30);
        [_deleteButton setImage:[UIImage imageNamed:@"closeButton"]
                       forState:UIControlStateNormal];
        [_deleteButton addTarget:self
                          action:@selector(handleClose)
                forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.center = self.frame.origin;

        if (animated) {
            [UIView animateWithDuration:1 animations:^{
                _deleteButton.alpha = !_isSelected;
            }];
        } else {
            _deleteButton.alpha = _isSelected;
        }

        [self insertSubview:_deleteButton aboveSubview:_contentView];
    }

    if (_deletable && !deleteable) {
        [_deleteButton removeFromSuperview];
        _deleteButton = nil;
    }

    _deletable = deleteable;
}


//- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//
//    if (animated) {
//
//        [UIView animateWithDuration:1
//                         animations:^{
//                             _closeButton.alpha = 1;
//                         }];
//    }
//    _closeButton
//}


- (void)setAlpha:(CGFloat)alpha {

    super.alpha = alpha;
}

- (void)handleTap {

    [self.delegate selectTabContentView:self];
}

- (void)handleClose {

    [self.delegate deleteTabContentView:self];
}

- (void)addContentView:(UIView *)contentView {

    [_contentView addSubview:contentView];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {

    //    return !CGRectContainsPoint(_closeButton.frame, point)
    //            && CGRectContainsPoint(_contentView.frame, point);

    return (!_isSelected
            && (CGRectContainsPoint(_deleteButton.frame, point)
                || CGRectContainsPoint(_contentView.frame, point)));
}


- (float)visibility {

    return _visibility;
}

- (void)setVisibility:(float)visibility {

    _visibility = visibility;
    _deleteButton.alpha = visibility;
    self.alpha = MAX(visibility, 0.5);
}

- (void)selectAnimated:(BOOL)animated {

    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             [self selectNonAnimated];
                         }
         ];
    } else {
        [self selectNonAnimated];
    }

    _isSelected = YES;
}

- (void)selectNonAnimated {

    _contentView.transform = CGAffineTransformIdentity;

    CGPoint newCenter = CGPointMake(_contentView.frame.origin.x,
                                    _contentView.frame.origin.y);
    _deleteButton.center = newCenter;
    _deleteButton.alpha = 0;
}

- (void)deselectAnimated:(BOOL)animated {

    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             [self deselectNonAnimated];
                         }
         ];
    } else {
        [self deselectNonAnimated];
    }

    _isSelected = NO;
}

- (void)deselectNonAnimated {

    CGAffineTransform scale = CGAffineTransformMakeScale(kDeselectedScale, kDeselectedScale);
    CGAffineTransform transform = CGAffineTransformTranslate(scale, 0, kDeselectedTranslation);
    _contentView.transform = transform;

    CGPoint newCenter = CGPointMake(_contentView.frame.origin.x,
                                    _contentView.frame.origin.y);
    _deleteButton.center = newCenter;
    _deleteButton.alpha = 1;
}


@end