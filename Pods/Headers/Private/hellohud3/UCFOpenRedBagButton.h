//
//  UCFOpenRedBagButton.h
//  VXinRedDemo
//
//  Created by njw on 2018/7/11.
//  Copyright © 2018年 njw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UCFOpenRedBagButton : UIButton
@property (nonatomic, strong) NSArray *animationImagesArray;

- (void)startAnimation;
- (void)stopAnimation;
@end
