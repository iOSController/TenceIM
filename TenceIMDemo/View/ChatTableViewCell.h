//
//  ChatTableViewCell.h
//  TenceIMDemo
//
//  Created by ldhios2 on 17/8/3.
//  Copyright © 2017年 林任任. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatModel.h"
@interface ChatTableViewCell : UITableViewCell

@property (nonatomic,strong) UIImageView *headImageView; // 用户头像
@property (nonatomic,strong) UIImageView *backView; // 气泡
@property (nonatomic,strong) UILabel *contentLabel; // 气泡内文本
@property (nonatomic,strong) UILabel *nameLabel;//用户名
@property (nonatomic,strong) UILabel *timeLabel;//时间


- (void)refreshCell:(ChatModel *)model; // 安装我们的cell


@end
