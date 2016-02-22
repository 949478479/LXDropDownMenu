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

@property (nonatomic) NSArray<NSString *> *sectionTitles;
@property (nonatomic) NSArray<NSArray<NSString *> *> *itemTitles;
@property (weak, nonatomic) IBOutlet YZPullDownMenu *pullDownMenu;
@property (nonatomic) NSMutableDictionary *selectedItemsRecord;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 修改字体大小
    self.pullDownMenu.barButtonTextFont = [UIFont boldSystemFontOfSize:17];
    self.pullDownMenu.itemTextFont = self.pullDownMenu.barButtonTextFont;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if (self.isViewLoaded && !self.view.window) {
        self.view = nil;
        self.itemTitles = nil;
        self.sectionTitles = nil;
    }
}

- (NSArray<NSString *> *)sectionTitles
{
    if (!_sectionTitles) {
        _sectionTitles = @[@"附近", @"排序", @"分类"];
    }
    return _sectionTitles;
}

- (NSMutableDictionary *)selectedItemsRecord
{
    if (!_selectedItemsRecord) {
        _selectedItemsRecord = [NSMutableDictionary new];
    }
    return _selectedItemsRecord;
}

- (NSArray<NSArray<NSString *> *> *)itemTitles
{
    if (!_itemTitles) {
        _itemTitles = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MenuItems.plist" ofType:nil]];
    }
    return _itemTitles;
}

- (IBAction)openMenu:(id)sender
{
    [self.pullDownMenu openMenuInSection:0];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pullDownMenu closeMenu];
    });
}

- (NSUInteger)numberOfSectionsInPullDownMenu:(YZPullDownMenu *)menu
{
    return self.sectionTitles.count;
}

- (NSArray<NSString *> *)sectionTitlesForPullDownMenu:(YZPullDownMenu *)menu
{
    return self.sectionTitles;
}

- (NSArray<NSString *> *)pullDownMenu:(YZPullDownMenu *)menu itemTitlesForMenuInSection:(NSUInteger)section
{
    return self.itemTitles[section];;
}

- (void)pullDownMenu:(YZPullDownMenu *)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", self.itemTitles[indexPath.section][indexPath.row]);

    self.selectedItemsRecord[@(indexPath.section)] = indexPath;
}

- (void)pullDownMenu:(YZPullDownMenu *)menu willOpenMenuInSection:(NSUInteger)section
{
    [menu selectItemAtIndexPath:self.selectedItemsRecord[@(section)]];
}

- (void)pullDownMenu:(YZPullDownMenu *)menu didCloseMenuInSection:(NSUInteger)section
{
    NSLog(@"%@", self.sectionTitles[section]);
}

@end
