//
//  CMDirectionsResponse.m
//  PebbleNav
//
//  Created by Philip Brechler on 20.11.13.
//  Copyright (c) 2013 Call a Nerd. All rights reserved.
//

#import "CMDirectionsResponse.h"

#pragma mark - CMDirectionsResponse

@interface CMDirectionsResponse ()

@property (nonatomic, readwrite, strong) NSArray *routes;

@end

@implementation CMDirectionsResponse

- (instancetype)initWithResponseObject:(id)responseObject {
    self = [super init];
    if (self){
        if ([responseObject isKindOfClass:[NSArray class]]){
            NSMutableArray *arrayToSet = [NSMutableArray array];
            for (NSDictionary *dict in responseObject){
                [arrayToSet addObject:[self routeWithResponseObject:dict]];
            }
            self.routes = [NSArray arrayWithArray:arrayToSet];
        }
        else if ([responseObject isKindOfClass:[NSDictionary class]]){
            CMRoute *routeToSet = [self routeWithResponseObject:responseObject];
            self.routes = @[routeToSet];
        }
    }
    return self;
}

- (CMRoute *)routeWithResponseObject:(NSDictionary *)responseObject {
    CMRoute *routeToReturn = [CMRoute routeFromDictionaryRepresentation:responseObject];
    return routeToReturn;
}

@end


#pragma mark - CMRoute

@interface CMRoute ()

@property (nonatomic, readwrite, strong) NSString *name; // Combinded from start and end point

@property (nonatomic, readwrite) CLLocationDistance distance; // overall route distance in meters

@property (nonatomic, readwrite) NSTimeInterval expectedTravelTime;

@property (nonatomic, readwrite, strong) MKPolyline *polyline; // detailed route geometry

@property (nonatomic, readwrite, strong) NSArray *steps;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

@implementation CMRoute

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self){
        NSDictionary *routeSummaryDict = dict[@"route_summary"];
        if (routeSummaryDict) {
            _name = [NSString stringWithFormat:@"%@ - %@", routeSummaryDict[@"start_point"], routeSummaryDict[@"end_point"]];
            _expectedTravelTime = [routeSummaryDict[@"total_time"] doubleValue];
            _distance = [routeSummaryDict[@"total_distance"] doubleValue];
            _polyline = [self polylineFromDict:dict];
            _steps = [self stepsFromDict:dict];
        }
    }
    return self;
}

+ (CMRoute *)routeFromDictionaryRepresentation:(NSDictionary *)dict {
    CMRoute *route = [[CMRoute alloc] initWithDictionary:dict];
    return route;
}

# pragma mark - Polyline Creation

- (MKPolyline *)polylineFromDict:(NSDictionary *)dict {
    NSArray *geometryArray = dict[@"route_geometry"];
    CLLocationCoordinate2D points[geometryArray.count];
    
    for (int i = 0; i < geometryArray.count; i++){
        NSArray *arrayForPoint = geometryArray[i];
        points[i] = CLLocationCoordinate2DMake([arrayForPoint[0] doubleValue], [arrayForPoint[1] doubleValue]);
    }
    return [MKPolyline polylineWithCoordinates:points count:geometryArray.count];
}

# pragma mark - Steps Creation

- (NSArray *)stepsFromDict:(NSDictionary *)dict {
    NSArray *stepsForRoute = dict[@"route_instructions"];
    NSMutableArray *arrayToReturn = [[NSMutableArray alloc]initWithCapacity:stepsForRoute.count];
    for (NSArray *stepArray in stepsForRoute){
        CMRouteStep *stepFromDict = [CMRouteStep stepFromArrayRepresentation:stepArray forPolyline:_polyline];
        [arrayToReturn addObject:stepFromDict];
    }
    return [NSArray arrayWithArray:arrayToReturn];
}

@end

#pragma mark - CMRouteStep

@interface CMRouteStep ()

@property (nonatomic, readwrite, strong) NSString *instruction;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite) CLLocationDistance distance;
@property (nonatomic, readwrite) NSInteger positionInPolyline;
@property (nonatomic, readwrite) NSTimeInterval expectedTravelTime;
@property (nonatomic, readwrite, strong) NSString *distanceCaption;
@property (nonatomic, readwrite, strong) NSString *earthDirection;
@property (nonatomic, readwrite) CLLocationDirection azimute;
@property (nonatomic, readwrite) RouteStepTurnType turnType;
@property (nonatomic, readwrite) CLLocationDirection turnAngle;

- (instancetype)initWithArray:(NSArray *)array forPolyline:(MKPolyline *)polyline;

@end

@implementation CMRouteStep

- (instancetype)initWithArray:(NSArray *)array forPolyline:(MKPolyline *)polyline {
    self = [super init];
    if (self){
        _instruction = array[0];
        _distance = [array[1] doubleValue];
        _positionInPolyline = [array[2] integerValue];
        _expectedTravelTime = [array[3] doubleValue];
        _distanceCaption = array[4];
        _earthDirection = array[5];
        _azimute = [array[6] doubleValue];
        if (array.count > 7){
            _turnType = [self turnTypeForString:array[7]];
            _turnAngle = [array[8] doubleValue];
        } else {
            _turnType = 0;
            _turnAngle = 0;
        }
        _coordinate = [self getCoordinatesFromPolyline:polyline];
    }
    return self;
}

+ (CMRouteStep *)stepFromArrayRepresentation:(NSArray *)array forPolyline:(MKPolyline *)polyline {
    CMRouteStep *stepToReturn = [[CMRouteStep alloc]initWithArray:array forPolyline:polyline];
    return stepToReturn;
}

# pragma mark - Turntype switch

- (RouteStepTurnType)turnTypeForString:(NSString *)string {
    if ([string isEqualToString:@"C"]){
        return RouteStepTurnTypeContinue;
    } else if ([string isEqualToString:@"TL"]){
        return RouteStepTurnTypeLeft;
    } else if ([string isEqualToString:@"TSLL"]){
        return RouteStepTurnTypeSlightLeft;
    } else if ([string isEqualToString:@"TSHL"]){
        return RouteStepTurnTypeSharpLeft;
    } else if ([string isEqualToString:@"TR"]){
        return RouteStepTurnTypeRight;
    } else if ([string isEqualToString:@"TSLR"]){
        return RouteStepTurnTypeSlightRight;
    } else if ([string isEqualToString:@"TSHR"]){
        return RouteStepTurnTypeSharpRight;
    } else if ([string isEqualToString:@"TU"]){
        return RouteStepTurnTypeUTurn;
    } else  {
        return 0;
    }
}


# pragma mark - Coordinates from Polyline

- (CLLocationCoordinate2D)getCoordinatesFromPolyline:(MKPolyline *)polyline {
    CLLocationCoordinate2D pointsHolder[1];
    NSRange rangeToGet = {.location=_positionInPolyline, .length=1};
    [polyline getCoordinates:pointsHolder range:rangeToGet];
    return pointsHolder[0];
}


@end