//
//  NSDictionary+Safety.h
//  CVBarrageViewDemo
//
//  Created by chengwei06 on 2017/1/12.
//  Copyright © 2017年 WellCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Safety)

- (id)objectForKeySafely:(id)aKey;

/// 获取指定key下的string值，获取规则：
/// 1，若key对应的value是一个字符串类型，则直接返回value；
/// 2，若该value实现了stringValue方法(比如：NSNumber)，则返回该方法的值；
/// 3，反之，则返回nil
- (NSString *)CVL_stringValueForKey:(NSString *)key;

/// 获取指定key下的number值，获取规则：
/// 1，若key对应的value是一个数字类型，则直接返回value；
/// 2，若该value为一个字符串类型，且该字符串为一个纯数字的，则返回对应的数值
/// 3，反之，则返回nil
- (NSNumber *)CVL_numberValueForKey:(NSString *)key;

/// 获取指定key下的类型为array的value，获取规则：
/// 1，若key对应的value是一个array类型，则直接返回value；
/// 2，反之，返回nil
- (NSArray *)CVL_arrayValueForKey:(NSString *)key;

/// 获取指定key下的类型为字典的value，获取规则：
/// 1，若key对应的value是一个字典类型，则直接返回value；
/// 2，反之，返回nil
- (NSDictionary *)CVL_dictionaryValueForKey:(NSString *)key;

@end
