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
#import "TestHelper.h"

@interface ViewController ()
{
    TestHelper *_helper;
}

- (void)configView;

- (void)initTestData;

- (void)appendTextToTextView:(NSString *)text;

@end

@implementation ViewController

//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configView];
    [self initTestData];
}
//------------------------------------------------------------------------------
- (void)viewDidUnload
{
    [self setMainTextView:nil];
    [self setBbiCall:nil];
    [self setBbiHangUp:nil];
    [self setBbiTalk:nil];
    [self setBbiDialect:nil];
    [self setBbiChunk:nil];
    [self setBbiDownload:nil];
    [super viewDidUnload];
}
//------------------------------------------------------------------------------
- (void)configView
{
    self.mainTextView.delegate = self;
    [self.bbiCall setAction:@selector(doCallHandler:)];
    [self.bbiHangUp setAction:@selector(doHangUpHandler:)];
    [self.bbiTalk setAction:@selector(doTalkHandler:)];
    [self.bbiDialect setAction:@selector(doDialectHandler:)];
    [self.bbiChunk setAction:@selector(doChunkHandler:)];
    [self.bbiDownload setAction:@selector(doDownloadHandler:)];

    self.bbiCall.enabled = TRUE;
    self.bbiHangUp.enabled = FALSE;
    self.bbiTalk.enabled = FALSE;
    self.bbiDialect.enabled = FALSE;
    self.bbiChunk.enabled = FALSE;
    self.bbiDownload.enabled = FALSE;

    NSString *text = [[NSString alloc] initWithFormat:
                      @"Cell Cloud %d.%d.%d (Build iOS - %@)\n"\
                      " ___ ___ __  __     ___ __  ___ _ _ ___\n"\
                      "| __| __| | | |    | __| | |   | | | _ \\\n"\
                      "| |_| _|| |_| |_   | |_| |_| | | | | | |\n"\
                      "|___|___|___|___|  |___|___|___|___|___/\n\n"\
                      "Copyright (c) 2009,2016 Cell Cloud Team, www.cellcloud.net\n"\
                      "-----------------------------------------------------------------------\n"
                      , [CCVersion major]
                      , [CCVersion minor]
                      , [CCVersion revision]
                      , [CCVersion name]];
    [self.mainTextView setText:text];

    [CCLoggerManager sharedSingleton].delegate = self;
}
//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark Text View Delegate

//------------------------------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}
//------------------------------------------------------------------------------
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

#pragma mark Test method

//------------------------------------------------------------------------------
- (void)initTestData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        , ^{
            _helper = [[TestHelper alloc] init];
            [_helper fillPrimitive:10];

            // 设置监听器
            [CCTalkService sharedSingleton].listener = self;
        });
}
//------------------------------------------------------------------------------
- (void)disableAllButtonItems
{
    self.bbiCall.enabled = FALSE;
    self.bbiHangUp.enabled = FALSE;
    self.bbiTalk.enabled = FALSE;
    self.bbiDialect.enabled = FALSE;
    self.bbiChunk.enabled = FALSE;
    self.bbiDownload.enabled = FALSE;
}
#pragma mark FileManagerDelegate
//------------------------------------------------------------------------------
- (void)onSendProgress:(NSData *)file andReceiver:(NSString *)receiver andProcessed:(long)processed andTotal:(long)total
{
    //TODO
    [CCLogger d:[NSString stringWithFormat:@"Send File Progress: receiver : %@, processed: %ld / %ld", receiver, processed, total]];
}

//------------------------------------------------------------------------------
- (void)onReceiveProgress:(NSData *)file andSender:(NSString *)sender andProcessed:(long)processed andTotal:(long)total
{
    //TODO
    [CCLogger d:[NSString stringWithFormat:@"Receive File Progress: sender : %@, processed: %ld / %ld", sender, processed, total]];
}

#pragma mark Talk Listener

//------------------------------------------------------------------------------
- (void)dialogue:(NSString *)identifier primitive:(CCPrimitive *)primitive
{
    [CCLogger d:@"dialogue : identifier=%@ tag=%@", identifier, primitive.ownerTag];

    if ([primitive isDialectal])
    {
        [CCLogger i:@"Dialect: %@", primitive.dialect.name];

        if ([primitive.dialect.name isEqualToString:ACTION_DIALECT_NAME])
        {
            CCActionDialect *action = (CCActionDialect *)primitive.dialect;
            [CCLogger i:@"Action Dialect: action=%@ name=%@ project=%@"
                , action.action, [action getParamAsString:@"name"], [action getParamAsString:@"project"]];

            // 使用委派方式
            [action act:self];

            // 使用 BLOCK
//            [action actWithBlock:^(CCActionDialect* dialect) {
//                [CCLogger d:@"Do action '%@' (thread:%@)", dialect.action, [NSThread currentThread]];
//            }];
            
            [CCLogger d:@"Action acted (thread:%@)", [NSThread currentThread]];
        }
        else if ([primitive.dialect.name isEqualToString:CHUNK_DIALECT_NAME])
        {
            CCChunkDialect *chunk = (CCChunkDialect *)primitive.dialect;
            [[FileManager sharedSingleton] receiveChunk:chunk];
        }
    }
    else
    {
        int index = [[primitive.complements objectAtIndex:0] getValueAsInt];
        CCPrimitive *expected = [_helper.primitives objectAtIndex:index];
        CCPrimitive *actual = primitive;

        char result[8] = {0x0};
        if ([_helper assertPrimitive:expected actual:actual])
            memcpy(result, "true", 4);
        else
            memcpy(result, "false", 5);

        [CCLogger i:@"Result (%d): %s", ++_helper.counts, result];
    }
}
//------------------------------------------------------------------------------
- (void)contacted:(NSString *)identifier tag:(NSString *)tag
{
    [CCLogger d:@"contacted : identifier=%@ tag=%@", identifier, tag];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.bbiHangUp.enabled = YES;
        self.bbiTalk.enabled = YES;
        self.bbiDialect.enabled = YES;
        self.bbiChunk.enabled = YES;
        self.bbiDownload.enabled = YES;
        
        [FileManager sharedSingleton].delegate = self;
    });
}
//------------------------------------------------------------------------------
- (void)quitted:(NSString *)identifier tag:(NSString *)tag
{
    [CCLogger d:@"quitted : identifier=%@ tag=%@", identifier, tag];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self disableAllButtonItems];
        self.bbiCall.enabled = YES;
        self.bbiHangUp.enabled = YES;
    });
}
//------------------------------------------------------------------------------
- (void)failed:(CCTalkServiceFailure *)failure
{
    [CCLogger d:@"failed - Code:%d - Reason:%@ - Desc:%@", failure.code, failure.reason, failure.description];

    if (CCFailureCallFailed == failure.code
        || CCFailureTalkLost == failure.code)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bbiHangUp.enabled = YES;
        });
    }
}

#pragma mark Log Delegate

//------------------------------------------------------------------------------
- (void)logDebug:(NSString *)text
{
    [self appendTextToTextView:text];
}
//------------------------------------------------------------------------------
- (void)logInfo:(NSString *)text
{
    [self appendTextToTextView:text];
}
//------------------------------------------------------------------------------
- (void)logWarn:(NSString *)text
{
    [self appendTextToTextView:text];
}
//------------------------------------------------------------------------------
- (void)logError:(NSString *)text
{
    [self appendTextToTextView:text];
}
//------------------------------------------------------------------------------
- (void)appendTextToTextView:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.mainTextView text].length > 10240)
        {
            [self.mainTextView setText:text];
        }
        else
        {
            NSString *str = [[NSString alloc] initWithFormat:@"%@\n%@", [self.mainTextView text], text];
            [self.mainTextView setText:str];
        }
    });
}

#pragma mark Action Delegate

//------------------------------------------------------------------------------
- (void)doAction:(CCActionDialect *)dialect
{
    if ([dialect.action isEqualToString:@"iOS_ACK"]) {
        [CCLogger d:@"Do action '%@' - identifier=%@ tag=%@ (thread:%@)"
         , dialect.action
         , dialect.celletIdentifier
         , dialect.ownerTag
         , [NSThread currentThread]];
    }
    else if ([dialect.action isEqualToString:@"Accept_Ack"])
    {
        [CCLogger d:@"Do action '%@' - identifier=%@ tag=%@ (thread:%@)"
         , dialect.action
         , dialect.celletIdentifier
         , dialect.ownerTag
         , [NSThread currentThread]];
    }

}

#pragma mark Bar Button Item Action

//------------------------------------------------------------------------------
- (void)doCallHandler:(id)sender
{
    [CCLogger d:@"Tap 'Call' ..."];

    [self disableAllButtonItems];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            , ^{
                // 连接 Cellet 服务
                CCInetAddress *address = [[CCInetAddress alloc] initWithAddress:@"127.0.0.1" port:8000];
                [[CCTalkService sharedSingleton] call:[NSArray arrayWithObjects:@"Dummy", nil] hostAddress:address];
            });
}
//------------------------------------------------------------------------------
- (void)doHangUpHandler:(id)sender
{
    [CCLogger d:@"Tap 'Hang Up' ..."];
    
    [self disableAllButtonItems];
    self.bbiCall.enabled = YES;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            , ^{
                [[CCTalkService sharedSingleton] hangUp:@"Dummy"];
            });
}
//------------------------------------------------------------------------------
- (void)doTalkHandler:(id)sender
{
    [CCLogger d:@"Tap 'Talk' ..."];

    _helper.counts = 0;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            , ^{
                for (CCPrimitive *pri in _helper.primitives)
                {
                    [[CCTalkService sharedSingleton] talk:@"Dummy" primitive:pri];
                    [NSThread sleepForTimeInterval:0.1];  
                }
            });
}
//------------------------------------------------------------------------------
- (void)doDialectHandler:(id)sender
{
    [CCLogger d:@"Tap 'Dialect' ..."];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            , ^{
                CCActionDialect *dialect = (CCActionDialect *)[[CCDialectEnumerator sharedSingleton] createDialect:ACTION_DIALECT_NAME tracker:@"Ambrose"];
                dialect.action = @"iOS";
                [dialect appendParam:@"name" stringValue:@"Ambrose Xu"];
                [dialect appendParam:@"project" stringValue:@"Cell Cloud"];

                [[CCTalkService sharedSingleton] talk:@"Dummy" dialect:dialect];
            });
}
//------------------------------------------------------------------------------
- (void)doTalkerHandler:(id)sender
{
    [CCLogger d:@"Tap 'Talker' ..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            , ^{
                /*CCInetAddress *address = [[CCInetAddress alloc] initWithAddress:@"192.168.0.110" port:7000];
                CCTalker *talker = [[CCTalker alloc] initWithIdentifier:@"Dummy" address:address];
                
                CCPrimitive *pri = [_helper.primitives objectAtIndex:0];
                [talker talkWithPrimitive:pri];*/
            });
}
//------------------------------------------------------------------------------
- (void)doChunkHandler:(id)sender
{
    [CCLogger d:@"Tap 'Chunk' ..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                   , ^{
                       NSString *fileName = @"WhatsNewIniPhoneOS.pdf";
                       NSFileManager *fm = [NSFileManager defaultManager];
                       NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                       NSString *path = [documentPath stringByAppendingPathComponent:fileName];
                       
                       NSString *tmpPath = [[NSBundle mainBundle] pathForResource:@"WhatsNewIniPhoneOS" ofType:@"pdf"];
                       if (![fm fileExistsAtPath:path]) {
                           [fm copyItemAtPath:tmpPath toPath:path error:nil];
                       }
                       NSData *file = [fm contentsAtPath:path];
                       
                    [[FileManager sharedSingleton]sendFile:fileName
                                       andCelletIdentifier:@"Dummy"
                                                   andFile:file
                                                 andSender:@"Ambrose"
                                               andReceiver:@"Zhu"];

                       
                       
//                       CCActionDialect *dialect = (CCActionDialect *)[[CCDialectEnumerator sharedSingleton] createDialect:ACTION_DIALECT_NAME tracker:@"Ambrose"];
//                       dialect.action = @"iOS";
//                       [dialect appendParam:@"name" stringValue:@"Ambrose Xu"];
//                       [dialect appendParam:@"project" stringValue:@"Cell Cloud"];
//                       
//                       [[CCTalkService sharedSingleton] talk:@"Dummy" dialect:dialect];
                   });
}

- (void)doDownloadHandler:(id)sender
{
    
    [CCLogger d:@"Tap 'Download' ..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                   , ^{
                       CCActionDialect *dialect = (CCActionDialect *)[[CCDialectEnumerator sharedSingleton] createDialect:ACTION_DIALECT_NAME tracker:@"Ambrose,Zhu"];
                       dialect.action = @"Accept";
                       [dialect appendParam:@"fileName" stringValue:@"WhatsNewIniPhoneOS.pdf"];
                       [dialect appendParam:@"sender" stringValue:@"Ambrose"];
                       [dialect appendParam:@"receiver" stringValue:@"Zhu"];
                       
                       [[CCTalkService sharedSingleton] talk:@"Dummy" dialect:dialect];
                   });

}

@end
