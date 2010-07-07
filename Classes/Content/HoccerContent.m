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
@synthesize filename;
@synthesize isFromContentSource;

@synthesize persist;


#pragma mark -
#pragma mark static Methods

+ (NSString *)contentDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	
	if ([paths count] < 1) {
		@throw [NSException exceptionWithName:@"directoryException" reason:@"could not locate document directory" userInfo:nil];
	}
	
	NSString *documentsDirectoryUrl = [paths objectAtIndex:0];
	if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectoryUrl]) {
		NSError *error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectoryUrl withIntermediateDirectories:YES attributes:nil error:&error];
		
		if (error != nil) {
			@throw [NSException exceptionWithName:@"directoryException" reason:@"could not create directory" userInfo:nil];
		}
	}
	
	return documentsDirectoryUrl;
}


#pragma mark NSCoding Delegate Methods
- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if (self != nil) {
		self.filename = [decoder decodeObjectForKey:@"filepath"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:filename forKey:@"filepath"];
}

- (id) initWithFilename: (NSString *)theFilename {
	self = [super init];
	if (self != nil) {
		self.filename = theFilename;
		
		previewDelegate = (id <HoccerContentPreviewDelegate>)[[NSClassFromString(@"HoccerContentIPadPreviewDelegate") alloc] init];
		if (previewDelegate == nil) {
			previewDelegate = (id <HoccerContentPreviewDelegate>)[[NSClassFromString(@"HoccerContentIPhonePreviewDelegate") alloc] init];
		}
	}
	
	return self;
}

- (id) initWithData: (NSData *)theData filename: (NSString *)theFilename {
	self = [super init];
	if (self != nil) {
		self.filename = [self uniqueFilenameForFilename: theFilename inDirectory: [[self class] contentDirectory]];
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
		NSString *newFilename = [NSString stringWithFormat:@"%@.%@", [self defaultFilename], self.extension];
		self.filename = [self uniqueFilenameForFilename: newFilename inDirectory: [[self class] contentDirectory]];
		
		previewDelegate = (id <HoccerContentPreviewDelegate>)[[NSClassFromString(@"HoccerContentIPadPreviewDelegate") alloc] init];
	}
	
	return self;
}

- (NSData *)data {
	if (data == nil && filename != nil) {
		self.data = [NSData dataWithContentsOfFile:self.filepath];
	}
	return data;
}

- (void) saveDataToDocumentDirectory {
	[data writeToFile: self.filepath atomically: NO];
} 

- (void) removeFromDocumentDirectory {
	NSError *error = nil;
	if (filename != nil) {
		[[NSFileManager defaultManager] removeItemAtPath:self.filepath error:&error]; 
	}	
}

- (void) dealloc {		
	[data release];
	[filename release];
	[previewDelegate release];
		
	[super dealloc];
}

- (NSString *)filepath {
	return [[HoccerContent contentDirectory] stringByAppendingPathComponent:self.filename];
}

- (NSString *)extension {
	return @"na";
}

- (NSString *)defaultFilename {
	return @"File";
}

- (void)prepareSharing{
	//overwrite in subclasses: text
}

- (void)saveDataToContentStorage {
	//overwrite in subclasses: text, img, vcards	
}

- (UIView *)fullscreenView {
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

- (NSString *)uniqueFilenameForFilename: (NSString *)theFilename inDirectory: (NSString *)directory {
	if (![[NSFileManager defaultManager] fileExistsAtPath: [directory stringByAppendingPathComponent:theFilename]]) {
		return theFilename;
	};
	
	NSString *extension = [theFilename pathExtension];
	NSString *baseFilename = [theFilename stringByDeletingPathExtension];

	NSInteger i = 1;
	NSString* newFilename = [NSString stringWithFormat:@"%@_%@", baseFilename, [[NSNumber numberWithInteger:i] stringValue]];
	newFilename = [newFilename stringByAppendingPathExtension: extension];
	while ([[NSFileManager defaultManager] fileExistsAtPath: [directory stringByAppendingPathComponent:newFilename]]) {
		newFilename = [NSString stringWithFormat:@"%@_%@", baseFilename, [[NSNumber numberWithInteger:i] stringValue]];
		newFilename = [newFilename stringByAppendingPathExtension: extension];
		
		i++;
	}
	
	return newFilename;
}

- (UIImage *)imageForSaveButton {
	return [UIImage imageNamed:@"container_btn_double-save.png"];
}

- (UIImage *)historyThumbButton {
	return [UIImage imageNamed:@"history_icon_image.png"];
}



@end
