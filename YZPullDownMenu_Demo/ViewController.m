//
//  ViewController.m
//  YZPullDownMenu_Demo
//
//  Created by 从今以后 on 16/2/20.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "ViewController.h"
#import "YZPullDownMenu.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet YZPullDownMenu *pullDownMenu;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pullDownMenu.willOpenLeftMenu = ^(YZPullDownMenu *menu) {
        return @[@"附近", @"和平区", @"河西区", @"河东区", @"南开区", @"河北区", @"虹桥区", @"北辰区", @"西青区", @"津南区", @"滨海新区"];
    };

    self.pullDownMenu.willOpenCenterMenu = ^(YZPullDownMenu *menu) {
        return @[@"商家贴分排序", @"离我最近", @"评价最好"];
    };

    self.pullDownMenu.willOpenRightMenu = ^(YZPullDownMenu *menu) {
        return @[@"全部美食", @"火锅", @"小吃快餐", @"烧烤", @"西餐", @"面包甜点", @"咖啡厅", @"天津菜", @"日料", @"韩料", @"其它"];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    
}

@end
