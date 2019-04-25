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

#import <AVFoundation/AVFoundation.h>

@interface NGTwoViewController ()<WPFLyricViewDelegate>
{
    NSString *filePath;

}
@property (nonatomic, strong) WPFLyricView *lyricView;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSArray *lyrics;
@property (nonatomic,assign) NSInteger currentLyricIndex;


@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) AVAudioRecorder *recorder;//录音器
@property (nonatomic, strong) AVAudioPlayer *player; //播放器
@property (nonatomic, strong) NSURL *recordFileUrl; //文件地址
///播放录音
@property (nonatomic, strong) UIButton *btnPlayingRecord;



@end

@implementation NGTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentLyricIndex = 0;
    [self.view addSubview:self.lyricView];
   
    self.view.backgroundColor = [UIColor grayColor];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"陈奕迅 - 陪你度过漫长岁月 (国语).mp3" withExtension:nil];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];

    [self.player play];
    // 强制布局
    [self startRecord];
    [self.view addSubview:self.btnPlayingRecord];

    [self.view layoutIfNeeded];
}


-(void)startRecord{
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
    if (session == nil) {
        
        NSLog(@"Error creating session: %@",[sessionError description]);
        
    }else{
        [session setActive:YES error:nil];
        
    }
    
    self.session = session;
    
    
    //1.获取沙盒地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [path stringByAppendingString:@"/RRecord.wav"];
    
    //2.获取文件路径
    self.recordFileUrl = [NSURL fileURLWithPath:filePath];
    
    //设置参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                   // 音频格式
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   //采样位数  8、16、24、32 默认为16
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   // 音频通道数 1 或 2
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   //录音质量
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];
    
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:recordSetting error:nil];
    
    if (_recorder) {
        
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        [_recorder record];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self stopRecord];
        });
        
        
        
    }else{
        NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder");
    }
}

-(void)stopRecord{
    NSLog(@"停止录音");
    
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
    NSFileManager *manager = [NSFileManager defaultManager];

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
    
    
    //  更新歌词
    [self updateLyric];
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
    // 设置歌词颜色
    CGFloat progress = (pm.currentTime - lyric.time) / (nextLyric.time - lyric.time);
    self.lyricView.currentLyricIndex = self.currentLyricIndex;
    self.lyricView.lyricProgress = progress;
    self.lyricView.alpha = 0.5;
}
-(void)onClickBtnPlayingRecord{
    NSLog(@"播放录音");
    [self.recorder stop];
    [self.player stop];
    if ([self.player isPlaying])return;
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:nil];
    
    NSLog(@"%li",self.player.data.length/1024);
    
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [self.player play];
    
}
#pragma mark 代理
- (void)lyricView:(WPFLyricView *)lyricView withProgress:(CGFloat)progress {
    
}

-(NSArray *)lyrics{
    if (!_lyrics) {
        self.lyrics = [WPFLyricParser parserLyricWithFileName:@"陈奕迅 - 陪你度过漫长岁月 (国语).lrc"];
    }return _lyrics;
}

-(WPFLyricView *)lyricView{
    if (!_lyricView) {
        _lyricView = [[ WPFLyricView alloc] initWithFrame:self.view.bounds];
        _lyricView.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height);
        _lyricView.delegate = self;
     
        // 给竖直歌词赋值
        self.lyricView.lyrics = self.lyrics;
        self.lyricView.rowHeight = 50;
    }return _lyricView;
}

-(UIButton *)btnPlayingRecord{
    if (!_btnPlayingRecord) {
        _btnPlayingRecord = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnPlayingRecord.frame = CGRectMake( 100, 100, 100, 100);
        _btnPlayingRecord.backgroundColor = [UIColor redColor];
        [_btnPlayingRecord addTarget:self action:@selector(onClickBtnPlayingRecord) forControlEvents:UIControlEventTouchUpInside];
    }return _btnPlayingRecord;
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
