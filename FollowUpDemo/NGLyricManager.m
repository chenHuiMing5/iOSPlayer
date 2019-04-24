//
//  NGLyricManager.m
//  FollowUpDemo
//
//  Created by ngmmxh on 2019/4/24.
//  Copyright © 2019 ngmmxh. All rights reserved.
//

#import "NGLyricManager.h"
#import "NGLyricModel.h"
#import "NSDateFormatter+shared.h"
@implementation NGLyricManager

+ (NSMutableArray <NGLyricModel *>*)lyricParserWithFileName:(NSString *)fileName {
    // 根据文件名称获取文件地址
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    // 根据文件地址获取转化后的总体的字符串
    NSString *lyricStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSMutableArray <NGLyricModel *>*arr = [self lyricParseLyricWithLyricString:lyricStr];
    return arr;
}

+ (NSMutableArray <NGLyricModel *>*)lyricParseLyricWithLyricString:(NSString *)lyricString{
    // 将歌词总体字符串按行拆分开，每句都作为一个数组元素存放到数组中
    NSArray *lineStrs = [lyricString componentsSeparatedByString:@"\n"];
    
    // 设置歌词时间正则表达式格式
    NSString *pattern = @"\\[[0-9]{2}:[0-9]{2}.[0-9]{2}\\]";
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
//    // 创建可变数组存放歌词模型
    NSMutableArray *lyrics = [NSMutableArray array];
//
//    // 设置标签过滤数组. Note: 本段代码中, 只解析了时间标签, 其他标记标签没解析
//    NSArray<NSString *> *arrFilter = @[@"[ar", @"[ti", @"[al", @"[by", @"[of", @"t_"];
//    NSMutableArray  * marr = [NSMutableArray array];
//    //过滤
//    for (NSString *lyric in lineStrs) {
//        // 空句直接进入下一次循环.
//        if (!lyric.length) continue;
//
//        // 歌词不以 "[" 开头为非法格式, 直接进入下一次循环
//        if (![lyric hasPrefix: @"["]) continue;
//
//        // 过滤标签, 如果是标签则直接进入下一次循环.
//        BOOL needFilter = NO;
//        for (NSString *filter in arrFilter) {
//            if ([lyric hasPrefix: filter]) {
//                needFilter = YES;
//                break;
//            }
//        }
//        if (needFilter) continue;
//    }
    
    // 遍历歌词字符串数组
    for (NSString *lineStr in lineStrs) {
        
        NSArray *results = [reg matchesInString:lineStr options:0 range:NSMakeRange(0, lineStr.length)];
        
        // 歌词内容
        NSTextCheckingResult *lastResult = [results lastObject];
        NSString *content = [lineStr substringFromIndex:lastResult.range.location + lastResult.range.length];
        
          if (!content.length) continue;
        
        
        // 每一个结果的range
        for (NSTextCheckingResult *result in results) {
          
            
            NSString *time = [lineStr substringWithRange:result.range];
            
            NSDateFormatter *formatter = [NSDateFormatter sharedDateFormatter];
            formatter.dateFormat = @"[mm:ss.SS]";
            NSDate *timeDate = [formatter dateFromString:time];
            NSDate *initDate = [formatter dateFromString:@"[00:00.00]"];
            
            // 创建模型
            NGLyricModel *lyric = [[NGLyricModel alloc] init];
            lyric.text = content;
            // 歌词的开始时间
            lyric.time = [timeDate timeIntervalSinceDate:initDate];
            
            // 将歌词对象添加到模型数组汇总
            [lyrics addObject:lyric];
        }
    }
    
    // 按照时间正序排序
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    [lyrics sortUsingDescriptors:@[sortDes]];
    
    return lyrics;
}


@end
