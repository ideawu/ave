//  Created by ideawu on 3/6/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "TransitionView.h"

@interface TransitionView()
@property NSImage *img;
@end


@implementation TransitionView

- (void)setup{
	[super setup];
	self.resizable = NO;
	_img = [NSImage imageNamed:NSImageNameSlideshowTemplate];
	[self setFrameSize:NSMakeSize(22, 22)];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
	NSArray *vals = @[self.transition];
	[aCoder encodeRootObject:vals];
}

- (id)initWithCoder:(NSCoder *)aCoder{
	self = [super initWithCoder:aCoder];
	[self setup];
	NSArray *vals = (NSArray *)[aCoder decodeObject];
	self.transition = (Transition *)[vals objectAtIndex:0];
	return self;
}

- (NSView *)hitTest:(NSPoint)parentPoint{
	NSPoint pos = [self convertPoint:parentPoint fromView:self.superview];
	NSRect rect = NSZeroRect;
	rect.size = _img.size;
	rect.origin.x = (self.bounds.size.width - rect.size.width)/2;
	rect.origin.y = (self.bounds.size.height - rect.size.height)/2;
	return NSPointInRect(pos, rect)? self : nil;
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
	NSRect rect = NSZeroRect;
	rect.size = _img.size;
	rect.origin.x = (self.bounds.size.width - rect.size.width)/2;
	rect.origin.y = (self.bounds.size.height - rect.size.height)/2;
	[_img drawInRect:rect
			fromRect:NSMakeRect(0, 0, _img.size.width, _img.size.height)
		   operation:NSCompositeSourceOver
			fraction:1.0
	  respectFlipped:YES
			   hints:nil];
}

@end
