/*
 Copyright (c) 2014 ideawu. All rights reserved.
 Use of this source code is governed by a license that can be
 found in the LICENSE file.
 
 @author:  ideawu
 @website: http://www.cocoaui.com/
 */

#import "IKitUtil.h"

@implementation IKitUtil

static NSString *substr(NSString *str, NSUInteger offset, NSUInteger len){
	return [str substringWithRange:NSMakeRange(offset, len)];
}

static CGFloat colorVal(NSString *hex){
	hex = (hex.length == 2) ? hex : [NSString stringWithFormat:@"%@%@", hex, hex];
	unsigned num;
	[[NSScanner scannerWithString:hex] scanHexInt:&num];
	return num / 255.0;
}

+ (NSColor *)colorFromHex:(NSString *)hex {
	if([hex isEqualToString:@"none"]){
		return [NSColor clearColor];
	}
	if([hex characterAtIndex:0] == '#'){
		hex = [hex substringFromIndex:1];
	}
	
	CGFloat alpha, red, blue, green;
	switch ([hex length]) {
		case 3: // #RGB
			alpha = 1.0f;
			red   = colorVal(substr(hex, 0, 1));
			green = colorVal(substr(hex, 1, 1));
			blue  = colorVal(substr(hex, 2, 1));
			break;
		case 4: // #ARGB
			alpha = colorVal(substr(hex, 0, 1));
			red   = colorVal(substr(hex, 1, 1));
			green = colorVal(substr(hex, 2, 1));
			blue  = colorVal(substr(hex, 3, 1));
			break;
		case 6: // #RRGGBB
			alpha = 1.0f;
			red   = colorVal(substr(hex, 0, 2));
			green = colorVal(substr(hex, 2, 2));
			blue  = colorVal(substr(hex, 4, 2));
			break;
		case 8: // #AARRGGBB
			alpha = colorVal(substr(hex, 0, 2));
			red   = colorVal(substr(hex, 2, 2));
			green = colorVal(substr(hex, 4, 2));
			blue  = colorVal(substr(hex, 6, 2));
			break;
		default:
			return [NSColor clearColor];
			break;
	}
	return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
}

+ (BOOL)isHTML:(NSString *)str{
	if([str rangeOfString:@"</html>"].length > 0 || [str rangeOfString:@"</HTML>"].length > 0){
		if([str rangeOfString:@"</body>"].length > 0 || [str rangeOfString:@"</BODY>"].length > 0){
			return YES;
		}
	}
	return NO;
}

+ (BOOL)isHttpUrl:(NSString *)src{
	if(!src){
		return NO;
	}
	if([src rangeOfString:@"http://"].location == 0 || [src rangeOfString:@"https://"].location == 0){
		return YES;
	}
	return NO;
}

+ (NSString *)getBasePath:(NSString *)url{
	NSArray *arr = [IKitUtil parsePath:url];
	return arr[1];
}

+ (NSString *)getRootPath:(NSString *)url{
	NSArray *arr = [IKitUtil parsePath:url];
	return arr[0];
}

+ (NSArray *)parsePath:(NSString *)url{
	NSString *basePath, *rootPath;
	NSRange r1 = [url rangeOfString:@"http://"];
	if(r1.location != 0){
		r1 = [url rangeOfString:@"https://"];
	}
	NSRange r2 = [url rangeOfString:@"/" options:NSBackwardsSearch];
	if(r1.location != 0){ // File path
		if(r2.location == NSNotFound){
			rootPath = [NSBundle mainBundle].resourcePath;
			basePath = rootPath;
		}else{
			rootPath = [url substringToIndex:r2.location];
			basePath = rootPath;
		}
	}else{ // HTTP URL
		if(r2.location < r1.location + r1.length){ // like http://cocoaui.com
			basePath = [NSString stringWithFormat:@"%@/", url];
			rootPath = basePath;
		}else{
			basePath = [url substringToIndex:r2.location + 1];
			NSUInteger idx = r1.location + r1.length;
			while(idx < url.length){
				if([url characterAtIndex:idx] == '/'){
					break;
				}
				idx ++;
			}
			rootPath = [url substringToIndex:idx + 1];
		}
	}
	return [NSArray arrayWithObjects:rootPath, basePath, nil];
}

+ (NSString *)buildPath:(NSString *)basePath src:(NSString *)src{
	if(!basePath){
		return src;
	}
	if([IKitUtil isHttpUrl:src]){
		return src;
	}
	if([IKitUtil isHttpUrl:basePath]){
		if(src.length > 0 && [src characterAtIndex:0] == '/'){
			NSString *rootPath = [IKitUtil getRootPath:basePath];
			src = [rootPath stringByAppendingString:[src substringFromIndex:1]];
		}else{
			if([basePath characterAtIndex:basePath.length-1] != '/'){
				[basePath stringByAppendingString:@"/"];
			}
			src = [basePath stringByAppendingString:src];
		}
	}else{
		if([src characterAtIndex:0] == '/'){
			src = [[NSBundle mainBundle] pathForResource:src ofType:@""];
		}else{
			src = [basePath stringByAppendingPathComponent:src];
		}
	}
	return src;
}

+ (BOOL)isDataURI:(NSString *)src{
	NSRange range = [src rangeOfString:@"data:"];
	if(range.location == 0 && range.length > 0){
		return YES;
	}else{
		return NO;
	}
}

+ (NSImage *)loadImageFromDataURI:(NSString *)src{
	NSURL* dataURL = [NSURL URLWithString:src];
	NSData *data = [NSData dataWithContentsOfURL:dataURL];
	return [[NSImage alloc] initWithData:data];
}

+ (NSString *)trim:(NSString *)str{
	return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSArray *)split:(NSString *)str{
	NSMutableArray *ps = [NSMutableArray arrayWithArray:
						  [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	[ps removeObject:@""];
	return ps;
}

@end
