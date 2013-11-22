//
//  CMDirectionsResponse.h
//  PebbleNav
//
//  Created by Philip Brechler on 20.11.13.
//  Copyright (c) 2013 Call a Nerd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "CMDirections.h"

@interface CMDirectionsResponse : NSObject

// Source and destination may be filled with additional details compared to the request object.
@property (nonatomic, readonly) MKMapItem *source;
@property (nonatomic, readonly) MKMapItem *destination;

@property (nonatomic, readonly) NSArray *routes; // array of CMRoute objects

- (instancetype)initWithResponseObject:(id)responseObject; // Gets called by CMDirections

@end

@interface CMRoute : NSObject

@property (nonatomic, readonly) NSString *name; // Combinded from start and end point

@property (nonatomic, readonly) CLLocationDistance distance; // overall route distance in meters
@property (nonatomic, readonly) NSTimeInterval expectedTravelTime;

@property (nonatomic, readonly) MKPolyline *polyline; // detailed route geometry

@property (nonatomic, readonly) NSArray *steps; // array of CMRouteStep objects

+ (CMRoute *)routeFromDictionaryRepresentation:(NSDictionary *)dict; // Used when creating a new directions objects should not be called manually

@end

typedef enum {
    CMRouteSTepTurnTypeContinue = 1,
    CMRouteSTepTurnTypeLeft = 2,
    CMRouteSTepTurnTypeSlightLeft = 3,
    CMRouteSTepTurnTypeSharpLeft = 4,
    CMRouteSTepTurnTypeRight = 5,
    CMRouteSTepTurnTypeSlightRight = 6,
    CMRouteSTepTurnTypeSharpRight = 7,
    CMRouteSTepTurnTypeUTurn = 8,
} CMRouteStepTurnType;

@interface CMRouteStep : NSObject

@property (nonatomic, readonly) NSString *instruction; // localized written instructions

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate; // The coordinate of the step

@property (nonatomic, readonly) CLLocationDistance distance; // step distance in meters

@property (nonatomic, readonly) NSInteger positionInPolyline;

@property (nonatomic, readonly) NSTimeInterval expectedTravelTime; // Expected time for this step

@property (nonatomic, readonly) NSString *distanceCaption; //distance with localized format

@property (nonatomic, readonly) NSString *earthDirection; // Earth direction for the step (N, NE, E...)

@property (nonatomic, readonly) CLLocationDirection azimute; //Azimute for this step in degress;

@property (nonatomic, readonly) CMRouteStepTurnType turnType; //Type of the turn (left, right...), optional, absent for the first segment

@property (nonatomic, readonly) CLLocationDirection turnAngle; //The angle of the turn in degrees (0 for go straight, 90 for turn right, 270 for turn left, 180 for U-turn...)

+ (CMRouteStep *)stepFromArrayRepresentation:(NSArray *)array forPolyline:(MKPolyline *)polyline; // Used when creating a new directions objects should not be called manually

@end
