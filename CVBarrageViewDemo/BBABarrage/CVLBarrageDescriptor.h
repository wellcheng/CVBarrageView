//
//  CVLBarrageDescriptor.h
//  CVLComs
//
//  Created by wellcheng on 2016/12/24.
//
//

#import <Foundation/Foundation.h>

/**
 弹幕的描述数据模型
 */
@interface CVLBarrageDescriptor : NSObject

/**
 弹幕的发送时间，单位秒
 */
@property (nonatomic, assign) CGFloat shootTime;

/**
 弹幕是否为用户自己所发送的
 */
@property (nonatomic, assign) BOOL isUserSelf;
@property (nonatomic, strong) UIColor *outLineColor;
@property (nonatomic, assign) CGFloat outLineWidth;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, assign, readonly) CGFloat fontSize;
/**
 弹幕的属性字典
 */
@property(nonatomic, strong, readonly) NSDictionary *attributeDict;

/**
 默认的初始化方法不可用，请使用推荐的初始化方法 - (instancetype)initWithAttributeDict:(NSDictionary *)dict
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 通过弹幕的属性字典，初始化弹幕描述符

 @param dict 弹幕的属性字典
 @return 弹幕描述符，可以根据描述符初始化不同类型的弹幕
 */
- (instancetype)initWithAttributeDict:(NSDictionary *)dict NS_DESIGNATED_INITIALIZER;

/**
 通过一组字典初始化一组弹幕描述符

 @param dicts 弹幕属性字典
 @return 一组弹幕描述符，可以根据描述符初始化不同类型的弹幕
 */
+ (NSArray<CVLBarrageDescriptor *>*)createByDicts:(NSArray<NSDictionary *> *)dicts;

/**
 给没有时间的弹幕分配时间
 
 @param barrageDescs 需要设置 shootTime 的弹幕描述符数组
 @param duration 弹幕数组需要填充的时间长度
 @return 带有 shootTime 的弹幕描述符数组
 */
+ (NSArray<CVLBarrageDescriptor *> *)assignShootTimeForBarrages:(NSArray<CVLBarrageDescriptor *> *)barrageDescs
                                                   withDuration:(CGFloat)duration;
@end
