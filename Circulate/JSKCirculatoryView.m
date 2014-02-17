//
//  JSKCirculatoryView.m
//  Circulate
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

CGFloat const kPaddingX = 20.0;
CGFloat const kWallThickness = 1.0;
CGFloat const kBuffer = 22.0;

CGFloat const kVesselDiameter = 2.0;
CGFloat const kVesselOffset = 0.0;
CGFloat const kSystemHeight = 78.0;
CGFloat const kSystemWidth = 150.0 * 2;
CGFloat const kSystemOriginX = kPaddingX + ((kVesselDiameter + kBuffer) * 2);
CGFloat const kSystemTwinWidth = (kSystemWidth / 2) - (kBuffer / 2);
CGFloat const kSystemTwinOriginX = kSystemOriginX + kSystemTwinWidth + kBuffer;

@interface JSKCirculatoryView () {
    NSUInteger _pulmonaryArteryPointCount;
    BOOL _isDrawing;
    UIColor *_oxygenatedColor;
    UIColor *_deoxygenatedColor;
}

@property (nonatomic, assign) NSUInteger pointCount;
@property (nonatomic, assign) NSUInteger currentPointIndex;

- (NSUInteger)calculatePointCount;
- (void)drawRect:(CGRect)rect system:(JSKSystem)system;
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
        _oxygenatedColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.5];
        _deoxygenatedColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.8 alpha:0.5];
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
    
    for (JSKSystem t_system = 0; t_system < JSKSystem_MaxValue; t_system++)
        [self drawRect:rect system:t_system];
    
    self.currentPointIndex = 0;
    _isDrawing = NO;
    
    return;
}

- (void)drawRect:(CGRect)rect system:(JSKSystem)system
{
    if (self.currentPointIndex >= self.pointIndex)
        return;
    
    CGContextRef t_context = UIGraphicsGetCurrentContext();
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
            CGPathMoveToPoint(pathRef, nil, CGRectGetMidX(t_frame), t_frame.origin.y + kWallThickness);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMidX(t_frame), t_frame.origin.y + t_frame.size.height - kWallThickness);
            
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
            UIColor *t_borderColor = _deoxygenatedColor;
            
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
        
        case JSKSystemPulmonaryVein:{
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = kVesselDiameter + kBuffer;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.y = t_lastPoint.y + t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = kBuffer + kSystemTwinWidth + kBuffer + kVesselDiameter;
                t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            if (t_shouldDraw) {
                t_delta = kBuffer + kVesselDiameter;
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
                t_delta = kBuffer + kVesselDiameter;
                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                t_lastPoint = t_point;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            }
            
            if (t_shouldDraw) {
                t_delta = kBuffer + kVesselDiameter;
                CGPoint t_origin = [self originForSystem:JSKSystemRightLung];
                t_origin = CGPointMake(t_origin.x + kSystemTwinWidth, t_origin.y + kSystemHeight + t_delta);
                t_point = CGPointMake(t_origin.x, t_origin.y - t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_origin.y - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemAorta: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = kVesselDiameter + kBuffer + kBuffer;
            CGPoint t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.x = t_lastPoint.x + t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                CGPoint t_origin = [self originForSystem:system];
                CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
                t_refPoint.x += (kSystemWidth + kVesselDiameter + kBuffer);
                t_refPoint.y += (kSystemHeight);
                
                t_delta = t_origin.y - t_refPoint.y;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y - t_delta);
                CGPoint t_point2 = CGPointZero;
                t_point2 = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    if (t_lastPoint.y > t_refPoint.y)
                        t_point.y = t_lastPoint.y - t_trim;
                    t_point2.y = t_lastPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_lastPoint.y);
                CGPathAddLineToPoint(pathRef, nil, t_point2.x, t_point2.y);
                t_lastPoint = t_point;
            }
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemCarotidArteries: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = (kVesselDiameter + kBuffer) * 2;
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
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemHead: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            t_origin.x += kSystemWidth;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = [self pointCountForSystem:system];
            CGRect t_frame = CGRectMake(t_origin.x - t_delta, t_origin.y, t_delta, kSystemHeight);
            if ((self.currentPointIndex + t_delta) > self.pointIndex) {
                t_frame.origin.x = t_origin.x - t_trim;
                t_frame.size.width = t_trim;
            }
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            self.currentPointIndex += t_frame.size.width;
            break;
        }
    
        case JSKSystemJugularVeins: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = (kVesselDiameter + kBuffer) * 2;
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
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemSuperiorVenaCava: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            CGFloat t_delta = (t_refPoint.y + kSystemHeight) - t_origin.y;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.y = t_lastPoint.y + t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = kVesselDiameter + kBuffer + kBuffer;
                t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemSubclavianArteries: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = (kVesselDiameter + kBuffer + kVesselDiameter + kBuffer);
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
                t_delta = kBuffer + kSystemTwinWidth;
                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y - kBuffer);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_lastPoint.y - kBuffer);
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
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
            
        case JSKSystemRightArm:
        case JSKSystemLeftArm: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            t_origin.x += kSystemTwinWidth;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = [self pointCountForSystem:system];
            CGRect t_frame = CGRectMake(t_origin.x - t_delta, t_origin.y, t_delta, kSystemHeight);
            if ((self.currentPointIndex + t_delta) > self.pointIndex) {
                t_frame.origin.x = t_origin.x - t_trim;
                t_frame.size.width = t_trim;
            }
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            self.currentPointIndex += t_frame.size.width;
            break;
        }
            
        case JSKSystemSubclavianVeins: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = kBuffer + kVesselDiameter;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.y = t_lastPoint.y + t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = t_lastPoint.x - kPaddingX;
                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }

            if (t_shouldDraw) {
                CGPoint t_refPoint = [self originForSystem:JSKSystemLeftArm];
                t_refPoint.y += kSystemHeight;
                t_delta = kBuffer + kVesselDiameter;
                t_point = CGPointMake(t_refPoint.x, t_refPoint.y + t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_refPoint.y + t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathMoveToPoint(pathRef, nil, t_refPoint.x, t_refPoint.y);
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemCeliacArtery: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = (kVesselDiameter + kBuffer + kVesselDiameter + kBuffer);
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
            
        case JSKSystemGut: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            t_origin.x += kSystemTwinWidth;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = [self pointCountForSystem:system];
            CGRect t_frame = CGRectMake(t_origin.x - t_delta, t_origin.y, t_delta, kSystemHeight);
            if ((self.currentPointIndex + t_delta) > self.pointIndex) {
                t_frame.origin.x = t_origin.x - t_trim;
                t_frame.size.width = t_trim;
            }
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            self.currentPointIndex += t_frame.size.width;
            break;
        }
            
        case JSKSystemHepaticPortalVein: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = kBuffer + kVesselDiameter;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_pointCount += t_delta;
            if (self.currentPointIndex + t_delta > self.pointIndex) {
                t_shouldDraw = NO;
                t_point.y = t_lastPoint.y + t_trim;
            }
            self.currentPointIndex += t_delta;
            t_trim = self.pointIndex - self.currentPointIndex;
            t_lastPoint = t_point;
            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
            
            if (t_shouldDraw) {
                t_delta = kBuffer;
                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.x = t_lastPoint.x - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            if (t_shouldDraw) {
                t_delta = kBuffer;
                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y - t_delta);
                t_pointCount += t_delta;
                if (self.currentPointIndex + t_delta > self.pointIndex) {
                    t_shouldDraw = NO;
                    t_point.y = t_lastPoint.y - t_trim;
                }
                self.currentPointIndex += t_delta;
                t_trim = self.pointIndex - self.currentPointIndex;
                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
                t_lastPoint = t_point;
            }
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
        case JSKSystemHepaticArtery: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _oxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = kSystemTwinWidth + kBuffer;
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
            
        case JSKSystemLiver: {
            CGFloat t_borderWidth = kWallThickness;
            UIColor *t_borderColor = [UIColor lightGrayColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            CGContextSetFillColorWithColor(t_context, t_fillColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            t_origin.x += kSystemTwinWidth;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            
            CGFloat t_delta = [self pointCountForSystem:system];
            CGRect t_frame = CGRectMake(t_origin.x - t_delta, t_origin.y, t_delta, kSystemHeight);
            if ((self.currentPointIndex + t_delta) > self.pointIndex) {
                t_frame.origin.x = t_origin.x - t_trim;
                t_frame.size.width = t_trim;
            }
            
            CGPathAddRect(pathRef, nil, t_frame);
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGContextAddPath(t_context, pathRef);
            CGContextFillPath(t_context);
            
            CGPathRelease(pathRef);
            self.currentPointIndex += t_frame.size.width;
            break;
        }
            
        case JSKSystemHepaticVeins: {
            CGFloat t_borderWidth = kVesselDiameter;
            UIColor *t_borderColor = _deoxygenatedColor;
            
            CGContextSetLineWidth(t_context, t_borderWidth);
            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
            
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
            BOOL t_shouldDraw = YES;
            
            NSUInteger t_pointCount = 0;
            CGFloat t_delta = kSystemOriginX - kPaddingX;
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
            
            CGContextAddPath(t_context, pathRef);
            CGContextStrokePath(t_context);
            
            CGPathRelease(pathRef);
            break;
        }
            
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
            t_return = (kVesselDiameter + kBuffer) + (kBuffer + kWallThickness + kVesselDiameter + kWallThickness + kBuffer + kSystemHeight + kBuffer) + (kVesselDiameter + kBuffer) + (kBuffer) + (kSystemTwinWidth + kBuffer) + (kBuffer);
            break;
            
        case JSKSystemLeftLung:
            t_return = kSystemTwinWidth;
            break;
            
        case JSKSystemRightLung:
            t_return = kSystemTwinWidth;
            break;
            
        case JSKSystemPulmonaryVein:
            t_return = (kVesselDiameter + kBuffer) + (kBuffer + kSystemTwinWidth + kBuffer + kVesselDiameter) + (kBuffer + kVesselDiameter) + (kBuffer + kVesselDiameter) + (kBuffer + kVesselDiameter);
            break;
            
        case JSKSystemAorta: {
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            t_refPoint.x += (kSystemWidth + kVesselDiameter + kBuffer);
            t_refPoint.y += kSystemHeight;
            CGFloat t_toHead = t_origin.y - t_refPoint.y;
            
            t_refPoint = [self originForSystem:JSKSystemRightLeg];
            CGFloat t_toLegs = t_refPoint.y - t_origin.y;
            
            t_return = (kVesselDiameter + kBuffer + kBuffer) + t_toHead + t_toLegs;
            break;
        }
        
        case JSKSystemCarotidArteries:
            t_return = (kVesselDiameter + kBuffer) * 2;
            break;
            
        case JSKSystemHead:
            t_return = kSystemWidth;
            break;
            
        case JSKSystemJugularVeins:
            t_return = (kVesselDiameter + kBuffer) * 2;
            break;
            
        case JSKSystemSuperiorVenaCava: {
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            t_return = ((t_refPoint.y + kSystemHeight) - t_origin.y) + (kVesselDiameter + kBuffer);
            break;
        }
            
        case JSKSystemSubclavianArteries:
            t_return = (kVesselDiameter + kBuffer + kVesselDiameter + kBuffer) + kSystemTwinWidth + kBuffer + kBuffer + kBuffer;
            break;
            
        case JSKSystemRightArm:
            t_return = kSystemTwinWidth;
            break;
            
        case JSKSystemLeftArm:
            t_return = kSystemTwinWidth;
            break;
            
        case JSKSystemSubclavianVeins:
            t_return = [self pointCountForSystem:JSKSystemSubclavianArteries];
            break;
            
        case JSKSystemCeliacArtery:
            t_return = (kVesselDiameter + kBuffer + kVesselDiameter + kBuffer) + kBuffer;
            break;
            
        case JSKSystemGut:
            t_return = kSystemTwinWidth;
            break;
            
        case JSKSystemHepaticPortalVein:
            t_return = kBuffer * 3;
            break;
            
        case JSKSystemHepaticArtery:
            t_return = (kBuffer + kSystemTwinWidth) + kBuffer;
            break;
            
        case JSKSystemLiver:
            t_return = kSystemTwinWidth;
            break;
            
        case JSKSystemHepaticVeins:
            t_return = kSystemOriginX - kPaddingX;
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
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            CGFloat t_y = t_refPoint.y + (kSystemHeight * 3) + ((kBuffer + kVesselDiameter + kBuffer) * 3) + (kVesselDiameter + kBuffer);
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
            CGFloat t_delta = (kBuffer + kVesselDiameter + kBuffer) + kSystemHeight;
            t_return = CGPointMake(t_heartPoint.x, t_heartPoint.y - t_delta);
            break;
        }
        
        case JSKSystemRightLung: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLeftLung];
            t_return = CGPointMake(kSystemTwinOriginX, t_refPoint.y);
            break;
        }
        
        case JSKSystemPulmonaryVein: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLeftLung];
            t_return = CGPointMake(t_refPoint.x + kSystemTwinWidth, t_refPoint.y + kSystemHeight);
            break;
        }
            
        case JSKSystemAorta: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            t_return = CGPointMake(t_refPoint.x + kSystemWidth, t_refPoint.y + kSystemHeight);
            break;
        }
        
        case JSKSystemCarotidArteries: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            t_return = CGPointMake(t_refPoint.x + kSystemWidth + ((kVesselDiameter + kBuffer) * 2), t_refPoint.y + kSystemHeight);
            break;
        }
    
        case JSKSystemHead:
            t_return = CGPointMake(kSystemOriginX, kWallThickness);
            break;
            
        case JSKSystemJugularVeins:
            t_return = CGPointMake(kSystemOriginX, kSystemHeight);
            break;
            
        case JSKSystemSuperiorVenaCava:
            t_return = CGPointMake(kPaddingX, kSystemHeight);
            break;
            
        case JSKSystemSubclavianArteries: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            t_return = CGPointMake(t_refPoint.x + kSystemWidth + ((kVesselDiameter + kBuffer) * 2), t_refPoint.y + kSystemHeight + kBuffer);
            break;
        }
            
        case JSKSystemRightArm:{
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            t_return = CGPointMake(kSystemTwinOriginX, t_refPoint.y + (kSystemHeight + kBuffer + kVesselDiameter + kBuffer));
            break;
        }
            
        case JSKSystemLeftArm: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            t_return = CGPointMake(kSystemOriginX, t_refPoint.y + (kSystemHeight + kBuffer + kVesselDiameter + kBuffer));
            break;
        }
            
        case JSKSystemSubclavianVeins: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemRightArm];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + kSystemHeight);
            break;
        }
        
        case JSKSystemCeliacArtery: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            t_return = CGPointMake(t_refPoint.x + kSystemWidth + (kVesselDiameter + kBuffer) + kBuffer, t_refPoint.y + kSystemHeight + kBuffer + kVesselDiameter);
            break;
        }
            
        case JSKSystemGut: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            t_return = CGPointMake(kSystemTwinOriginX, t_refPoint.y + kSystemHeight + kBuffer + kVesselDiameter + kBuffer);
            break;
        }
        
        case JSKSystemHepaticPortalVein: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemGut];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + kSystemHeight);
            break;
        }
            
        case JSKSystemHepaticArtery: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemGut];
            t_return = CGPointMake(t_refPoint.x + kSystemTwinWidth, t_refPoint.y - kBuffer);
            break;
        }
            
        case JSKSystemLiver: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemGut];
            t_return = CGPointMake(kSystemOriginX, t_refPoint.y);
            break;
        }
            
        case JSKSystemHepaticVeins: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLiver];
            t_return = CGPointMake(kSystemOriginX, t_refPoint.y + kSystemHeight);
            break;
        }
            
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
            
        case JSKSystemRightLeg: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            CGFloat t_deltaY = ((kSystemHeight + kBuffer) * 3) + kVesselDiameter + kBuffer;
            t_return = CGPointMake(kSystemTwinOriginX, t_refPoint.y + t_deltaY);
            break;
        }
            
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
    
    for (JSKSystem t_system = 0; t_system < JSKSystem_MaxValue; t_system++)
        t_count += [self pointCountForSystem:t_system];
    
//    t_count += [self pointCountForSystem:JSKSystemHeart];
//    t_count += [self pointCountForSystem:JSKSystemPulmonaryArtery];
//    t_count += [self pointCountForSystem:JSKSystemLeftLung];
//    t_count += [self pointCountForSystem:JSKSystemRightLung];
//    t_count += [self pointCountForSystem:JSKSystemPulmonaryVein];
//    t_count += [self pointCountForSystem:JSKSystemAorta];
//    t_count += [self pointCountForSystem:JSKSystemCarotidArteries];
//    t_count += [self pointCountForSystem:JSKSystemHead];
//    t_count += [self pointCountForSystem:JSKSystemJugularVeins];
//    t_count += [self pointCountForSystem:JSKSystemSuperiorVenaCava];
//    t_count += [self pointCountForSystem:JSKSystemSubclavianArteries];
//    t_count += [self pointCountForSystem:JSKSystemRightArm];
//    t_count += [self pointCountForSystem:JSKSystemLeftArm];
//    t_count += [self pointCountForSystem:JSKSystemSubclavianVeins];
//    t_count += [self pointCountForSystem:JSKSystemCeliacArtery];
//    t_count += [self pointCountForSystem:JSKSystemGut];
//    t_count += [self pointCountForSystem:JSKSystemHepaticPortalVein];
//    t_count += [self pointCountForSystem:JSKSystemHepaticArtery];
//    t_count += [self pointCountForSystem:JSKSystemLiver];
//    t_count += [self pointCountForSystem:JSKSystemHepaticVeins];
//    t_count += [self pointCountForSystem:JSKSystemInferiorVenaCava];
//    t_count += [self pointCountForSystem:JSKSystemRenalArteries];
//    t_count += [self pointCountForSystem:JSKSystemRightKidney];
//    t_count += [self pointCountForSystem:JSKSystemLeftKidney];
//    t_count += [self pointCountForSystem:JSKSystemRenalVeins];
//    t_count += [self pointCountForSystem:JSKSystemTesticularisArteries];
//    t_count += [self pointCountForSystem:JSKSystemLowerBody];
//    t_count += [self pointCountForSystem:JSKSystemTesticularisVeins];
//    t_count += [self pointCountForSystem:JSKSystemIliacArtieries];
//    t_count += [self pointCountForSystem:JSKSystemRightLeg];
//    t_count += [self pointCountForSystem:JSKSystemLeftLeg];
//    t_count += [self pointCountForSystem:JSKSystemIliacVeins];
    
    return t_count;
}

- (void)setPointIndex:(NSUInteger)pointIndex
{
    _pointIndex = pointIndex;
    [self setNeedsDisplay];
}

@end
