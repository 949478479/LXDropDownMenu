//
//  ViewController.m
//  YZPullDownMenu_Demo
//
//  Created by 从今以后 on 16/2/20.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "ViewController.h"
#import "YZPullDownMenu.h"
#import "YZScoreRangeCell.h"

@interface ViewController () <YZPullDownMenuDelegate, YZPullDownMenuDataSource>

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

    [self.pullDownMenu registerNib:[YZScoreRangeCell lx_nib] forCellReuseIdentifier:@"YZScoreRangeCell"];
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
        _sectionTitles = @[@"附近", @"排序", @"分类", @"积分"];
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

#pragma mark - <YZPullDownMenuDataSource>

- (NSInteger)numberOfSectionsInPullDownMenu:(YZPullDownMenu *)menu
{
    return 4;
}

- (NSInteger)pullDownMenu:(YZPullDownMenu *)menu numberOfRowsInSection:(NSInteger)section
{
    if (section < 3) {
        return self.itemTitles[section].count;
    }
    return 2;
}

- (NSArray<NSString *> *)sectionTitlesForPullDownMenu:(YZPullDownMenu *)menu
{
    return self.sectionTitles;
}

- (UITableViewCell *)pullDownMenu:(YZPullDownMenu *)menu cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const reuseIdentifier = @"UITableViewCell";

    if (indexPath.section == 3) {
        if (indexPath.row == 1) {
            return [menu dequeueReusableCellWithIdentifier:@"YZScoreRangeCell"];
        }
    }

    UITableViewCell *cell = [menu dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifier];
        cell.selectedBackgroundView = [UIView new];
    }

    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.highlightedTextColor = [UIColor orangeColor];
    cell.selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];

    if (indexPath.section == 3 && indexPath.row == 0) {
        cell.textLabel.text = @"全部";
    } else {
        cell.textLabel.text = self.itemTitles[indexPath.section][indexPath.row];
    }

    return cell;
}

- (CGFloat)pullDownMenu:(YZPullDownMenu *)menu heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            return 44.0;
        }
        return 162.0;
    }
    return 44.0;
}

- (CGFloat)pullDownMenu:(YZPullDownMenu *)menu heightForMenuInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 44 * 10;
        case 1: return 44 * 3;
        case 2: return 44 * 10;
        case 3: return 44 + 162;
    }
    return 233;
}

#pragma mark - <YZPullDownMenuDelegate>

- (void)pullDownMenu:(YZPullDownMenu *)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", self.itemTitles[indexPath.section][indexPath.row]);

    self.selectedItemsRecord[@(indexPath.section)] = indexPath;
}

- (void)pullDownMenu:(YZPullDownMenu *)menu willOpenMenuInSection:(NSInteger)section
{
    [menu selectItemAtIndexPath:self.selectedItemsRecord[@(section)]];
}

- (void)pullDownMenu:(YZPullDownMenu *)menu didCloseMenuInSection:(NSInteger)section
{
    NSLog(@"%@", self.sectionTitles[section]);
}

@end
