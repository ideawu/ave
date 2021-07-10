//  Created by ideawu on 2/28/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "TestListView.h"
#import "ListView.h"
#import "ClipView.h"

@interface TestListView (){
}
@property (weak) IBOutlet NSView *myView;
@property ListView *topView;

@end

@implementation TestListView

- (void)windowDidLoad {
    [super windowDidLoad];
	[self setup];
}

- (void)setup{
	if(_topView){
		[_topView removeFromSuperview];
	}
	
	_topView = [[ListView alloc] initWithFrame:_myView.bounds];
	_topView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	
	_topView.isVerticalScroll = NO;
	[_topView allowDragging:YES];
	[_topView allowResizing:YES];
	_topView.wantsLayer = YES;
	_topView.layer.backgroundColor = [NSColor whiteColor].CGColor;
	[_topView.style set:@"border: 5 solid #f00;"];
	[_topView.style set:@"padding: 5;"];
	NSImage *img = [[NSImage alloc] initWithContentsOfFile:@"/Users/ideawu/Downloads/mc-7.png"];
	for(int i=0; i<15; i++){
		ListViewItem *item = [[ListViewItem alloc] init];
		item.resizable = YES;
		item.contentView = [[IView alloc] init];
		[item.contentView.style set:@"border: 1px solid #333;"];
		[item setFrameSize:NSMakeSize(100, 0)];
		
		NSTextField *label = [[NSTextField alloc] init];
		label.editable = NO;
		label.drawsBackground = NO;
		label.bordered = NO;
		label.stringValue = [NSString stringWithFormat:@"%d", i];
		label.font = [NSFont systemFontOfSize:18];
		[label sizeToFit];
		[label setFrameOrigin:NSMakePoint((item.frame.size.width - label.frame.size.width)/2, 4)];
		[item.contentView addSubview:label];
		
		NSImageView *iv = [[NSImageView alloc] init];
		iv.image = img;
		[iv setFrameOrigin:NSMakePoint(0, 24)];
		[iv setFrameSize:NSMakeSize(item.frame.size.width - 10, item.frame.size.width - 10)];
		[item.contentView addSubview:iv];
		
		[_topView addItem:item];
	}

	[_myView addSubview:_topView];
}

- (void)keyDown:(NSEvent *)event{
	[self setup];
}

@end
