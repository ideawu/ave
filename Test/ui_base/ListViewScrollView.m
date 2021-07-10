//  Created by ideawu on 3/7/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListViewScrollView.h"

@interface ListViewScrollView(){
	BOOL isVerticalScrolling;
}
@property BOOL myHasHorizontalScroller;
@property BOOL myHasVerticalScroller;
@end


@implementation ListViewScrollView

- (void)scrollWheel:(NSEvent *)event{
	if(!self.hasVerticalScroller && !self.hasHorizontalScroller){
		[[self nextResponder] scrollWheel:event];
	}else{
		[super scrollWheel:event];
	}
}

- (void)tile{
	[super tile];
}
@end
