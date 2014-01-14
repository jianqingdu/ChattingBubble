//
//  BubbleTextView.m
//  RichText
//
//  Created by jianqing.du on 14-1-9.
//  Copyright (c) 2014年 ziteng. All rights reserved.
//

#import "BubbleTextView.h"
#import "NSImage+Stretchable.h"

@implementation BubbleTextView {
    NSBezierPath *selectImagePath;
}

@synthesize imageRect;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    [[NSColor blueColor] set];
    [selectImagePath removeAllPoints];
    [selectImagePath appendBezierPathWithRect:imageRect];
    [selectImagePath stroke];
}

- (void)awakeFromNib
{
    [self setTextContainerInset:NSMakeSize(20, 20)];
    
    selectImagePath = [NSBezierPath bezierPath];
    [selectImagePath setLineWidth:1.5];
    
    // useless, why
    /*NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle  alloc] init];
    
    [paragraphStyle setAlignment:NSRightTextAlignment];
    [paragraphStyle setHeadIndent:20];
    [paragraphStyle setTailIndent:-20];
    [paragraphStyle setParagraphSpacing:30];
    [paragraphStyle setParagraphSpacingBefore:9];
    [paragraphStyle setMaximumLineHeight:200];
    
    [self setDefaultParagraphStyle:paragraphStyle];*/
}

- (void)drawBubbleAroundTextInRect:(NSRect)rect
{
    rect.size.height += 20;
    rect.size.width += 20;
    
    if (rect.origin.x > 10)
        rect.origin.x -= 10;
    if (rect.origin.y > 10)
        rect.origin.y -= 10;
    
    NSImage *image = [NSImage imageNamed:@"bubble_left"];
    NSImage *imageStrech = [image stretchableImageWithSize:rect.size
                                       edgeInsets:NSEdgeInsetsMake(10, 10, 10, 10)];
    
    [imageStrech drawInRect:rect];
    
    // scroll to the end of NSTextView
    //NSUInteger totalLen = [[self string] length];
    //[self scrollRangeToVisible:NSMakeRange(totalLen, 0)];
}

- (void)drawViewBackgroundInRect:(NSRect)rect
{
    NSLayoutManager *layoutManager = [self layoutManager];
    NSPoint containerOrigin = [self textContainerOrigin];
    NSRange glyphRange, charRange, paragraphCharRange,
    paragraphGlyphRange, lineGlyphRange;
    NSRect paragraphRect, lineUsedRect;
    
    // Draw the background first, before the bubbles.
    [super drawViewBackgroundInRect:rect];
    
    // Convert from view to container coordinates, then to the
    //corresponding glyph and character ranges.
    rect.origin.x -= containerOrigin.x;
    rect.origin.y -= containerOrigin.y;
    glyphRange = [layoutManager glyphRangeForBoundingRect:rect
                                          inTextContainer:[self textContainer]];
    charRange = [layoutManager characterRangeForGlyphRange:glyphRange
                                          actualGlyphRange:NULL];
    
    // Iterate through the character range, paragraph by paragraph.
    for (paragraphCharRange = NSMakeRange(charRange.location, 0);
         NSMaxRange(paragraphCharRange) < NSMaxRange(charRange);
         paragraphCharRange = NSMakeRange(NSMaxRange(paragraphCharRange), 0)) {
        // For each paragraph, find the corresponding character and glyph ranges.
        paragraphCharRange = [[[self textStorage] string]
                              paragraphRangeForRange:paragraphCharRange];
        paragraphGlyphRange = [layoutManager
                               glyphRangeForCharacterRange:paragraphCharRange
                               actualCharacterRange:NULL];
        paragraphRect = NSZeroRect;
        
        // Iterate through the paragraph glyph range, line by line.
        for (lineGlyphRange = NSMakeRange(paragraphGlyphRange.location,0);
             NSMaxRange(lineGlyphRange) < NSMaxRange(paragraphGlyphRange);
             lineGlyphRange = NSMakeRange(NSMaxRange(lineGlyphRange), 0)) {
            // For each line, find the used rect and glyph range, and
            // add the used rect to the paragraph rect.
            lineUsedRect = [layoutManager
                            lineFragmentUsedRectForGlyphAtIndex:lineGlyphRange.location
                            effectiveRange:&lineGlyphRange];
            paragraphRect = NSUnionRect(paragraphRect, lineUsedRect);
        }
        
        // Convert back from container to view coordinates, then draw the bubble.
        paragraphRect.origin.x += containerOrigin.x;
        paragraphRect.origin.y += containerOrigin.y;
        //if (paragraphGlyphRange.length > 1)
            [self drawBubbleAroundTextInRect:paragraphRect];
    }
}

// capture mouse scroll event
- (void)scrollWheel:(NSEvent *)theEvent
{
    [super scrollWheel:theEvent];
    
    NSClipView *clipView = (NSClipView *)[self superview];
    NSScrollView *scrollView = (NSScrollView *)[clipView superview];
    NSScroller *scroller = [scrollView verticalScroller];
    
    NSString *phaseName;
    NSEventPhase phase = [theEvent phase];
    switch (phase) {
        case NSEventPhaseNone:
            phaseName = @"NSEventPhaseNone";
            break;
        case NSEventPhaseBegan:
            phaseName = @"NSEventPhaseBegan" ;
            break;
        case NSEventPhaseStationary:
            phaseName = @"NSEventPhaseStationary";
            break;
        case NSEventPhaseChanged:
            phaseName = @"NSEventPhaseChanged";
            break;
        case NSEventPhaseEnded:
            phaseName = @"NSEventPhaseEnded";
            break;
        case NSEventPhaseCancelled:
            phaseName = @"NSEventPhaseCancelled";
            break;
        case NSEventPhaseMayBegin:
            phaseName = @"NSEventPhaseMayBegin";
            break;
        default:
            break;
    }
    float position = [scroller floatValue];
    NSLog(@"phase=%@, deltaY=%f, position=%f",
          phaseName, [theEvent deltaY], position);
}

@end
