//
//  UCFRedBagViewController.m
//  VXinRedDemo
//
//  Created by njw on 2018/7/11.
//  Copyright © 2018年 njw. All rights reserved.
//

#import "UCFRedBagViewController.h"
#import "UCFCustomPopTransitionAnimation.h"
#import "UCFOpenRedBagButton.h"

#define Width_RedBag [UIScreen mainScreen].bounds.size.width
#define Height_RedBag [UIScreen mainScreen].bounds.size.height
#define Rate_UpTangentLine 0.618f
#define Rate_UpTangentLine_TangentDot 0.2f
#define Rate_UpTangentOpen_Line 0.15f
#define Y_TangentDot ((Height_RedBag*Rate_UpTangentLine)+(Width_RedBag*Rate_UpTangentLine_TangentDot))
#define Y_Open_TangentDot (Y_TangentDot - (Height_RedBag*(Rate_UpTangentLine-Rate_UpTangentOpen_Line)))

@interface UCFRedBagViewController () <UIViewControllerTransitioningDelegate>
@property (strong, nonatomic) UIButton *closeBtn;
@property (strong, nonatomic) UCFOpenRedBagButton *sendBtn;
@property (nonatomic, strong) CAShapeLayer *redLayer;
@property (nonatomic, strong) CAShapeLayer *lineLayer;
@property (weak, nonatomic) IBOutlet UILabel *rebTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *openedCloseButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *logoTileLabel;
@property (weak, nonatomic) IBOutlet UILabel *desCribeLabel;
@property (weak, nonatomic) IBOutlet UILabel *header5Label;
@property (weak, nonatomic) IBOutlet UIView *resultBackView;


@property (weak, nonatomic) IBOutlet UILabel *result1Label;
@property (weak, nonatomic) IBOutlet UILabel *result2Label;
@property (weak, nonatomic) IBOutlet UILabel *result3Label;
@property (weak, nonatomic) IBOutlet UILabel *result4Label;
@property (weak, nonatomic) IBOutlet UILabel *result5Label;

@end

@implementation UCFRedBagViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        // 没有设置的话确实会造成presentVC被移除，需要dimiss时再添加（即使不添加也没问题只是会有一个淡出的动画），但是我测试的时候如果设置了的话，dismiss结束后presentVC也消失了
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.fold) {
        [self createUnfoldnedUI];
    }
    else {
        [self createFoldedUI];
    }
    [self setUnOpenUIState];
}

- (void)createUnfoldnedUI {
    self.closeBtn.hidden = YES;
    self.result4Label.text = @"您已成功领取一张返现券\n您使用后，才能再次领取哦!";
    self.result4Label.textAlignment = NSTextAlignmentCenter;
    self.result4Label.numberOfLines = 0;
    self.result4Label.lineBreakMode = NSLineBreakByWordWrapping;
    
    _lineLayer = [[CAShapeLayer alloc] init];
    UIBezierPath *newPath = [UIBezierPath bezierPath];
    CGPoint startPoint = CGPointMake(0,  Height_RedBag*Rate_UpTangentOpen_Line);
    CGPoint endPoint = CGPointMake(Width_RedBag, Height_RedBag*Rate_UpTangentOpen_Line);
    CGPoint controlPoint = CGPointMake(Width_RedBag*0.5, Y_Open_TangentDot);
    [newPath moveToPoint:CGPointMake(0, 0)];
    //曲线起点
    [newPath addLineToPoint:startPoint];
    //曲线终点和控制基点
    [newPath addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    
    [newPath addLineToPoint:CGPointMake(Width_RedBag, 0)];
    [newPath closePath];
    //曲线部分颜色和阴影
    [_lineLayer setFillColor:[UIColor colorWithRed:0.851 green:0.3216 blue:0.2784 alpha:1.0].CGColor];
    [_lineLayer setStrokeColor:[UIColor colorWithRed:0.9401 green:0.0 blue:0.0247 alpha:0.02].CGColor];
    [_lineLayer setShadowColor:[UIColor blackColor].CGColor];
    [_lineLayer setLineWidth:0.1];
    [_lineLayer setShadowOffset:CGSizeMake(6, 6)];
    [_lineLayer setShadowOpacity:0.2];
    [_lineLayer setShadowOffset:CGSizeMake(1, 1)];
    _lineLayer.path = newPath.CGPath;
    _lineLayer.zPosition = 1;
    [self.view.layer addSublayer:_lineLayer];
}

- (void)createFoldedUI {
    //深色背景 下部视图
    _redLayer = [[CAShapeLayer alloc] init];
//    UIBezierPath *downPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, Height_RedBag *Rate_UpTangentLine, Width_RedBag, Height_RedBag * (1-Rate_UpTangentLine)) byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(4, 4)];
    UIBezierPath *downPath = [UIBezierPath bezierPath];
    CGPoint downStartPoint = CGPointMake(0, Height_RedBag *Rate_UpTangentLine);
    CGPoint downEndPoint = CGPointMake(Width_RedBag, Height_RedBag *Rate_UpTangentLine);
    CGPoint downControlPoint = CGPointMake(Width_RedBag*0.5, Y_TangentDot);
    //曲线起点
    
    [downPath moveToPoint:downStartPoint];
    //曲线终点和控制基点
    [downPath addQuadCurveToPoint:downEndPoint controlPoint:downControlPoint];
    [downPath addLineToPoint:CGPointMake(Width_RedBag, Height_RedBag)];
    [downPath addLineToPoint:CGPointMake(0, Height_RedBag)];
    [downPath closePath];
    //曲线部分颜色和阴影
    [_redLayer setFillColor:[UIColor colorWithRed:0.7968 green:0.2186 blue:0.204 alpha:1.0].CGColor];//深色背景
    _redLayer.path = downPath.CGPath;
    _redLayer.zPosition = 1;
    [self.view.layer addSublayer:_redLayer];
    
    //浅色红包口
    _lineLayer = [[CAShapeLayer alloc] init];
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, Width_RedBag, Height_RedBag * Rate_UpTangentLine) byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(0, 0)];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    
    CGPoint startPoint = CGPointMake(0, Height_RedBag * Rate_UpTangentLine);
    CGPoint endPoint = CGPointMake(Width_RedBag, Height_RedBag * Rate_UpTangentLine);
    CGPoint controlPoint = CGPointMake(Width_RedBag*0.5, Y_TangentDot);
    //曲线起点
    [path addLineToPoint:startPoint];
    //曲线终点和控制基点
    [path addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    [path addLineToPoint:CGPointMake(Width_RedBag, 0)];
    [path closePath];
    
    //曲线部分颜色和阴影
    [_lineLayer setFillColor:[UIColor colorWithRed:0.851 green:0.3216 blue:0.2784 alpha:1.0].CGColor];
    [_lineLayer setStrokeColor:[UIColor colorWithRed:0.9401 green:0.0 blue:0.0247 alpha:0.02].CGColor];
    [_lineLayer setShadowColor:[UIColor blackColor].CGColor];
    [_lineLayer setLineWidth:0.1];
    [_lineLayer setShadowOffset:CGSizeMake(6, 6)];
    [_lineLayer setShadowOpacity:0.2];
    [_lineLayer setShadowOffset:CGSizeMake(1, 1)];
    _lineLayer.path = path.CGPath;
    _lineLayer.zPosition = 1;
    //线条之间
    _lineLayer.lineJoin = kCALineJoinMiter;
    //线条结尾
    _lineLayer.lineCap = kCALineCapButt;
    [self.view.layer addSublayer:_lineLayer];
    
    //发红包按钮
    UCFOpenRedBagButton *sendBtn = [[UCFOpenRedBagButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    sendBtn.layer.masksToBounds = YES;
    sendBtn.layer.cornerRadius = sendBtn.bounds.size.height/2;
    //    [sendBtn setTitle:@"开红包" forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"btn_open_pre"] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(moveAnimation:) forControlEvents:UIControlEventTouchUpInside];
    //    [sendBtn setBackgroundColor:[UIColor brownColor]];
    sendBtn.center = CGPointMake(Width_RedBag*0.5, Height_RedBag*Rate_UpTangentLine+Width_RedBag*Rate_UpTangentLine_TangentDot*0.5);
    sendBtn.layer.zPosition = 2;
    self.sendBtn = sendBtn;
    
    [self.view addSubview:sendBtn];
    sendBtn.animationImagesArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"gold_1"],[UIImage imageNamed:@"gold_2"],[UIImage imageNamed:@"gold_3"],[UIImage imageNamed:@"gold_4"],[UIImage imageNamed:@"gold_5"],[UIImage imageNamed:@"gold_6"],nil ];
    
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    closeBtn.layer.masksToBounds = YES;
    closeBtn.layer.zPosition = 2;
    closeBtn.layer.cornerRadius = sendBtn.bounds.size.height/2;
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"btn-close_pre"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    self.closeBtn = closeBtn;
}

- (void)moveAnimation:(UIButton *)sender {
    [self coinRotateWithObj:sender];
    __block typeof(self) blockSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [blockSelf openRedBag];
        [self setOpenedUIState];
    });
}

- (void)setUnOpenUIState {
    if (!_fold) {
        self.result2Label.hidden = YES;
        self.result3Label.hidden = YES;
        self.rebTitleLabel.layer.zPosition = 3;
        self.openedCloseButton.layer.zPosition = 3;
        self.logoImageView.layer.zPosition = 3;
        return;
    }
    self.rebTitleLabel.layer.zPosition = 3;
    self.openedCloseButton.layer.zPosition = -1;
    self.logoImageView.layer.zPosition = 3;
    self.logoTileLabel.layer.zPosition = 3;
    self.desCribeLabel.layer.zPosition = 3;
    self.header5Label.layer.zPosition = 3;
    self.resultBackView.layer.zPosition = 0;
}

- (void)setOpenedUIState {
    if (_fold) {
        self.openedCloseButton.layer.zPosition = 3;
        self.logoTileLabel.layer.zPosition = -1;
        self.desCribeLabel.layer.zPosition = -1;
        self.header5Label.layer.zPosition = -1;
        self.resultBackView.layer.zPosition = 0;
    }
}

- (void)openRedBag {
    [self.sendBtn removeFromSuperview];
    [self upLineMoveUp];
    [self downLineMoveDown];
    [self.closeBtn removeFromSuperview];
}

- (void)coinRotateWithObj:(UIView *)obj {
    if ([obj isKindOfClass:[UCFOpenRedBagButton class]]) {
        UCFOpenRedBagButton *btn = (UCFOpenRedBagButton *)obj;
        [btn startAnimation];
    }
}

- (void)upLineMoveUp {
//    UIBezierPath *newPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, Width_RedBag, Height_RedBag*Rate_UpTangentOpen_Line) byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4, 4)];
    UIBezierPath *newPath = [UIBezierPath bezierPath];
    CGPoint startPoint = CGPointMake(0,  Height_RedBag*Rate_UpTangentOpen_Line);
    CGPoint endPoint = CGPointMake(Width_RedBag, Height_RedBag*Rate_UpTangentOpen_Line);
    CGPoint controlPoint = CGPointMake(Width_RedBag*0.5, Y_Open_TangentDot);
    
    [newPath moveToPoint:CGPointMake(0, 0)];
    //曲线起点
    [newPath addLineToPoint:startPoint];
    
    //曲线终点和控制基点
    [newPath addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    
    [newPath addLineToPoint:CGPointMake(Width_RedBag, 0)];
    [newPath closePath];
    CGRect newFrame = CGRectMake(0, 0, Width_RedBag, Y_Open_TangentDot);
    
    CABasicAnimation* pathAnim = [CABasicAnimation animationWithKeyPath: @"path"];
    pathAnim.toValue = (id)newPath.CGPath;
    
    CABasicAnimation* boundsAnim = [CABasicAnimation animationWithKeyPath: @"frame"];
    boundsAnim.toValue = [NSValue valueWithCGRect:newFrame];
    
    CAAnimationGroup *anims = [CAAnimationGroup animation];
    anims.animations = [NSArray arrayWithObjects:pathAnim, boundsAnim, nil];
    anims.removedOnCompletion = NO;
    anims.duration = 0.25f;
    anims.fillMode  = kCAFillModeForwards;
    [self.lineLayer addAnimation:anims forKey:nil];
}

- (void)downLineMoveDown {
    UIBezierPath *downPath = [UIBezierPath bezierPath];
    CGPoint downStartPoint = CGPointMake(0, Height_RedBag);
    CGPoint downEndPoint = CGPointMake(Width_RedBag, Height_RedBag);
    CGPoint downControlPoint = CGPointMake(Width_RedBag*0.5, Height_RedBag + Width_RedBag*Rate_UpTangentLine_TangentDot);
    //曲线起点
    [downPath moveToPoint:downStartPoint];
    //曲线终点和控制基点
    [downPath addQuadCurveToPoint:downEndPoint controlPoint:downControlPoint];
    [downPath addLineToPoint:CGPointMake(Width_RedBag, Height_RedBag*(2-Rate_UpTangentLine))];
    [downPath addLineToPoint:CGPointMake(0, Height_RedBag*(2-Rate_UpTangentLine))];
    [downPath closePath];
    CABasicAnimation* downPathAnim = [CABasicAnimation animationWithKeyPath: @"path"];
    downPathAnim.toValue = (id)downPath.CGPath;
    
    CAAnimationGroup *anims1 = [CAAnimationGroup animation];
    anims1.animations = [NSArray arrayWithObjects:downPathAnim, nil];
    anims1.removedOnCompletion = NO;
    anims1.duration = 0.25f;
    anims1.fillMode  = kCAFillModeForwards;
    [self.redLayer addAnimation:anims1 forKey:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[UCFCustomPopTransitionAnimation alloc]init];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [[UCFCustomPopTransitionAnimation alloc]init];
}

- (IBAction)clicked:(id)sender {
    [self close:nil];
}

- (void)close:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
