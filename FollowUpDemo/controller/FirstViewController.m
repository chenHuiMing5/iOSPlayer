//
//  FirstViewController.m
//  FollowUpDemo
//
//  Created by ngmmxh on 2019/4/23.
//  Copyright © 2019 ngmmxh. All rights reserved.
//

#import "FirstViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioManager.h"
#import "AudioModel.h"
#import "MJExtension.h"
#import "AudioTableViewCell.h"
@interface FirstViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *words;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, strong) AVAudioPlayer *wordPlayer;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];

    [self.view addSubview:self.tableView];
    self.wordPlayer = [AudioManager playMusic:@"一东.mp3"];
    
    [AudioManager playMusic:@"Background.caf"];
    
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (CADisplayLink *)link
{
    if (!_link) {
        self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    }
    return _link;
}

- (NSArray *)words
{
    if (!_words) {
        self.words = [AudioModel objectArrayWithFilename:@"一东.plist"];
    }
    return _words;
}

- (void)update
{
    // 当前播放的位置
    double currentTime = self.wordPlayer.currentTime;
    
    int count = self.words.count;
    for (int i = 0; i<count; i++) {
        // 1.当前词句
        AudioModel *word = self.words[i];
        
        // 2.获得下一条词句
        int nextI = i + 1;
        AudioModel *nextWord = nil;
        if (nextI < count) {
            nextWord = self.words[nextI];
        }
        
        if (currentTime < nextWord.time && currentTime >= word.time) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionTop];
            break;
        }
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.words.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.创建cell
    static NSString *ID = @"word";
    AudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];

    // 2.设置cell的数据
    AudioModel *word = self.words[indexPath.row];
    cell.labTitle.text = word.text;
    
    return cell;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        [_tableView registerClass:[AudioTableViewCell class] forCellReuseIdentifier:@"word"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }return _tableView;
}

@end

