#import "ImageAndTextCell.h"

#define kIconImageSize          16.0

#define kImageOriginXOffset     3
#define kImageOriginYOffset     1

#define kTextOriginXOffset      2
#define kTextOriginYOffset      0
#define kTextHeightAdjust       0

@interface ImageAndTextCell ()

@end

@implementation ImageAndTextCell

- (id)init
{
	self = [super init];
	if (self)
    {
    }
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ImageAndTextCell *cell = (ImageAndTextCell*)[super copyWithZone:zone];
    cell.image = self.image;
    return cell;
}

- (void)setImage:(NSImage *)aImage
{
    if (aImage != _image)
	{
        _image = aImage;
		[self.image setSize:NSMakeSize(kIconImageSize, kIconImageSize)];
    }
}

// -------------------------------------------------------------------------------
//	titleRectForBounds:cellRect
//
//	Returns the proper bound for the cell's title while being edited
// -------------------------------------------------------------------------------
- (NSRect)titleRectForBounds:(NSRect)cellRect
{
	// the cell has an image: draw the normal item cell
	NSSize imageSize = self.image.size;
	NSRect imageFrame;
    
	NSDivideRect(cellRect, &imageFrame, &cellRect, 3 + imageSize.width, NSMinXEdge);
    
	imageFrame.origin.x += kImageOriginXOffset;
	imageFrame.origin.y -= kImageOriginYOffset;
	imageFrame.size = imageSize;
	
	imageFrame.origin.y += ceil((cellRect.size.height - imageFrame.size.height) / 2);
	
	NSRect newFrame = cellRect;
	newFrame.origin.x += kTextOriginXOffset;
	newFrame.origin.y += kTextOriginYOffset;
	newFrame.size.height -= kTextHeightAdjust;
    
	return newFrame;
}

// -------------------------------------------------------------------------------
//	editWithFrame:inView:editor:delegate:event
// -------------------------------------------------------------------------------
- (void)editWithFrame:(NSRect)aRect inView:(NSView*)controlView editor:(NSText*)textObj delegate:(id)anObject event:(NSEvent*)theEvent
{
	NSRect textFrame = [self titleRectForBounds:aRect];
	[super editWithFrame:textFrame inView:controlView editor:textObj delegate:anObject event:theEvent];
}

// -------------------------------------------------------------------------------
//	selectWithFrame:inView:editor:delegate:event:start:length
// -------------------------------------------------------------------------------
- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{
	NSRect textFrame = [self titleRectForBounds:aRect];
	[super selectWithFrame:textFrame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

// -------------------------------------------------------------------------------
//	drawWithFrame:cellFrame:controlView:
// -------------------------------------------------------------------------------
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    // the cell has an image: draw the normal item cell
    NSSize imageSize = self.image.size;
    NSRect imageFrame;
    
    NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
    
    imageFrame.origin.x += kImageOriginXOffset;
    imageFrame.origin.y -= kImageOriginYOffset;
    imageFrame.size = imageSize;
    
    if ([controlView isFlipped])
        imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
    else
        imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
    [self.image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
    
    NSRect newFrame = cellFrame;
    newFrame.origin.x += kTextOriginXOffset;
    newFrame.origin.y += kTextOriginYOffset;
    newFrame.size.height -= kTextHeightAdjust;
    
    //NSLog(@"Text of cell: %@", self.stringValue);
    [super drawWithFrame:newFrame inView:controlView];
}

- (NSSize)cellSize
{
    NSSize cellSize = [super cellSize];
    cellSize.width += (self.image ? self.image.size.width : 0) + 3;
    return cellSize;
}


@end

