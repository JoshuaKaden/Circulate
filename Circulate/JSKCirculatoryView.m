//
//  JSKCirculatoryView.m
//  Circulate
//
//  Created by Joshua Kaden on 2/12/14.
//  Copyright (c) 2014 Chadford Software. All rights reserved.
//

//
//  JSKCirculatoryView.m
//  Circlulate
//
//  Created by Joshua Kaden on 2/12/14.
//  Copyright (c) 2014 Chadford Software. All rights reserved.
//

#import "JSKCirculatoryView.h"

NSUInteger const kSegmentCount = 8;

CGFloat const kPhoneWidth = 320.0;
CGFloat const kPhoneHeight = 480.0;
CGFloat const kPhone5Height = 568.0;
CGFloat const kPadWidth = 664.0;
CGFloat const kPadHeight = 920.0;

CGFloat const kWallThickness = 1.0;
CGFloat const kBuffer = 20.0;

CGFloat const kVesselDiameter = 2.0;
CGFloat const kVesselOffset = 0.0;
CGFloat const kSystemHeight = 84.0;
CGFloat const kSystemWidth = 150.0;
CGFloat const kSystemOriginX = (kWallThickness + kVesselDiameter + kWallThickness + kBuffer) * 2;
CGFloat const kSystemTwinWidth = (kSystemWidth / 2) - (kBuffer / 2);

typedef enum {
    JSKSystemHeart,
    JSKSystemPulmonaryArtery,
    JSKSystemLeftLung,
    JSKSystemRightLung,
    JSKSystemPulmonaryVein,
    JSKSystemAorta,
    JSKSystemCarotidArteries,
    JSKSystemHead,
    JSKSystemJugularVeins,
    JSKSystemSuperiorVenaCava,
    JSKSystemSubclavianArteries,
    JSKSystemRightArm,
    JSKSystemLeftArm,
    JSKSystemSubclavianVeins,
    JSKSystemCeliacArtery,
    JSKSystemGut,
    JSKSystemHepaticPortalVein,
    JSKSystemHepaticArtery,
    JSKSystemLiver,
    JSKSystemHepaticVeins,
    JSKSystemInferiorVenaCava,
    JSKSystemRenalArteries,
    JSKSystemRightKidney,
    JSKSystemLeftKidney,
    JSKSystemRenalVeins,
    JSKSystemTesticularisArteries,
    JSKSystemLowerBody,
    JSKSystemTesticularisVeins,
    JSKSystemIliacArtieries,
    JSKSystemRightLeg,
    JSKSystemLeftLeg,
    JSKSystemIliacVeins,
    JSKSystem_MaxValue
} JSKSystem;

@interface JSKCirculatoryView () {
    NSUInteger _pulmonaryArteryPointCount;
    BOOL _isDrawing;
}

@property (nonatomic, assign) NSUInteger pointCount;
@property (nonatomic, assign) NSUInteger currentPointIndex;

- (NSUInteger)calculatePointCount;
- (void)drawRect:(CGRect)rect system:(JSKSystem)system context:(CGContextRef)context;
- (NSString *)titleForSystem:(JSKSystem)system;
- (NSUInteger)pointCountForSystem:(JSKSystem)system;
- (CGPoint)originForSystem:(JSKSystem)system;

@end

@implementation JSKCirculatoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pointCount = [self calculatePointCount];
        _pointIndex = self.pointCount;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code

    if (self.pointIndex == 0)
        return;

    if (_isDrawing)
        return;
    _isDrawing = YES;
    
    CGContextRef t_context = UIGraphicsGetCurrentContext();
    [self drawRect:rect system:JSKSystemHeart context:t_context];
    [self drawRect:rect system:JSKSystemPulmonaryArtery context:t_context];
    [self drawRect:rect system:JSKSystemLeftLung context:t_context];
    [self drawRect:rect system:JSKSystemRightLung context:t_context];
    
    
    self.currentPointIndex = 0;
    _isDrawing = NO;
    
    return;
}

- (void)drawRect:(CGRect)rect system:(JSKSystem)system context:(CGContextRef)context
{
    if (self.currentPointIndex >= self.pointIndex)
        return;
    
    CGContextRef t_context = context;
    CGFloat t_trim = self.pointIndex - self.currentPointIndex;
    
    switch (system) {
            
        case JSKSystemHeart: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = [self pointCountForSystem:system];
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, t_delta, kSystemHeight);
            if ((self.currentPointIndex + t_delta) > self.pointIndex)
                t_frame.size.width = t_trim;
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            self.currentPointIndex += t_frame.size.width;
            break;
        }
            
        case JSKSystemPulmonaryArtery: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = [UIColor colorWithRed:0.0 green:0. blue:0.8 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = kVesselDiameter + kBuffer;
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x - t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = kBuffer + kWallThickness + kVesselDiameter + kWallThickness + kBuffer + kSystemHeight + kBuffer;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y - t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            if (t_shouldDraw) {
                t_delta = kVesselDiameter + kBuffer;
                CGPoint t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point = CGPointMake(t_lastPoint.x + t_trim, t_lastPoint.y);
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            if (t_shouldDraw) {
                t_delta = kBuffer;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }

            if (t_shouldDraw) {
                t_delta = kSystemTwinWidth + kBuffer;
                t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y - kBuffer);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_point.y);
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//                NSLog(@"move to %.0f, %.0f", t_lastPoint.x, t_point.y);
//                NSLog(@"line to %.0f, %.0f", t_point.x, t_point.y);
                t_lastPoint = t_point;
            }

            if (t_shouldDraw) {
                t_delta = kBuffer;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemLeftLung:
        case JSKSystemRightLung: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = [self pointCountForSystem:system];
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, t_delta, kSystemHeight);
            if ((self.currentPointIndex + t_delta) > self.pointIndex)
                t_frame.size.width = t_trim;
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            self.currentPointIndex += t_frame.size.width;
            break;
        }
        
        case JSKSystemPulmonaryVein:
            break;
            
        case JSKSystemAorta:
            break;
            
        case JSKSystemCarotidArteries:
            break;
            
        case JSKSystemHead:
            break;
            
        case JSKSystemJugularVeins:
            break;
            
        case JSKSystemSuperiorVenaCava:
            break;
            
        case JSKSystemSubclavianArteries:
            break;
            
        case JSKSystemRightArm:
            break;
            
        case JSKSystemLeftArm:
            break;
            
        case JSKSystemSubclavianVeins:
            break;
            
        case JSKSystemCeliacArtery:
            break;
            
        case JSKSystemGut:
            break;
            
        case JSKSystemHepaticPortalVein:
            break;
            
        case JSKSystemHepaticArtery:
            break;
            
        case JSKSystemLiver:
            break;
            
        case JSKSystemHepaticVeins:
            break;
            
        case JSKSystemInferiorVenaCava:
            break;
            
        case JSKSystemRenalArteries:
            break;
            
        case JSKSystemRightKidney:
            break;
            
        case JSKSystemLeftKidney:
            break;
            
        case JSKSystemRenalVeins:
            break;
            
        case JSKSystemTesticularisArteries:
            break;
            
        case JSKSystemLowerBody:
            break;
            
        case JSKSystemTesticularisVeins:
            break;
            
        case JSKSystemIliacArtieries:
            break;
            
        case JSKSystemRightLeg:
            break;
            
        case JSKSystemLeftLeg:
            break;
            
        case JSKSystemIliacVeins:
            break;
            
        case JSKSystem_MaxValue:
            break;
    }
}

- (NSString *)titleForSystem:(JSKSystem)system
{
    NSString *t_return = nil;
    switch (system) {
        case JSKSystemHeart:
            break;
            
        case JSKSystemPulmonaryArtery:
            break;
            
        case JSKSystemLeftLung:
            break;
            
        case JSKSystemRightLung:
            break;
            
        case JSKSystemPulmonaryVein:
            break;
            
        case JSKSystemAorta:
            break;
            
        case JSKSystemCarotidArteries:
            break;
            
        case JSKSystemHead:
            break;
            
        case JSKSystemJugularVeins:
            break;
            
        case JSKSystemSuperiorVenaCava:
            break;
            
        case JSKSystemSubclavianArteries:
            break;
            
        case JSKSystemRightArm:
            break;
            
        case JSKSystemLeftArm:
            break;
            
        case JSKSystemSubclavianVeins:
            break;
            
        case JSKSystemCeliacArtery:
            break;
            
        case JSKSystemGut:
            break;
            
        case JSKSystemHepaticPortalVein:
            break;
            
        case JSKSystemHepaticArtery:
            break;
            
        case JSKSystemLiver:
            break;
            
        case JSKSystemHepaticVeins:
            break;
            
        case JSKSystemInferiorVenaCava:
            break;
            
        case JSKSystemRenalArteries:
            break;
            
        case JSKSystemRightKidney:
            break;
            
        case JSKSystemLeftKidney:
            break;
            
        case JSKSystemRenalVeins:
            break;
            
        case JSKSystemTesticularisArteries:
            break;
            
        case JSKSystemLowerBody:
            break;
            
        case JSKSystemTesticularisVeins:
            break;
            
        case JSKSystemIliacArtieries:
            break;
            
        case JSKSystemRightLeg:
            break;
            
        case JSKSystemLeftLeg:
            break;
            
        case JSKSystemIliacVeins:
            break;
            
        case JSKSystem_MaxValue:
            break;
    }
    return t_return;
}

- (NSUInteger)pointCountForSystem:(JSKSystem)system
{
    NSUInteger t_return = 0;
    switch (system) {
        case JSKSystemHeart:
            t_return = kSystemWidth;
            break;
            
        case JSKSystemPulmonaryArtery:
            t_return = (kBuffer) + (kBuffer + kWallThickness + kVesselDiameter + kWallThickness + kBuffer + kSystemHeight + kBuffer) + (kVesselDiameter + kBuffer) + (kBuffer) + (kSystemTwinWidth + kBuffer) + (kBuffer);
            break;
            
        case JSKSystemLeftLung:
            t_return = kSystemTwinWidth;
            break;
            
        case JSKSystemRightLung:
            t_return = kSystemTwinWidth;
            break;
            
        case JSKSystemPulmonaryVein:
            break;
            
        case JSKSystemAorta:
            break;
            
        case JSKSystemCarotidArteries:
            break;
            
        case JSKSystemHead:
            break;
            
        case JSKSystemJugularVeins:
            break;
            
        case JSKSystemSuperiorVenaCava:
            break;
            
        case JSKSystemSubclavianArteries:
            break;
            
        case JSKSystemRightArm:
            break;
            
        case JSKSystemLeftArm:
            break;
            
        case JSKSystemSubclavianVeins:
            break;
            
        case JSKSystemCeliacArtery:
            break;
            
        case JSKSystemGut:
            break;
            
        case JSKSystemHepaticPortalVein:
            break;
            
        case JSKSystemHepaticArtery:
            break;
            
        case JSKSystemLiver:
            break;
            
        case JSKSystemHepaticVeins:
            break;
            
        case JSKSystemInferiorVenaCava:
            break;
            
        case JSKSystemRenalArteries:
            break;
            
        case JSKSystemRightKidney:
            break;
            
        case JSKSystemLeftKidney:
            break;
            
        case JSKSystemRenalVeins:
            break;
            
        case JSKSystemTesticularisArteries:
            break;
            
        case JSKSystemLowerBody:
            break;
            
        case JSKSystemTesticularisVeins:
            break;
            
        case JSKSystemIliacArtieries:
            break;
            
        case JSKSystemRightLeg:
            break;
            
        case JSKSystemLeftLeg:
            break;
            
        case JSKSystemIliacVeins:
            break;
            
        case JSKSystem_MaxValue:
            break;
    }
    return t_return;
}

- (CGPoint)originForSystem:(JSKSystem)system
{
    CGPoint t_return = CGPointZero;
    switch (system) {
        case JSKSystemHeart: {
            CGFloat t_y = (kSystemHeight * 3) + ((kBuffer + kWallThickness + kVesselDiameter + kWallThickness + kBuffer) * 4);
            t_return = CGPointMake(kSystemOriginX, t_y);
            break;
        }
            
        case JSKSystemPulmonaryArtery: {
            CGPoint t_heartPoint = [self originForSystem:JSKSystemHeart];
            CGFloat t_delta = kVesselOffset;
            t_return = CGPointMake(t_heartPoint.x, t_heartPoint.y + t_delta);
            break;
        }
            
        case JSKSystemLeftLung: {
            CGPoint t_heartPoint = [self originForSystem:JSKSystemHeart];
            CGFloat t_delta = (kBuffer + kWallThickness + kVesselDiameter + kWallThickness + kBuffer) + kSystemHeight;
            t_return = CGPointMake(t_heartPoint.x, t_heartPoint.y - t_delta);
            break;
        }
            
        case JSKSystemRightLung: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLeftLung];
            CGFloat t_delta = kSystemTwinWidth + kBuffer;
            t_return = CGPointMake(t_refPoint.x + t_delta, t_refPoint.y);
            break;
        }
        
        case JSKSystemPulmonaryVein:
            break;
            
        case JSKSystemAorta:
            break;
            
        case JSKSystemCarotidArteries:
            break;
            
        case JSKSystemHead:
            break;
            
        case JSKSystemJugularVeins:
            break;
            
        case JSKSystemSuperiorVenaCava:
            break;
            
        case JSKSystemSubclavianArteries:
            break;
            
        case JSKSystemRightArm:
            break;
            
        case JSKSystemLeftArm:
            break;
            
        case JSKSystemSubclavianVeins:
            break;
            
        case JSKSystemCeliacArtery:
            break;
            
        case JSKSystemGut:
            break;
            
        case JSKSystemHepaticPortalVein:
            break;
            
        case JSKSystemHepaticArtery:
            break;
            
        case JSKSystemLiver:
            break;
            
        case JSKSystemHepaticVeins:
            break;
            
        case JSKSystemInferiorVenaCava:
            break;
            
        case JSKSystemRenalArteries:
            break;
            
        case JSKSystemRightKidney:
            break;
            
        case JSKSystemLeftKidney:
            break;
            
        case JSKSystemRenalVeins:
            break;
            
        case JSKSystemTesticularisArteries:
            break;
            
        case JSKSystemLowerBody:
            break;
            
        case JSKSystemTesticularisVeins:
            break;
            
        case JSKSystemIliacArtieries:
            break;
            
        case JSKSystemRightLeg:
            break;
            
        case JSKSystemLeftLeg:
            break;
            
        case JSKSystemIliacVeins:
            break;
            
        case JSKSystem_MaxValue:
            break;
    }
    return t_return;
}

- (NSUInteger)calculatePointCount
{
    NSUInteger t_count = 0;
    
    t_count += [self pointCountForSystem:JSKSystemHeart];
    t_count += [self pointCountForSystem:JSKSystemPulmonaryArtery];
    t_count += [self pointCountForSystem:JSKSystemLeftLung];
    t_count += [self pointCountForSystem:JSKSystemRightLung];
    t_count += [self pointCountForSystem:JSKSystemPulmonaryVein];
    t_count += [self pointCountForSystem:JSKSystemAorta];
    t_count += [self pointCountForSystem:JSKSystemCarotidArteries];
    t_count += [self pointCountForSystem:JSKSystemHead];
    t_count += [self pointCountForSystem:JSKSystemJugularVeins];
    t_count += [self pointCountForSystem:JSKSystemSuperiorVenaCava];
    t_count += [self pointCountForSystem:JSKSystemSubclavianArteries];
    t_count += [self pointCountForSystem:JSKSystemRightArm];
    t_count += [self pointCountForSystem:JSKSystemLeftArm];
    t_count += [self pointCountForSystem:JSKSystemSubclavianVeins];
    t_count += [self pointCountForSystem:JSKSystemCeliacArtery];
    t_count += [self pointCountForSystem:JSKSystemGut];
    t_count += [self pointCountForSystem:JSKSystemHepaticPortalVein];
    t_count += [self pointCountForSystem:JSKSystemHepaticArtery];
    t_count += [self pointCountForSystem:JSKSystemLiver];
    t_count += [self pointCountForSystem:JSKSystemHepaticVeins];
    t_count += [self pointCountForSystem:JSKSystemInferiorVenaCava];
    t_count += [self pointCountForSystem:JSKSystemRenalArteries];
    t_count += [self pointCountForSystem:JSKSystemRightKidney];
    t_count += [self pointCountForSystem:JSKSystemLeftKidney];
    t_count += [self pointCountForSystem:JSKSystemRenalVeins];
    t_count += [self pointCountForSystem:JSKSystemTesticularisArteries];
    t_count += [self pointCountForSystem:JSKSystemLowerBody];
    t_count += [self pointCountForSystem:JSKSystemTesticularisVeins];
    t_count += [self pointCountForSystem:JSKSystemIliacArtieries];
    t_count += [self pointCountForSystem:JSKSystemRightLeg];
    t_count += [self pointCountForSystem:JSKSystemLeftLeg];
    t_count += [self pointCountForSystem:JSKSystemIliacVeins];
    
    return t_count;
}

- (void)setPointIndex:(NSUInteger)pointIndex
{
    _pointIndex = pointIndex;
    [self setNeedsDisplay];
}

@end
