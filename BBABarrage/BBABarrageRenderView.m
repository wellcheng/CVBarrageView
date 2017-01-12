//
//  BBABarrageRenderView.m
//  BBAComs
//
//  Created by chengwei06 on 2016/12/24.
//
//

#import "BBABarrageRenderView.h"
#import <QuartzCore/QuartzCore.h>
#import "BBACountdownTrigger.h"
#import "BBABarrageCell.h"
#import "BBABarrageDescriptor.h"
#import "BBABarrageSpirit.h"

@interface BBABarrageRenderView ()
{
    CGFloat _timerInterval;
    CGFloat _duration;
}
@property(nonatomic, assign, readwrite) BOOL isReadyToRender;
@property(nonatomic, assign, readwrite) BBAPlayBarrageViewStatus userRenderStatus;
@property(nonatomic, assign) CGFloat lastRenderTime;
@property (nonatomic, strong) NSArray<BBABarrageDescriptor *> *originBarrageDescs;   // 原始未经处理的弹幕数据
@property (nonatomic, strong) NSArray<BBABarrageDescriptor *> *descNeedsRender;     // 已经处理好的弹幕数据
@property (nonatomic,strong) BBACountdownTrigger *sendBarrageTrigger;
@property (nonatomic, strong) NSArray<NSNumber *> *trajectories;
@end

@implementation BBABarrageRenderView

#pragma mark - Init Method
- (instancetype)init {
    self = [super init];
    if (self) {
        [self propertyInit];
        [self commonInit];
        [self configTimer];
    }
    return self;
}
/*
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self propertyInit];
        [self commonInit];
        [self configTimer];
    }
    return self;
}
*/
- (void)propertyInit {
    _timerInterval = 0.8;
    _lastRenderTime = 0.0f;
    _duration = 5.0f;
    _descNeedsRender = [NSArray array];
    _originBarrageDescs = [NSArray array];
    _barragesDesc = [NSMutableArray array];
    _isReadyToRender = NO;
    _userRenderStatus = BBAPlayBarrageViewNotSupport;
}

- (void)commonInit {
    self.userInteractionEnabled = NO;
    self.clipsToBounds = YES;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self createTrajectory];
}

- (void)configTimer {
    _sendBarrageTrigger = [[BBACountdownTrigger alloc] initWithTarget:self selector:@selector(timeToRenderBarrage:) tickTimes:_timerInterval tickUnit:BBATimeSecond repeats:YES];
}

#pragma mark - Calcuate Property

- (CGFloat)duration {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoDuration:)]) {
        return [self.delegate videoDuration:self];
    }
    return 0.0f;
}

- (CGFloat)currentPlayingTime {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoCurrentPlayTime:)]) {
        return [self.delegate videoCurrentPlayTime:self];
    }
    return 0.0f;
}

- (BOOL)isPlaying {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoIsPlaying:)]) {
        return [self.delegate videoIsPlaying:self];
    }
    return NO;
}

#pragma mark - Touch Event
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // 不响应任何点击
    return NO;
}

#pragma mark - Invoke Interface
- (void)start {
    [self.sendBarrageTrigger resume];
    [self resumeCellAnimation];
}

- (void)stop {
    [self.sendBarrageTrigger pause];
    [self clearAllCells];
    [self removeFromSuperview];
}

- (void)pause {
    [self.sendBarrageTrigger pause];
    [self pauseCellAnimation];
}

- (void)reset {
    [self clearAllCells];
}

- (void)setRenderStatus:(BBAPlayBarrageViewStatus)status {
    if (status == BBAPlayBarrageViewOpen) {
        self.userRenderStatus = BBAPlayBarrageViewOpen;
    } else {
        self.userRenderStatus = BBAPlayBarrageViewClose;
        [self clearAllCells];
    }
}

- (void)loadBarrages:(NSArray<BBABarrageDescriptor *> *)barrageDescs {
    self.originBarrageDescs = barrageDescs;
    // 此时播放器的 duration 数据都还未完成设置，下次 Runloop 中处理数据
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self prepareBarragesIfNeed];
    }];
}


/**
 立即显示一批弹幕
 */
- (void)showBarrage:(NSArray<BBABarrageDescriptor *> *)barrageDescs {
    if (!barrageDescs || barrageDescs.count == 0 || self.userRenderStatus != BBAPlayBarrageViewOpen) {
        return;
    }
    // 获取当前的弹幕分布
    NSMutableArray *cellsForPerTrajectory = [NSMutableArray arrayWithArray:[self getCurrentCellInfo]];
    
    for (BBABarrageDescriptor *desc in barrageDescs) {
        // 来一条 渲染一条
        BBABarrageCell *cell = [[BBABarrageCell alloc] initWithSpirit:[[BBABarrageSpirit alloc] initWithDesc:desc]
                                                         withDuration:_duration];
        [self dispatchNewBarrageCell:cell cellLayoutInfo:[cellsForPerTrajectory copy]];
        // 该弹道已经被使用，不能再被使用
        NSInteger usedtrajectory = cell.trajectory;
        cellsForPerTrajectory[usedtrajectory] = @{@"cell": cell, @"maxRight" : @(self.bounds.size.width)};
    }
}

#pragma mark - Priavate Method

- (NSArray *)getCurrentCellInfo {
//    NSLog(@"cv getCurrentCellInfo start **");
    // 初始化
    NSMutableArray *cellsForPerTrajectory = [NSMutableArray arrayWithCapacity:self.trajectories.count];
    NSDictionary *originalCellInfo = @{@"cell" : @"", @"maxRight" : @(0)};
    for (NSUInteger index = 0; index < self.trajectories.count; ++ index) {
        [cellsForPerTrajectory addObject:originalCellInfo];
    }
    
    for (UIView *view in [[self.subviews reverseObjectEnumerator] allObjects]) {
        BBABarrageCell *animCell = nil;
        if ([view isKindOfClass:[BBABarrageCell class]]) {
            animCell = (BBABarrageCell *)view;
        }
        if (!animCell ) {
            continue;
        }
        if (animCell.trajectory >= cellsForPerTrajectory.count) {
            continue;
        }
        NSUInteger trajectory = animCell.trajectory;
        // get cell and it's origin x
        CGRect realFrame = animCell.layer.presentationLayer.frame;
        CGFloat animCellRight = realFrame.origin.x + CGRectGetWidth(realFrame);
        CGFloat curMaxRight = [cellsForPerTrajectory[trajectory][@"maxRight"] floatValue];
        if (animCellRight > curMaxRight) {  // 如果 animCell 还未消失
            // 得到每一个弹道最右边的 cell origin.x
            cellsForPerTrajectory[trajectory] = @{@"cell" : animCell, @"maxRight" : @(animCellRight)};
        }
    }
//    NSLog(@"cv getCurrentCellInfo stop  **:\n %@", cellsForPerTrajectory);
    return [cellsForPerTrajectory copy];
}

/**
 将 cell 分发到弹幕弹道中进行播放

 @param cell 弹幕 cell
 @param index   影响弹幕所处的弹道以及动画播放的延迟时间，在同时播放一批弹幕时，通过不同的 index 可以让这批弹幕
                显示时，不会集中显示
 @param isImmediately   如果设置了 isImmediately，那么弹幕将立即显示，不会延时
 */
- (void)dispatchNewBarrageCell:(BBABarrageCell *)cell
                cellLayoutInfo:(NSArray *)cellLayoutInfo {
//    NSLog(@"cv dispatchNewBarrageCell start ==");
    BOOL isCorrespondTrajectory = [self ajustTrajectory:cell withCellLayoutInfo:cellLayoutInfo];
    if (isCorrespondTrajectory) {
        [self animationCell:cell];
    }
//    NSLog(@"cv dispatchNewBarrageCell stop  ==");
}

// 是否需要处理原始的弹幕数据
- (BOOL)prepareBarragesIfNeed {
    if (!self.originBarrageDescs) {
        return NO;
    }
    [self prepareForBarrageDescs];
    return YES;
}

/**
 处理弹幕数据，为渲染弹幕做准备
 @param barrageDescs
 */
- (void)prepareForBarrageDescs {
    NSArray<BBABarrageDescriptor *> *barrageDescs = self.originBarrageDescs;
    // 平均分配弹幕的渲染时间
    CGFloat duration = [self duration];
    if (duration < 1.0f || !barrageDescs || !barrageDescs.count) {
        self.isReadyToRender = NO;
        return;
    }
    NSMutableArray *barragesNeedsTime = [NSMutableArray array];
    NSMutableArray *barragesHaveTime = [NSMutableArray array];
    for (BBABarrageDescriptor *desc in barrageDescs) {
        if (desc.shootTime > 0.0000001f) {
            [barragesHaveTime addObject:desc];
            continue;
        }
        [barragesNeedsTime addObject:desc];
    }
    
    NSArray *barragesWithTime = [BBABarrageDescriptor assignShootTimeForBarrages:[barragesNeedsTime copy] withDuration:duration];
    [barragesHaveTime addObjectsFromArray:barragesWithTime];
    [barragesHaveTime sortUsingComparator:^NSComparisonResult(BBABarrageDescriptor * _Nonnull obj1, BBABarrageDescriptor * _Nonnull obj2) {
        return obj1.shootTime < obj2.shootTime ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    self.descNeedsRender = [barragesHaveTime copy];
    [self preparedForRender];
}

/**
 弹幕数据的初始化完成 ，可以发送弹幕
 */
- (void)preparedForRender {
    self.isReadyToRender = YES;
    self.originBarrageDescs = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(barrageViewPerpareDone:)]) {
        [self.delegate barrageViewPerpareDone:self];
    }
}
/**
 根据当前的播放器高度创建弹道
 */
- (void)createTrajectory {
    
    CGFloat baseLineHeight = 14.0f; // first row baseLine y coordinates
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) &&
        self.bounds.size.height > self.bounds.size.width) {
        // current barrage is in a portrait orientation，ajust for not block status bar
        baseLineHeight += 64.0f;
    }
    
    CGFloat height = self.bounds.size.height / 2;   // 弹幕的可显示区域
    NSUInteger countOfTrajectory = (NSUInteger)floor(height / 23.0f);   // 单条弹幕高度 23 pt
    NSMutableArray *trajectoryPoints = [NSMutableArray arrayWithCapacity:countOfTrajectory];
    for (NSUInteger trajectory = 0; trajectory < countOfTrajectory; ++ trajectory) {
        [trajectoryPoints addObject:@(baseLineHeight + trajectory * 23.0f)];
    }
    _trajectories = [trajectoryPoints copy];
}


- (BOOL)ajustTrajectory:(BBABarrageCell *)cell withCellLayoutInfo:(NSArray *)cellLayoutInfo {
    if (!self.trajectories || !self.trajectories.count) {
        return NO;
    }
    
    // 最适合的弹道
    NSInteger preferTrajectory = -1;
    
    // 是否有空闲弹道
    NSInteger idleTrajectory = [cellLayoutInfo indexOfObject:@{@"cell" : @"", @"maxRight" : @(0)}];
    if (idleTrajectory == NSNotFound) {
        for (NSUInteger trajectory = 0; trajectory < cellLayoutInfo.count; ++ trajectory) {
            NSDictionary *cellInfo = [cellLayoutInfo objectAtIndex:trajectory];
            NSNumber *trajectoryMaxRight = [cellInfo objectForKey:@"maxRight"];
            BBABarrageCell *rightCell = [cellInfo objectForKey:@"cell"];
            
            // 当前弹道上最右边 cell，右边缘 x 坐标
            CGFloat maxRight = [trajectoryMaxRight floatValue];
            
            CGFloat barrageWidth = self.bounds.size.width;
            CGFloat cellWidth = cell.bounds.size.width;
            
            if (maxRight + 20 > barrageWidth) {
                continue;   // cell 右边缘距离 barrageView 右边缘不到 20pt ，不能选择该弹道
            }
            cell.transPerSecond = (barrageWidth + cellWidth) / cell.defaultDuration;
            if (cell.transPerSecond <= rightCell.transPerSecond) {
                preferTrajectory = rightCell.trajectory; // 新的 cell 速度小，肯定不会碰撞
//                NSLog(@"cv prefer = 11 = %i \t before:%@ ", preferTrajectory, rightCell.barrageLabel.text);
                break;
            }
            // cell 与 animCell 碰撞需要的时间
            CGFloat meetTime = (barrageWidth - maxRight) / (cell.transPerSecond - rightCell.transPerSecond);
            CGFloat remainTime = maxRight / rightCell.transPerSecond;
            if (meetTime >= remainTime) {
                // 不会相遇
                preferTrajectory = rightCell.trajectory;
//                NSLog(@"cv prefer = 22 = %i \t before:%@ ", preferTrajectory, rightCell.barrageLabel.text);
                break;
            }
        }
    } else {
        preferTrajectory = idleTrajectory;
//        NSLog(@"cv prefer = 33 = %i \t iddle ", preferTrajectory);
    }
    
    if (preferTrajectory == -1) {
        // 仍然没有适合的弹道, 放弃
        NSLog(@"cv prefer = 44 = %i \t abandon ", preferTrajectory);
        return NO;
    }

    cell.trajectory = preferTrajectory;
    CGFloat oriPointY = [self.trajectories[preferTrajectory % self.trajectories.count] floatValue];
    CGFloat oriPointX = CGRectGetWidth(self.bounds) + (CGRectGetWidth(cell.bounds) / 2);
    CGPoint originPoint = CGPointMake(oriPointX, oriPointY);
    
    [cell setOriginAnimationPositon:originPoint];
    // NSLog(@"cv center:(%f, %f)", oriPointX, oriPointY);
    
    return YES;
}


#pragma mark - Timer Events
- (void)timeToRenderBarrage:(id)userInfo
{
    if (self.userRenderStatus != BBAPlayBarrageViewOpen) {
        // 用户弹幕开发被关闭
        return;
    }
    if ([self prepareBarragesIfNeed]) {
        // 如果有需要处理的原始弹幕数据，先进行处理
        return;
    }
    CGFloat currentPlayingTime = [self currentPlayingTime];
    if (currentPlayingTime  < 0.00001f || !self.isReadyToRender || ![self isPlaying] ) {
        // 当前视频的播放时间太小需等待下个定时器触发
        // 没有准备好弹幕数据、当前视频不是播放状态，需要重置上次渲染时间
        self.lastRenderTime = currentPlayingTime;
        return;
    }

    CGFloat lastRenderTime = self.lastRenderTime;
    if (currentPlayingTime - lastRenderTime > 3 * _timerInterval) {
        // 本次渲染和上次渲染之间的时间差远远大于定时器时间周期，因此这段时间内的弹幕不渲染，等待下个正常的渲染周期
        self.lastRenderTime = currentPlayingTime;
        return;
    }
    
    NSPredicate *needRenderPredicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        CGFloat shootTime = [evaluatedObject shootTime];
        if (shootTime < currentPlayingTime && shootTime > self.lastRenderTime) {
            return YES;
        }
        return NO;
    }];
    // 得到本次需要渲染的弹幕数据
    NSArray *barragesToRender = [self.descNeedsRender filteredArrayUsingPredicate:needRenderPredicate];
    self.lastRenderTime = currentPlayingTime;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       [self showBarrage:barragesToRender];
    }];
}



#pragma mark - Cell Animaitons
- (void)animationCell:(BBABarrageCell *)cell {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addSubview:cell];
        [cell addAnimationOnView:self];
    }];
}

- (void)pauseCellAnimation {
    for (BBABarrageCell *cell in self.subviews) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [cell pauseAnimations];
            /*
            NSLog(@"cv pauseCellAnimation cell(%@) , layer = %@ , present = %@, real = %@",
                  cell.barrageLabel.text,
                  NSStringFromCGPoint(cell.layer.position),
                  NSStringFromCGPoint(cell.layer.presentationLayer.position),
                  NSStringFromCGPoint(cell.realPosition));
             */
        }];
    }
}

- (void)resumeCellAnimation {
    for (BBABarrageCell *cell in self.subviews) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [cell resumeAnimations];
            /*
            NSLog(@"cv resumeCellAnimation cell(%@) ,layer = %@ , present = %@, real = %@",
                  cell.barrageLabel.text,
                  NSStringFromCGPoint(cell.layer.position),
                  NSStringFromCGPoint(cell.layer.presentationLayer.position),
                  NSStringFromCGPoint(cell.realPosition));
             */
        }];
    }
}
#pragma mark - Delloc
-(void)dealloc {
    [self clearAllCells];
}
- (void)clearAllCells {
    for (BBABarrageCell *cell in self.subviews) {
        [cell.layer removeAllAnimations];
        cell.alpha = 0;
        [cell removeFromSuperview];
    }
}

#pragma mark - Helper
@end
