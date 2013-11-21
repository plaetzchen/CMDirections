//
//  CMAuthTokenProvider.h
//  PebbleNav
//
//  Created by Philip Brechler on 20.11.13.
//  Copyright (c) 2013 Call a Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>

// token could be nil as well as error
typedef void (^CMAuthHandler)(NSString *token, NSError *error);

@interface CMAuthTokenProvider : NSObject

- (void)requestTokenWithCompletionHandler:(CMAuthHandler)completionHandler;
- (void)forceNewToken;
@end
