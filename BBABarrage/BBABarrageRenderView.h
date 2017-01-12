//
//  BBABarrageRenderView.h
//  BBAComs
//
//  Created by chengwei06 on 2016/12/24.
//
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, BBAPlayBarrageViewStatus) {
    BBAPlayBarrageViewNotSupport = -1,
    BBAPlayBarrageViewClose = 0,
    BBAPlayBarrageViewOpen = 1,
};

@class BBABarrageRenderView;
@protocol BBABarrageRenderDelegate <NSObject>
@required

/**
 * 当前视频的播放时间
 */
- (CGFloat)videoCurrentPlayTime:(BBABarrageRenderView *)barrageRenderView;

/** 
 * 视频播放状态，如果设为 NO，不会绘制新弹幕，已绘制弹幕会继续动画直至消失
 */
- (BOOL)videoIsPlaying:(BBABarrageRenderView *)barrageRenderView;

@optional

/**
 当前视频的时长，当弹幕没有时间轴时，需要此值来将弹幕均匀分配
 @param barrageRenderView
 @return 时长
 */
- (CGFloat)videoDuration:(BBABarrageRenderView *)barrageRenderView;

/**
 弹幕初始化完成
 */
- (void)barrageViewPerpareDone:(BBABarrageRenderView *)barrageRenderView;
@end



@class BBABarrageCell;
@class BBABarrageDescriptor;
@interface BBABarrageRenderView : UIView
@property(nonatomic, assign, readonly) BBAPlayBarrageViewStatus userRenderStatus;;
@property(nonatomic, weak) id<BBABarrageRenderDelegate> delegate;
@property(nonatomic, strong) NSMutableArray<BBABarrageDescriptor *> *barragesDesc;

/**
 默认的初始化方法不可用，请使用推荐的初始化方法 - (instancetype)initWithFrame:(CGRect)frame
 */
- (instancetype)init;

/**
 推荐的初始化方法

 @param frame 弹幕在视频播放器中的frame
 */
- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

/**
 弹幕器加载一批弹幕数据，耗时操作，完成后可以在 delegate barrageViewPerpareDone: 中调用 start 方法
 @param barrageDescs 一批弹幕描述符
 */
- (void)loadBarrages:(NSArray<BBABarrageDescriptor *> *)barrageDescs;

/**
 弹幕开始渲染
 */
- (void)start;

/**
 弹幕停止渲染，并销毁
 */
- (void)stop;

/**
 弹幕暂停渲染
 */
- (void)pause;

/**
 重置弹幕数据,可以在加载另一个视频时调用
 */
- (void)reset;

/**
 设置用户是否开启弹幕
 */
- (void)setRenderStatus:(BBAPlayBarrageViewStatus)status;

/**
 发送一批弹幕，这些弹幕会立即显示在播放器弹幕浮层上，忽略播放器的播放状态, 只跟弹幕的开关状态相关
 @param barrageDescs 一组弹幕描述符
 */
- (void)showBarrage:(NSArray<BBABarrageDescriptor *> *)barrageDescs;

@end
