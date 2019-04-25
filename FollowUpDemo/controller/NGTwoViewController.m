//
//  NGTwoViewController.m
//  FollowUpDemo
//
//  Created by ngmmxh on 2019/4/24.
//  Copyright © 2019 ngmmxh. All rights reserved.
//

#import "NGTwoViewController.h"

#import "WPFLyricView.h"
#import "Masonry.h"
#import "WPFPlayManager.h"
#import "WPFMusic.h"
#import "NSObject+MJKeyValue.h"
#import "WPFLyric.h"
#import "WPFLyricParser.h"

@interface NGTwoViewController ()<WPFLyricViewDelegate>
@property (nonatomic, strong) WPFLyricView *lyricView;
//@property (nonatomic,strong) NSArray *musics;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSArray *lyrics;
@property (nonatomic,assign) NSInteger currentLyricIndex;

@end

@implementation NGTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentLyricIndex = 0;
    [self.view addSubview:self.lyricView];
   
    self.view.backgroundColor = [UIColor grayColor];
    WPFPlayManager *playManager = [WPFPlayManager sharedPlayManager];
//    if (self.playBtn.selected == NO) {
        [self startUpdateProgress];
        [playManager playMusicWithFileName:@"陈奕迅 - 陪你度过漫长岁月 (国语).mp3" didComplete:^{
//            [self next];
        }];
    
//        self.playBtn.selected = YES;
//    }else{
//        self.playBtn.selected = NO;
//        [playManager pause];
//        [self stopUpdateProgress];
//    }

    // 强制布局
    [self.view layoutIfNeeded];
}

- (void)startUpdateProgress {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    
}

- (void)stopUpdateProgress {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateProgress {
    WPFPlayManager *pm = [WPFPlayManager sharedPlayManager];
//    self.currentTimeLabel.text = [WPFTimeTool stringWithTime:pm.currentTime];
    
    
    
    //  更新歌词
    [self updateLyric];
    
    // 更新锁屏界面
//    if (isLocked && isScreenBright) {
//        [self updateLockScreen];
//    }
}

- (void)updateLyric {
    WPFPlayManager *pm = [WPFPlayManager sharedPlayManager];
    WPFLyric *lyric = self.lyrics[self.currentLyricIndex];
    WPFLyric *nextLyric = nil;
    if (self.currentLyricIndex >= self.lyrics.count - 1) {
        nextLyric = [[WPFLyric alloc] init];
        nextLyric.time = pm.duration;
    }else{
        nextLyric = self.lyrics[self.currentLyricIndex + 1];;
    }
    
    
    if (pm.currentTime < lyric.time && self.currentLyricIndex > 0) {
        self.currentLyricIndex --;
        [self updateLyric];
    }else if(pm.currentTime >= nextLyric.time && self.currentLyricIndex < self.lyrics.count - 1){
        self.currentLyricIndex ++;
        [self updateLyric];
    }
    // 设置歌词内容
//    [self.lyricsLabel setValue:lyric.content forKey:@"text"];
    
    // 设置歌词颜色
    CGFloat progress = (pm.currentTime - lyric.time) / (nextLyric.time - lyric.time);
//    [self.lyricsLabel setValue:@(progress) forKey:@"progress"];
    
    self.lyricView.currentLyricIndex = self.currentLyricIndex;
    
    self.lyricView.lyricProgress = progress;
    self.lyricView.alpha = 0.5;
}

//- (NSArray *)musics {
//    if (!_musics) {
//        _musics = [WPFMusic objectArrayWithFilename:@"mlist.plist"];
//    }
//    return _musics;
//}
#pragma mark 代理
- (void)lyricView:(WPFLyricView *)lyricView withProgress:(CGFloat)progress {
    
//    self.view.alpha = 1- progress;
}

-(NSArray *)lyrics{
    if (!_lyrics) {
        self.lyrics = [WPFLyricParser parserLyricWithFileName:@"陈奕迅 - 陪你度过漫长岁月 (国语).lrc"];
    }return _lyrics;
}

-(WPFLyricView *)lyricView{
    if (!_lyricView) {
        _lyricView = [[ WPFLyricView alloc] initWithFrame:self.view.bounds];
        _lyricView.frame = self.view.bounds;
        _lyricView.delegate = self;
     
        // 给竖直歌词赋值
        self.lyricView.lyrics = self.lyrics;
        self.lyricView.rowHeight = 50;
    }return _lyricView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
