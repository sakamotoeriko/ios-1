//
//  EditSignatureViewController.h
//  CarApp
//
//  Created by MacPro-Mr.Lu on 14-4-14.
//  Copyright (c) 2014年 Leno. All rights reserved.
//

#import "CommonViewController.h"
#import "People.h"
@class ProfileViewController;
@interface EditSignatureViewController : CommonViewController<UITextViewDelegate>
{
    UIScrollView *_scrollView;
    UILabel *_lastWordLable;
    UITextView *_textView;
}

@property (strong, nonatomic) People *peopleInfo;
@property (assign, nonatomic) ProfileViewController *parentVC;

@end
