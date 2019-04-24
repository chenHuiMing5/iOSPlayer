//
//  AudioManager.h
//  FollowUpDemo
//
//  Created by ngmmxh on 2019/4/23.
//  Copyright © 2019 ngmmxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>



@interface AudioManager : NSObject
/**
 *  播放音乐
 *
 *  @param filename 音乐文件名
 */
+ (AVAudioPlayer *)playMusic:(NSString *)filename;

/**
 *  暂停音乐
 *
 *  @param filename 音乐文件名
 */
+ (void)pauseMusic:(NSString *)filename;

/**
 *  停止音乐
 *
 *  @param filename 音乐文件名
 */
+ (void)stopMusic:(NSString *)filename;

/**
 *  返回当前正在播放的音乐播放器
 */
+ (AVAudioPlayer *)currentPlayingAudioPlayer;

@end
