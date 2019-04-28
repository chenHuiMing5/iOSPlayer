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
//{
//    NSString *filePath;
//
//}
@property (nonatomic, strong) WPFLyricView *lyricView;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSArray *lyrics;
@property (nonatomic,assign) NSInteger currentLyricIndex;


@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) AVAudioRecorder *recorder;//录音器
@property (nonatomic, strong) AVAudioPlayer *player; //播放器
@property (nonatomic, strong) NSURL *recordFileUrl; //文件地址
///合成声音
@property (nonatomic, strong) UIButton *btnMP3RecordMixture;

@property (nonatomic,strong) NSString *filePath;
///节奏数组
@property (nonatomic, strong) NSArray *arrFBTime;
@property (nonatomic, strong) UILabel *labFBPoint;
@property (nonatomic, strong) UILabel *labAllFB;
@property (nonatomic, strong) NSMutableArray *marrFBNumAll;




@end

@implementation NGTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.view.backgroundColor = [UIColor grayColor];
    [self createUI];
    [self startRecord];

    [self playAudioMp3];


    // 强制布局
    [self.view layoutIfNeeded];
}
-(void)createUI{
    self.currentLyricIndex = 0;
    self.arrFBTime = @[@"5000.0",@"9000.0",@"12000.0"];
    self.marrFBNumAll = [NSMutableArray array];
    [self.view addSubview:self.lyricView];
    [self.view addSubview:self.btnMP3RecordMixture];
    [self.view addSubview:self.labAllFB];
    [self.view addSubview:self.labFBPoint];
}
///播放
-(void)playAudioMp3{
    WPFPlayManager *playManager = [WPFPlayManager sharedPlayManager];
    //    if (self.playBtn.selected == NO) {
    [self startUpdateProgress];
    [playManager playMusicWithFileName:@"张金多（女孩）.m4a" didComplete:^{
        [self.recorder stop];
        [self.timer invalidate];
        //播放完成后合成
        [self audioAndAudio];
        
    }];
}
    

///合成
- (void)audioAndAudio
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    NSDate *datenow = [NSDate date];
    NSString *nowtimeStr = [formatter stringFromDate:datenow];
     NSLog(@"------------------------time 1 =  %@",nowtimeStr);
 
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"张金多（女孩）" ofType:@"m4a"];
//    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"清明（刘琮）" ofType:@"mp3"];
//    AVURLAsset *audioAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath]];
//    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    
//        NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"陈奕迅 - 陪你度过漫长岁月 (国语)" ofType:@"mp3"];
//        NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"清明（刘琮）" ofType:@"mp3"];
        AVURLAsset *videoAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
        AVURLAsset *audioAsset = [AVURLAsset assetWithURL:self.recordFileUrl];

    
    AVMutableComposition *compostion = [AVMutableComposition composition];
    AVMutableCompositionTrack *video = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    [video insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
    video.preferredVolume = 0.2;
    AVMutableCompositionTrack *audio = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    [audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:[audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
    audio.preferredVolume = 1.0;
    /*
     批量插入音轨到文件最后
     CMTimeRange range = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
     [video insertTimeRanges:@[[NSValue valueWithCMTimeRange:range],[NSValue valueWithCMTimeRange:range]] ofTracks:@[[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject,[audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject] atTime:kCMTimeZero error:nil];
     */
    
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:compostion presetName:AVAssetExportPresetAppleM4A];
    NSString *outPutFilePath = [[self.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Audio.m4a"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outPutFilePath error:nil];
    }
    session.outputURL = [NSURL fileURLWithPath:outPutFilePath];
    session.outputFileType = @"com.apple.m4a-audio";
    session.shouldOptimizeForNetworkUse = YES;
    [session exportAsynchronouslyWithCompletionHandler:^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath])
        {
        
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
             NSDate *datenow = [NSDate date];
            NSString *nowtimeStr = [formatter stringFromDate:datenow];
            NSLog(@"------------------------time 222222 =  %@",nowtimeStr);
            // 调用播放方法
            [self playAudio:[NSURL fileURLWithPath:outPutFilePath]];
        }
        else
        {
            NSLog(@"输出错误");
        }
    }];
    
}
- (void)playAudio:(NSURL *)url
{
    // 传入地址
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    // 播放器
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    // 播放器layer
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.view.frame;
    // 视频填充模式
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加到imageview的layer上
    [self.view.layer addSublayer:playerLayer];
    player.volume =1.0;

    // 隐藏提示框 开始播放
    // 播放
    [player play];
}

-(void)startRecord{
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
//    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth|AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionAllowBluetoothA2DP|AVAudioSessionCategoryOptionAllowAirPlay error:nil];

    if (session == nil) {
        
        NSLog(@"Error creating session: %@",[sessionError description]);
        
    }else{
        [session setActive:YES error:nil];
        
    }
    
    self.session = session;
    
    
    //1.获取沙盒地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
   NSString *filePath = [path stringByAppendingString:@"/RRecordNew.wav"]; //这里必须是wav格式，不然音频格式和文件存储格式不匹配

    //2.获取文件路径
    self.recordFileUrl = [NSURL fileURLWithPath:filePath];
    
    //设置参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   [NSNumber numberWithFloat: 44100.0],AVSampleRateKey,
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
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
//            [self stopRecord];
//        });
        
        
        
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
    [self audioAndAudio];
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
    
    //检测分贝值
    int fbNum =  [self audioPowerChangeNUM];
    NSLog(@"分贝值：--------------——：%d",fbNum);
    self.labAllFB.text = [NSString stringWithFormat:@"实时分贝值：%d",fbNum];
//    //是否要加锁
//    for (NSString *timeStr in self.arrFBTime) {
//        double secondTime = [timeStr doubleValue]/1000.0;
//        double minSecondTimeS= ([timeStr doubleValue] -50) /1000.0;
//        double maxSecondTime = ([timeStr doubleValue] + 50)/1000.0;
//        NSLog(@"pm.currentTime -----:%.001f",pm.currentTime);
//        NSLog(@"secondTime ------------------------------------%.001f",secondTime);
//
//        if (pm.currentTime == secondTime ||( pm.currentTime >minSecondTimeS && pm.currentTime < maxSecondTime)) {
//            NSLog(@"打印当前这个分贝值：%d",fbNum);
//            self.labFBPoint.text = [NSString stringWithFormat:@"在固定时间点：%@ 的分贝值：%d",timeStr,fbNum];
//        }
//    }
    
    
    [self.arrFBTime enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * timeStr = obj;
        double secondTime = [timeStr doubleValue]/1000.0;
        double minSecondTimeS= ([timeStr doubleValue] -50) /1000.0;
        double maxSecondTime = ([timeStr doubleValue] + 50)/1000.0;
        NSLog(@"pm.currentTime -----:%.001f",pm.currentTime);
        NSLog(@"secondTime ------------------------------------%.001f",secondTime);
        
        if (pm.currentTime == secondTime ||( pm.currentTime >minSecondTimeS && pm.currentTime < maxSecondTime)) {
            NSLog(@"打印当前这个分贝值：%d",fbNum);
            UILabel *lab = [[UILabel alloc] init];
            lab.frame = CGRectMake(100, idx *40 + 100  , self.view.frame.size.width - 100, 40);
            lab.textColor = [UIColor redColor];
            lab.text = [NSString stringWithFormat:@"在固定时间点：%@ 的分贝值：%d",timeStr,fbNum];
            
            [self.view addSubview:lab];
        }
    }];
   
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
-(void)onClickbtnMP3RecordMixture{
    NSLog(@"播放录音");
    WPFPlayManager *pm = [WPFPlayManager sharedPlayManager];
    [pm pause];
    [self.recorder stop];
    [self.player stop];
    if ([self.player isPlaying])return;
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:nil];
    
    NSLog(@"%li",self.player.data.length/1024);
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth|AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionAllowBluetoothA2DP|AVAudioSessionCategoryOptionAllowAirPlay error:nil];

    [self.player play];
    
}


/**
 *  录音声波状态设置 返回分贝值
 */
-(int)audioPowerChangeNUM{
    
    [_recorder updateMeters];//更新测量值
    float power = [_recorder averagePowerForChannel:0];
    float powerMax = [_recorder peakPowerForChannel:0];
//    NSLog(@"-------------power = %f, powerMax = %f",power, powerMax);
    
    CGFloat progress = (1.0 / 160.0) * (power + 160.0);
    
    power = power + 160  - 50;
    
    int dB = 0;
    if (power < 0.f) {
        dB = 0;
    } else if (power < 40.f) {
        dB = (int)(power * 0.875);
    } else if (power < 100.f) {
        dB = (int)(power - 15);
    } else if (power < 110.f) {
        dB = (int)(power * 2.5 - 165);
    } else {
        dB = 110;
    }
    
 
    return dB;
    
    
}


#pragma mark 代理
- (void)lyricView:(WPFLyricView *)lyricView withProgress:(CGFloat)progress {
    
}

-(NSArray *)lyrics{
    if (!_lyrics) {
        //清明
//        self.lyrics = [WPFLyricParser parserLyricWithFileName:@"陈奕迅 - 陪你度过漫长岁月 (国语).lrc"];
        self.lyrics = [WPFLyricParser parserLyricWithFileName:@"清明.lrc"];

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

-(UIButton *)btnMP3RecordMixture{
    if (!_btnMP3RecordMixture) {
        _btnMP3RecordMixture = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnMP3RecordMixture.frame = CGRectMake( 0, 64, 100, 100);
        _btnMP3RecordMixture.backgroundColor = [UIColor redColor];
        [_btnMP3RecordMixture addTarget:self action:@selector(onClickbtnMP3RecordMixture) forControlEvents:UIControlEventTouchUpInside];
    }return _btnMP3RecordMixture;
}
- (NSString *)filePath
{
    if (!_filePath)
    {
        _filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        _filePath = [_filePath stringByAppendingPathComponent:@"user"];
        NSFileManager *manage = [NSFileManager defaultManager];
        if ([manage createDirectoryAtPath:_filePath withIntermediateDirectories:YES attributes:nil error:nil])
        {
            _filePath = [_filePath stringByAppendingPathComponent:@"testAudio.aac"];
        }
    }
    
    return _filePath;
}

-(UILabel *)labAllFB{
    if (!_labAllFB) {
        _labAllFB = [[UILabel alloc] init];
        _labAllFB .frame = CGRectMake(100, 70, self.view.frame.size.width  - 100, 50);
        _labAllFB.textColor = [UIColor redColor];
    }return _labAllFB;
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
