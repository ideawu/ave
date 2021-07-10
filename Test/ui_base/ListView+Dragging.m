//  Created by ideawu on 3/1/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListView+Dragging.h"
#import "ListView+Dragging_private.h"

@implementation ListView (Dragging)

- (void)allowDragging:(BOOL)allow{
	self.allowDragging = allow;
	if(allow){
		[self registerForDraggedTypes:@[kDraggedType]];
	}else{
		[self unregisterDraggedTypes];
	}
}

@end
