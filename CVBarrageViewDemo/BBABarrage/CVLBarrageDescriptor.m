//
//  CVLBarrageDescriptor.m
//  CVLComs
//
//  Created by wellcheng on 2016/12/24.
//
//
#import <UIKit/UIKit.h>
#import "CVLBarrageDescriptor.h"
#import "NSDictionary+Safety.h"
#import "UIColor+Utility.h"

@interface CVLBarrageDescriptor ()
@property(nonatomic, strong, readwrite) NSDictionary *attributeDict;
@end

@implementation CVLBarrageDescriptor

- (instancetype)initWithAttributeDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _attributeDict = dict;
        [self propertyInit];
    }
    return self;
}

- (void)propertyInit {
    _isUserSelf = NO;
    _outLineWidth = - 2.0f;
    _outLineColor = [UIColor blackColor];
    _content = [_attributeDict CVL_stringValueForKey:@"content"] ?: @"";
    _shootTime = [[_attributeDict CVL_numberValueForKey:@"time"] floatValue];
}

- (CGFloat)fontSize {
    if (self.isUserSelf) {
        return 18.0f;
    }
    return 16.0f;
}

- (UIColor *)titleColor {
    if (!_titleColor) {
        _titleColor = [UIColor whiteColor];
    }
    if (self.isUserSelf) {
        _titleColor = [self randomUserColor];
    }
    return _titleColor;
}

+ (NSArray<CVLBarrageDescriptor *>*)createByDicts:(NSArray<NSDictionary *> *)dicts {
    if (!dicts || dicts.count == 0) {
        return nil;
    }
    NSMutableArray *descs = [NSMutableArray array];
    for (NSDictionary *dict in dicts) {
        CVLBarrageDescriptor *desc = [[CVLBarrageDescriptor alloc] initWithAttributeDict:dict];
        if (desc) {
            [descs addObject:desc];
        }
    }
    return [descs copy];
}

#pragma mark - Helper

- (UIColor *)randomUserColor {
    NSArray *colorStrings = @[@"#EBBC00", @"#FF00F6", @"#09C900", @"#1089F0"];
    NSUInteger index = arc4random() % colorStrings.count;
    return [UIColor RGBColorFromHexString:colorStrings[index]];
}
/**
 给没有时间的弹幕分配时间
 */
+ (NSArray<CVLBarrageDescriptor *> *)assignShootTimeForBarrages:(NSArray<CVLBarrageDescriptor *> *)barrageDescs
                                                   withDuration:(CGFloat)duration {
    NSInteger intDuration = (NSInteger)floor(duration);
    NSInteger countOfFirstSecond = barrageDescs.count % intDuration;
    NSInteger countOfOther = (barrageDescs.count - countOfFirstSecond);
    NSInteger countPerSecond = countOfOther / intDuration;
    
    //
    NSArray *firstSecondDescs = [self subarraySafely:barrageDescs WithRange:NSMakeRange(0, countOfFirstSecond)];
    NSArray *otherDescs = [self subarraySafely:barrageDescs WithRange:NSMakeRange(countOfFirstSecond, countOfOther)];
    
    NSArray *firstSecondTimeDescs = [self assignShootTimeForBarrages:firstSecondDescs withSecond:0];
    NSMutableArray *otherTimeDescs = [NSMutableArray arrayWithCapacity:otherDescs.count];
    for (NSUInteger second = 1; second <= intDuration; ++ second) {
        NSRange curRange = NSMakeRange((second - 1) * countPerSecond, countPerSecond);
        NSArray *descs = [self assignShootTimeForBarrages:[self subarraySafely:otherDescs WithRange:curRange] withSecond:second];
        [otherTimeDescs addObjectsFromArray:descs];
    }
    return [firstSecondDescs arrayByAddingObjectsFromArray:otherTimeDescs];
}

/**
 分配弹幕时间给单位秒内的所有弹幕
 */
+ (NSArray<CVLBarrageDescriptor *> *)assignShootTimeForBarrages:(NSArray<CVLBarrageDescriptor *> *)barrageDescs
                                                     withSecond:(NSInteger)second {
    if (second < 0 || barrageDescs.count == 0) {
        return @[];
    }
    
    CGFloat shootTime = second;
    CGFloat timeInterval = floor(1.0f / barrageDescs.count * 100000) / 100000;    // 小数点保留 5 位
    if (timeInterval == 0) {
        timeInterval = 0.01f; // 至少 0.01 间隔
    }
    NSMutableArray *resDescs = [NSMutableArray arrayWithCapacity:barrageDescs.count];
    for (CVLBarrageDescriptor *desc in barrageDescs) {
        //CVTODO : 删除
        /*
        NSUInteger times = arc4random() % 3;
        while (times > 0) {
            desc.content = [desc.content stringByAppendingString:desc.content];
            -- times;
        }
        //
        */
        desc.shootTime = shootTime;
        shootTime += timeInterval;
        [resDescs addObject:desc];
    }
    return [resDescs copy];
}

+ (NSArray *)subarraySafely:(NSArray *)originArray WithRange:(NSRange)range{
    if (range.location >= originArray.count) {
        return @[];
    }
    if (range.length == 0) {
        return @[];
    }
    if (range.location + range.length > originArray.count) {
        return @[];
    }
    return [originArray subarrayWithRange:range];
}

@end
