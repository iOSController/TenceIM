//
//  ViewController.m
//  TenceIMDemo
//
//  Created by ldhios2 on 17/8/3.
//  Copyright © 2017年 林任任. All rights reserved.
//

#import "ViewController.h"
#import "ChatModel.h"
#import "ChatInputView.h"
#import "ChatTableViewCell.h"
#import <ImSDK/ImSDK.h>
#import <IMMessageExt/IMMessageExt.h>

#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height


#define SDK_APPID @""//appid
#define SDK_ACCOUNTTYPE @""//accountType 以上两个在腾讯云配置的时候拿到

#define USER_IDENTIFIER @""// identifier为用户名
#define USER_SIG @""//userSig 为用户登录凭证
#define USER_3RD @""// appidAt3rd 在私有帐号情况下，填写与sdkAppId 一样，以上由后台配置

#define MyTitle @""//我的用户名（对话上的名字）
/*
 
 需要自己去腾讯云下载导入第三库
 
 
 */

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,TIMConnListener,TIMUserStatusListener,TIMRefreshListener,TIMFriendshipListener,TIMGroupListener,TIMMessageListener,TIMMessageUpdateListener>


@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSouce;
@property (nonatomic,strong) ChatInputView *inputView;
@property (nonatomic,strong) TIMConversation * conversation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self TIMStart];
    
    [self createIMUI];

}


-(void)TIMStart{
    
    TIMManager * manger = [TIMManager sharedInstance];
    [manger addMessageListener:self];
    
    
    TIMSdkConfig * config = [[TIMSdkConfig alloc]init];
    config.sdkAppId = [SDK_APPID intValue];
    config.accountType = SDK_ACCOUNTTYPE;
    config.disableCrashReport = NO;
    config.connListener = self;
    [manger initSdk:config];
    
    TIMUserConfig *userConfig = [[TIMUserConfig alloc] init];
    //    userConfig.disableStorage = YES;//禁用本地存储（加载消息扩展包有效）
    //    userConfig.disableAutoReport = YES;//禁止自动上报（加载消息扩展包有效）
    //    userConfig.enableReadReceipt = YES;//开启C2C已读回执（加载消息扩展包有效）
    userConfig.disableRecnetContact = NO;//不开启最近联系人（加载消息扩展包有效）
    userConfig.disableRecentContactNotify = YES;//不通过onNewMessage:抛出最新联系人的最后一条消息（加载消息扩展包有效）
    userConfig.enableFriendshipProxy = YES;//开启关系链数据本地缓存功能（加载好友扩展包有效）
    userConfig.enableGroupAssistant = YES;//开启群组数据本地缓存功能（加载群组扩展包有效）
    TIMGroupInfoOption *giOption = [[TIMGroupInfoOption alloc] init];
    giOption.groupFlags = 0xffffff;//需要获取的群组信息标志（TIMGetGroupBaseInfoFlag）,默认为0xffffff
    giOption.groupCustom = nil;//需要获取群组资料的自定义信息（NSString*）列表
    userConfig.groupInfoOpt = giOption;//设置默认拉取的群组资料
    TIMGroupMemberInfoOption *gmiOption = [[TIMGroupMemberInfoOption alloc] init];
    gmiOption.memberFlags = 0xffffff;//需要获取的群成员标志（TIMGetGroupMemInfoFlag）,默认为0xffffff
    gmiOption.memberCustom = nil;//需要获取群成员资料的自定义信息（NSString*）列表
    userConfig.groupMemberInfoOpt = gmiOption;//设置默认拉取的群成员资料
    TIMFriendProfileOption *fpOption = [[TIMFriendProfileOption alloc] init];
    fpOption.friendFlags = 0xffffff;//需要获取的好友信息标志（TIMProfileFlag）,默认为0xffffff
    fpOption.friendCustom = nil;//需要获取的好友自定义信息（NSString*）列表
    fpOption.userCustom = nil;//需要获取的用户自定义信息（NSString*）列表
    userConfig.friendProfileOpt = fpOption;//设置默认拉取的好友资料
    userConfig.userStatusListener = self;//用户登录状态监听器
    userConfig.refreshListener = self;//会话刷新监听器（未读计数、已读同步）（加载消息扩展包有效）
    //    userConfig.receiptListener = self;//消息已读回执监听器（加载消息扩展包有效）
    userConfig.messageUpdateListener = self;//消息svr重写监听器（加载消息扩展包有效）
    //    userConfig.uploadProgressListener = self;//文件上传进度监听器
    //    userConfig.groupEventListener todo
    userConfig.friendshipListener = self;//关系链数据本地缓存监听器（加载好友扩展包、enableFriendshipProxy有效）
    userConfig.groupListener = self;//群组据本地缓存监听器（加载群组扩展包、enableGroupAssistant有效）
    [manger setUserConfig:userConfig];
    
    //登录
    TIMLoginParam * login_param = [[TIMLoginParam alloc ]init];
    
    // identifier为用户名，userSig 为用户登录凭证
    // appidAt3rd 在私有帐号情况下，填写与sdkAppId 一样
    login_param.identifier = USER_IDENTIFIER;
    login_param.userSig = USER_SIG;
    login_param.appidAt3rd = USER_3RD;
    
    [[TIMManager sharedInstance] login: login_param succ:^(){
        NSLog(@"Login Succ");
        
        //登录会话
        _conversation = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:_talkID];
        
        //获取历史消息 最多拿十条数据
        [_conversation getMessage:10 last:nil succ:^(NSArray *msgs) {
            
            if (msgs.count>0) {
                
                //有历史消息
                for (NSInteger i = msgs.count-1; i>=0; i--) {
                    
                    TIMMessage * msg = msgs[i];
                    TIMElem * cont_elem = [msg getElem:0];
                    
                    //发送人
                    //NSString * senderStr = [msg sender];
                    //消息
                    NSString * msgStr;
                    if ([cont_elem isKindOfClass:[TIMTextElem class]]) {
                        
                        TIMTextElem * text_elem = (TIMTextElem *)cont_elem;
                        
                        msgStr = text_elem.text;
                    }
                    
                    ChatModel *chatModel = [[ChatModel alloc] init];
                    if (i == msgs.count-1) {
                        chatModel.lastDate = msg.timestamp;
                    }
                    chatModel.msg = msgStr;
                    chatModel.showTime = msg.timestamp;
                    
                    //TIMMessage的方法 isSelf  判断是不是值发出的消息
                    if (msg.isSelf) {
                        chatModel.isRight = YES;
                        chatModel.name = MyTitle;
                    }else{
                        chatModel.isRight = NO;
                        chatModel.name = self.nickName;
                    }
                    
                    
                    [self.dataSouce addObject:chatModel];
                    
                    
                }
                
                [self.tableView reloadData];
                
                // 滚到底部
                if (self.dataSouce.count != 0) {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSouce.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            }
            
        } fail:^(int code, NSString *msg) {
            NSLog(@"获取消息失败");
        }];
        
        
    } fail:^(int code, NSString * err) {
        NSLog(@"Login Failed: %d->%@", code, err);
        
        
    }];
    
    
    
}

//获取当前用户的聊天消息
-(void)onNewMessage:(NSArray *)msgs
{
    //获取最新的一条信息
    TIMMessage * message = (TIMMessage *)msgs[0];
    
    TIMElem * elem = [message getElem:0];
    
    if ([elem isKindOfClass:[TIMTextElem class]]) {
        TIMTextElem * text_elem = (TIMTextElem * )elem;
        
        ChatModel *chatModel = [[ChatModel alloc] init];
        chatModel.msg = text_elem.text;
        chatModel.isRight = NO; // 0 or 1
        chatModel.name = self.nickName;
        chatModel.showTime = message.timestamp;
        chatModel.lastDate = message.timestamp;
        [self.dataSouce addObject:chatModel];
        
    }
    [self.tableView reloadData];
    
    // 滚到底部
    if (self.dataSouce.count != 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSouce.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

//当未读消息或者新联系人发送消息时触发回调
-(int) setRefreshListener: (id<TIMRefreshListener>)listener
{
    NSLog(@"当未读消息或者新联系人发送消息时触发回调");
    return 10;
}
//刷新聊天内容
- (void) onRefresh
{
    NSLog(@"刷新聊天内容");
}

-(void)createIMUI{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 40) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    // 小技巧，用了之后不会出现多余的Cell
    UIView *view = [[UIView alloc] init];
    self.tableView.tableFooterView = view;
    
    // 底部输入栏
    self.inputView = [[ChatInputView alloc] initWithFrame:CGRectMake(0, ScreenHeight-40, ScreenWidth, 40)];
    self.inputView.backgroundColor = [UIColor lightGrayColor];
    self.inputView.textField.delegate = self;
    [self.inputView.button addTarget:self action:@selector(clickSengMsg:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.inputView];
    
    // 注册键盘的通知hide or show
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 增加手势，点击弹回
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
    [self.view addGestureRecognizer:tap];
}


- (void)click:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}
// 监听键盘弹出
- (void)keyBoardShow:(NSNotification *)noti
{
    
    // 咱们取自己需要的就好了
    CGRect rec = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 小于，说明覆盖了输入框
    if ([UIScreen mainScreen].bounds.size.height - rec.size.height < self.inputView.frame.origin.y + self.inputView.frame.size.height)
    {
        // 把我们整体的View往上移动
        CGRect tempRec = self.view.frame;
        tempRec.origin.y =64 - (rec.size.height);
        self.view.frame = tempRec;
    }
    // 由于可见的界面缩小了，TableView也要跟着变化Frame
    self.tableView.frame = CGRectMake(0, rec.size.height, ScreenWidth, ScreenHeight - 64 - rec.size.height - 40);
    if (self.dataSouce.count != 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSouce.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    
}
// 监听键盘隐藏
- (void)keyboardHide:(NSNotification *)noti
{
    self.view.frame = CGRectMake(0, 64, ScreenWidth, ScreenHeight);
    self.tableView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64 - 40);
}


#pragma mark-----发送消息
- (void)clickSengMsg:(UIButton *)btn
{
    //输入为空 不发送
    if (!self.inputView.textField.text) {
        return;
    }
    
    TIMTextElem * text_elem = [[TIMTextElem alloc] init];
    [text_elem setText:self.inputView.textField.text];
    TIMMessage * msg = [[TIMMessage alloc] init];
    [msg addElem:text_elem];
    [_conversation sendMessage:msg succ:^{
        NSLog(@"消息发送成功");
        if (![self.inputView.textField.text isEqualToString:@""])
        {
            ChatModel *chatModel = [[ChatModel alloc] init];
            chatModel.msg = self.inputView.textField.text;
            chatModel.isRight = YES; // 0 or 1
            chatModel.showTime = msg.timestamp;
            chatModel.lastDate = msg.timestamp;
            chatModel.name = MyTitle;
            [self.dataSouce addObject:chatModel];
        }
        [self.tableView reloadData];
        
        // 滚到底部
        if (self.dataSouce.count != 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSouce.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        self.inputView.textField.text = nil;
        
    } fail:^(int code, NSString *msg) {
        NSLog(@"消息发送失败");
    }];
    
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSouce.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell refreshCell:self.dataSouce[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatModel *model = self.dataSouce[indexPath.row];
    CGRect rec =  [model.msg boundingRectWithSize:CGSizeMake(200, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil];
    return rec.size.height + 45+20;
    
}

- (NSMutableArray *)dataSouce
{
    if (_dataSouce == nil) {
        _dataSouce = [[NSMutableArray alloc] init];
    }
    return _dataSouce;
}





@end
