//
//  KdbReaderFactory.m
//  KeePass2
//
//  Created by Qiang Yu on 3/8/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "KdbReaderFactory.h"
#import "Kdb3Reader.h"
#import "Kdb4Reader.h"
#import "FileInputStream.h"

@implementation KdbReaderFactory

+ (KdbTree*)load:(NSString*)fileName withPassword:(KdbPassword*)kdbPassword {
    NSLog(@"START: load kdb file: %@", fileName);

    FileInputStream *inputStream = [[FileInputStream alloc] initWithFilename:fileName];
    uint32_t sig1 = [inputStream readInt32];
    sig1 = CFSwapInt32LittleToHost(sig1);
    
    uint32_t sig2 = [inputStream readInt32];
    sig2 = CFSwapInt32LittleToHost(sig2);
    
    id<KdbReader> reader;
    if (sig1 == KDB3_SIG1 && sig2 == KDB3_SIG2) {
        reader = [[Kdb3Reader alloc] init];
    } else if (sig1 == KDB4_SIG1 && sig2 == KDB4_SIG2) {
        reader = [[Kdb4Reader alloc] init];
    } else {
        [inputStream release];
        @throw [NSException exceptionWithName:@"IOException" reason:@"Invalid file signature" userInfo:nil];
    }

    // Reset the input stream back to the beginning of the file
    [inputStream seek:0];
    
    KdbTree *tree = [reader load:inputStream withPassword:kdbPassword];
    [reader release];
    
    [inputStream release];

    NSLog(@"END: load kdb file: %@", fileName);
    
    return tree;
}

@end
