//
//  ImageCache.m
//  MiniKeePass
//
//  Created by Andreas Bentele on 01.01.13.
//  Copyright (c) 2013 Andreas Bentele. All rights reserved.
//

#import "ImageCache.h"

#define NUM_IMAGES 69

@interface ImageCache () {
    NSImage *images[NUM_IMAGES];
}

@end

@implementation ImageCache

static ImageCache *INSTANCE;

+ (ImageCache*)sharedInstance {
    if (INSTANCE == nil) {
        INSTANCE = [[ImageCache alloc] init];
    }
    return INSTANCE;
}

- (id)init {
    self = [super init];
    if (self) {
        // Initialize the images array
        int i;
        for (i = 0; i < NUM_IMAGES; i++) {
            images[i] = nil;
        }
    }
    return self;
}

- (NSImage*)getImage:(NSUInteger)index {
    if (index >= NUM_IMAGES) {
        return nil;
    }
    
    if (images[index] == nil) {
        NSString *imageFileName = [NSString stringWithFormat:@"%ld", index];
        NSLog(@"Load image file: %@", imageFileName);
        images[index] = [NSImage imageNamed:[NSString stringWithFormat:@"%ld", index]];
    }
    
    return images[index];
}

@end