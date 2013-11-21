//
//  CMDirectionsRequest.h
//  PebbleNav
//
//  Created by Philip Brechler on 20.11.13.
//  Copyright (c) 2013 Call a Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    CMDirectionsTransportTypeAutomobile     = 1 << 0,
    CMDirectionsTransportTypeWalking        = 1 << 1,
    CMDirectionsTransportTypeCycling            = 1 << 2,
} CMDirectionsTransportType;

@interface CMDirectionsRequest : NSObject

@property (nonatomic) CLLocationCoordinate2D source;
@property (nonatomic) CLLocationCoordinate2D destination;
@property (nonatomic) CMDirectionsTransportType transportType;

@end
