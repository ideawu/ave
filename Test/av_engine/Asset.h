//  Created by ideawu on 3/8/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"
#import "Clip.h"
#import "Transition.h"
#import "Action.h"

@interface Asset : NSObject

@property (readonly) int width;
@property (readonly) int height;
@property (readonly) double duration;

@property (readonly) NSArray<Track *> *tracks;

/** 获取当前已渲染的内容，在 render 之后有效。 */
@property (readonly) CGImageRef CGImage;

+ (id)new NS_UNAVAILABLE;
- (id)init NS_UNAVAILABLE;
- (id)initWidth:(int)width height:(int)height;

- (void)debug;

- (void)addTrack:(Track *)track;

- (void)renderAtTime:(double)time callback:(void (^)(void))callback;

@end
