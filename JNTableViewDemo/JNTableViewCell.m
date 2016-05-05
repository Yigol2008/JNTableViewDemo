//
//  JNTableViewCell.m
//  JNTableViewDemo
//
//  Created by Yigol on 16/5/4.
//  Copyright © 2016年 Injoinow. All rights reserved.
//

#import "JNTableViewCell.h"



@implementation JNTableViewCell

@synthesize contentView = _contentView ,reuseIdentifier = _reuseIdentifier ,backgroundView = _backgroundView ,selectedBackgroundView = _selectedBackgroundView ,index = _index ;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super init];
    if (self) {
        _reuseIdentifier = reuseIdentifier;
        
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 20)];
        
        [self addSubview:_textLabel];
    }
    return self;
}


- (void)prepareForReuse
{
    _index = NSNotFound;
    [self setSelected:NO];
}

#pragma mark - ************ setter
- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        _selected = selected;
        [self setNeedsLayout];
    }
}

#pragma mark - ************ touches
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self setSelected:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setSelected:NO];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self setSelected:NO];
}


@end
