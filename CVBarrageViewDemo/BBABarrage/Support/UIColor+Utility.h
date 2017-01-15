//
//  UIColor+Utility.h
//  CVBarrageViewDemo
//
//  Created by chengwei06 on 2017/1/15.
//  Copyright © 2017年 WellCheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utility)
+ (UIColor *)RGBColorFromHexString:(NSString *)aHexStr alpha:(float)aAlpha;
+ (UIColor *)RGBColorFromHexString:(NSString *)aHexStr;
@end
