//
//  ViewController.m
//  FollowUpDemo
//
//  Created by ngmmxh on 2019/4/23.
//  Copyright © 2019 ngmmxh. All rights reserved.
//

#import "ViewController.h"
#import "NGTwoViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    UIButton *btnTest = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTest.backgroundColor = [UIColor redColor];
    btnTest.frame = CGRectMake(100, 100, 100, 100);
    [btnTest addTarget:self action:@selector(onClickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnTest];
    
    
}
-(void)onClickBtn{
    NGTwoViewController *vc = [[NGTwoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:NO];
}

@end
