//
//  UploadRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 16.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "UploadRequest.h"
#import "NSObject+DelegateHelper.h"


@interface UploadRequest (Private)

- (NSData  *)bodyWithData: (NSData *) data type: (NSString *)type filename: (NSString *)filename;

@end

NSString *kBorder = @"ycKtoN8VURwvDC4sUzYC9Mo7l0IVUyDDVf";

@implementation UploadRequest

- (id)initWithURL: (NSURL *)uploadUrl data: (NSData *)bodyData type: (NSString *)type filename: (NSString *)filename delegate: (id)aDelegate {
	self = [super init];
	if (self != nil) {
		self.delegate = aDelegate;
		
		NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:uploadUrl];
		[uploadRequest setHTTPMethod: @"PUT"];
		[uploadRequest setValue: [NSString stringWithFormat: @"multipart/form-data; boundary=%@", kBorder]
				 forHTTPHeaderField:@"Content-Type"];
		
		[uploadRequest setHTTPBody: [self bodyWithData: bodyData type: type filename: filename]];
		[uploadRequest setValue: self.userAgent forHTTPHeaderField:@"User-Agent"];
		self.request = uploadRequest;
		
		self.connection = [NSURLConnection connectionWithRequest: self.request delegate:self]; 
		if (!connection)  {
			NSLog(@"Error while executing url connection");
		}
	}
	
	return self;
}


#pragma mark -
#pragma mark BaseHoccerRequest Delegate Methods

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {	
	self.result = [self parseJsonToDictionary: receivedData];
	self.connection = nil;
	
	[delegate checkAndPerformSelector:@selector(uploadRequestDidFinished:) withObject: self];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten 
											   totalBytesWritten:(NSInteger)totalBytesWritten 
									   totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	
	float percentage =  (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
	[self.delegate checkAndPerformSelector: @selector(request:didPublishDownloadedPercentageUpdate:)
								withObject: self withObject: [NSNumber numberWithFloat:  percentage]];
}

#pragma mark -
#pragma mark Private Methods


- (NSData  *)bodyWithData: (NSData *) data type: (NSString *)type filename: (NSString *)filename
{
	NSString *name = @"upload[attachment]";
	
	NSMutableData *bodyData = [NSMutableData data];
	
	[bodyData appendData: [[NSString stringWithFormat: @"--%@\r\n", kBorder] dataUsingEncoding: NSUTF8StringEncoding]]; 
	[bodyData appendData: [[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"", name] dataUsingEncoding: NSUTF8StringEncoding]];
	[bodyData appendData: [[NSString stringWithFormat: @" filename=\"%@\"\r\n", filename] dataUsingEncoding: NSUTF8StringEncoding]];
	[bodyData appendData: [[NSString stringWithFormat: @"Content-Type: %@\r\n", type] dataUsingEncoding: NSUTF8StringEncoding]];
	[bodyData appendData: [[NSString stringWithFormat: @"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	
	[bodyData appendData: data];
	[bodyData appendData: [[NSString stringWithFormat: @"\r\n--%@--\r\n", kBorder] dataUsingEncoding: NSUTF8StringEncoding]];
			
	return bodyData;
}




				   
				   
				   

@end
