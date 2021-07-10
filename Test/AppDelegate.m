//  Created by ideawu on 27/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import "AppDelegate.h"
#import "TestVideoAsset.h"
#import "TestSVGView.h"
#import "TestAssetView.h"
#import "TestListView.h"
#import "TestTimelineEditor.h"
#import "TestCollectionView.h"

@interface AppDelegate (){
	TestVideoAsset *_TestVideoAsset;
	TestSVGView *_TestSVGView;
	TestAssetView *_TestAssetView;
	TestListView *_TestListView;
	TestTimelineEditor *_TestTimelineEditor;
	TestCollectionView *_TestCollectionView;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//	_TestCollectionView = [[TestCollectionView alloc] initWithWindowNibName:@"TestCollectionView"];
//	[_TestCollectionView showWindow:self];
	
	_TestTimelineEditor = [[TestTimelineEditor alloc] initWithWindowNibName:@"TestTimelineEditor"];
	[_TestTimelineEditor showWindow:self];
	
//	_TestListView = [[TestListView alloc] initWithWindowNibName:@"TestListView"];
//	[_TestListView showWindow:self];
	
//	_TestAssetView = [[TestAssetView alloc] initWithWindowNibName:@"TestAssetView"];
//	[_TestAssetView showWindow:self];
	
//	_TestVideoAsset = [[TestVideoAsset alloc] initWithWindowNibName:@"TestVideoAsset"];
//	[_TestVideoAsset showWindow:self];
	
//	_TestSVGView = [[TestSVGView alloc] initWithWindowNibName:@"TestSVGView"];
//	[_TestSVGView showWindow:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
	return YES;
}


@end
