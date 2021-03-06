//
//  ProfileCell.m
//  CarApp
//
//  Created by MacPro-Mr.Lu on 14-3-4.
//  Copyright (c) 2014年 Leno. All rights reserved.
//

#import "ProfileCell.h"

@implementation ProfileCell

-(void)dealloc
{
    [SafetyRelease release:_titleLabel];
    
    [SafetyRelease release:_infoLabel];
    
    [SafetyRelease release:_checkLable];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setView];
    }
    return self;
}

- (void)setView
{
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, (self.contentView.frame.size.height-20)/2.0, 70, 20)];
    [titleLabel setTextColor:[UIColor lightGrayColor]];
    [titleLabel setFont:[UIFont fontWithName:kFangZhengFont size:14]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:titleLabel];
    [self setTitleLabel:titleLabel];
    [titleLabel release];
    
    UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(75,(self.contentView.frame.size.height-20)/2.0, 150, 20)];
    [infoLabel setTextColor:[UIColor appBlackColor]];
    [infoLabel setFont:[UIFont fontWithName:kFangZhengFont size:14]];
    [infoLabel setTextAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:infoLabel];
    [self setInfoLabel:infoLabel];
    [infoLabel release];
    
    CheckLable *checkLable = [[CheckLable alloc]initWithFrame:CGRectMake(320-60, (44-12)/2, 60, 12)];
    [self.contentView addSubview:checkLable];
    [self setCheckLable:checkLable];
    [checkLable release];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
