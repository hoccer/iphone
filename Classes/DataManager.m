//
//  DataManager.m
//  Hoccer
//
//  Created by Ralph At Hoccer on 18.10.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import "DataManager.h"
#import "NSString+URLHelper.h"

@implementation DataManager

@synthesize historyObjectsArray;

static DataManager* _sharedDataManager = nil;

+(DataManager *)sharedDataManager
{
    //singleton instance
    @synchronized([DataManager class])
    {
        if (!_sharedDataManager) {
            _sharedDataManager = [[DataManager alloc] init];
        }
    }
    return _sharedDataManager;
}

- (id)init
{
    self = [super init];
    if (self) {

//        HCHistoryImageWidget *widget1 = [[[HCHistoryImageWidget alloc] init] autorelease];
//        NSArray *topLevelObjects1 = [[NSBundle mainBundle] loadNibNamed:@"HCHistoryImageWidget" owner:self options:nil];
//        for (NSObject *object in topLevelObjects1) {
//            if ([object isKindOfClass:[HCHistoryImageWidget class]]) {
//                widget1 = (HCHistoryImageWidget *)object;
//                break;
//            }
//        }
//        HCHistoryImageWidget *widget2 = [[[HCHistoryImageWidget alloc] init] autorelease];
//        NSArray *topLevelObjects2 = [[NSBundle mainBundle] loadNibNamed:@"HCHistoryImageWidget" owner:self options:nil];
//        for (NSObject *object in topLevelObjects2) {
//            if ([object isKindOfClass:[HCHistoryImageWidget class]]) {
//                widget2 = (HCHistoryImageWidget *)object;
//                break;
//            }
//        }
//        HCHistoryImageWidget *widget3 = [[[HCHistoryImageWidget alloc] init] autorelease];
//        NSArray *topLevelObjects3 = [[NSBundle mainBundle] loadNibNamed:@"HCHistoryImageWidget" owner:self options:nil];
//        for (NSObject *object in topLevelObjects3) {
//            if ([object isKindOfClass:[HCHistoryImageWidget class]]) {
//                widget3 = (HCHistoryImageWidget *)object;
//                break;
//            }
//        }
//        
//        widget1.widgetIsOpen = NO;
//        widget2.widgetIsOpen = NO;
//        widget3.widgetIsOpen = NO;
//        
//        widget1.historyFileName.text = @"first picture";
//        widget2.historyFileName.text = @"second picture";
//        widget3.historyFileName.text = @"third picture";
//        
//        widget1.historyImageSmall.image = [UIImage imageNamed:@"fail_kitten.jpg"];
//        widget2.historyImageSmall.image = [UIImage imageNamed:@"fail_kitten.jpg"];
//        widget3.historyImageSmall.image = [UIImage imageNamed:@"fail_kitten.jpg"];
//        
//        widget1.historyImageBig.image = [UIImage imageNamed:@"fail_kitten.jpg"];
//        widget2.historyImageBig.image = [UIImage imageNamed:@"fail_kitten.jpg"];
//        widget3.historyImageBig.image = [UIImage imageNamed:@"fail_kitten.jpg"];
//        
//        self.historyObjectsArray = @[widget1, widget2, widget3];
    }
    
    return self;
}

- (void)sendKSMS:(NSString *)content toPhone:(NSString *)toPhone toName:(NSString *)toName from:(NSString *)from
{
    NSString *ksmsBasisUrl = @"https://www.smskaufen.com/sms/gateway/sms.php";
    NSString *ksmsUserPwTypUrl = @"?id=ralphatci&apikey=b6589fc6ab0dc82cf12099d1c2d40ab994e8410c&type=4";
    
    NSString *to = [NSString stringWithFormat:@"&empfaenger=%@", toPhone];
    //NSString *textURL = @"&text=" + URLEncoder.encode(content, "ISO-8859-1");
    
    NSString *contentTemplate = NSLocalizedString(@"Default_FileSharingText", nil);
    NSString *channelLink = [@"hoccerchannel://channel/" stringByAppendingString:toName];
    content = [NSString stringWithFormat:contentTemplate, channelLink];
    
    NSString *text = [NSString stringWithFormat:@"&text=%@", [content urlEncodeValue]];
    
    NSString *absender = [NSString stringWithFormat:@"&absender=%@", from];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%@%@%@", ksmsBasisUrl, ksmsUserPwTypUrl, to, text, absender];

    //NSLog(@"url : #%@#", urlStr);
    
    ///#####################
    
    NSURL *serverUrl = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc]
                                       initWithURL:serverUrl
                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:120.0];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    [theRequest release];
    
    
	if(theConnection) {
        NSLog(@"#%@#", theConnection);
    }
	else {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Title_ConnectionError", nil)
                                                        message:NSLocalizedString(@"Message_ConnectionError", nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Button_OK", nil), nil];
        [alert show];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (USES_DEBUG_MESSAGES) { NSLog(@"DataManager: didReceiveData: %@", data);}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (USES_DEBUG_MESSAGES) { NSLog(@"DataManager: connectionDidFinishLoading");}
}

- (void)didFinishWithData:(NSData*)data;
{
    if (USES_DEBUG_MESSAGES) { NSLog(@"DataManager: didFinishWithData : %@", data);}
}

- (void)didFailWithError:(NSError*)error
{
    if (USES_DEBUG_MESSAGES) { NSLog(@"DataManager: didFailWithError %@", error);}
}

- (NSString *)generateRandomString:(int)length
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%c", [letters characterAtIndex:rand()%[letters length]]];
    }
    return randomString;
}

@end
