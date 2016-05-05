//
//  JNTableView.h
//  JNTableViewDemo
//
//  Created by Yigol on 16/5/4.
//  Copyright © 2016年 Injoinow. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JNTableView;
@class JNTableViewCell;


@protocol JNTableViewDataSource <NSObject>

@required
- (NSInteger)numberOfRowsInTableView:(JNTableView *)tableView;
- (JNTableViewCell *)tableView:(JNTableView *)tableView cellAtRow:(NSInteger)row;
@optional
- (CGFloat)tableView:(JNTableView *)tableView cellHeightAtRow:(NSInteger)row;

@end

@protocol JNTableViewDelegate <NSObject>

@optional

- (void)tableView:(JNTableView *)tableView didTapAtRow:(NSInteger)row;

@end

@interface JNTableView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, weak) id<JNTableViewDelegate> tableDelegate;

@property (nonatomic, weak) id<JNTableViewDataSource> tableDataSource;

@property (nonatomic, readonly, strong) NSArray *visibleCells;

@property (nonatomic, assign) NSInteger selectedIndex;

- (JNTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)reloadData;

@end






