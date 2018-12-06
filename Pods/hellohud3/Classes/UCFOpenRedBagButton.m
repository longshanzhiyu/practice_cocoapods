//
//  UCFOpenRedBagButton.m
//  VXinRedDemo
//
//  Created by njw on 2018/7/11.
//  Copyright © 2018年 njw. All rights reserved.
//

#import "UCFOpenRedBagButton.h"

@interface UCFOpenRedBagButton ()
@property (weak, nonatomic) UIImageView *rotateImageView;
@end

@implementation UCFOpenRedBagButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
        
    }
    return self;
}

- (void)createUI {
    UIImageView *imageView = [[UIImageView alloc] init];
    [self addSubview:imageView];
    self.rotateImageView = imageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.rotateImageView.frame = self.bounds;
    if (self.animationImagesArray.count>0) {
        
    }
}

- (void)startAnimation {
    [self setBackgroundImage:nil forState:UIControlStateNormal];
    
    self.rotateImageView.contentMode = UIViewContentModeScaleAspectFit;
    //设置动画总时间
    self.rotateImageView.animationDuration=0.6;
    //设置重复次数，0表示无限
    self.rotateImageView.animationRepeatCount = 0;
    
    //开始动画
    if (!self.rotateImageView.isAnimating) {
        [self.rotateImageView startAnimating];
    }
}

- (void)stopAnimation {
    //开始动画
    if (self.rotateImageView.isAnimating) {
        [self.rotateImageView stopAnimating];
    }
}

- (void)setAnimationImagesArray:(NSArray *)animationImagesArray
{
    _animationImagesArray = animationImagesArray;
    _rotateImageView.animationImages = animationImagesArray;
}

- (void)dealloc {
    [self stopAnimation];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
