//
//  ViewController.m
//  JNTableViewDemo
//
//  Created by Yigol on 16/5/4.
//  Copyright © 2016年 Injoinow. All rights reserved.
//

#import "ViewController.h"
#import "JNTableView.h"
#import "JNTableViewCell.h"

@interface ViewController ()<JNTableViewDataSource,JNTableViewDelegate>

@property (nonatomic, strong) JNTableView *tableView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView = [[JNTableView alloc] initWithFrame:CGRectMake(20, 40, 280, 450)];
    self.tableView.backgroundColor = [UIColor yellowColor];
    self.tableView.tableDelegate = self;
    self.tableView.tableDataSource = self;
    
    [self.view addSubview:self.tableView];
    
    [self.tableView reloadData];
}


- (NSInteger)numberOfRowsInTableView:(JNTableView *)tableView
{
    return 30;
}

- (JNTableViewCell *)tableView:(JNTableView *)tableView cellAtRow:(NSInteger)row
{
    static NSString *const cellId = @"cellId";
    JNTableViewCell *cell = (JNTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[JNTableViewCell alloc] initWithReuseIdentifier:cellId];
        cell.tag = row;
        NSLog(@"row ---> %ld",(long)row);
    }
    cell.backgroundColor = [self getRandomColor];
    cell.textLabel.text =[NSString stringWithFormat:@"hehe = %ld ---> tag = %ld",(long)row,(long)cell.tag];
    cell.textLabel.backgroundColor = [UIColor lightGrayColor];
    
    return cell;
}

- (CGFloat)tableView:(JNTableView *)tableView cellHeightAtRow:(NSInteger)row
{
    return 50;
}



- (void)tableView:(JNTableView *)tableView didTapAtRow:(NSInteger)row
{
    NSLog(@" tap ===> %ld",row);
}

- (UIColor *)getRandomColor{
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat green = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;
    return  [UIColor colorWithRed:red
                            green:green
                             blue:blue
                            alpha:1.0];
}

@end
