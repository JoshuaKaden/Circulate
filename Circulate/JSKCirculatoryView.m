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

CGFloat const kSystemHeight = 84.0;
CGFloat const kSystemWidth = 150.0;
CGFloat const kVesselDiameter = 18.0;
CGFloat const kWallThickness = 2.0;
CGFloat const kBuffer = 20.0;
CGFloat const kSystemOriginX = (kWallThickness + kVesselDiameter + kWallThickness + kBuffer) * 2;

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

@interface JSKCirculatoryView ()

@property (nonatomic, assign) NSUInteger pointCount;
@property (nonatomic, assign) NSUInteger currentPointIndex;

- (NSUInteger)calculatePointCount;
- (void)drawRect:(CGRect)rect system:(JSKSystem)system context:(CGContextRef)context;
- (NSString *)titleForSystem:(JSKSystem)system;
- (NSUInteger)pointCountForSystem:(JSKSystem)system;
- (CGPoint)originForSystem:(JSKSystem)system;

@end

@implementation JSKCirculatoryView {
    NSUInteger _pulmonaryArteryPointCount;
}

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
    
    CGContextRef t_context = UIGraphicsGetCurrentContext();
    [self drawRect:rect system:JSKSystemHeart context:t_context];
    [self drawRect:rect system:JSKSystemPulmonaryArtery context:t_context];
    
    
    self.currentPointIndex = 0;
    
    return;
}

- (void)drawRect:(CGRect)rect system:(JSKSystem)system context:(CGContextRef)context
{
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
            
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, kSystemWidth, kSystemHeight);
            if ((self.currentPointIndex + kSystemWidth) > self.pointIndex)
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
            UIColor *t_borderColor = [UIColor whiteColor];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGPoint t_point = CGPointMake(t_lastPoint.x - kBuffer, t_lastPoint.y);
            t_pointCount += kBuffer;
            if (self.currentPointIndex + t_pointCount > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x - t_trim;
            }
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                CGFloat t_delta = kBuffer + kWallThickness + kVesselDiameter + kWallThickness + kBuffer + kSystemHeight + kBuffer;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y - t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_pointCount > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y - t_trim;
                }
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            if (t_shouldDraw) {
                CGFloat t_delta = kVesselDiameter + kBuffer;
                t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_pointCount > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x + t_trim;
                }
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            if (t_shouldDraw) {
                CGFloat t_delta = kBuffer;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_pointCount > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y + t_trim;
                }
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            self.currentPointIndex += t_pointCount;
            break;
        }
            
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
            t_return = (kBuffer) + (kBuffer + kWallThickness + kVesselDiameter + kWallThickness + kBuffer + kSystemHeight + kBuffer) + (kVesselDiameter + kBuffer) + (kBuffer);
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
            t_return = [self originForSystem:JSKSystemHeart];
            break;
        }
            
        case JSKSystemLeftLung: {
            break;
        }
            
        case JSKSystemRightLung: {
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
