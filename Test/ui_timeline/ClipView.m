//  Created by ideawu on 2019/2/27.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ClipView.h"

@interface ClipView(){
}
@property NSTextField *titleLabel;
@property NSTextField *durationLabel;
@end

@implementation ClipView

- (void)setup{
	[super setup];
	
	self.contentView = [[IView alloc] init];
	[self.contentView.style set:@"border-radius: 4;"];

	self.resizable = YES;
	
	_titleLabel = [[NSTextField alloc] init];
	_titleLabel.editable = NO;
	_titleLabel.stringValue = @"@";
	[self.contentView addSubview:_titleLabel];
	
	_durationLabel = [[NSTextField alloc] init];
	_durationLabel.editable = NO;
	_durationLabel.stringValue = @"0s";
	[self.contentView addSubview:_durationLabel];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
	NSArray *vals = @[self.title,
					  @(self.frame.size.width), @(self.frame.size.height),
					  self.clip];
	[aCoder encodeRootObject:vals];
}

- (id)initWithCoder:(NSCoder *)aCoder{
	self = [super initWithCoder:aCoder];
	[self setup];
	NSArray *vals = (NSArray *)[aCoder decodeObject];
	self.title = (NSString *)[vals objectAtIndex:0];
	CGFloat w = [(NSNumber *)[vals objectAtIndex:1] floatValue];
	CGFloat h = [(NSNumber *)[vals objectAtIndex:2] floatValue];
	self.clip = (Clip *)[vals objectAtIndex:3];

	[self setFrameSize:NSMakeSize(w, h)];
	return self;
}

- (NSString *)title{
	return _titleLabel.stringValue;
}

- (void)setTitle:(NSString *)title{
	_titleLabel.stringValue = title;
}

- (double)duration{
	return _durationLabel.floatValue;
}

- (void)setDuration:(double)duration{
	_durationLabel.stringValue = [NSString stringWithFormat:@"%.2fs", duration];
}

- (void)setSelected:(BOOL)selected{
	[super setSelected:selected];
	[self setNeedsLayout:YES];
}

- (void)layout{
	[super layout];
	if(self.selected){
		[self.contentView.style set:@"border: 1 solid #993"];
	}else{
		[self.contentView.style set:@"border: 1 solid #333"];
	}
	[_titleLabel sizeToFit];
	[_durationLabel sizeToFit];
	[_durationLabel setFrameOrigin:NSMakePoint(2, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 2)];
}

@end
