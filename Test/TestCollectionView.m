//
//  TestCollectionView.m
//  Test
//
//  Created by ideawu on 3/12/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "TestCollectionView.h"
#import "NestedListView.h"

@interface TestCollectionView ()
@property NestedListView *collectionView;
@end

@implementation TestCollectionView

- (void)windowDidLoad {
    [super windowDidLoad];
	
	_collectionView = [[NestedListView alloc] initWithFrame:self.window.contentView.bounds];
	_collectionView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self.window.contentView addSubview:_collectionView];
	
	{
		ListView *listView = [[ListView alloc] init];
		listView.isVerticalScroll = NO;
		[listView setFrameSize:NSMakeSize(0, 140)];
		
		for(int i=0; i<20; i++){
			ListViewItem *item = [[ListViewItem alloc] init];
			[item setFrameSize:NSMakeSize(100, 0)];
			[item.style set:@"border: 1px solid #000"];
			[listView addItem:item];
		}
		
		[_collectionView addSubListView:listView];
	}
	
	{
		ListView *listView = [[ListView alloc] init];
		listView.isVerticalScroll = NO;
		[listView setFrameSize:NSMakeSize(0, 180)];

		ListViewItem *item = [[ListViewItem alloc] init];
		[item setFrameSize:NSMakeSize(1500, 0)];
		[item.style set:@"border: 2px solid #f00"];
		[listView addItem:item];
		log_debug(@"%f", listView.scrollView.documentView.frame.size.width);

		[_collectionView addSubListView:listView];
	}

	{
		ListView *listView = [[ListView alloc] init];
		listView.isVerticalScroll = NO;
		[listView setFrameSize:NSMakeSize(0, 150)];

		ListViewItem *item = [[ListViewItem alloc] init];
		[item setFrameSize:NSMakeSize(800, 0)];
		[item.style set:@"border: 2px solid #00f"];
		[listView addItem:item];
		log_debug(@"%f", listView.scrollView.documentView.frame.size.width);

		[_collectionView addSubListView:listView];
	}
}

@end
