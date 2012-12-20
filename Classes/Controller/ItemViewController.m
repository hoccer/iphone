//
//  hoccerControllerData.m
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import "ItemViewController.h"
#import "HoccerContent.h"
#import "StatusViewController.h"
#import "ContentContainerView.h"
#import "Preview.h"
#import "HoccerAppDelegate.h"
#import "HoccerMusic.h"

#import "HCButton.h"

@interface ItemViewController ()

- (NSArray *)actionButtons;


@end


@implementation ItemViewController

@synthesize content;
@synthesize contentView;
@synthesize viewOrigin;

@synthesize delegate;
@synthesize isUpload;

@synthesize statusMessage;
@synthesize progress;
@synthesize status;

@synthesize viewFromNib;



#pragma mark NSCoding Delegate Methods
- (id)initWithCoder:(NSCoder *)decoder {
	self = [super init];
	if (self != nil) {
		content = [[decoder decodeObjectForKey:@"content"] retain];
		viewOrigin = [decoder decodeCGPointForKey:@"position"];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:content forKey:@"content"];
	[encoder encodeCGPoint:viewOrigin forKey:@"position"];
}

- (void) dealloc {
	[content release];
	[contentView release];
	[statusMessage release];
	[status release];
	[progress release];
	
	[super dealloc];
}

- (void)setContent:(HoccerContent *)newContent {
	if (content != newContent) {
		[content release];
		content = [newContent retain];
	}
	
	self.contentView = nil;
}

- (void)removeFromFileSystem {
	[content removeFromDocumentDirectory];
}


- (ContentContainerView *)contentView
{
	if (contentView == nil) {
		Preview *preview = [content desktopItemView];
		if (preview != nil) {
			contentView = [[ContentContainerView alloc] initWithView:preview actionButtons: [self actionButtons]];
		}
        else {
        }
	}
	
	if (contentView == nil) {

		[[NSBundle mainBundle] loadNibNamed:@"EmptyContent" owner:self options:nil];
		Preview *preview = (Preview *)viewFromNib;
		viewFromNib = nil;
		preview.allowsOverlay = YES;
		contentView = [[ContentContainerView alloc] initWithView:preview actionButtons:[self actionButtons]];
	}

	return contentView;
}

- (void)updateView {
	Preview *preview = [content desktopItemView];
	if (preview != nil) {
		contentView.containedView = preview;
        [contentView updateFrame];
	}	
}

#pragma mark -
#pragma mark Private Methods

- (NSArray *)actionButtons
{
	if (content.isFromContentSource) {
        //NSLog(@"actionButtons  ---- content.isFromContentSource ----");

		HCButton *button = [HCButton buttonWithType:UIButtonTypeCustom];
		[button setBackgroundImage:[UIImage imageNamed:@"container_btn_single-close.png"] forState:UIControlStateNormal];
		[button setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];

		[button addTarget: self action: @selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
        
		[button setFrame: CGRectMake(0, 0, 45, 40)];
		
		NSMutableArray *buttons = [NSMutableArray array]; 
		[buttons addObject:button];
		
		return buttons;
	}
    else if ([content isKindOfClass:[HoccerMusic class]]) {
        //NSLog(@"actionButtons  #### NOT content.isFromContentSource ####");
		HCButton *button = [HCButton buttonWithType:UIButtonTypeCustom];
		[button setBackgroundImage:[UIImage imageNamed:@"container_btn_double-close.png"] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
		[button setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
		[button setTextLabelOffset:1];
		[button setFrame: CGRectMake(0, 0, 42, 40)];
		
		HCButton *button2 = [HCButton buttonWithType:UIButtonTypeCustom];
		[button2 setBackgroundImage:[content imageForSaveButton] forState:UIControlStateNormal];
		[button2 addTarget:self action:@selector(saveButton:) forControlEvents:UIControlEventTouchUpInside];
		[button2 setTitle: [content descriptionOfSaveButton] forState:UIControlStateNormal];
		[button2 setTextLabelOffset:2];
		[button2 setFrame: CGRectMake(0, 0, 43, 40)];
		
//		HCButton *button3 = [HCButton buttonWithType:UIButtonTypeCustom];
//		[button3 setBackgroundImage:[UIImage imageNamed:@"container_btn_double-safari.png"] forState:UIControlStateNormal];
//		[button3 addTarget:self action:@selector(playAudioButton:) forControlEvents:UIControlEventTouchUpInside];
//		//[button3 setTitle:NSLocalizedString(@"Play", nil) forState:UIControlStateNormal];
//		//[button3 setTextLabelOffset:1];
//		[button3 setFrame: CGRectMake(0, 0, 42, 40)];
//		
//		NSArray *buttons = [NSArray arrayWithObjects:button, button2, button3, nil];
        
		NSArray *buttons = [NSArray arrayWithObjects:button, button2, nil];
        
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"playPlayer" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playPlayer) name:@"playPlayer" object:nil];
        
		return buttons;
	}
    else {
        //NSLog(@"actionButtons  #### NOT content.isFromContentSource ####");
		HCButton *button = [HCButton buttonWithType:UIButtonTypeCustom];
		[button setBackgroundImage:[UIImage imageNamed:@"container_btn_double-close.png"] forState:UIControlStateNormal];
		[button addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
		[button setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
		[button setTextLabelOffset:1];
		[button setFrame: CGRectMake(0, 0, 42, 40)];
		
		HCButton *button2 = [HCButton buttonWithType:UIButtonTypeCustom];
		[button2 setBackgroundImage:[content imageForSaveButton] forState:UIControlStateNormal];
		[button2 addTarget:self action:@selector(saveButton:) forControlEvents:UIControlEventTouchUpInside];
		[button2 setTitle: [content descriptionOfSaveButton] forState:UIControlStateNormal];
		[button2 setTextLabelOffset:2];
		[button2 setFrame: CGRectMake(0, 0, 43, 40)];
		
		NSArray *buttons = [NSArray arrayWithObjects:button, button2, nil];
		
		return buttons;
	}
}

#pragma mark -
#pragma mark User Actions
- (IBAction)closeView: (id)sender
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"PausePlayer2" object:nil];

	if ([delegate respondsToSelector:@selector(itemViewControllerWasClosed:)]) {
		[delegate itemViewControllerWasClosed:self];
	} 
}

- (IBAction)saveButton: (id)sender {		
	if ([delegate respondsToSelector:@selector(itemViewControllerSaveButtonWasClicked:)]) {
		[delegate itemViewControllerSaveButtonWasClicked: self];
	}
}

- (IBAction)playAudioButton:(id)sender
{
    NSLog(@"start play old");

    //[self.contentView insertSubview:content.smallView atIndex:8];

//    [self.contentView.containedView audioPlayButtonPressed:self];
}

- (void)playPlayer
{
    //NSLog(@"really start play");
    
    [self.contentView insertSubview:content.smallView atIndex:8];
}

@end
