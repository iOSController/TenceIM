//
//  ChatInputView.m
//  TenceIMDemo
//
//  Created by ldhios2 on 17/8/3.
//  Copyright © 2017年 林任任. All rights reserved.
//

#import "ChatInputView.h"


@implementation ChatInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, frame.size.width - 75, frame.size.height-10)];
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
        [self addSubview:self.textField];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(frame.size.width - 65, 5, 60, frame.size.height-10);
        [self.button setTitle:@"发送" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.button setBackgroundColor:[UIColor cyanColor]];
        self.button.layer.cornerRadius = 8;
        [self addSubview:self.button];
        
    }
    return self;
}


@end
