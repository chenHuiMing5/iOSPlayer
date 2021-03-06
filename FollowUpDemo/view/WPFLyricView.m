//
//  WPFLyricView.m
//  WPFMusicPlayer
//
//  Created by 王鹏飞 on 16/8/28.
//  Copyright © 2016年 王鹏飞. All rights reserved.
//

// 忽略前缀
#define MAS_SHORTHAND

// 集中装箱  基本数据类型转换成对象
#define MAS_SHORTHAND_GLOBALS
#import "WPFLyricView.h"
#import "Masonry.h"
#import "NGColorLabel.h"
#import "WPFLyric.h"
#import "WPFSliderView.h"

@interface WPFLyricView ()<UIScrollViewDelegate>

/* 水平滚动的大view，包含音乐播放界面及歌词界面 */
//@property (nonatomic,weak) UIScrollView *hScrollerView;

/** 定位播放的View */
@property (nonatomic,weak) WPFSliderView *sliderView;

@end


@implementation WPFLyricView

@synthesize currentLyricIndex = _currentLyricIndex;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {

    UIScrollView *vScrollerView = [[UIScrollView alloc] init];
    [self addSubview:vScrollerView];
    vScrollerView.frame = self.bounds;
    vScrollerView.delegate = self;
    self.vScrollerView = vScrollerView;

}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.vScrollerView.contentSize = CGSizeMake(0, self.lyrics.count * self.rowHeight);
#warning 必须使用self.bounds.size.height  不能使用self.vScrollerView.bounds.size.height   这个layoutSubviews只作用于self   所以self.vScrollerView可能还没有布局完成
    CGFloat top = (self.bounds.size.height - self.rowHeight) * 0.5;
    CGFloat bottom = top;
    self.vScrollerView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
    
}

#pragma mark UIScrollerView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        [self vScrollerViewDidScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.vScrollerView) {
        self.sliderView.hidden = NO;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    if (scrollView == self.vScrollerView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.vScrollerView.isDragging == YES) {
                return ;
            }
            self.sliderView.hidden = YES;
        });
    }
}

/**
 *  水平滚动
 */
- (void)hScrollerViewDidScroll {
    
//    CGFloat scrollProgress = self.hScrollerView.contentOffset.x / self.bounds.size.width;
//    NSLog(@"%lf",scrollProgress);
//    if ([self.delegate respondsToSelector:@selector(lyricView:withProgress:)]) {
//        [self.delegate lyricView:self withProgress:scrollProgress];
//    }
}

- (void)vScrollerViewDidScroll {
    CGFloat offy = self.vScrollerView.contentOffset.y + self.vScrollerView.contentInset.top;
    NSInteger currentIndex = offy / self.rowHeight;
    if (currentIndex < 0) {
        currentIndex = 0;
    }else if(currentIndex > self.lyrics.count - 1){
        currentIndex = self.lyrics.count - 1;
    }
    WPFLyric *lyric = self.lyrics[currentIndex];
    self.sliderView.time = lyric.time;
}


#pragma mark setter和getter
- (void)setLyrics:(NSArray *)lyrics {
    
    _lyrics = lyrics;
    [self.vScrollerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i =0; i < lyrics.count; i ++) {
        
        NGColorLabel *colorLabel = [[NGColorLabel alloc] init];
        colorLabel.textColor = [UIColor whiteColor];
        colorLabel.font = [UIFont systemFontOfSize:16];
        WPFLyric *lyric = lyrics[i];
        colorLabel.text = lyric.content;
        [self.vScrollerView addSubview:colorLabel];
        
        // 添加约束
        [colorLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.vScrollerView);
            make.top.equalTo(self.rowHeight * i);
            make.height.equalTo(self.rowHeight);
        }];
    }
    
    self.vScrollerView.contentSize = CGSizeMake(0, self.lyrics.count * self.rowHeight);
}

- (NSInteger)rowHeight {
    if (_rowHeight == 0) {
        _rowHeight = 44;
    }
    return _rowHeight;
}


- (void)setCurrentLyricIndex:(NSInteger)currentLyricIndex {
    
    // 切歌时数组越界
    NGColorLabel *preLabel = self.vScrollerView.subviews[self.currentLyricIndex];
    preLabel.progress = 0;
    preLabel.font = [UIFont systemFontOfSize:16];
    _currentLyricIndex = currentLyricIndex;
    NGColorLabel *colorLabel = self.vScrollerView.subviews[currentLyricIndex];
    colorLabel.font = [UIFont systemFontOfSize:20];
    
    colorLabel.currentColor = [UIColor redColor];
//    if (self.vScrollerView.hidden == NO) {
//        return;
//    }
    
    NSInteger offY = currentLyricIndex * self.rowHeight - self.vScrollerView.contentInset.top;
    self.vScrollerView.contentOffset = CGPointMake(0, offY);
    [self.vScrollerView setContentOffset:CGPointMake(0, offY) animated:YES];
}

- (NSInteger)currentLyricIndex {
    
    if (_currentLyricIndex <0) {
        _currentLyricIndex = 0;
    }else if(_currentLyricIndex >= self.lyrics.count - 1){
        _currentLyricIndex = self.lyrics.count - 1;
    }
    return _currentLyricIndex;
}

- (void)setLyricProgress:(CGFloat)lyricProgress {
    
    _lyricProgress = lyricProgress;
    NGColorLabel *colorLabel = self.vScrollerView.subviews[self.currentLyricIndex];
    colorLabel.progress = lyricProgress;
}


@end
