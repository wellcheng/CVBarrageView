//
//  CVLBarrageCell.h
//  CVLComs
//
//  Created by wellcheng on 2016/12/29.
//
//

#import <UIKit/UIKit.h>

@class CVLBarrageSpirit;

@interface CVLBarrageCell : UIView<CAAnimationDelegate>

@property (nonatomic, assign) NSUInteger trajectory;
@property (nonatomic, assign, readonly) CGFloat defaultDuration;
@property (nonatomic, assign) CGFloat transPerSecond;
@property (nonatomic, strong) UILabel *barrageLabel;
@property (nonatomic, strong) CVLBarrageSpirit *barrageSpirit;
@property (nonatomic, assign) CGPoint realPosition;
- (NSString *)animationUniqueKey;
- (instancetype)initWithSpirit:(CVLBarrageSpirit *)barrageSpirit withDuration:(CGFloat)duration;
- (void)resumeAnimations;
- (void)pauseAnimations;
- (void)setOriginAnimationPositon:(CGPoint)position;
- (void)setBaseTime:(CGFloat)time;
- (void)addAnimationOnView:(UIView *)view;
@end
