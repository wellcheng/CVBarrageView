//
//  UIColor+Utility.m
//  CVBarrageViewDemo
//
//  Created by chengwei06 on 2017/1/15.
//  Copyright © 2017年 WellCheng. All rights reserved.
//

#import "UIColor+Utility.h"
#import "CVLGlobal.h"

@implementation UIColor (Utility)
+ (UIColor *)RGBColorFromHexString:(NSString *)aHexStr {
    return [self RGBColorFromHexString:aHexStr alpha:1.0f];
}

+ (UIColor *)RGBColorFromHexString:(NSString *)aHexStr alpha:(float)aAlpha
{
    if ([aHexStr isKindOfClass:[NSString class]] && CHECK_STRING_VALID(aHexStr)
        && aHexStr.length > 6) // #rrggbb 大小写字母及数字
    {
        int nums[6] = {0};
        for (int i = 1; i < MIN(7, [aHexStr length]); i++) // 第一个字符是“＃”号
        {
            int asc = [aHexStr characterAtIndex:i];
            if (asc >= '0' && asc <= '9') // 数字
                nums[i - 1] = [aHexStr characterAtIndex:i] - '0';
            else if(asc >= 'A' && asc <= 'F') // 大写字母
                nums[i - 1] = [aHexStr characterAtIndex:i] - 'A' + 10;
            else if(asc >= 'a' && asc <= 'f') // 小写字母
                nums[i - 1] = [aHexStr characterAtIndex:i] - 'a' + 10;
            else
                return [UIColor whiteColor];
        }
        float rValue = (nums[0] * 16 + nums[1]) / 255.0f;
        float gValue = (nums[2] * 16 + nums[3]) / 255.0f;
        float bValue = (nums[4] * 16 + nums[5]) / 255.0f;
        UIColor *rgbColor = [UIColor colorWithRed:rValue green:gValue blue:bValue alpha:aAlpha];
        return rgbColor;
    }
    
    return [UIColor blackColor]; // 默认黑色
}
@end
