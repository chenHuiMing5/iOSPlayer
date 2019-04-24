//
//  NGLyricManager.h
//  FollowUpDemo
//
//  Created by ngmmxh on 2019/4/24.
//  Copyright © 2019 ngmmxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGLyricModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NGLyricManager : NSObject
///解析本地歌词
+ (NSMutableArray *)lyricParserWithFileName:(NSString *)fileName;

/**
 解析后台 歌词字符串

 @param lyricString 后台歌词字符串
 @return NGLyricModel 数组
 */
+ (NSMutableArray <NGLyricModel *>*)lyricParseLyricWithLyricString:(NSString *)lyricString;

@end

NS_ASSUME_NONNULL_END
