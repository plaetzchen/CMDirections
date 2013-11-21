//
//  CMDirections.m
//  PebbleNav
//
//  Created by Philip Brechler on 20.11.13.
//  Copyright (c) 2013 Call a Nerd. All rights reserved.
//

#import "CMDirections.h"
#import "AFNetworking.h"
#import "CMDirectionsResponse.h"
#import "CMAuthTokenProvider.h"

@implementation CMDirections

- (instancetype)initWithRequest:(CMDirectionsRequest *)request {
    self = [super init];
    if (self){
        _request = request;
    }
    return self;
}

- (void)calculateDirectionsWithCompletionHandler:(CMDirectionsHandler)directionsHandler {
    
    CMAuthTokenProvider *authTokenProvider = [[CMAuthTokenProvider alloc]init];
    [authTokenProvider requestTokenWithCompletionHandler:^(NSString *token, NSError *error){
        if (error){
            directionsHandler(nil,error);
        } else {

            NSString *typeString = nil;
            
            NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
            NSArray *availableLanguages = @[@"de", @"en", @"es", @"fr", @"hu", @"it", @"nl", @"ro", @"ru", @"se", @"vi", @"zh"];
            if (![availableLanguages containsObject:language]){
                language = @"en";
            }
            
            if (self.request.transportType == CMDirectionsTransportTypeAutomobile){
                typeString = @"car";
            } else if (self.request.transportType == CMDirectionsTransportTypeCycling){
                typeString = @"bicycle";
            } else {
                typeString = @"foot";
            }
            
            NSString *urlToCall = [NSString stringWithFormat:@"http://routes.cloudmade.com/%@/api/0.3/%f,%f,%f,%f/%@.js",CMAPIKey,self.request.source.latitude,self.request.source.longitude,self.request.destination.latitude,self.request.destination.longitude,typeString];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSDictionary *parameters = @{@"token": token, @"lang": language, @"units": @"km"};
            
            [manager GET:urlToCall parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([[responseObject objectForKey:@"status"] integerValue] > 0){
                    NSString *errorMessage = @"An unknown error accured";
                    if ([responseObject objectForKey:@"status_message"]){
                        errorMessage = responseObject[@"status_message"];
                    }
                    NSError *failedToGetRouteError = [NSError errorWithDomain:@"CMRouteErrorDomain" code:1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey:errorMessage}];
                    directionsHandler(nil, failedToGetRouteError);
                } else {
                    CMDirectionsResponse *response = [[CMDirectionsResponse alloc] initWithResponseObject:responseObject];
                    directionsHandler(response,nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error getting Directions: %@",error);
                if (operation.response.statusCode == 403){
                    [authTokenProvider forceNewToken];
                }
                directionsHandler(nil,error);
            }];
        }

    }];
    
}

@end
