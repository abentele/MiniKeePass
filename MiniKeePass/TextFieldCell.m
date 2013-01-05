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

#import "TextFieldCell.h"
#import <UIKit/UIPasteboard.h>

#define INSET 83

@interface TextFieldCell()
@property (nonatomic, retain) UIView *grayBar;
@end

@implementation TextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect frame = self.contentView.frame;
        frame.origin.x = INSET;
        frame.size.width -= INSET;
        
        self.textField = [[UITextField alloc] initWithFrame:frame];
        self.textField.delegate = self;
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.textColor = [UIColor colorWithRed:.285 green:.376 blue:.541 alpha:1];
        self.textField.font = [UIFont systemFontOfSize:16];
        self.textField.returnKeyType = UIReturnKeyNext;
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.textField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.textField.font = [UIFont boldSystemFontOfSize:15];
        self.textField.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:self.textField];

        CGFloat grayIntensity = 202.0 / 255.0;
        UIColor *color = [UIColor colorWithRed:grayIntensity green:grayIntensity blue:grayIntensity alpha:1];

        self.grayBar = [[UIView alloc] initWithFrame:CGRectMake(79, -1, 1, self.contentView.frame.size.height - 4)];
        self.grayBar.backgroundColor = color;
        self.grayBar.hidden = YES;
        [self.contentView addSubview:_grayBar];
    }
    return self;
}

- (void)dealloc {
    self.textFieldCellDelegate = nil;
}

- (BOOL)showGrayBar {
    return !self.grayBar.hidden;
}

- (void)setShowGrayBar:(BOOL)showGrayBar {
    self.grayBar.hidden = !showGrayBar;
}

- (void)setAccessoryButton:(UIButton *)accessoryButton {
    _accessoryButton = accessoryButton;
    self.accessoryView = accessoryButton;
}

- (void)setEditAccessoryButton:(UIButton *)editAccessoryButton {
    _editAccessoryButton = editAccessoryButton;
    self.editingAccessoryView = editAccessoryButton;
}

- (void)textFieldDidBeginEditing:(UITextField *)field {
    // Keep cell visable
    UITableView *tableView = (UITableView*)self.superview;
    [tableView scrollRectToVisible:self.frame animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.textFieldCellDelegate respondsToSelector:@selector(textFieldCellDidEndEditing:)]) {
        [self.textFieldCellDelegate textFieldCellDidEndEditing:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)field {
    if ([self.textFieldCellDelegate respondsToSelector:@selector(textFieldCellWillReturn:)]) {
        [self.textFieldCellDelegate textFieldCellWillReturn:self];
    }
    
    return NO;
}

@end
