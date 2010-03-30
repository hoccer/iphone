//
//  HoccerData.m
//  Hoccer
//
//  Created by Robert Palmer on 24.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//


#import "HoccerContent.h"
#import "Preview.h"

@implementation HoccerContent
@synthesize data;
@synthesize filepath;

- (id) initWithData: (NSData *)theData filename: (NSString *)filename {
	self = [super init];
	if (self != nil) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString *documentsDirectoryUrl = [paths objectAtIndex:0];
		
		self.filepath = [documentsDirectoryUrl stringByAppendingPathComponent: filename];
		self.data = theData;
		
		[self saveDataToDocumentDirectory];
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
	return nil;
}

- (Preview *)desktopItemView{
	return nil;
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

@end
