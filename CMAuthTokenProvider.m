//
//  CMAuthTokenProvider.m
//  PebbleNav
//
//  Created by Philip Brechler on 20.11.13.
//  Copyright (c) 2013 Call a Nerd. All rights reserved.
//

#import "CMAuthTokenProvider.h"
#import "AFNetworking.h"

@implementation CMAuthTokenProvider


- (void)requestTokenWithCompletionHandler:(CMAuthHandler)completionHandler {
    NSString *userUUIDString = [[NSUserDefaults standardUserDefaults]objectForKey:@"CMAuthUUID"];
    NSString *tokenForUser = [[NSUserDefaults standardUserDefaults]objectForKey:@"CMAuthToken"];

    if (!userUUIDString){
        NSUUID *userUUID = [NSUUID UUID];
        userUUIDString = [userUUID UUIDString];
        [[NSUserDefaults standardUserDefaults]setObject:userUUIDString forKey:@"CMAuthUUID"];
    }
    
    if (!tokenForUser){
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSDictionary *parameters = @{@"userid": userUUIDString};
        [manager POST:[NSString stringWithFormat:@"http://auth.cloudmade.com/token/%@",CMAPIKey] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSData class]]){
                NSString *newToken = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                [[NSUserDefaults standardUserDefaults]setObject:newToken forKey:@"CMAuthToken"];
                completionHandler(newToken,nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            completionHandler(nil,error);
        }];
    } else {
        completionHandler(tokenForUser,nil);
    }
    
}

- (void)forceNewToken {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CMAuthUUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CMAuthToken"];
    [self requestTokenWithCompletionHandler:^(NSString *token, NSError *error) {
        NSLog(@"Got new token %@",token);
    }];
}

@end
