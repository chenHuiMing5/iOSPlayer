//
//  NGColorLabel.m
//  FollowUpDemo
//
//  Created by ngmmxh on 2019/4/24.
//  Copyright © 2019 ngmmxh. All rights reserved.
//

#import "NGColorLabel.h"

@implementation NGColorLabel
- (void)setProgress:(CGFloat)progress {
    
    _progress = progress;
    // 重绘
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    // 设置颜色
    [self.currentColor set];
    rect.size.width *= self.progress;
    
    // 图形混合模式
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
}

- (UIColor *)currentColor {
    
    if (_currentColor == nil) {
        _currentColor = [UIColor grayColor];
    }
    return _currentColor;
}

@end
