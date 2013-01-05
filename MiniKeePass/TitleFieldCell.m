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

#import "TitleFieldCell.h"


@implementation TitleFieldCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        
        self.accessoryButton = self.imageButton;
        self.editAccessoryButton = self.imageButton;
    }
    return self;
}

- (void)textFieldDidEndEditing:(UITextField *)inTextField {
    [super textFieldDidEndEditing:inTextField];
    
    UITableView *tableView = (UITableView*)self.superview;
    UITableViewController *tableViewController = (UITableViewController*)tableView.delegate;
    tableViewController.title = self.textField.text;
}

@end
