//
//  ViewController.m
//  YZPullDownMenu_Demo
//
//  Created by 从今以后 on 16/2/20.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "ViewController.h"
#import "YZPullDownMenu.h"

@interface ViewController () <YZPullDownMenuDelegate>

@property (weak, nonatomic) IBOutlet YZPullDownMenu *pullDownMenu;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if (self.isViewLoaded && !self.view.window) {
        self.view = nil;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view layoutIfNeeded];
}
- (NSArray<NSString *> *)pullDownMenu:(YZPullDownMenu *)menu itemsForMenuAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            return @[@"附近", @"和平区", @"河西区", @"河东区", @"南开区", @"河北区", @"虹桥区", @"北辰区", @"西青区", @"津南区", @"滨海新区"];
        case 1:
            return @[@"商家贴分排序", @"离我最近", @"评价最好"];
        case 2:
            return @[@"全部美食", @"火锅", @"小吃快餐", @"烧烤", @"西餐", @"面包甜点", @"咖啡厅", @"天津菜", @"日料", @"韩料", @"其它"];
    }
    NSAssert(NO, @"这不科学");
    return nil;
}

@end
