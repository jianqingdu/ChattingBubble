//
//  RichTextAppDelegate.m
//  RichText
//
//  Created by jianqing.du on 14-1-7.
//  Copyright (c) 2014年 ziteng. All rights reserved.
//

#import "RichTextAppDelegate.h"

#define MAX_IMAGE_SIZE  300

@implementation RichTextAppDelegate {
    NSDictionary *attribleDict;
    NSString *lineSeparatorStr;
    NSString *paragraphSeperatorStr;
    NSDataDetector *dataDetector;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        NSFont *font = [NSFont fontWithName:@"Helvetica" size:13];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        //[paragraphStyle setAlignment:NSRightTextAlignment];
        //[paragraphStyle setFirstLineHeadIndent:20];
        //[paragraphStyle setHeadIndent:20];
        //[paragraphStyle setTailIndent:-20];
        [paragraphStyle setParagraphSpacing:25];
        [paragraphStyle setParagraphSpacingBefore:10];
        [paragraphStyle setMaximumLineHeight:MAX_IMAGE_SIZE + 20];
        
        attribleDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              font, NSFontAttributeName,
                              paragraphStyle, NSParagraphStyleAttributeName, nil];
        
        lineSeparatorStr = [NSString stringWithFormat:@"%C", (unichar)NSLineSeparatorCharacter];
        paragraphSeperatorStr = [NSString stringWithFormat:@"%C", (unichar)NSParagraphSeparatorCharacter];
        
        NSError *error = NULL;
        dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    }
    
    return self;
}

- (void)appendAttributeText:(NSString *)textStr
                      atEnd:(BOOL)atEnd;
{
    NSMutableAttributedString *textContent = [[NSMutableAttributedString alloc]
                                       initWithString:textStr
                                       attributes:attribleDict];
    
    // add http link highlight
    NSArray *matches = [dataDetector matchesInString:textStr
                                             options:0
                                               range:NSMakeRange(0, [textStr length])];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            [textContent addAttributes:@{NSLinkAttributeName:url.absoluteString}
                                 range:matchRange];
        }
    }
    
    // append to NSTextStorage
    if (atEnd) {
        [[_bubbleTextView textStorage] appendAttributedString:textContent];
    } else {
        NSRange range = NSMakeRange(0, 0);
        [[_bubbleTextView textStorage] replaceCharactersInRange:range
                                           withAttributedString:textContent];
    }
}

- (NSImage *)scaleImage:(NSImage *)image
{
    NSSize size = [image size];
    
    BOOL scale = NO;
    if (size.height > MAX_IMAGE_SIZE) {
        size.height = MAX_IMAGE_SIZE;
        scale = YES;
    }
    
    if (size.width > MAX_IMAGE_SIZE) {
        size.width = MAX_IMAGE_SIZE;
        scale = YES;
    }
    
    if (scale) {
        NSRect scaleRect = NSMakeRect(0, 0, size.width, size.height);
        NSImage *scaleImage = [[NSImage alloc] initWithSize:size];
        [scaleImage lockFocus];
        [image drawInRect:scaleRect];
        [scaleImage unlockFocus];
        return scaleImage;
    }
    
    return image;
}

- (void)appendAttributeImage:(NSImage *)image
{
    NSImage *scaleImage = [self scaleImage:image];
    
    NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc]
                                            initImageCell:scaleImage];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    [attachment setAttachmentCell: attachmentCell ];
    NSMutableAttributedString *attributedString = (NSMutableAttributedString*)[NSAttributedString  attributedStringWithAttachment: attachment];
    
    [attributedString addAttributes:attribleDict
                              range:NSMakeRange(0, [attributedString length])];
     
    [[_bubbleTextView textStorage] appendAttributedString:attributedString];
}



- (void)replaceAttributeImage:(NSUInteger)index withImage:(NSImage *)image
{
    NSImage *scaleImage = [self scaleImage:image];
    
    NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc]
                                            initImageCell:scaleImage];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    [attachment setAttachmentCell: attachmentCell ];
    NSAttributedString *attributedString = [NSAttributedString  attributedStringWithAttachment: attachment];
    
    NSRange range = NSMakeRange(index, 1);
    [[_bubbleTextView textStorage] replaceCharactersInRange:range
                                       withAttributedString:attributedString];
}

- (void)awakeFromNib
{
    [_bubbleTextView setDelegate:self];

    // start a paragraph
    [self appendAttributeText: @"Text Layout Programming Guide describes how the Cocoa text system lays out text. Text layout is the process of converting a string of text characters, font information, and page specifications into lines of glyphs placed at specific locations on a page, suitable for display and printing"
     atEnd:YES];

    NSUInteger index = [[_bubbleTextView string] length];
    NSLog(@"image attach position: %lu", index);
    NSImage *okImage = [NSImage imageNamed:@"ok"];
    [self appendAttributeImage:okImage];
    NSLog(@"image index=%lu", [[_bubbleTextView string] length]);
    
    [self appendAttributeText:@"哈哈\n"
                        atEnd:YES];
    
    // start a new paragraph
    [self appendAttributeText:@"哈哈哈哈哈哈发" atEnd:YES];
    [self appendAttributeText:lineSeparatorStr atEnd:YES];
    [self appendAttributeText:@"mgj: http://www.mogujie.com google: www.google.com\n"
                        atEnd:YES];
    
    // add 2 new paragraph
    for (uint32_t i = 0; i < 2; i++) {
         [self appendAttributeText:@"测试测试测试测试\n哈哈哈\n" atEnd:YES];
    }
    
    // replace an attachment image with a new one
    // this can be used in this situation:
    // 1. the program receive an image url address, display an downloading image
    // 2. request image data through http request
    // 3. when received all image data, replace the downloading image with the real one
    NSImage *spaceImage = [NSImage imageNamed:@"space"];
    [self replaceAttributeImage:index withImage:spaceImage];
    
    [self appendAttributeImage:okImage];
    
    [self appendAttributeText:@"insert text\n" atEnd:NO];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)textView:(NSTextView *)textView
   clickedOnCell:(id<NSTextAttachmentCell>)cell
          inRect:(NSRect)cellFrame
         atIndex:(NSUInteger)charIndex
{
    NSLog(@"click in (%f, %f, %f, %f), atIndex=%lu", cellFrame.origin.x,
          cellFrame.origin.y, cellFrame.size.width, cellFrame.size.height, charIndex);
    
    [_bubbleTextView setImageRect:cellFrame];
    [_bubbleTextView setNeedsDisplay:YES];
}

- (void)textView:(NSTextView *)aTextView
doubleClickedOnCell:(id < NSTextAttachmentCell >)cell
          inRect:(NSRect)cellFrame
         atIndex:(NSUInteger)charIndex
{
    NSLog(@"double click");
    
    [_bubbleTextView setImageRect:NSZeroRect];
    [_bubbleTextView setNeedsDisplay:YES];
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"space"
                                                          ofType:@"jpg"];
    
    [[NSWorkspace sharedWorkspace] openFile:imagePath];
}

@end
