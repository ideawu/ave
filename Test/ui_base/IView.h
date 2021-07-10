//  Created by ideawu on 2/28/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IStyle.h"

/**
 用于替代 NSView，所有自定义类都不要继承 NSView！
 注意：不要定义 NSView 子类的 init 方法，应该定义 initWithFrame，init 会自动调用 initWithFrame！
 */
@interface IView : NSView

@property (readonly) IStyle *style;

@property BOOL userInteractionEnabled;

/**
 NSView 中 init initWithFrame awakeFromNib 的关系：
 
 init 调用 initWithFrame
 initWithFrame 不调用 init
 awakeFromNib 不调用 init 和 initWithFrame
 */

/**
 子类只重写 setup 方法即可，不要重写 init, initWithFrame, awakeFromNib！
 注意：子类必须调用 [super setup]！
 */
- (void)setup;

/** 已重写，返回 YES */
- (BOOL)isFlipped;

- (NSImage *)snapshot;

@end
