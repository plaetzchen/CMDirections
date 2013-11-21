//
//  CMDirections.h
//  PebbleNav
//
//  Created by Philip Brechler on 20.11.13.
//  Copyright (c) 2013 Call a Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "CMDirectionsRequest.h"
#import "CMDirectionsResponse.h"

@class CMDirectionsResponse;
typedef void (^CMDirectionsHandler)(CMDirectionsResponse *response, NSError *error);

@interface CMDirections : NSObject

@property (nonatomic, strong) CMDirectionsRequest *request;

- (instancetype)initWithRequest:(CMDirectionsRequest *)request;
- (void)calculateDirectionsWithCompletionHandler:(CMDirectionsHandler)directionsHandler;
@end
