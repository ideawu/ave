//  Created by ideawu on 2/28/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "IView.h"
#import "IStyle+Private.h"

@interface IView(){
	IStyle *_style;
}
@end

@implementation IView

- (id)init{
	self = [super init];
	// 不要调用 setup!!! 因为 super.init 会自动调用 initWithFrame。
	return self;
}

- (id)initWithFrame:(NSRect)frameRect{
	self = [super initWithFrame:frameRect];
	[self setup];
	return self;
}

- (void)awakeFromNib{
	[self setup];
}

- (IStyle *)style{
	if(!_style){
		_style = [[IStyle alloc] initWithIView:self];
	}
	return _style;
}

- (void)setup{
	_style = nil;
	_userInteractionEnabled = YES;
}

- (BOOL)isFlipped{
	return YES;
}

- (NSImage *)snapshot{
	NSRect cacheRect = [self bounds];
	NSBitmapImageRep *bitmapRep = [self bitmapImageRepForCachingDisplayInRect:cacheRect];
	[self cacheDisplayInRect:cacheRect toBitmapImageRep:bitmapRep];
	
	NSImage *image = [[NSImage alloc] initWithSize:cacheRect.size];
	[image addRepresentation:bitmapRep];
	return image;
}

- (NSView *)hitTest:(NSPoint)point{
	if(!_userInteractionEnabled){
		return nil;
	}
	return [super hitTest:point];
}

- (void)setFrameSize:(NSSize)newSize{
	[super setFrameSize:newSize];
	[self setNeedsLayout:YES];
}

- (void)layout{
	[super layout];
}

- (void)drawRect:(CGRect)rect{
	[super drawRect:rect];
	[self drawBorder];
}

- (void)strokeBorder:(IStyleBorder *)border context:(CGContextRef)context{
	if(border.type == IStyleBorderDashed){
		CGFloat dashes[] = {border.width * 5, border.width * 5};
		CGContextSetLineDash(context, 0, dashes, 2);
	}
	CGContextSetLineWidth(context, border.width);
	[border.color set];
	CGContextStrokePath(context);
}

- (void)drawBorder{
	if(!_style){
		return;
	}
	if([_style borderNone]){
		return;
	}
//	log_debug(@"%s", __func__);

	NSEdgeInsets borderEdge = self.style.borderEdge;
	CGFloat radius = _style.borderRadius;
	CGRect rect = self.bounds;
	CGFloat x1, y1, x2, y2;
	x1 = rect.origin.x;
	y1 = rect.origin.y;
	x2 = x1 + rect.size.width;
	y2 = y1 + rect.size.height;
//	log_debug(@"%f %f %f", self.frame.size.height, y1, y2);

	CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;;
	
	// TODO: border 太大时有bug
	// top
	CGContextAddArc(context, radius, radius, radius-borderEdge.top/2, M_PI*5/4-20.0/180, M_PI*6/4, 0);
	CGContextAddLineToPoint(context, x2 - radius, y1+borderEdge.top/2);
	CGContextAddArc(context, x2 - radius, y1 + radius, radius-borderEdge.top/2, M_PI*6/4, M_PI*7/4, 0);
	[self strokeBorder:_style.borderTop context:context];
	
	// right
	CGContextAddArc(context, x2 - radius, y1 + radius, radius-borderEdge.right/2, M_PI*7/4-20.0/180, M_PI*8/4, 0);
	CGContextAddLineToPoint(context, x2-borderEdge.right/2, y2 - radius);
	CGContextAddArc(context, x2 - radius, y2 - radius, radius-borderEdge.right/2, M_PI*8/4, M_PI*9/4, 0);
	[self strokeBorder:_style.borderRight context:context];
	
	// bottom
	CGContextAddArc(context, x2 - radius, y2 - radius, radius-borderEdge.bottom/2, M_PI*9/4-20.0/180, M_PI*10/4, 0);
	CGContextAddLineToPoint(context, x1 + radius, y2-borderEdge.bottom/2);
	CGContextAddArc(context, x1 + radius, y2 - radius, radius-borderEdge.bottom/2, M_PI*10/4, M_PI*11/4, 0);
	[self strokeBorder:_style.borderBottom context:context];
	
	// left
	CGContextAddArc(context, x1 + radius, y2 - radius, radius-borderEdge.left/2, M_PI*11/4-20.0/180, M_PI*12/4, 0);
	CGContextAddLineToPoint(context, x1+borderEdge.left/2, y1 + radius);
	CGContextAddArc(context, x1 + radius, y1 + radius, radius-borderEdge.left/2, M_PI*12/4, M_PI*13/4, 0);
	[self strokeBorder:_style.borderLeft context:context];
}

- (void)drawBackground{
//	[NSGraphicsContext saveGraphicsState];
//	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:imageFrame
//														 xRadius:5
//														 yRadius:5];
//	[path addClip];
//	[image drawInRect:imageFrame
//			 fromRect:NSZeroRect
//			operation:NSCompositeSourceOver
//			 fraction:1.0];
//	[NSGraphicsContext restoreGraphicsState];
}

@end
