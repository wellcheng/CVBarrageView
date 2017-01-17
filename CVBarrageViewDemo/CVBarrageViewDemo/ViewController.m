//
//  ViewController.m
//  CVBarrageViewDemo
//
//  Created by chengwei06 on 2017/1/12.
//  Copyright © 2017年 WellCheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - ViewController Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addBackImageAnimation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self clearBackImageAnimation];
}

#pragma mark - Caculate Property

- (NSArray *)animationImages {
    NSArray *imageNames =  @[@"demo-1",
                             @"demo-2",
                             @"demo-3",
                             @"demo-4",
                             @"demo-5",];
    NSMutableArray *images = [NSMutableArray array];
    for (NSString *imgName in imageNames) {
        UIImage *img = [UIImage imageNamed:imgName];
        if (img) {
            [images addObject:img];
        }
    }
    return [images copy];
}

#pragma mark - Private Method
- (void)addBackImageAnimation {
    self.backImageView.animationImages = [self animationImages];
    self.backImageView.animationDuration = 1.2f * self.backImageView.animationImages.count;
    self.backImageView.animationRepeatCount = 0;
    [self.backImageView startAnimating];
}
- (void)clearBackImageAnimation {
    [self.backImageView stopAnimating];
}
#pragma mark - Actions

- (IBAction)start:(id)sender {
}

- (IBAction)pause:(id)sender {
}

- (IBAction)reset:(id)sender {
}
- (IBAction)sliderChanged:(UISlider *)sender {
}

@end
