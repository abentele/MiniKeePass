/*
 * Copyright 2011-2012 Jason Rush and John Flanagan. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "ImagesViewController.h"
#import "MiniKeePassAppDelegate.h"

//#define IMAGES_PER_ROW 7
#define SIZE 24
#define HORIZONTAL_SPACING 10.5
#define VERTICAL_SPACING 10.5

NSInteger imagesPerRow;

@implementation ImagesViewController

- (id)init {
    self = [super init];
    if (self) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.alwaysBounceHorizontal = NO;
        UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageSelected:)];
        [scrollView addGestureRecognizer:gestureRecognizer];

        CGRect frame = self.view.frame;
        frame.origin = CGPointMake(0.0, 0.0);
        imageContainerView = [[ImageContainerView alloc] initWithFrame:frame];    
        imageContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [scrollView addSubview:imageContainerView];
        self.view = scrollView;
    }
    return self;
}

- (void)imageSelected:(UIGestureRecognizer*)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:imageContainerView];
    NSUInteger col = point.x / (SIZE + 2 * HORIZONTAL_SPACING);
    NSUInteger row = point.y / (SIZE + 2 * VERTICAL_SPACING);
    
    NSUInteger index = row * imagesPerRow + col;
    [self setSelectedImage:index];
    
    if ([self.delegate respondsToSelector:@selector(imagesViewController:imageSelected:)]) {
        [self.delegate imagesViewController:self imageSelected:index];
    }
}

- (void)setSelectedImage:(NSUInteger)index {
    [imageContainerView setSelectedImage:index];
}

@end
