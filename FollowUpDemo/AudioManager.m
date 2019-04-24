//
//  AudioManager.m
//  FollowUpDemo
//
//  Created by ngmmxh on 2019/4/23.
//  Copyright © 2019 ngmmxh. All rights reserved.
//

#import "AudioManager.h"

@implementation AudioManager
/**
 *  存放所有的音频ID
 *  字典: filename作为key, soundID作为value
 */
static NSMutableDictionary *_soundIDDict;

/**
 *  存放所有的音乐播放器
 *  字典: filename作为key, audioPlayer作为value
 */
static NSMutableDictionary *_audioPlayerDict;

/**
 *  初始化
 */
+ (void)initialize
{
    _soundIDDict = [NSMutableDictionary dictionary];
    _audioPlayerDict = [NSMutableDictionary dictionary];
    
    // 设置音频会话类型
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    [session setActive:YES error:nil];
}

/**
 *  播放音乐
 *
 *  @param filename 音乐文件名
 */
+ (AVAudioPlayer *)playMusic:(NSString *)filename
{
    if (!filename) return nil;
    
    // 1.从字典中取出audioPlayer
    AVAudioPlayer *audioPlayer = _audioPlayerDict[filename];
    if (!audioPlayer) { // 创建
        // 加载音乐文件
        NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        
        if (!url) return nil;
        
        // 创建audioPlayer
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        
        // 缓冲
        [audioPlayer prepareToPlay];
        
        //        audioPlayer.enableRate = YES;
        //        audioPlayer.rate = 10.0;
        
        // 放入字典
        _audioPlayerDict[filename] = audioPlayer;
    }
    
    // 2.播放
    if (!audioPlayer.isPlaying) {
        [audioPlayer play];
    }
    
    return audioPlayer;
}

/**
 *  暂停音乐
 *
 *  @param filename 音乐文件名
 */
+ (void)pauseMusic:(NSString *)filename
{
    if (!filename) return;
    
    // 1.从字典中取出audioPlayer
    AVAudioPlayer *audioPlayer = _audioPlayerDict[filename];
    
    // 2.暂停
    if (audioPlayer.isPlaying) {
        [audioPlayer pause];
    }
}

/**
 *  停止音乐
 *
 *  @param filename 音乐文件名
 */
+ (void)stopMusic:(NSString *)filename
{
    if (!filename) return;
    
    // 1.从字典中取出audioPlayer
    AVAudioPlayer *audioPlayer = _audioPlayerDict[filename];
    
    // 2.暂停
    if (audioPlayer.isPlaying) {
        [audioPlayer stop];
        
        // 直接销毁
        [_audioPlayerDict removeObjectForKey:filename];
    }
}

/**
 *  返回当前正在播放的音乐播放器
 */
+ (AVAudioPlayer *)currentPlayingAudioPlayer
{
    for (NSString *filename in _audioPlayerDict) {
        AVAudioPlayer *audioPlayer = _audioPlayerDict[filename];
        
        if (audioPlayer.isPlaying) {
            return audioPlayer;
        }
    }
    
    return nil;
}
@end
