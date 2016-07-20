//
//  ViewController.m
//  LXDropdownMenu_Demo
//
//  Created by 从今以后 on 16/2/20.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "ViewController.h"
#import "LXDropdownMenu.h"
#import "YZScoreRangeCell.h"

@interface ViewController () <LXDropdownMenuDelegate, LXDropdownMenuDataSource>

@property (nonatomic) NSArray<NSString *> *sectionTitles;
@property (nonatomic) NSArray<NSArray<NSString *> *> *itemTitles;
@property (weak, nonatomic) IBOutlet LXDropdownMenu *dropDownMenu;
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

#pragma mark - <LXDropdownMenuDataSource>

- (NSInteger)numberOfSectionsInDropdownMenu:(LXDropdownMenu *)menu
{
    return 4;
}

- (NSInteger)dropdownMenu:(LXDropdownMenu *)menu numberOfRowsInSection:(NSInteger)section
{
    if (section < 3) {
        return self.itemTitles[section].count;
    }
    return 2;
}

- (NSArray<NSString *> *)sectionTitlesForDropdownMenu:(LXDropdownMenu *)menu
{
    return self.sectionTitles;
}

- (UITableViewCell *)dropdownMenu:(LXDropdownMenu *)menu cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const reuseIdentifier = @"UITableViewCell";

    if (indexPath.section == 3) {
        if (indexPath.row == 1) {
            YZScoreRangeCell *cell = [menu dequeueReusableCellWithIdentifier:@"YZScoreRangeCell"];
            [cell setDidTapSearchButton:^{
                [menu deselectRowAtIndex:0 animated:NO];
            }];
            return cell;
        }
    }

    UITableViewCell *cell = [menu dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifier];
//        cell.selectedBackgroundView = [UIView new];
    }

    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.highlightedTextColor = [UIColor orangeColor];
//    cell.selectedBackgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    if (indexPath.section == 3 && indexPath.row == 0) {
        cell.textLabel.text = @"全部";
    } else {
        cell.textLabel.text = self.itemTitles[indexPath.section][indexPath.row];
    }

    return cell;
}

- (CGFloat)dropdownMenu:(LXDropdownMenu *)menu heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            return 44.0;
        }
        return 162.0;
    }
    return 44.0;
}

- (CGFloat)dropdownMenu:(LXDropdownMenu *)menu heightForMenuInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 44 * 10;
        case 1: return 44 * 3;
        case 2: return 44 * 10;
        case 3: return 44 + 162;
    }
    return 233;
}

#pragma mark - <LXDropdownMenuDelegate>

- (void)dropdownMenu:(LXDropdownMenu *)menu didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath - section:%@, row:%@, currentSection:%@", @(indexPath.section), @(indexPath.row), @(menu.currentSection));

    if (indexPath.section < 3) {
        NSLog(@"%@", self.itemTitles[indexPath.section][indexPath.row]);
    }

    self.selectedItemsRecord[@(indexPath.section)] = indexPath;

    [menu closeMenu];
}

- (void)dropdownMenu:(LXDropdownMenu *)menu willOpenMenuInSection:(NSInteger)section
{
    NSLog(@"willOpenMenuInSection - section:%@, currentSection:%@", @(section), @(menu.currentSection));

    [menu selectRowAtIndex:[self.selectedItemsRecord[@(section)] row] animated:NO];
}

- (void)dropdownMenu:(LXDropdownMenu *)menu didOpenMenuInSection:(NSInteger)section
{
    NSLog(@"didOpenMenuInSection - section:%@, currentSection:%@", @(section), @(menu.currentSection));
}

- (void)dropdownMenu:(LXDropdownMenu *)menu willCloseMenuInSection:(NSInteger)section
{
    NSLog(@"willCloseMenuInSection - section:%@, currentSection:%@", @(section), @(menu.currentSection));
}

- (void)dropdownMenu:(LXDropdownMenu *)menu didCloseMenuInSection:(NSInteger)section
{
    NSLog(@"didCloseMenuInSection - section:%@, currentSection:%@", @(section), @(menu.currentSection));

//    NSLog(@"%@", self.sectionTitles[section]);
}

- (BOOL)dropdownMenu:(LXDropdownMenu *)menu shouldSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3 && indexPath.row == 1) {
        return NO;
    }
    return YES;
}

@end
