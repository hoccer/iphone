//
//  UploadRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 16.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "UploadRequest.h"

@interface UploadRequest (Private)

- (NSData  *)bodyWithData: (NSData *) data;

@end

NSString *kBorder = @"ycKtoN8VURwvDC4sUzYC9Mo7l0IVUyDDVf";

@implementation UploadRequest

- (id)initWithResult: (id) aResult data: (NSData *)bodyData delegate: (id)aDelegate
{
	self = [super init];
	if (self != nil) {
		
		self.delegate = aDelegate;
		NSURL *uploadUrl = [NSURL URLWithString: [aResult valueForKey:@"upload_uri"]];
		
		NSLog(@"uploading to %@", uploadUrl);

		request = [[NSMutableURLRequest requestWithURL: uploadUrl] retain];
		[request setHTTPMethod: @"PUT"];
		[request setValue: [NSString stringWithFormat: @"multipart/form-data; boundary=%@", kBorder]
				 forHTTPHeaderField:@"Content-Type"];
		
		[request setHTTPBody: [self bodyWithData: bodyData]];
		
		self.connection = [NSURLConnection connectionWithRequest:request delegate:self]; 
		if (!connection)  {
			NSLog(@"Error while executing url connection");
		}
	}
	
	return self;
}


#pragma mark -
#pragma mark Private Methods


- (NSData  *)bodyWithData: (NSData *) data 
{
		
	NSString *filename = @"woo.txt";
	NSString *mime = @"text/plain";
	NSString *name = @"upload[attachment]";
	
	NSMutableString *bodyData = [NSMutableString string];
	
	[bodyData appendFormat: @"--%@\r\n", kBorder]; 
	[bodyData appendFormat: @"Content-Disposition: form-data; name=\"%@\"", name];
	[bodyData appendFormat: @"filename=\"%@\"\r\n", filename];
	[bodyData appendFormat: @"Content-Type: %@\r\n", mime];
	[bodyData appendString: @"Content-Transfer-Encoding: binary\r\n\r\n"];
	
	[bodyData appendString: @"http://www.artcom.de"];
	
	[bodyData appendFormat: @"\r\n--%@--\r\n", kBorder];
	
	NSLog(bodyData);
	
	
	return [bodyData dataUsingEncoding: NSUTF8StringEncoding];
	
}




				   
				   
				   

@end
