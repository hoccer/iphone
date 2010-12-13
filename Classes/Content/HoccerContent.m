//
//  HoccerData.m
//  Hoccer
//
//  Created by Robert Palmer on 24.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//


#import "HoccerContent.h"
#import "Preview.h"
#import "NSFileManager+FileHelper.h"

@implementation HoccerContent
@synthesize data;
@synthesize filename;
@synthesize isFromContentSource;

@synthesize persist;
@synthesize mimeType;


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
	}
	
	return self;
}

- (id) initWithDictionary: (NSDictionary *)dict {
	NSLog(@"dict: %@", dict);
	
	if ([dict objectForKey:@"content"]) {
		NSData *theData = [[dict objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding]; 
		return [self initWithData:theData];
	} else {
		return [super init];
	}
}

- (id) initWithData: (NSData *)theData {
	self = [super init];
	if (self != nil) {
		NSString *theFilename = [NSString stringWithFormat:@"%@.%@", [self defaultFilename], self.extension];
		
		self.filename = [[NSFileManager defaultManager] uniqueFilenameForFilename: theFilename 
																	  inDirectory: [[NSFileManager defaultManager] contentDirectory]];
		NSLog(@"filename %@", self.filename);
		self.data = theData;

		[self saveDataToDocumentDirectory];
	}
	
	return self;
}

- (id) init {
	self = [super init];
	if (self != nil) {
		NSString *newFilename = [NSString stringWithFormat:@"%@.%@", [self defaultFilename], self.extension];
		self.filename = [[NSFileManager defaultManager] uniqueFilenameForFilename: newFilename 
																	  inDirectory: [[NSFileManager defaultManager] contentDirectory]];
	}
	
	return self;
}


- (void) dealloc {		
	[data release];
	[filename release];
	[interactionController release];
	
	[super dealloc];
}

- (NSData *)data {
	NSLog(@"in data, filename: %@", self.filename);
	if (data == nil && self.filename != nil) {
		self.data = [NSData dataWithContentsOfFile:self.filepath];
	}

	return data;
}


#pragma mark -
#pragma mark Saving and Removing 
- (void) saveDataToDocumentDirectory {
	[data writeToFile: self.filepath atomically: NO];
} 

- (void) removeFromDocumentDirectory {
	NSError *error = nil;
	if (self.filename != nil) {
		[[NSFileManager defaultManager] removeItemAtPath:self.filepath error:&error]; 
	}	
}


#pragma mark -
#pragma mark View Generator Methods
- (UIView *)fullscreenView {
	UIWebView *webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 0, 320, 323)];
	webView.scalesPageToFit = YES;
		
	[webView loadRequest: [NSURLRequest requestWithURL: [NSURL fileURLWithPath:self.filepath]]];	
	return [webView  autorelease];
}

- (Preview *)desktopItemView {
	Preview *view = [[Preview alloc] initWithFrame: CGRectMake(0, 0, 303, 224)];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"container_image-land.png"]];
	
	[view addSubview:backgroundImage];
	[view sendSubviewToBack:backgroundImage];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 83, view.frame.size.width, 40)];
	label.backgroundColor = [UIColor clearColor];
	label.text = [[self.filename pathExtension] uppercaseString];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor colorWithWhite:0.7 alpha:1];
	label.font = [UIFont boldSystemFontOfSize:50];
	[view addSubview:label];

	UILabel *filenameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 175, view.frame.size.width - 60, 30)];
	filenameLabel.backgroundColor = [UIColor clearColor];
	filenameLabel.text = self.filename;
	filenameLabel.textAlignment = UITextAlignmentCenter;
	filenameLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
	filenameLabel.font = [UIFont systemFontOfSize:14];
	filenameLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
	[view addSubview:filenameLabel];

	
	[backgroundImage release];
	[label release];
	
	return [view autorelease];
}

#pragma mark -
#pragma mark Saving Callbacks Methods
- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector context: (id)aContext {
	target = aTarget;
	selector  = aSelector;
	
	[aContext retain];
	[context release];
	context = aContext;
}

- (void)sendSaveSuccessEvent {
	if ([target respondsToSelector:selector]) {
		[target performSelector:selector withObject:context];
	}
}

#pragma mark -
#pragma mark File Location Methods
- (NSURL *)fileUrl {
	return [NSURL fileURLWithPath:self.filepath];
}

- (NSString *)filepath {
	return [[[NSFileManager defaultManager] contentDirectory] stringByAppendingPathComponent:self.filename];
}

#pragma mark -
- (NSDictionary *)dataDesctiption {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	[dictionary setObject:self.mimeType forKey:@"type"];
	
	return dictionary;
}

- (NSObject <Transferable> *)transferer {
	
	return nil;
}

#pragma mark -
#pragma mark Type Description Methods
- (NSString *)mimeType{
	//overwrite in subclasses: text, img, vcards	
	return mimeType;
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
	return NSLocalizedString(@"Open", nil);
}

- (UIImage *)imageForSaveButton {
	return [UIImage imageNamed:@"container_btn_double-openwith.png"];
}

- (UIImage *)historyThumbButton {
	return [UIImage imageNamed:@"history_icon_image.png"];
}

- (NSString *)extension {
	return @"na";
}

- (NSString *)defaultFilename {
	return @"File";
}

- (BOOL)saveDataToContentStorage {	
	return NO;
}

#pragma mark -
#pragma mark UIDocumentInteractionController
- (id)interactionController; {
	if (interactionController == nil) {
		interactionController = [[NSClassFromString(@"UIDocumentInteractionController") interactionControllerWithURL:self.fileUrl] retain];
	}
	
	return interactionController;
}

@end
