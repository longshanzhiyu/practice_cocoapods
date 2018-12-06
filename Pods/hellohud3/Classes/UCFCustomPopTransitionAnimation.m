//
//  UCFCustomPopTransitionAnimation.m
//  VXinRedDemo
//
//  Created by njw on 2018/7/11.
//  Copyright © 2018年 njw. All rights reserved.
//

#import "UCFCustomPopTransitionAnimation.h"

@implementation UCFCustomPopTransitionAnimation
#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    return 0.5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    // 下面这几个参数的获取和意义我们不说了，前面代码中都有
    UIViewController * fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    //UIView           * fromView           = [transitionContext viewForKey:UITransitionContextFromViewKey];
    //UIView           * toView             = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView           * contextView        = [transitionContext containerView];
    
    // 接下来还是我们的判断是present还是dismiss
    /*
     
     这个逻辑在这里在整理一次，怕不理解：
     我们把 fromViewController 比喻成A   toViewController比喻成B
     当从A prsent 到 B的时候。 A 就是B的presentingViewController B就是A的presentedViewController 这个过程是不受prsent 还是 dismiss影响的
     也就是从B dismiss 到 A 的时候。A 依旧是B的presentingViewController B依旧是A的presentedViewController
     不过在 B dismiss 到 A 的时候， B 就成了fromViewController A 就成了 toViewController
     
     下面的逻辑  A  P到 B  toViewController.presentingViewController == A
     B  D到 A  toViewController.presentingViewController 等价于 A.presentingViewController
     也就是     A.presentingViewController == B 显然不成立
     
     */
    
    BOOL isPresent   = (toViewController.presentingViewController == fromViewController);
    
    UIView *tempView = nil;
    if (isPresent) {
        
        tempView = [fromViewController.view snapshotViewAfterScreenUpdates:NO];
        
        tempView.frame = fromViewController.view.frame;
        fromViewController.view.hidden = YES;
        [contextView addSubview:tempView];
        [contextView addSubview:toViewController.view];
        //           toViewController.view.frame = CGRectMake(0, contextView.frame.size.height, contextView.frame.size.width, 400);
//        toViewController.view.layer.cornerRadius = 4;
        toViewController.view.clipsToBounds = YES;
        toViewController.view.frame = contextView.bounds;
        toViewController.view.center = contextView.center;
        
    }else{
        
        //参照present动画的逻辑，present成功后，containerView的最后一个子视图就是截图视图，我们将其取出准备动画
        NSArray *subviewsArray = contextView.subviews;
        tempView = subviewsArray[MIN(subviewsArray.count, MAX(0, subviewsArray.count - 2))];
    }
    
    if (isPresent) {
        
        // Present
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.55 initialSpringVelocity:1.0 / 0.55 options:0 animations:^{
            CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            //                    popAnimation.duration = 0.4;
            //                    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
            //                                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
            //                                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
            //                                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)], [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            //                    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
            popAnimation.keyTimes = @[@0.5f];
            popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [toViewController.view.layer addAnimation:popAnimation forKey:nil];
            //                        toViewController.view.transform   = CGAffineTransformMakeTranslation(0, -400);
            //                        tempView.transform = CGAffineTransformMakeScale(0.85, 0.85);
            
        } completion:^(BOOL finished) {
            
            BOOL  cancle = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!cancle];
            
            if (cancle) {
                
                //失败后，我们要把vc1显示出来
                fromViewController.view.hidden = NO;
                //然后移除截图视图，因为下次触发present会重新截图
                [tempView removeFromSuperview];
            }
        }];
        
    }else{
        
        // Dismiss
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            fromViewController.view.transform = CGAffineTransformIdentity;
            tempView.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            
            if ([transitionContext transitionWasCancelled]) {
                
                //失败了接标记失败
                [transitionContext completeTransition:NO];
            }else{
                //如果成功了，我们需要标记成功，同时让vc1显示出来，然后移除截图视图，
                [transitionContext completeTransition:YES];
                toViewController.view.hidden = NO;
                [tempView removeFromSuperview];
            }
        }];
    }
}
@end
