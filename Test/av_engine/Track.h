//  Created by ideawu on 2019/3/9.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Clip.h"
#import "Transition.h"

@interface Track : NSObject

@property (readonly) NSArray<Clip *> *clips;
@property (readonly) NSArray<Transition *> *transitions;

@property (readonly) double duration;
@property int layer;

- (void)debug;

/** 参见 Clip 关于时间区间的说明。 */
- (Clip *)clipAtTime:(double)time;
/** 参见 Clip 关于时间区间的说明。 */
- (Clip *)clipBeforeTime:(double)time;
/** 参见 Clip 关于时间区间的说明。 */
- (Clip *)clipAfterTime:(double)time;

/**
 TODO: 可以不做重叠判断，直接将其后移即可？
 判断是否可以插入一个 clip 在指定时间。下列情况之一将无法插入：
 1. time 处于某个 clip 的 (beginTime, endTime) 开区间内。
 2. time 之前的 clip 有 transition。
 3. time 之后的 clip 有 transition。
 */
- (BOOL)canInsertClipAtTime:(double)time;
/**
 插入一个 clip，beginTime 大于或者等于的其它 clip 都后移。
 注意：插入 clip 之前，必须移除插入位置前后的 transitions，否则无法插入！
 */
- (void)insertClip:(Clip *)clip;
/**
 删除一个 clip，beginTime 大于或者等于的其它 clip 都前移。
 注意：删除 clip 时，将同时把它的 transitions 移除！
 */
- (void)removeClip:(Clip *)clip;

/** clip 之前的(开场) transition。 */
- (Transition *)transitionBeforeClip:(Clip *)clip;
/** clip 之后的(退场) transition。 */
- (Transition *)transitionAfterClip:(Clip *)clip;

/**
 如果 clip 的指定位置已经存在 transition，则不可再插入，除非将原 transition 删除。
 */
- (BOOL)canAddTransitionBeforeClip:(Clip *)clip;
/**
 如果 clip 的指定位置已经存在 transition，则不可再插入，除非将原 transition 删除。
 */
- (BOOL)canAddTransitionAfterClip:(Clip *)clip;
/**
 如果两个 clip 之间有 transition，则不可插入新的。
 */
- (BOOL)canAddTransitionAfterClip:(Clip *)first andBeforeClip:(Clip *)second;

/**
 添加一个 transition，并根据 gapDuration 前移或者后移受影响的 clip。
 注意：插入 transition 之前，必须移除插入位置的 transition，否则无法插入！
 */
- (void)addTransition:(Transition *)transition;
/**
 删除一个 transition，并根据 gapDuration 前移或者后移受影响的 clip。
 */
- (void)removeTransition:(Transition *)transition;
/**
 删除 clip 相关的 transition。
 */
- (void)removeTransitionsAroundClip:(Clip *)clip;

@end
