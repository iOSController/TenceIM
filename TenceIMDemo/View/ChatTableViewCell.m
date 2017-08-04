//
//  ChatTableViewCell.m
//  TenceIMDemo
//
//  Created by ldhios2 on 17/8/3.
//  Copyright © 2017年 林任任. All rights reserved.
//

#import "ChatTableViewCell.h"

#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

@implementation ChatTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.headImageView = [[UIImageView alloc] init];
        self.headImageView.layer.cornerRadius = 25.0f;
        self.headImageView.layer.borderWidth = 1.0f;
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.headImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.headImageView];
        
        self.backView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.backView];
        
        self.contentLabel = [[UILabel alloc] init];
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.font = [UIFont systemFontOfSize:17.0f];
        [self.backView addSubview:self.contentLabel];
        
        self.nameLabel = [[UILabel alloc]init];
        self.nameLabel.textColor = [UIColor lightGrayColor];
        self.nameLabel.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:self.nameLabel];
        
        self.timeLabel = [[UILabel alloc]init];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.layer.cornerRadius = 2;
        self.timeLabel.layer.masksToBounds = YES;
        self.timeLabel.backgroundColor = [UIColor lightGrayColor];
        self.timeLabel.font = [UIFont systemFontOfSize:9];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.timeLabel];
        
    }
    return self;
}

- (void)refreshCell:(ChatModel  *)model
{
    // 首先计算文本宽度和高度
    CGRect rec = [model.msg boundingRectWithSize:CGSizeMake(200, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil];
    // 气泡
    UIImage *image = nil;
    // 头像
    UIImage *headImage = nil;
    // 模拟左边
    if (!model.isRight)
    {
        // 当输入只有一个行的时候高度就是20多一点
        self.headImageView.frame = CGRectMake(10, rec.size.height - 18, 50, 50);
        self.backView.frame = CGRectMake(60, 30, rec.size.width + 20, rec.size.height + 20);
        image = [UIImage imageNamed:@"bubbleSomeone"];
        headImage = [UIImage imageNamed:@"login_icon"];
        self.nameLabel.frame = CGRectMake(60, 10, 100, 20);
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    else // 模拟右边
    {
        self.headImageView.frame = CGRectMake(ScreenWidth - 60, rec.size.height - 18, 50, 50);
        self.backView.frame = CGRectMake(ScreenWidth - 60 - rec.size.width - 20, 30, rec.size.width + 20, rec.size.height + 20);
        image = [UIImage imageNamed:@"bubbleMine"];
        headImage = [UIImage imageNamed:@"header_view"];
        
        self.nameLabel.frame = CGRectMake(ScreenWidth-60-100, 10, 100, 20);
        self.nameLabel.textAlignment = NSTextAlignmentRight;
    }
    
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:9]};
    CGSize labelWidth=[[self changeTime:model.showTime andLastDate:model.lastDate] sizeWithAttributes:attrs];
    
    CGFloat widthL = labelWidth.width;
    CGFloat widthAll = ScreenWidth;
    //时间Label
    self.timeLabel.frame = CGRectMake((widthAll - widthL)/2, 0, widthL, 10);
    self.timeLabel.text = [self changeTime:model.showTime andLastDate:model.lastDate];
    
    
    // 拉伸图片 参数1 代表从左侧到指定像素禁止拉伸，该像素之后拉伸，参数2 代表从上面到指定像素禁止拉伸，该像素以下就拉伸
    image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
    self.backView.image = image;
    self.headImageView.image = headImage;
    // 文本内容的frame
    self.contentLabel.frame = CGRectMake(model.isRight ? 5 : 13, 5, rec.size.width, rec.size.height);
    self.contentLabel.text = model.msg;
    
    self.nameLabel.text = model.name;
    
}

-(NSString *)changeTime:(NSDate *)date andLastDate:(NSDate *)lastDate{
    
    NSString * showStr;
    
    NSDate * today = [[NSDate alloc]init];
    NSString * todayStr = [[today description] substringToIndex:10];
    NSString * dateStr = [[date description] substringToIndex:10];
    if ([dateStr isEqualToString:todayStr]) {
        //今天
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"HH:mm";
        showStr = [format stringFromDate:date];
    }else{
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"yyyy年MM月dd日 HH:mm";
        showStr = [format stringFromDate:date];
    }
    
    return showStr;
}


@end
