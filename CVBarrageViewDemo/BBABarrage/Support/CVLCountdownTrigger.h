//
//  CVLCountdownTrigger.h
//  CVBarrageViewDemo
//
//  Created by chengwei06 on 2017/1/12.
//  Copyright © 2017年 WellCheng. All rights reserved.
//



#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CVLTimeUnit) {
    CVLTimeSecond = 1,
    CVLTimeMinute = CVLTimeSecond * 60,
    CVLTimeHours = CVLTimeMinute * 60,
};

@interface CVLCountdownTrigger : NSObject

- (instancetype)initWithTarget:(id)aTarget
                      selector:(SEL)aSelector
                     tickTimes:(unsigned long int)aTickTimes
                      tickUnit:(CVLTimeUnit)aTickUnit
                       repeats:(BOOL)yesOrNo;

- (void)pause;

- (void)resume;

- (void)reset;

@end
