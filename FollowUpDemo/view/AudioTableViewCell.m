//
//  AudioTableViewCell.m
//  FollowUpDemo
//
//  Created by ngmmxh on 2019/4/24.
//  Copyright © 2019 ngmmxh. All rights reserved.
//

#import "AudioTableViewCell.h"
#import "Masonry.h"
@implementation AudioTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
        
    }
    return self;
}

-(void)createUI{
    [self addSubview:self.labTitle];
    [self.labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
}
-(NGColorLabel *)labTitle{
    if (!_labTitle) {
        _labTitle = [[NGColorLabel alloc] init];
        _labTitle.textAlignment = NSTextAlignmentCenter;
        _labTitle.textColor = [UIColor blackColor];
    }return _labTitle;
}
@end
