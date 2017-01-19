//
//  ViewController.m
//  CVBarrageViewDemo
//
//  Created by chengwei06 on 2017/1/12.
//  Copyright © 2017年 WellCheng. All rights reserved.
//

#import "ViewController.h"
#import "CVLBarrageRenderView.h"

@interface ViewController ()<CVLBarrageRenderDelegate>
@property (nonatomic, strong) CVLBarrageRenderView *barrageView;
@property (nonatomic, assign, getter=isPlaying) BOOL playing;
@end

@implementation ViewController

#pragma mark - ViewController Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configBarrageView];
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

- (void)configBarrageView {
    self.barrageView = [[CVLBarrageRenderView alloc] init];
    self.barrageView.delegate = self;
}


#pragma mark - Actions

- (IBAction)start:(id)sender {
    [self startBarrageRender];
}

- (IBAction)pause:(id)sender {
    [self pauseBarrageRender];
}

- (IBAction)reset:(id)sender {
    [self stopBarrageRender];
}
- (IBAction)sliderChanged:(UISlider *)sender {
}

#pragma mark - Barrage Action

- (void)startBarrageRender {
    
}


- (void)pauseBarrageRender {
    
}


- (void)stopBarrageRender {
    
}

#pragma mark - Barrage View Delegate

- (CGFloat)videoCurrentPlayTime:(CVLBarrageRenderView *)barrageRenderView {
    return self.sliderBar.value;
}

- (BOOL)videoIsPlaying:(CVLBarrageRenderView *)barrageRenderView {
    return self.isPlaying;
}


- (CGFloat)videoDuration:(CVLBarrageRenderView *)barrageRenderView {
    return self.sliderBar.maximumValue;
}

- (void)barrageViewPerpareDone:(CVLBarrageRenderView *)barrageRenderView {
    // auto start when barrage data ok
    [barrageRenderView start];
}

@end
