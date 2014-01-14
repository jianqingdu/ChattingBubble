//
//  RichTextAppDelegate.h
//  RichText
//
//  Created by jianqing.du on 14-1-7.
//  Copyright (c) 2014年 ziteng. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BubbleTextView.h"

@interface RichTextAppDelegate : NSObject <NSApplicationDelegate, NSTextViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet BubbleTextView *bubbleTextView;

@end
