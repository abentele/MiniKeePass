//
//  PasswordViewController.m
//  MiniKeePass
//
//  Created by Andreas Bentele on 30.12.12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "PasswordViewControllerOSX.h"

@interface PasswordViewControllerOSX ()

@property (nonatomic, assign) IBOutlet NSTextField *fileNameLabel;
@property (nonatomic, assign) IBOutlet NSSecureTextField *passwordField;
@property (nonatomic, assign) IBOutlet NSTextField *keyFileField;

@end

@implementation PasswordViewControllerOSX

- (id)initWithFilename:(NSString*)aFileName {
    self = [super initWithWindowNibName:@"PasswordViewControllerOSX"];
    if (self) {
        self.fileName = aFileName;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.fileNameLabel setStringValue:self.fileName];
    [self.window makeFirstResponder:self.passwordField];
}

- (IBAction)doneClicked:(id)sender {
    [self close];
    NSString *keyFile = self.keyFileField.stringValue;
    if ([keyFile isEqualToString:@""]) {
        keyFile = nil;
    }
    [self.delegate didEnterPassword:self.passwordField.stringValue keyFile:keyFile];
}

@end
