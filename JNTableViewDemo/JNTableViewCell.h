//
//  JNTableViewCell.h
//  JNTableViewDemo
//
//  Created by Yigol on 16/5/4.
//  Copyright © 2016年 Injoinow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JNTableViewCell : UIView


@property (nonatomic, readonly, strong) UIView *contentView;

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIView *selectedBackgroundView;

@property (nonatomic, getter=isSelected) BOOL selected;

@property (nonatomic, assign) NSInteger index;


@property (nonatomic, readonly, strong) UILabel *textLabel;


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)prepareForReuse;

@end
