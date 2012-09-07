//
//  HoccerData.m
//  Hoccer
//
//  Created by Robert Palmer on 24.03.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//


#import "HoccerContent.h"
#import "Preview.h"
#import "NSFileManager+FileHelper.h"
#import "NSData_Base64Extensions.h"
#import "NSData+CommonCrypto.h"
#import "RSA.h"
#import "NSData+CommonCrypto.h"

@implementation HoccerContent
@synthesize data;
@synthesize filename;
@synthesize isFromContentSource,canBeCiphered;

@synthesize persist;
@synthesize mimeType;

@synthesize cryptor;

#pragma mark NSCoding Delegate Methods
- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if (self != nil) {
		filename = [[decoder decodeObjectForKey:@"filepath"] copy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:filename forKey:@"filepath"];
}

- (id) initWithFilename: (NSString *)theFilename {
	self = [super init];
	if (self != nil) {
		filename = [theFilename copy];
        canBeCiphered = YES;
	}
	
	return self;
}

- (id) initWithDictionary: (NSDictionary *)dict {
    
    //NSLog(@"received %@", dict);
    
    NSDictionary *encryption = nil;
    if ((encryption = [dict objectForKey:@"encryption"])) {
        NSString *method = [encryption objectForKey:@"method"];
        NSString *salt    = [encryption objectForKey:@"salt"];
        NSString *password;
        NSDictionary *passwordDict = [encryption objectForKey:@"password"];
        NSString *uuid = [[NSUserDefaults standardUserDefaults]stringForKey:@"hoccerClientUri"];
        if (passwordDict != nil){
            password = [passwordDict objectForKey:[[[uuid dataUsingEncoding:NSUTF8StringEncoding] SHA1Hash] hexString]];
            [self cryptorWithType:method salt: salt password:password];
        }
        else {
            password = [[NSUserDefaults standardUserDefaults]stringForKey:@"encryptionKey"];
            [self cryptorWithType:@"AESwoRSA" salt: salt password:password];
        }
       
        if (password == nil) {
            NSNotification *notification = [NSNotification notificationWithName:@"encryptionError" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }
    
    if ([dict objectForKey:@"content"]) {
		NSString *content = [self.cryptor decryptString:[dict objectForKey:@"content"]]; 
        NSData *theData = [content dataUsingEncoding:NSUTF8StringEncoding]; 
        return [self initWithData:theData];
        	
    } else {
		return [super init];
	}
}

- (id) initWithData: (NSData *)theData {
	self = [super init];
	if (self != nil) {
		NSString *theFilename = [NSString stringWithFormat:@"%@.%@", [self defaultFilename], self.extension];
		
		filename = [[[NSFileManager defaultManager] uniqueFilenameForFilename: theFilename 
                                                                  inDirectory: [[NSFileManager defaultManager] contentDirectory]] copy];
		data = [theData retain];
        
		[self saveDataToDocumentDirectory];
        
        canBeCiphered = YES;
	}
	
	return self;
}

- (id) init {
	self = [super init];
	if (self != nil) {
		NSString *newFilename = [NSString stringWithFormat:@"%@.%@", [self defaultFilename], self.extension];
		filename = [[[NSFileManager defaultManager] uniqueFilenameForFilename: newFilename 
                                                                 inDirectory: [[NSFileManager defaultManager] contentDirectory]] copy];
	}
	
	return self;
}

- (void)cryptorWithType: (NSString *)type salt: (NSString *)salt password:(NSString *)password{
    //NSLog(@"generating cryptor with %@", type);
    
    if ([type isEqualToString:@"AES"]) {
        
        SecKeyRef thePrivateKey = [[RSA sharedInstance] getPrivateKeyRef];
        
        NSData *cipherData = [NSData dataWithBase64EncodedString:password];
        
        NSData *keyData = [[RSA sharedInstance] decryptWithKey:thePrivateKey cipherData:cipherData];
        
        NSString *key  = [[[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding] autorelease];
                
        if (![key isEqualToString:@""]){
            [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"encryptionKey"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            NSNotification *notification = [NSNotification notificationWithName:@"encryptionError" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
        
        self.cryptor = [[[AESCryptor alloc] initWithKey:key salt:[NSData dataWithBase64EncodedString:salt]] autorelease];

    }
    if ([type isEqualToString:@"AESwoRSA"]) {
        self.cryptor = [[[AESCryptor alloc] initWithKey:password salt:[NSData dataWithBase64EncodedString:salt]] autorelease];
    }

}

- (void) dealloc {	
	if (data){
        [data release];
    }
	[filename release];
	[interactionController release];
	
	[super dealloc];
}

- (NSData *)data {
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
	UIWebView *webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 0, 320, 367)];
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
    [filenameLabel release];
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

- (NSArray *)transferers {
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

- (BOOL) readyForSending {
	return ![self transferer] || ((id <Transferable>)[self transferer]).state != TransferableStatePreparing || [self isDataReady];
}

- (BOOL)presentOpenInViewController: (UIViewController *)controller {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return [self.interactionController presentOpenInMenuFromRect:CGRectMake(320, 40, 20, 20) inView:controller.view animated:YES];

    }
        return [self.interactionController presentOpenInMenuFromRect:CGRectNull inView:controller.view animated:YES];
}

#pragma mark -
#pragma mark UIDocumentInteractionController
- (id)interactionController; {
	if (interactionController == nil) {
		interactionController = [[UIDocumentInteractionController interactionControllerWithURL:self.fileUrl] retain];
        interactionController.delegate = self;
	}
	
	return interactionController;
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    
    

}


- (id<Cryptor>)cryptor {
    if (cryptor == nil) {
        cryptor = [[NoCryptor alloc] init];
    }
    
    return cryptor;
}

- (void)viewDidLoad {}


@end
