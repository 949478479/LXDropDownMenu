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

@property (nonatomic) NSArray<NSArray<NSString *> *> *items;
@property (weak, nonatomic) IBOutlet YZPullDownMenu *pullDownMenu;
@property (nonatomic) NSMutableDictionary *selectedItemsRecord;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.selectedItemsRecord = [NSMutableDictionary new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if (self.isViewLoaded && !self.view.window) {
        self.view = nil;
        self.items = nil;
    }
}

- (NSArray<NSArray<NSString *> *> *)items
{
    if (!_items) {
        _items = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MenuItems.plist" ofType:nil]];
    }
    return _items;
}

- (NSArray<NSString *> *)pullDownMenu:(YZPullDownMenu *)menu itemsForMenuInSection:(NSUInteger)section
{
    return self.items[section];;
}

- (void)pullDownMenu:(YZPullDownMenu *)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", self.items[indexPath.section][indexPath.row]);

    self.selectedItemsRecord[@(indexPath.section)] = indexPath;
}

- (void)pullDownMenu:(YZPullDownMenu *)menu willOpenMenuInSection:(NSUInteger)section
{
    [menu selectItemAtIndexPath:self.selectedItemsRecord[@(section)]];
}

@end
