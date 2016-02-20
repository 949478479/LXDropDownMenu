//
//  YZPullDownMenuTableView.m
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "YZPullDownMenuTableView.h"

@interface YZPullDownMenuTableView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak, readwrite) IBOutlet NSLayoutConstraint *heightConstraint;
@end

@implementation YZPullDownMenuTableView

#pragma mark - 配置表视图

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.delegate = self;
    self.dataSource = self;

    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

#pragma mark - 触摸处理

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // 触摸点位于菜单表视图的内容范围内则让表视图处理
    CGRect contentRect = self.bounds;
    contentRect.size.height = MIN(self.contentSize.height, contentRect.size.height);
    if (CGRectContainsPoint(contentRect, point)) {
        return self;
    }
    return nil;
}

#pragma mark - 设置菜单显示

- (void)setRowHeight:(CGFloat)rowHeight
{
    super.rowHeight = rowHeight;

    self.heightConstraint.constant = rowHeight * MIN(self.items.count, self.maxVisibleRows);
}

- (void)setMaxVisibleRows:(NSUInteger)maxVisibleRows
{
    _maxVisibleRows = maxVisibleRows;

    self.heightConstraint.constant = self.rowHeight * MIN(self.items.count, self.maxVisibleRows);
}

- (void)setItems:(NSArray<NSString *> *)items
{
    _items = items.copy;

    self.heightConstraint.constant = self.rowHeight * MIN(self.items.count, self.maxVisibleRows);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                                                            forIndexPath:indexPath];
    cell.textLabel.text = self.items[indexPath.row];

    return cell;
}

@end
