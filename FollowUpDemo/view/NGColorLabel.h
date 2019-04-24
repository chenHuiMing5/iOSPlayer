//
//  NGColorLabel.h
//  FollowUpDemo
//
//  Created by ngmmxh on 2019/4/24.
//  Copyright © 2019 ngmmxh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NGColorLabel : UILabel

/** 歌词播放进度 */
@property (nonatomic,assign) CGFloat progress;

/** 歌词颜色 */
@property (nonatomic,strong) UIColor *currentColor;

@end

NS_ASSUME_NONNULL_END
