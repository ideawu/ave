//  Created by ideawu on 3/11/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IView;

typedef enum{
	IStyleBorderSolid,
	IStyleBorderDashed,
}IStyleBorderType;

@interface IStyleBorder : NSObject
@property (nonatomic, weak) IView *view;
@property (nonatomic) CGFloat width;
@property (nonatomic) IStyleBorderType type;
@property (nonatomic) NSColor *color;
@end
