//
//  ViewController.m
//  CheckExpiredDate
//
//  Created by apple on 2018/12/11.
//  Copyright © 2018年 WangXinjia. All rights reserved.
//

#import "ViewController.h"
#import "WxjCheckExpiredDate.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    WxjCheckExpiredDate *checkExpired = [[WxjCheckExpiredDate alloc]init];
    BOOL isExpired = [checkExpired tellExpiredDate];
    if (isExpired) {
        NSLog(@"will expire in a month");
    }
}


@end
