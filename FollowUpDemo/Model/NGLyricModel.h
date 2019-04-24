//
//  AudioModel.h
//  FollowUpDemo
//
//  Created by ngmmxh on 2019/4/23.
//  Copyright © 2019 ngmmxh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGLyricModel : NSObject
/** 歌词内容 */
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) double time;
@end

NS_ASSUME_NONNULL_END
