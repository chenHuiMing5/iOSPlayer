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
#import "NGLyricModel.h"
#import "MJExtension.h"
#import "AudioTableViewCell.h"

#import "NGLyricManager.h"
@interface FirstViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *words;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, strong) AVAudioPlayer *wordPlayer;
@property (nonatomic,assign) NSInteger currentMusicIndex;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    [self createUI];
    [self initData];
}

-(void)createUI{
    [self.view addSubview:self.tableView];

}
-(void)initData {
    _currentMusicIndex = 0;
    ///test1
//    self.wordPlayer = [AudioManager playMusic:@"一东.mp3"];
//    [AudioManager playMusic:@"Background.caf"];
//    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    //test2
    self.wordPlayer = [AudioManager playMusic:@"陈奕迅 - 陪你度过漫长岁月 (国语).mp3"];
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
        //test1
//        self.words = [NGLyricModel objectArrayWithFilename:@"一东.plist"];
        
        //test2
        self.words = [NGLyricManager lyricParserWithFileName:@"陈奕迅 - 陪你度过漫长岁月 (国语).lrc"];

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
        NGLyricModel *word = self.words[i];
        
        // 2.获得下一条词句
        int nextI = i + 1;
        NGLyricModel *nextWord = nil;
        if (nextI < count) {
            nextWord = self.words[nextI];
        }
        
        if (currentTime < nextWord.time && currentTime >= word.time) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
//            [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionTop];
//            [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

            AudioTableViewCell *cell =(AudioTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
            CGFloat progress = (currentTime - word.time) / (nextWord.time - word.time);
            cell.labTitle.currentColor = [UIColor redColor];
            cell.labTitle.progress = progress;
            break;
        }
        // 设置歌词颜色
//        [self.lyricsLabel setValue:@(progress) forKey:@"progress"];
        
      
      
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.words.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"word";
    AudioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    NGLyricModel *word = self.words[indexPath.row];
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

