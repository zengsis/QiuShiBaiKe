//
//  ViewController.m
//  New
//
//  Created by apple on 15/9/4.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "TFHpple.h"
@interface Story : NSObject
@property (nonatomic,copy) NSString *nickName;//用户昵称
@property (nonatomic,copy)NSString *avatorSrc;//头像网址
@property (nonatomic,copy)NSString *storyText;//笑话内容
@property (nonatomic,copy)NSString *votesStr;//好笑的数目
@property (nonatomic,copy)NSString *commentStr;//评论的数目
@end
@implementation Story

@end

@interface ViewController ()
{
    NSString *_qiushiPath;//糗事百科文本笑话网址
    NSMutableArray *_storysArray;//存解析后的笑话数组，元素类型为
    //Story *
}

@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;


@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@property (weak, nonatomic) IBOutlet UILabel *votesLabel;

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _qiushiPath = @"http://www.qiushibaike.com/text";
    _storysArray = [NSMutableArray array];
    [self loadStoryFromQiuShi];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)loadStoryFromQiuShi
{
    //创建一个HTTP请求操作管理器
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //由于默认的管理器中对http响应的序列化属性是AFJSONResponseSerializer
    //现在是要去html数据，故设置为普通的AFHTTPResponseSerializer,不然跑到失败里去了
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_qiushiPath]];
    //修改HTTP请求头域，伪装成pc浏览器
    
    [request setValue:@"Mozilla/5.0" forHTTPHeaderField:@"User-Agent"];
    //创建一个请求操作
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^void
(AFHTTPRequestOperation *operation, id responseObject) {
        // 交给解析html的方法处理
        [self parseHTMLData:responseObject];
    } failure:^void(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"失败:%@",error);
    }];
    //开始这个请求操作
    [operation start];
}


-(void)parseHTMLData:(NSData *)data
{
    //由于某些原因，需要先把数据下载到桌面，然后再从桌面解析
//    [data writeToFile:@"/Users/apple/Desktop/9098.html" atomically:YES];
    data=[NSData dataWithContentsOfFile:@"/Users/apple/Desktop/yunxingziliao/90981.html"];
    
    // 解析html
    TFHpple *doc = [[TFHpple alloc]initWithHTMLData:data encoding:@"utf-8"];
    NSArray *result = [doc searchWithXPathQuery:@"//div[@class='article block untagged mb15']"];//取出所有故事一页20条
    for (TFHppleElement *elemt in result) {
        //遍历找出头像网址
        TFHppleElement *avatarEli = [[elemt searchWithXPathQuery:@"//div[@class='author']/a/img"]firstObject];
        NSString *avatar = [avatarEli attributes][@"src"];
        NSLog(@"avatar:%@",avatar);
        
        //找出笑话
        TFHppleElement *contEli = [[elemt searchWithXPathQuery:@"//div[@class='content']"]firstObject];
        NSString *content = [contEli content];
        
        
        //余下的三个自己实现，类似填空
        TFHppleElement *nickEli= [[elemt searchWithXPathQuery:@"//div[@class='author']/a"]firstObject];
        NSString *nickName = [nickEli content];
        NSLog(@"nickName昵称:%@",nickName);
        
        TFHppleElement *comEli = [[elemt searchWithXPathQuery:@"//div[@class='stats']/span/a/i"]firstObject];
        NSString *comment = [comEli content];
        NSLog(@"comment评论:%@",comment);
        
        TFHppleElement *voteEli = [[elemt searchWithXPathQuery:@"//div[@class='stats']/span/i"]firstObject];
        NSString *vote = [voteEli content];
        NSLog(@"vote好笑:%@",vote);
        
        //赋值给对象后加入数组
        Story *story = [Story new];
        story.avatorSrc = avatar;
        story.commentStr = comment;
        story.storyText = content;
        story.votesStr = vote;
        story.nickName = nickName;
        [_storysArray addObject:story];
        [self displayWithStory:story];
    }
}


-(void)displayWithStory:(Story *)story
{
    _nickNameLabel.text = story.nickName;
    _contentTextView.text = story.storyText;
    _votesLabel.text = [NSString stringWithFormat:@"%@ 好笑",story.votesStr];
    _commentLabel.text = [NSString stringWithFormat:@"%@ 评论",story.commentStr];
    //重点，AFN给imageView加的类别里的方法
    NSLog(@"%@",story.avatorSrc) ;
[_avatarImageView
 setImageWithURL:[NSURL URLWithString:story.avatorSrc]];
}


- (IBAction)preClicked:(id)sender {
}

- (IBAction)nextClicked:(id)sender {
}


@end






