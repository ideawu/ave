//  Created by ideawu on 3/11/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "IStyle+Private.h"
#import "IView.h"
#import "IKitUtil.h"

@implementation IStyle

- (id)initWithIView:(IView *)view{
	self = [super init];
	self.view = view;

	_borderLeft = [[IStyleBorder alloc] init];
	_borderRight = [[IStyleBorder alloc] init];
	_borderTop = [[IStyleBorder alloc] init];
	_borderBottom = [[IStyleBorder alloc] init];
	
	_borderLeft.view = self.view;
	_borderRight.view = self.view;
	_borderTop.view = self.view;
	_borderBottom.view = self.view;

	return self;
}

- (NSEdgeInsets)edge{
	return NSEdgeInsetsMake(_padding.top + _borderTop.width,
							_padding.left + _borderLeft.width,
							_padding.bottom + _borderBottom.width,
							_padding.right + _borderRight.width);
}

- (NSEdgeInsets)borderEdge{
	return NSEdgeInsetsMake(_borderTop.width,
							_borderLeft.width,
							_borderBottom.width,
							_borderRight.width);
}

- (NSRect)bounds{
	NSEdgeInsets edge = self.edge;
	NSRect rect = self.view.bounds;
	rect.origin.x = edge.left;
	rect.origin.y = edge.top;
	rect.size.width -= edge.left + edge.right;
	rect.size.height -= edge.top + edge.bottom;
	return rect;
}

- (void)set:(NSString *)css{
	[self.view setNeedsDisplay:YES];
	
	ICssBlock *block = [ICssBlock fromCss:css baseUrl:nil];
	for(ICssDecl *decl in block.decls){
		[self applyDecl:decl baseUrl:block.baseUrl];
	}
}

- (void)applyDecl:(ICssDecl *)decl baseUrl:(NSString *)baseUrl{
	NSString *k = decl.key;
	NSString *v = decl.val;

	if([k isEqualToString:@"display"]){
	}else if([k isEqualToString:@"padding"]){
		_padding = [self parseEdge:v];
		//log_trace(@"padding: %f %f %f %f", _padding.top, _padding.right, _padding.bottom, _padding.left);
	}else if([k isEqualToString:@"padding-top"]){
		_padding.top = [v floatValue];
	}else if([k isEqualToString:@"padding-right"]){
		_padding.right = [v floatValue];
	}else if([k isEqualToString:@"padding-bottom"]){
		_padding.bottom = [v floatValue];
	}else if([k isEqualToString:@"padding-left"]){
		_padding.left = [v floatValue];
	}else if([k isEqualToString:@"border"]){
		_borderLeft = [self parseBorder:v];
		_borderRight = _borderTop = _borderBottom = _borderLeft;
	}else if([k isEqualToString:@"border-top"]){
		_borderTop = [self parseBorder:v];
	}else if([k isEqualToString:@"border-right"]){
		_borderRight = [self parseBorder:v];
	}else if([k isEqualToString:@"border-bottom"]){
		_borderBottom = [self parseBorder:v];
	}else if([k isEqualToString:@"border-left"]){
		_borderLeft = [self parseBorder:v];
	}else if([k isEqualToString:@"border-radius"]){
		_borderRadius = [v floatValue];
	}
}

- (NSEdgeInsets)parseEdge:(NSString *)v{
	NSEdgeInsets edge = {0, 0, 0, 0};
	NSArray *ps = [IKitUtil split:v];
	if(ps.count == 1){
		edge.left = edge.right = edge.top = edge.bottom = [ps[0] floatValue];
	}else if(ps.count == 2){
		edge.top = edge.bottom = [ps[0] floatValue];
		edge.left = edge.right = [ps[1] floatValue];
	}else if(ps.count == 3){
		edge.top    = [ps[0] floatValue];
		edge.left   = [ps[1] floatValue];
		edge.right  = [ps[1] floatValue];
		edge.bottom = [ps[2] floatValue];
	}else if(ps.count == 4){
		edge.top    = [ps[0] floatValue];
		edge.right  = [ps[1] floatValue];
		edge.bottom = [ps[2] floatValue];
		edge.left   = [ps[3] floatValue];
	}
	return edge;
}

- (IStyleBorder *)parseBorder:(NSString *)v{
	IStyleBorder *border = [[IStyleBorder alloc] init];
	if([v isEqualToString:@"none"]){
		return border;
	}
	NSArray *ps = [IKitUtil split:v];
	if(ps.count > 0){
		border.width = [ps[0] floatValue];
	}
	if(ps.count > 1){
		if([ps[1] isEqualToString:@"dashed"]){
			border.type = IStyleBorderDashed;
		}else{
			border.type = IStyleBorderSolid;
		}
	}
	if(ps.count > 2){
		border.color = [IKitUtil colorFromHex:ps[2]];
	}
	return border;
}

@end
