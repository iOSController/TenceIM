//
//  ChatModel.h
//  TenceIMDemo
//
//  Created by ldhios2 on 17/8/3.
//  Copyright © 2017年 林任任. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatModel : NSObject
@property (nonatomic,copy) NSString *msg;
@property (nonatomic,assign) BOOL isRight;
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSDate * showTime;
@property (nonatomic,strong) NSDate * lastDate;
@end
