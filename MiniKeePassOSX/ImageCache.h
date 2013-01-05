//
//  ImageCache.h
//  MiniKeePass
//
//  Created by Andreas Bentele on 01.01.13.
//  Copyright (c) 2013 Andreas Bentele. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

+ (ImageCache*)sharedInstance;
- (NSImage*)getImage:(NSUInteger)index;

@end
