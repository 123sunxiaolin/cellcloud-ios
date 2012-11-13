/*
 -----------------------------------------------------------------------------
 This source file is part of Cell Cloud.
 
 Copyright (c) 2009-2012 Cell Cloud Team - cellcloudproject@gmail.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 -----------------------------------------------------------------------------
 */

#import "ViewController.h"
#import "Cell.h"

@interface ViewController (Private)

- (void)configView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self configView];
}

- (void)viewDidUnload
{
    [self setMainTextView:nil];
    [super viewDidUnload];
}

- (void)configView
{
    self.mainTextView.delegate = self;

    NSString *text = [[NSString alloc] initWithFormat:
                      @"Cell Cloud %d.%d.%d (Build iOS - %@)\n"\
                      " ___ ___ __  __     ___ __  ___ _ _ ___\n"\
                      "| __| __| | | |    | __| | |   | | | _ \\\n"\
                      "| |_| _|| |_| |_   | |_| |_| | | | | | |\n"\
                      "|___|___|___|___|  |___|___|___|___|___/\n\n"\
                      "Copyright (c) 2009,2012 Cell Cloud Team, www.cellcloud.net\n"\
                      "-----------------------------------------------------------------------\n"
                      , [CCVersion major]
                      , [CCVersion minor]
                      , [CCVersion revision]
                      , [CCVersion name]];
    [self.mainTextView setText:text];
    
    [CCLoggerManager sharedSingleton].delegate = self;

    // 连接 Cellet 服务
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        , ^{
            CCInetAddress *address = [[CCInetAddress alloc] initWithAddress:@"192.168.0.109" port:7000];
            [[CCTalkService sharedSingleton] call:address identifier:@"Dummy"];
        });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"textViewDidChange:");
}

#pragma Log Delegate

- (void)logDebug:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [[NSString alloc] initWithFormat:@"%@\n%@", [self.mainTextView text], text];
        [self.mainTextView setText:str];
    });
}
- (void)logInfo:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [[NSString alloc] initWithFormat:@"%@\n%@", [self.mainTextView text], text];
        [self.mainTextView setText:str];
    });
}
- (void)logWarn:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [[NSString alloc] initWithFormat:@"%@\n%@", [self.mainTextView text], text];
        [self.mainTextView setText:str];
    });
}
- (void)logError:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [[NSString alloc] initWithFormat:@"%@\n%@", [self.mainTextView text], text];
        [self.mainTextView setText:str];
    });
}

@end
