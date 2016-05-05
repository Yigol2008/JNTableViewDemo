//
//  JNTableView.m
//  JNTableViewDemo
//
//  Created by Yigol on 16/5/4.
//  Copyright © 2016年 Injoinow. All rights reserved.
//

#import "JNTableView.h"
#import "JNTableViewCell.h"


#define kJNTableViewDefaultHeight 44.0f

typedef struct {
    BOOL funcNumberOfRows;
    BOOL funcCellAtRow;
    BOOL funcHeightRow;
    BOOL funcPullDownCell;
}JNTableViewDataSourceresponse;

@interface JNTableView ()

// 复用池
@property (nonatomic, strong) NSMutableSet *cacheCells;
// 储存可视区域的视图及其index
@property (nonatomic, strong) NSMutableDictionary *visibleCellsMap;

/** tableView中cell的数量 */
@property (nonatomic, assign) NSUInteger numberOfCells;
/** tableView中每个cell 对应的 Y 的 offset */
@property (nonatomic, strong) NSMutableDictionary *cellYOffsets;
/** tableView中cell的高度 数组 */
@property (nonatomic, strong) NSMutableArray *cellHeightArry;

@property (nonatomic, assign) JNTableViewDataSourceresponse dataSourceResponse;

@end

@implementation JNTableView

#pragma mark - ************ setter
- (void)setTableDataSource:(id<JNTableViewDataSource>)tableDataSource
{
    _tableDataSource = tableDataSource;
    _dataSourceResponse.funcNumberOfRows = [_tableDataSource respondsToSelector:@selector(numberOfRowsInTableView:)];
    _dataSourceResponse.funcCellAtRow = [_tableDataSource respondsToSelector:@selector(tableView:cellAtRow:)];
    _dataSourceResponse.funcHeightRow = [_tableDataSource respondsToSelector:@selector(tableView:cellHeightAtRow:)];
    
}

#pragma mark - ************ init
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"--- init ---");
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"--- initWithFrame ---");
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _cacheCells = [NSMutableSet set];
    _visibleCellsMap = [NSMutableDictionary dictionary];
    _cellYOffsets = [NSMutableDictionary dictionary];
    _cellHeightArry = [NSMutableArray array];
    _selectedIndex = NSNotFound;
    [self addTapTarget:self selector:@selector(handleTapGesture:)];
}

- (void)reloadData
{
    [self reduceContentSize];
    [self layoutNeedDisplayCells];
}

/** 计算tableView的ContentSize */
- (void)reduceContentSize
{
    _numberOfCells = [_tableDataSource numberOfRowsInTableView:self];
    CGFloat height = 0;
    for (int i = 0; i < _numberOfCells; i++) {
        CGFloat cellHeight = (_dataSourceResponse.funcHeightRow ? [_tableDataSource tableView:self cellHeightAtRow:i] : kJNTableViewDefaultHeight);
        [_cellHeightArry addObject:@(cellHeight)];
        height += cellHeight;
        [_cellYOffsets setObject:@(height) forKey:@(i)];
    }
    if (height < CGRectGetHeight(self.frame)) {
        height = CGRectGetHeight(self.frame) + 0.00001;
    }
    CGSize size = CGSizeMake(CGRectGetWidth(self.frame), height);
    [self setContentSize:size];
}


#pragma mark - ************ layout
- (void)layoutSubviews
{
    [self layoutNeedDisplayCells];
}

/** tableview显示范围内的cell重新布局layout */
- (void)layoutNeedDisplayCells
{
    NSRange displayRange = [self displayRange];
    for (int i = (int)displayRange.location; i < displayRange.length + displayRange.location; i++) {
        JNTableViewCell *cell = [self cellForRow:i];
        [self addCell:cell atRow:i];
        cell.frame = [self rectForCellAtRow:i];
        if (_selectedIndex == i) {
            cell.selected = YES;
        } else {
            cell.selected = NO;
        }
    }
    
    [self cleanUnusedCellsWithDispalyRange:displayRange];
}

/** tableView显示范围内的range */
- (NSRange)displayRange
{
    if (_numberOfCells == 0) {
        return NSMakeRange(0, 0);
    }
    
    int beginIndex = 0;
    CGFloat beginHeight = self.contentOffset.y;
    CGFloat displayBeginHeight = -0.00000001f;
    
    for (int i = 0; i < _numberOfCells; i++) {
        CGFloat cellHeight = [(NSNumber *)_cellHeightArry[i] floatValue];
        displayBeginHeight += cellHeight;
        if (displayBeginHeight > beginHeight) {
            beginIndex = i;
            break;
        }
    }
    int endIndex = beginIndex;
    CGFloat displayEndHeight = self.contentOffset.y + CGRectGetHeight(self.frame);
    for (int i = beginIndex; i < _numberOfCells; i++) {
        CGFloat cellYOffset = [(NSNumber *)_cellYOffsets[@(i)] floatValue];
        if (cellYOffset > displayEndHeight) {
            endIndex = i;
            break;
        }
        if (i == _numberOfCells - 1) {
            endIndex = i;
            break;
        }
    }
    
    NSLog(@"--- %@",NSStringFromRange(NSMakeRange(beginIndex, endIndex - beginIndex + 1)));
    return NSMakeRange(beginIndex, endIndex - beginIndex + 1);
}
/** 获取index对应的cell */
- (JNTableViewCell *)cellForRow:(NSInteger)rowIndex
{
    JNTableViewCell *cell = [_visibleCellsMap objectForKey:@(rowIndex)];
    if (!cell) {
        cell = [_tableDataSource tableView:self cellAtRow:rowIndex];
    }
    return cell;
}

- (void)addCell:(JNTableViewCell *)cell atRow:(NSInteger)row
{
    [self addSubview:cell];
    cell.index = row;
    [self updateVisibleCell:cell withIndex:row];
}
/** 跟新可见的cell */
- (void)updateVisibleCell:(JNTableViewCell *)cell withIndex:(NSInteger)index
{
    _visibleCellsMap[@(index)] = cell;
    cell.contentView.backgroundColor = [UIColor clearColor];
}
/** 获取每个index对应的cell的rect */
- (CGRect)rectForCellAtRow:(int)rowIndex
{
    if (rowIndex < 0 || rowIndex >= _numberOfCells) {
        return CGRectZero;
    }
    CGFloat cellYOffset = [(NSNumber *)_cellYOffsets[@(rowIndex)] floatValue];
    CGFloat cellHieght = [(NSNumber *)_cellHeightArry[rowIndex] floatValue];
    return CGRectMake(0, cellYOffset - cellHieght, CGRectGetWidth(self.frame), cellHieght);
    
}
/** 清楚显示范围range 内 没用有到的cell */
- (void)cleanUnusedCellsWithDispalyRange:(NSRange)range
{
    NSDictionary *dic = [self.visibleCellsMap copy];
    NSArray *keys = dic.allKeys;
    for (NSNumber *rowIndex in keys) {
        int row = rowIndex.intValue;
        if (!NSLocationInRange(row, range)) {
            JNTableViewCell *cell = [self.visibleCellsMap objectForKey:rowIndex];
            [self.visibleCellsMap removeObjectForKey:rowIndex];
            [self enqueueTableViewCell:cell];
        }
    }
}

#pragma mark - ************ Cell Queue
- (void)enqueueTableViewCell:(JNTableViewCell *)cell
{
    if (cell) {
        [cell prepareForReuse];
        [self.cacheCells addObject:cell];
        [cell removeFromSuperview];
    }
}
/** cell的复用 */
- (JNTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    JNTableViewCell *cell = nil;
    for (JNTableViewCell *each in self.cacheCells) {
        if ([each.reuseIdentifier isEqualToString:identifier]) {
            cell = each;
            break;
        }
    }
    if (cell) {
        [self.cacheCells removeObject:cell];
    }
    return cell;
}

#pragma mark - ************ tapGesture
- (void)addTapTarget:(id)target selector:(SEL)selecotr
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:selecotr];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:self];
    NSArray *cells = _visibleCellsMap.allValues;
    for (JNTableViewCell *each in cells) {
        CGRect rect = each.frame;
        if (CGRectContainsPoint(rect, point)) {
            if ([_tableDelegate respondsToSelector:@selector(tableView:didTapAtRow:)]) {
                [_tableDelegate tableView:self didTapAtRow:each.index];
            }
            each.selected = YES;
            _selectedIndex = each.index;
        } else {
            each.selected = NO;
        }
    }
}

@end
