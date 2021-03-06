//
//  ScrollerMessageControl.m
//  CarApp
//
//  Created by MacPro-Mr.Lu on 14-3-5.
//  Copyright (c) 2014年 Leno. All rights reserved.
//

#import "ScrollerMessageControl.h"

@interface ScrollerMessageControl()

@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) UILabel *contentLable;
@property (retain, nonatomic) UILabel *contentExtendLable;
@property (retain, nonatomic) NSTimer *timer;

@end

@implementation ScrollerMessageControl

-(void)dealloc
{
    [_scrollView release];
    [self setScrollView:nil];
    
    [_contentLable release];
    [self setContentLable:nil];
    
    [_contentExtendLable release];
    [self setContentExtendLable:nil];
    
    [_timer release];
    [self setTimer:nil];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)setView
{
    UIScrollView * scroller = [[UIScrollView alloc]initWithFrame:self.bounds];
    [scroller setBackgroundColor:[UIColor clearColor]];
    [self addSubview:scroller];
    [scroller release];
    self.scrollView = scroller;
    
    UILabel * contextlable = [[UILabel alloc]init];
    contextlable.frame = CGRectMake( 0, 0, 200, 25);
    contextlable.textColor = [UIColor colorWithRed:0.0/255. green:180.0/255. blue:180.0/255. alpha:1.];
    contextlable.textAlignment = NSTextAlignmentCenter;
    contextlable.userInteractionEnabled = YES;
    contextlable.clipsToBounds = NO;
    contextlable.lineBreakMode = NSLineBreakByWordWrapping;
    [contextlable setBackgroundColor:[UIColor clearColor]];
    [contextlable setFont:[UIFont systemFontOfSize:14.0]];
    [scroller addSubview:contextlable];
    [contextlable release];
    self.contentLable = contextlable;
    
    UILabel * contentExtendLable = [[UILabel alloc]init];
    contentExtendLable.frame = CGRectMake( 0, 0, 200, 25);
    contentExtendLable.textColor = [UIColor colorWithRed:0.0/255. green:180.0/255. blue:180.0/255. alpha:1.];
    contentExtendLable.textAlignment = NSTextAlignmentCenter;
    contentExtendLable.userInteractionEnabled = YES;
    contentExtendLable.clipsToBounds = NO;
    contentExtendLable.lineBreakMode = NSLineBreakByWordWrapping;
    [contentExtendLable setBackgroundColor:[UIColor clearColor]];
    [contentExtendLable setFont:[UIFont systemFontOfSize:14.0]];
    [scroller addSubview:contentExtendLable];
    [contentExtendLable release];
    self.contentExtendLable = contentExtendLable;

}



@end
