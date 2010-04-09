//
//  HoccerData.m
//  Hoccer
//
//  Created by Robert Palmer on 24.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//


#import "HoccerContent.h"
#import "Preview.h"


#ifdef UI_USER_INTERFACE_IDIOM
#import "HoccerContentIPadPreviewDelegate.h"
#endif
#import "HoccerContentIPhonePreviewDelegate.h"	

@implementation HoccerContent
@synthesize data;
@synthesize filepath;

#pragma mark NSCoding Delegate Methods
- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if (self != nil) {
		self.filepath = [decoder decodeObjectForKey:@"filepath"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:filepath forKey:@"filepath"];
}

- (id) initWithFilename: (NSString *)filename
{
	self = [super init];
	if (self != nil) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString *documentsDirectoryUrl = [paths objectAtIndex:0];
		
		self.filepath = [documentsDirectoryUrl stringByAppendingPathComponent: filename];
		
		previewDelegate = (id <HoccerContentPreviewDelegate>)[[NSClassFromString(@"HoccerContentIPadPreviewDelegate") alloc] init];
		if (previewDelegate == nil) {
			previewDelegate = (id <HoccerContentPreviewDelegate>)[[NSClassFromString(@"HoccerContentIPhonePreviewDelegate") alloc] init];
		}
	}
	
	
	return self;
}



- (id) initWithData: (NSData *)theData filename: (NSString *)filename {
	self = [super init];
	if (self != nil) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString *documentsDirectoryUrl = [paths objectAtIndex:0];
		
		self.filepath = [documentsDirectoryUrl stringByAppendingPathComponent: filename];
		self.data = theData;
		
		[self saveDataToDocumentDirectory];
		
		previewDelegate = (id <HoccerContentPreviewDelegate>)[[NSClassFromString(@"HoccerContentIPadPreviewDelegate") alloc] init];
		if (previewDelegate == nil) {
			previewDelegate = (id <HoccerContentPreviewDelegate>)[[NSClassFromString(@"HoccerContentIPhonePreviewDelegate") alloc] init];
		}
	}
	
	return self;
}

- (id) init {
	self = [super init];
	if (self != nil) {
		NSString *filename = [NSString stringWithFormat:@"%f.%@", [NSDate timeIntervalSinceReferenceDate], self.extension];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString *documentsDirectoryUrl = [paths objectAtIndex:0];
		
		self.filepath = [documentsDirectoryUrl stringByAppendingPathComponent: filename];
		previewDelegate = (id <HoccerContentPreviewDelegate>)[[NSClassFromString(@"HoccerContentIPadPreviewDelegate") alloc] init];
	}
	return self;
}

- (NSData *)data {
	if (data == nil && filepath != nil) {
		self.data = [NSData dataWithContentsOfFile:filepath];
	}
	return data;
}

- (void) saveDataToDocumentDirectory {
	[data writeToFile: filepath atomically: NO];
} 

- (void) removeFromDocumentDirectory {
	NSError *error = nil;
	if (filepath != nil) {
		[[NSFileManager defaultManager] removeItemAtPath:filepath error:&error]; 
	}	
}

- (void) dealloc {	
	[data release];
	[filepath release];
	[previewDelegate release];
		
	[super dealloc];
}

- (NSString *)extension {
	return @"na";
}

- (void)prepareSharing{
	//overwrite in subclasses: text
}

- (void)saveDataToContentStorage{
	//overwrite in subclasses: text, img, vcards	
}

- (UIView *)fullscreenView{
	UIWebView *webView = [[UIWebView alloc] initWithFrame: CGRectMake(10, 60, 300, 350)];
	webView.scalesPageToFit = YES;
		
	[webView loadRequest: [NSURLRequest requestWithURL: [NSURL fileURLWithPath:self.filepath]]];	
	return [webView  autorelease];
}

- (Preview *)desktopItemView {
	Preview *view = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 319, 234)];
	
	NSString *backgroundImagePath = [[NSBundle mainBundle] pathForResource:@"Photobox" ofType:@"png"];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:backgroundImagePath]];
	
	[view addSubview:backgroundImage];
	[view sendSubviewToBack:backgroundImage];
	[backgroundImage release];
	
	[view setImage: [previewDelegate hoccerContentIcon:self]];
	return [view autorelease];
}

- (NSString *)filename{
	return [filepath lastPathComponent];
}

- (NSString *)mimeType{
	//overwrite in subclasses: text, img, vcards	
	return nil;
}

- (BOOL)isDataReady{
	//overwrite in subclasses: img
	return YES;
}

- (BOOL)needsWaiting{
	//overwrite in subclasses: img
	return NO;
}

- (NSString *)descriptionOfSaveButton{
	return nil;
}

- (void)previewInViewController: (UIViewController *)viewController {
	[previewDelegate hoccerContent: self previewInViewController: viewController];
}

- (void)decorateViewWithGestureRecognition: (UIView *)view inViewController: (UIViewController *)viewController {
	[previewDelegate hoccerContent: self decorateViewWithGestureRecognition: view inViewController: viewController]; 
}

- (NSURL *)fileUrl {
	return [NSURL fileURLWithPath:self.filepath];
}



@end
