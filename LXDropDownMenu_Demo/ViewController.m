//
//  ViewController.m
//  LXDropDownMenu_Demo
//
//  Created by 从今以后 on 16/2/20.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "ViewController.h"
#import "LXDropDownMenu.h"
#import "YZScoreRangeCell.h"

@interface ViewController () <LXDropDownMenuDelegate, LXDropDownMenuDataSource>

@property (nonatomic) NSArray<NSString *> *sectionTitles;
@property (nonatomic) NSArray<NSArray<NSString *> *> *itemTitles;
@property (weak, nonatomic) IBOutlet LXDropDownMenu *dropDownMenu;
@property (nonatomic) NSMutableDictionary *selectedItemsRecord;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 修改字体大小
    self.dropDownMenu.barButtonTextFont = [UIFont boldSystemFontOfSize:17];

    [self.dropDownMenu registerNib:[YZScoreRangeCell lx_nib] forCellReuseIdentifier:@"YZScoreRangeCell"];
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
    [self.dropDownMenu openMenuInSection:0];
}

#pragma mark - <LXDropDownMenuDataSource>

- (NSInteger)numberOfSectionsInDropDownMenu:(LXDropDownMenu *)menu
{
    return 4;
}

- (NSInteger)dropDownMenu:(LXDropDownMenu *)menu numberOfRowsInSection:(NSInteger)section
{
    if (section < 3) {
        return self.itemTitles[section].count;
    }
    return 2;
}

- (NSArray<NSString *> *)sectionTitlesForDropDownMenu:(LXDropDownMenu *)menu
{
    return self.sectionTitles;
}

- (UITableViewCell *)dropDownMenu:(LXDropDownMenu *)menu cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    cell.selectedBackgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    if (indexPath.section == 3 && indexPath.row == 0) {
        cell.textLabel.text = @"全部";
    } else {
        cell.textLabel.text = self.itemTitles[indexPath.section][indexPath.row];
    }

    return cell;
}

- (CGFloat)dropDownMenu:(LXDropDownMenu *)menu heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            return 44.0;
        }
        return 162.0;
    }
    return 44.0;
}

- (CGFloat)dropDownMenu:(LXDropDownMenu *)menu heightForMenuInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 44 * 10;
        case 1: return 44 * 3;
        case 2: return 44 * 10;
        case 3: return 44 + 162;
    }
    return 233;
}

#pragma mark - <LXDropDownMenuDelegate>

- (void)dropDownMenu:(LXDropDownMenu *)menu didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", self.itemTitles[indexPath.section][indexPath.row]);

    self.selectedItemsRecord[@(indexPath.section)] = indexPath;

    [menu closeMenu];
}

- (void)dropDownMenu:(LXDropDownMenu *)menu willOpenMenuInSection:(NSInteger)section
{
    [menu selectRowAtIndexPath:self.selectedItemsRecord[@(section)] animated:NO];
}

- (void)dropDownMenu:(LXDropDownMenu *)menu didCloseMenuInSection:(NSInteger)section
{
    NSLog(@"%@", self.sectionTitles[section]);
}

@end
