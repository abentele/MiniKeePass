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

#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import "PinViewController.h"
#import "PinTextField.h"
#import "MiniKeePassAppDelegate.h"

#define PINTEXTFIELDWIDTH  61.0f
#define PINTEXTFIELDHEIGHT 52.0f
#define TEXTFIELDSPACE     10.0f

@interface PinViewController ()

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSArray *pinTextFields;
@property (nonatomic, strong) UIToolbar *topBar;
@property (nonatomic, strong) UIToolbar *pinBar;

@end

@implementation PinViewController

- (id)init {
    return [self initWithText:NSLocalizedString(@"Enter your PIN to unlock", nil)];
}

- (id)initWithText:(NSString*)text {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor darkGrayColor];
        CGFloat frameWidth = CGRectGetWidth(self.view.frame);

        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        self.textField.delegate = self;
        self.textField.hidden = YES;
        self.textField.secureTextEntry = YES;
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.textField.keyboardAppearance = UIKeyboardAppearanceAlert;
        [self.view addSubview:self.textField];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self.textField];
        
        // Create topbar
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frameWidth, 95)];
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25];
        self.textLabel.numberOfLines = 0;
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.textLabel.text = text;
        
        self.topBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frameWidth, 95)];
        self.topBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.topBar.barStyle = UIBarStyleBlackTranslucent;

        [self.topBar addSubview:self.textLabel];

        [self.view addSubview:self.topBar];
        
        CGFloat textFieldViewWidth = PINTEXTFIELDWIDTH * 4 + TEXTFIELDSPACE * 3;
        
        UIView *textFieldsView = [[UIView alloc] initWithFrame:CGRectMake((frameWidth - textFieldViewWidth) / 2, 22, textFieldViewWidth, PINTEXTFIELDHEIGHT)];
        textFieldsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        CGFloat xOrigin = 0;
        
        PinTextField *pinTextField1 = [[PinTextField alloc] initWithFrame:CGRectMake(xOrigin, 0, PINTEXTFIELDWIDTH, PINTEXTFIELDHEIGHT)];
        xOrigin += (PINTEXTFIELDWIDTH + TEXTFIELDSPACE);
        [textFieldsView addSubview:pinTextField1];
        
        PinTextField *pinTextField2 = [[PinTextField alloc] initWithFrame:CGRectMake(xOrigin, 0, PINTEXTFIELDWIDTH, PINTEXTFIELDHEIGHT)];
        xOrigin += (PINTEXTFIELDWIDTH + TEXTFIELDSPACE);
        [textFieldsView addSubview:pinTextField2];
      
        PinTextField *pinTextField3 = [[PinTextField alloc] initWithFrame:CGRectMake(xOrigin, 0, PINTEXTFIELDWIDTH, PINTEXTFIELDHEIGHT)];
        xOrigin += (PINTEXTFIELDWIDTH + TEXTFIELDSPACE);
        [textFieldsView addSubview:pinTextField3];
      
        PinTextField *pinTextField4 = [[PinTextField alloc] initWithFrame:CGRectMake(xOrigin, 0, PINTEXTFIELDWIDTH, PINTEXTFIELDHEIGHT)];
        [textFieldsView addSubview:pinTextField4];
        
        self.pinTextFields = [NSArray arrayWithObjects:pinTextField1, pinTextField2, pinTextField3, pinTextField4, nil];
        
        self.pinBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frameWidth, 95)];
        self.pinBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.pinBar setBarStyle:UIBarStyleBlackTranslucent];
        [self.pinBar addSubview:textFieldsView];

        self.textField.inputAccessoryView = self.pinBar;

        // If the keyboard is dismissed, show it again.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
    }
    
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([self.delegate respondsToSelector:@selector(pinViewControllerShouldAutorotateToInterfaceOrientation:)]) {
        return [self.delegate pinViewControllerShouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    } else {
        return NO;
    }
}

- (void)resizeToolbarsToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    // Nothing needs to be done for the iPad; return
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) return;

    CGRect newFrame = self.topBar.frame;
    newFrame.size.height = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? 95 : 68;

    self.topBar.frame = newFrame;
    self.textLabel.frame = newFrame;
    self.pinBar.frame = newFrame;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration animations:^{
        [self resizeToolbarsToInterfaceOrientation:toInterfaceOrientation];
    }];
}

- (void)keyboardDidHide {
    // If the keyboard is dismissed, show it again.
    [self becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Required for 4.3 to show keyboard
    [self becomeFirstResponder];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ([self shouldAutorotateToInterfaceOrientation:orientation]) {
        [self resizeToolbarsToInterfaceOrientation:orientation];
    }

    [self clearEntry];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(pinViewControllerDidShow:)]) {
        [self.delegate pinViewControllerDidShow:self];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)textField:(UITextField *)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([field.text length] >= 4 && range.length == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (void)textDidChange:(NSNotification*)notification {
    NSUInteger n = [self.textField.text length];
    for (NSUInteger i = 0; i < 4; i++) {
        PinTextField *pinTextField = [self.pinTextFields objectAtIndex:i];
        if (i < n) {
            pinTextField.label.text = @"●";
        } else {
            pinTextField.label.text = @"";
        }
    }
    
    if ([self.textField.text length] == 4) {
        [self performSelector:@selector(checkPin:) withObject:nil afterDelay:0.3];
    }
}

- (void)checkPin:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pinViewController:pinEntered:)]) {
        [self.delegate pinViewController:self pinEntered:self.textField.text];
    }
}

- (BOOL)becomeFirstResponder {
    [super becomeFirstResponder];
    
    return [self.textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    
    return [self.textField resignFirstResponder];
}

- (void)clearEntry {
    self.textField.text = @"";
    
    for (PinTextField *pinTextField in self.pinTextFields) {
        pinTextField.label.text = @"";
    }
}

@end
