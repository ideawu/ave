//  Created by ideawu on 3/11/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IView;

@interface IStyle : NSObject

@property (nonatomic, weak) IView *view;

@property (nonatomic, readonly) NSEdgeInsets padding;

+ (id)new NS_UNAVAILABLE;
- (id)init NS_UNAVAILABLE;
- (id)initWithIView:(IView *)view;

- (void)set:(NSString *)css;

/** 包括 border, padding */
- (NSEdgeInsets)edge;
/** 仅包括 border */
- (NSEdgeInsets)borderEdge;

/** 去除 border, padding */
- (NSRect)bounds;

@end
