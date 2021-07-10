//  Created by ideawu on 3/5/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVEClip.h"
#import "AVETransition.h"

@class AVEAsset;

@interface AVETrack : NSObject

@property (weak) AVEAsset *asset;
@property (readonly) double duration;
@property (readonly) NSArray *clips;

- (NSUInteger)indexOfClip:(AVEClip *)clip;
- (AVEClip *)clipAtIndex:(NSUInteger)index;

/** 添加一个 clip 到尾部。*/
- (void)addClip:(AVEClip *)clip;

/** 插入 clip 到指定位置，其后面的 clip 自动改变 beginTime。*/
- (void)insertClip:(AVEClip *)clip atIndex:(NSUInteger)index;
/** 删除指定位置的 clip，其后面的 clip 自动改变 beginTime。*/
- (void)removeClipAtIndex:(NSUInteger)index;

- (AVETransition *)transitionAtIndex:(NSUInteger)index;
/** 根据 transition 的配置，可能改变 beginTime */
- (void)insertTransition:(AVETransition *)transition atIndex:(NSUInteger)index;
- (void)removeTransitionAtIndex:(NSUInteger)index;


@end
