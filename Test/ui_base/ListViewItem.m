//  Created by ideawu on 3/4/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListViewItem.h"
#import "ListView.h"

@interface ListViewItem(){
	IView *_contentView;
	BOOL _selected;
}
@end


@implementation ListViewItem

- (void)setup{
	[super setup];
	_contentView = nil;
	_selected = NO;
}

- (IView *)contentView{
	return _contentView;
}

- (void)setContentView:(IView *)contentView{
	if(_contentView){
		[_contentView removeFromSuperview];
	}else{
		NSEdgeInsets edge = self.style.edge;
		NSSize size = contentView.bounds.size;
		size.width += edge.left + edge.right;
		size.height += edge.top + edge.bottom;
		[self setFrameSize:size];
	}
	_contentView = contentView;
	[self addSubview:_contentView];
}

- (BOOL)selected{
	return _selected;
}

- (void)setSelected:(BOOL)selected{
	_selected = selected;
}

- (void)layout{
	[super layout];
	if(_contentView){
		_contentView.frame = self.style.bounds;
	}
}


@end
