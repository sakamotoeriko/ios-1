//
//  CusLocateInputView.h
//  CarApp
//
//  Created by MacPro-Mr.Lu on 14-5-3.
//  Copyright (c) 2014年 Leno. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CusLocateInputViewDelegate;

@interface CusLocateInputView : UIView<UITextFieldDelegate>
{
    UILabel *_startLocateLable;
    UITextField *_startInputView;
    UIButton *_locateBtn;
    UIActivityIndicatorView *_activity;
}

@property (assign, nonatomic) id<CusLocateInputViewDelegate>delegate;
@property (assign, nonatomic) int type; //当前状态 1，定位 2手动输入
@property (copy, nonatomic) NSString *locateAddress;//定位的信息
@property (copy, nonatomic) NSString *inputAddress;

- (void)resumeView;//恢复视图

@end

@protocol CusLocateInputViewDelegate <NSObject>

- (void)inputModeChange:(int)type;
- (void)locateBtnAction:(UIButton *)sender;

@end