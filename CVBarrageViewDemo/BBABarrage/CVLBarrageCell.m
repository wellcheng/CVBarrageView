//
//  CVLBarrageCell.m
//  CVLComs
//
//  Created by wellcheng on 2016/12/29.
//
//

#import "CVLBarrageCell.h"
#import "CVLBarrageRenderView.h"
#import "CVLBarrageSpirit.h"

@interface CVLBarrageCell ()

@property (nonatomic, assign, readwrite) CGFloat defaultDuration;
@end

@implementation CVLBarrageCell

- (instancetype)initWithSpirit:(CVLBarrageSpirit *)barrageSpirit withDuration:(CGFloat)duration {
    self = [super init];
    if (self) {
        _barrageSpirit = barrageSpirit;
        _defaultDuration = duration;
        _trajectory = 1;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.userInteractionEnabled = NO;
    _barrageLabel = [_barrageSpirit drawBarrageLabelByCell:self];
    self.bounds = _barrageLabel.bounds;
    [self addSubview:_barrageLabel];
}

- (NSString *)animationUniqueKey {
    return NSStringFromClass([self class]);
}
- (void)setBaseTime:(CGFloat)time {
    
}
// 设置 cell 在开始动画前的初始位置
- (void)setOriginAnimationPositon:(CGPoint)position {
    self.layer.position = position;
    self.realPosition = position;
}


- (void)pauseAnimations
{
    CFTimeInterval paused_time = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.layer.speed = 0.0;
    self.layer.timeOffset = paused_time;
}

- (void)resumeAnimations
{
    CFTimeInterval paused_time = [self.layer timeOffset];
    self.layer.speed = 1.0f;
    self.layer.timeOffset = 0.0f;
    self.layer.beginTime = 0.0f;
    CFTimeInterval time_since_pause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - paused_time;
    self.layer.beginTime = time_since_pause;
}

#pragma mark - Animation Delegate
- (void)animationDidStart:(CAAnimation *)anim {
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // 如果是完成动画，直接销毁
    if (flag) {
        /*
        NSLog(@"cv animation stop cell(%@), layer = %@ , present = %@, real = %@",
              self.barrageLabel.text,
              NSStringFromCGPoint(self.layer.position),
              NSStringFromCGPoint(self.layer.presentationLayer.position),
              NSStringFromCGPoint(self.realPosition));
         */
        [self.layer removeAllAnimations];
        [self removeFromSuperview];
    } else {
        self.frame = self.layer.presentationLayer.frame;
        self.realPosition = self.layer.presentationLayer.position;
    }
}

- (void)addAnimationOnView:(UIView *)view
{
    CGPoint oriPosition = self.realPosition;
    CGPoint toPosition= CGPointMake(-CGRectGetWidth(self.bounds)/2, oriPosition.y);
    
    CGFloat defaultDuration = self.defaultDuration;
    CGFloat defaultDistance = fabs(CGRectGetWidth(view.bounds) + CGRectGetWidth(self.bounds));
    CGFloat currentDistance = fabs(toPosition.x - oriPosition.x);
    
    self.transPerSecond = defaultDistance / defaultDuration;
    
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
    anim.fromValue = [NSValue valueWithCGPoint:oriPosition];
    anim.toValue = [NSValue valueWithCGPoint:toPosition];
    anim.duration = defaultDuration * (currentDistance / defaultDistance);
    anim.beginTime = CACurrentMediaTime();
    anim.repeatCount = 1;
    anim.fillMode = kCAFillModeForwards;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    anim.delegate = self;
    anim.removedOnCompletion = NO;
    
//    NSLog(@"cv create anim ori:%@, des:%@", NSStringFromCGPoint(oriPosition), NSStringFromCGPoint(toPosition));
    
    [self.layer addAnimation:anim forKey:self.animationUniqueKey];
}
@end




