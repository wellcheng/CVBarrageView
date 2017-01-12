//
//  BBABarrageCell.h
//  BBAComs
//
//  Created by chengwei06 on 2016/12/29.
//
//

#import <UIKit/UIKit.h>

@class BBABarrageSpirit;

@interface BBABarrageCell : UIView<CAAnimationDelegate>

@property (nonatomic, assign) NSUInteger trajectory;
@property (nonatomic, assign, readonly) CGFloat defaultDuration;
@property (nonatomic, assign) CGFloat transPerSecond;
@property (nonatomic, strong) UILabel *barrageLabel;
@property (nonatomic, strong) BBABarrageSpirit *barrageSpirit;
@property (nonatomic, assign) CGPoint realPosition;
- (NSString *)animationUniqueKey;
- (instancetype)initWithSpirit:(BBABarrageSpirit *)barrageSpirit withDuration:(CGFloat)duration;
- (void)resumeAnimations;
- (void)pauseAnimations;
- (void)setOriginAnimationPositon:(CGPoint)position;
- (void)setBaseTime:(CGFloat)time;
- (void)addAnimationOnView:(UIView *)view;
@end
