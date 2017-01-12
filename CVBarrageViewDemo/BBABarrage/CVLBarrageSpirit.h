//
//  CVLBarrageSpirit.h
//  CVLComs
//
//  Created by wellcheng on 2016/12/24.
//
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CVLBarrageMotionType) {
    CVLBarrageMotionRightLeft,
    CVLBarrageMotionLeftRight,
};
@class CVLBarrageDescriptor;
@class CVLBarrageCell;
/**
 Basic 弹幕
 */
@interface CVLBarrageSpirit : NSObject

@property (nonatomic, strong) CVLBarrageDescriptor *desc;
/**
 弹幕内容文本
 */
@property (nonatomic, strong) NSString *title;

/**
 弹幕的文本大小
 */
@property (nonatomic, assign) CGFloat fontSize;

/**
 弹幕的文本颜色
 */
@property (nonatomic, strong) UIColor *titleColor;

/**
 弹幕的运动轨迹类型
 */
@property (nonatomic, assign) CVLBarrageMotionType motionType;

/**
 弹幕的发送时间，单位秒
 */
@property (nonatomic, assign) CGFloat shootTime;
/**
 推荐的初始化方法，通过弹幕描述符构造一条弹幕

 @param desc 弹幕描述符
 @return 弹幕
 */
- (instancetype)initWithDesc:(CVLBarrageDescriptor *)desc NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (UILabel *)drawBarrageLabelByCell:(CVLBarrageCell *)cell;
@end
