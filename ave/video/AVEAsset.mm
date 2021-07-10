//  Created by ideawu on 2/15/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "AVEAsset.h"
#import "AVEClip.h"
#import "SVGView.h"

@interface AVEAsset(){
	a3d::Scene *_scene;
}
@property BOOL isReading;
@property NSMutableArray<AVETrack *> *tracks;
@end

@implementation AVEAsset

- (id)init {
	return nil;
}

- (id)initWidth:(int)width height:(int)height{
	self = [super init];
	_width = width;
	_height = height;
	
	_tracks = [[NSMutableArray alloc] init];

	a3d::Context *context = a3d::Context::create();
	a3d::Drawable *drawable = a3d::Drawable::create(self.width, self.height, 0);
	_scene = a3d::Scene::createWith(context, drawable);
	// a3d::Scene 默认是透明背景，但对于视频来，透明颜色将导致编码器特殊处理，
	// 所以，每一帧视频图像必须先用颜色填充整个背景。
	_scene->backgroundColor(a3d::Color::black());

	return self;
}

- (void)dealloc{
	log_debug(@"%s", __func__);
	// 释放 _clips OpenGL 对象前，需要 makeCurrent()
	_scene->context()->makeCurrent();
	[_tracks removeAllObjects];
	delete _scene;
}

- (double)duration{
	double duration = 0;
	for(AVETrack *track in _tracks){
		duration = MAX(duration, track.duration);
	}
	return duration;
}

- (void)buildScene{
	_scene->removeAllNodes();
	for(AVETrack *track in _tracks){
		for(AVEClip *clip in track.clips){
			_scene->layer(clip.layer);
			_scene->addNode(clip.node);
		}
	}
}

- (AVETrack *)track:(NSUInteger)index{
	for(NSUInteger i=_tracks.count; i<= index; i++){
		AVETrack *track = [[AVETrack alloc] init];
		track.asset = self;
		[_tracks addObject:track];
	}
	return [_tracks objectAtIndex:index];
}

- (CGImageRef)CGImage{
	_scene->context()->makeCurrent();
	return _scene->drawable()->bitmap()->CGImage();
}

- (void)renderAtTime:(double)time callback:(void (^)(void))callback{
	[self buildScene];
	[self setupClipsForTime:time callback:^{
		_scene->context()->makeCurrent();
		_scene->view3D();
		_scene->renderAtTime(time);
		callback();
	}];
}

- (void)setupClipsForTime:(double)time callback:(void (^)(void))callback{
	_scene->context()->makeCurrent();
	// 找出需要初始化的 clip 和需要释放资源的 clip
	NSMutableArray *clipsToInit = [[NSMutableArray alloc] init];
	for(AVETrack *track in _tracks){
		for(AVEClip *clip in track.clips){
			if(time < clip.beginTime || time >= clip.endTime){
				// 这里不用异步
				if(clip.node->content()->sprite()){
					log_debug(@"free %@", clip.file);
					clip.node->content()->sprite(NULL);
				}
			}else{
				if(!clip.node->content()->sprite()){
					[clipsToInit addObject:clip];
				}
			}
		}
	}
	// 异步加载 clip
	[self setupClips:clipsToInit callback:callback];
}

- (void)setupClip:(AVEClip *)clip withSprite:(a3d::Sprite *)sprite{
	log_debug(@"loaded %@", clip.file);
	_scene->context()->makeCurrent();
	clip.node->size(self.width, self.height, 0);
	clip.node->content()->sprite(sprite);
	if(clip.scale && [clip.scale isEqualToString:@"fullfill"]){
		clip.node->setContentToFullFill();
	}else if([clip.scale isEqualToString:@"fill"]){
		clip.node->setContentToFill();
	}else{
		clip.node->setContentToBestSize();
	}
}

- (void)setupClips:(NSMutableArray *)clipsToInit callback:(void (^)(void))callback{
	if(clipsToInit.count == 0){
		callback();
		return;
	}
	
	AVEClip *clip = clipsToInit.lastObject;
	[clipsToInit removeLastObject];
	
	BOOL isSVG = [clip.file.pathExtension.lowercaseString isEqualToString:@"svg"];
	if(!isSVG){
		_scene->context()->makeCurrent();
		a3d::Sprite *sprite = a3d::Sprite::imageSprite([clip.file cStringUsingEncoding:NSUTF8StringEncoding]);
		[self setupClip:clip withSprite:sprite];
		[self setupClips:clipsToInit callback:callback];
	}else{
		// SVGView(NSView) 需要在 main_queue 中
		dispatch_async(dispatch_get_main_queue(), ^{
			SVGView *svg = [[SVGView alloc] init];
			[svg loadSVGFile:clip.file callback:^(SVGViewLoadResult *result) {
				NSImage *img = [svg snapshot];
				[svg close];
				if(img){
					a3d::Sprite *sprite = [self NSImageToSprite:img];
					[self setupClip:clip withSprite:sprite];
					[self setupClips:clipsToInit callback:callback];
				}
			}];
		});
	}

}

- (a3d::Sprite *)NSImageToSprite:(NSImage *)img{
	a3d::Sprite *sprite = NULL;
	CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)[img TIFFRepresentation], NULL);
	if(imageSource){
		_scene->context()->makeCurrent();
		sprite = a3d::ImageSprite::createWithCGImageSource(imageSource);
		// NSImage 的 size 是 point，CGImage 是像素，这里应该使用 point
		sprite->width(img.size.width);
		sprite->height(img.size.height);
	}
	return sprite;
}

@end
