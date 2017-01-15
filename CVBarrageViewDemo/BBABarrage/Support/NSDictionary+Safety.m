//
//  NSDictionary+Safety.m
//  CVBarrageViewDemo
//
//  Created by chengwei06 on 2017/1/12.
//  Copyright © 2017年 WellCheng. All rights reserved.
//

#import "NSDictionary+Safety.h"


@implementation NSDictionary (Safety)

- (id)objectForKeySafely:(id)aKey
{
    if (!aKey) {
        return nil;
    }
    
    
    if (![self.allKeys containsObject:aKey]) {
        return nil;
    }
    
    return [self objectForKey:aKey];
}

- (NSString *)CVL_stringValueForKey:(NSString *)key {
    if (key.length == 0) {
        return nil;
    }
    
    if ([self ba_dic_safety_checkValueWithKey:key validClass:[NSString class]]) {
        return self[key];
    }
    
    id value = self[key];
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    
    return nil;
}

- (NSNumber *)CVL_numberValueForKey:(NSString *)key {
    if (key.length == 0) {
        return nil;
    }
    
    if ([self ba_dic_safety_checkValueWithKey:key validClass:[NSNumber class]]) {
        return self[key];
    }
    
    id value = self[key];
    if ([value isKindOfClass:[NSString class]] ) {
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        return [numberFormatter numberFromString:value];
    }
    
    return nil;
}

- (NSArray *)CVL_arrayValueForKey:(NSString *)key {
    if ([self ba_dic_safety_checkValueWithKey:key validClass:[NSArray class]]) {
        return self[key];
    }
    
    return nil;
}

- (NSDictionary *)CVL_dictionaryValueForKey:(NSString *)key {
    if ([self ba_dic_safety_checkValueWithKey:key validClass:[NSDictionary class]]) {
        return self[key];
    }
    
    return nil;
}

#pragma mark - Private
- (BOOL)ba_dic_safety_checkValueWithKey:(NSString *)key validClass:(Class)targetClass {
    if (key.length == 0) {
        return NO;
    }
    
    id value = self[key];
    if ([value isKindOfClass:targetClass]) {
        return YES;
    }
    
    return NO;
}

@end
