//
//  BBABarrageSpirit.m
//  BBAComs
//
//  Created by chengwei06 on 2016/12/24.
//
//

#import "BBABarrageSpirit.h"
#import "BBABarrageCell.h"
#import "BBABarrageDescriptor.h"
#import "BBAUtility.h"


@interface BBABarrageSpirit ()
@end

@implementation BBABarrageSpirit
- (instancetype)initWithDesc:(BBABarrageDescriptor *)desc {
    self = [super init];
    if (self) {
        _desc = desc;
        [self propertyInit];
        [self commonInit];
    }
    return self;
}
- (void)propertyInit {
    }

- (void)commonInit {
    
}

- (UILabel *)drawBarrageLabelByCell:(BBABarrageCell *)cell {
    
    CGRect labelBounds = [self.desc.content boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.desc.fontSize)
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.desc.fontSize],
                                                                   NSForegroundColorAttributeName : self.desc.titleColor}
                                                         context:nil];
    UILabel *barrageLabel = [[UILabel alloc] initWithFrame:labelBounds];
    
    barrageLabel.attributedText = [[NSAttributedString alloc] initWithString:self.desc.content
                                                                  attributes:@{ NSStrokeColorAttributeName : self.desc.outLineColor,
                                                                                NSForegroundColorAttributeName : self.desc.titleColor,
                                                                                NSStrokeWidthAttributeName : @(self.desc.outLineWidth)}];
    barrageLabel.font = [UIFont systemFontOfSize:self.desc.fontSize];
    barrageLabel.textColor = self.desc.titleColor;
    
    return barrageLabel;
}


@end
