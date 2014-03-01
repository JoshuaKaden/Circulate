//
//  JSKCirculatoryView.m
//  Circulate
//
//  Created by Joshua Kaden on 2/12/14.
//  Copyright (c) 2014 Chadford Software. All rights reserved.
//

#import "JSKCirculatoryView.h"

CGFloat const kBuffer = 22.0;
CGFloat const kSystemHeight = 60.0;
CGFloat const kSystemWidth = 150.0 * 2;
CGFloat const kPaddingX = 120.0;

CGFloat const kBufferPhone = 12.0;
CGFloat const kSystemHeightPhone = 28.0;
CGFloat const kSystemWidthPhone = 120.0;
CGFloat const kPaddingXPhone = 50.0;

CGFloat const kPaddingY = 5;
CGFloat const kWallThickness = 1.0;
CGFloat const kVesselDiameter = 2.0;
CGFloat const kVesselOffset = 0.0;

CGFloat const kPhoneWidth = 320.0;
CGFloat const kPhoneHeight = 480.0;
CGFloat const kPhone5Height = 568.0;
CGFloat const kPadWidth = 664.0;
CGFloat const kPadHeight = 920.0;

@interface JSKCirculatoryView () {
    NSUInteger _pulmonaryArteryPointCount;
    BOOL _isDrawing;
    UIColor *_oxygenatedColor;
    UIColor *_deoxygenatedColor;
    UIColor *_lightOxygenatedColor;
    UIColor *_lightDeoxygenatedColor;
    UIColor *_systemWallColor;
    UIColor *_systemFillColor;
    NSMutableDictionary *_magicNumbers;
    CGSize _systemSize;
    CGSize _systemTwinSize;
    CGSize _bufferSize;
    CGFloat _paddingX;
    CALayer *_floorLayer;
}

- (void)drawRect:(CGRect)rect system:(JSKSystem)system;
- (void)drawLabels:(CGRect)rect;
- (UIBezierPath *)pathForSystem:(JSKSystem)system;
- (CAShapeLayer *)layerForSystem:(JSKSystem)system;
- (NSString *)titleForSystem:(JSKSystem)system;
- (CGPoint)originForSystem:(JSKSystem)system;
- (CGFloat)systemOriginX;
- (CGFloat)systemTwinWidth;
- (CGFloat)systemTwinOriginX;
- (void)addArteryAnimation:(JSKSystem)system;
- (void)addVeinAnimation:(JSKSystem)system;
- (JSKSystemType)determineSystemType:(JSKSystem)system;

@end

@implementation JSKCirculatoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _bufferSize = CGSizeMake(kBuffer, kBuffer);
        _systemSize = CGSizeMake(kSystemWidth, kSystemHeight);
        _systemTwinSize = CGSizeMake([self systemTwinWidth], kSystemHeight);
        _paddingX = kPaddingX;
        
        if (frame.size.width <= kPhoneWidth) {
            _bufferSize = CGSizeMake(kBufferPhone, kBufferPhone);
            _systemSize = CGSizeMake(kSystemWidthPhone, kSystemHeightPhone);
            _systemTwinSize = CGSizeMake([self systemTwinWidth], kSystemHeightPhone);
            _paddingX = kPaddingXPhone;
        }
        
        _oxygenatedColor = [UIColor colorWithRed:144.0/255.0 green:42.0/255.0 blue:42.0/255.0 alpha:1.0];
        _deoxygenatedColor = [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:144.0/255.0 alpha:1.0];
        _lightOxygenatedColor = [UIColor colorWithRed:0.9 green:0.4 blue:0.4 alpha:0.8];
        _lightDeoxygenatedColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.9 alpha:0.8];
        _systemWallColor = [UIColor lightGrayColor];
        _systemFillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (_isDrawing)
        return;
    _isDrawing = YES;
    
    for (JSKSystem t_system = 0; t_system < JSKSystem_MaxValue; t_system++)
        [self drawRect:rect system:t_system];
    
    [self drawLabels:rect];
    
    _isDrawing = NO;
    return;
}

#pragma mark - Custom Accessors

- (void)setLabelsHidden:(BOOL)labelsHidden
{
    _labelsHidden = labelsHidden;
    [self setNeedsDisplay];
}

#pragma mark - Public Methods

- (void)startAnimating
{
    if (_isAnimating) {
        [self stopAnimating];
        return;
    }
    _isAnimating = YES;
    
    if (_floorLayer) {
        [_floorLayer removeAllAnimations];
        [_floorLayer removeFromSuperlayer];
        _floorLayer = nil;
    }
    
    _floorLayer = ({
        CALayer *t_layer = [CALayer layer];
        t_layer.frame = self.bounds;
        [self.layer addSublayer:t_layer];
        t_layer;
    });
    
    // Heart
    CAShapeLayer *t_layer = [self layerForSystem:JSKSystemHeart];
    CABasicAnimation *t_animation = ({
        CABasicAnimation *t_animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        t_animation.duration = 2.0;
        t_animation.fromValue = [NSNumber numberWithFloat:0.0f];
        t_animation.toValue = [NSNumber numberWithFloat:1.0f];
        t_animation.autoreverses = YES;
        t_animation.repeatCount = HUGE_VALF;
        t_animation;
    });
    [t_layer addAnimation:t_animation forKey:@"pulseIn"];
    [_floorLayer addSublayer:t_layer];
    
    // Arteries and veins
    for (JSKSystem t_system = 0; t_system < JSKSystem_MaxValue; t_system++) {
        JSKSystemType t_type = [self determineSystemType:t_system];
        switch (t_type) {
            case JSKSystemTypeArtery:
                [self addArteryAnimation:t_system];
                break;
            case JSKSystemTypeVein:
                [self addVeinAnimation:t_system];
                break;
            case JSKSystemTypeSystem:
                break;
            case JSKSystemType_MaxValue:
                break;
        }
    }
}

- (void)stopAnimating
{
    for (CALayer *t_layer in _floorLayer.sublayers)
        [t_layer removeAllAnimations];
    [_floorLayer removeFromSuperlayer];
    _isAnimating = NO;
}

#pragma mark - Private Methods

- (void)drawRect:(CGRect)rect system:(JSKSystem)system
{
    UIColor *t_borderColor = nil;
    UIColor *t_fillColor = nil;
    JSKSystemType t_type = [self determineSystemType:system];
    switch (t_type) {
            
        case JSKSystemTypeArtery:
            t_borderColor = _oxygenatedColor;
            t_fillColor = [UIColor clearColor];
            if (system == JSKSystemPulmonaryArtery)
                t_borderColor = _deoxygenatedColor;
            break;
            
        case JSKSystemTypeVein:
            t_borderColor = _deoxygenatedColor;
            t_fillColor = [UIColor clearColor];
            if (system == JSKSystemPulmonaryVein)
                t_borderColor = _oxygenatedColor;
            break;
            
        case JSKSystemTypeSystem:
            t_borderColor = _systemWallColor;
            t_fillColor = _systemFillColor;
            break;
            
        case JSKSystemType_MaxValue:
            break;
    }
    if (!t_borderColor || !t_fillColor)
        return;
    
    UIBezierPath *t_path = [self pathForSystem:system];
    if (!t_path)
        return;
    
    [t_fillColor setFill];
    [t_borderColor setStroke];
    [t_path fill];
    [t_path stroke];
}

- (JSKSystemType)determineSystemType:(JSKSystem)system
{
    JSKSystemType t_return = JSKSystemType_MaxValue;
    
    switch (system) {
        case JSKSystemAorta:
        case JSKSystemCarotidArteries:
        case JSKSystemCeliacArtery:
        case JSKSystemGonadalArteries:
        case JSKSystemHepaticArtery:
        case JSKSystemIliacArtieries:
        case JSKSystemPulmonaryArtery:
        case JSKSystemRenalArteries:
        case JSKSystemSubclavianArteries:
            t_return = JSKSystemTypeArtery;
            break;
        case JSKSystemGonadalVeins:
        case JSKSystemHepaticPortalVein:
        case JSKSystemHepaticVeins:
        case JSKSystemIliacVeins:
        case JSKSystemInferiorVenaCava:
        case JSKSystemJugularVeins:
        case JSKSystemPulmonaryVein:
        case JSKSystemRenalVeins:
        case JSKSystemSubclavianVeins:
        case JSKSystemSuperiorVenaCava:
            t_return = JSKSystemTypeVein;
            break;
        case JSKSystemGut:
        case JSKSystemHead:
        case JSKSystemHeart:
        case JSKSystemLeftArm:
        case JSKSystemLeftKidney:
        case JSKSystemLeftLeg:
        case JSKSystemLeftLung:
        case JSKSystemLiver:
        case JSKSystemLowerBody:
        case JSKSystemRightArm:
        case JSKSystemRightKidney:
        case JSKSystemRightLeg:
        case JSKSystemRightLung:
            t_return = JSKSystemTypeSystem;
            break;
        case JSKSystem_MaxValue:
            break;
    }
    
    return t_return;
}

- (void)addArteryAnimation:(JSKSystem)system
{
    NSTimeInterval t_time = CACurrentMediaTime();
    CGFloat t_speed = 2.0;
    UIColor *t_color1 = _lightOxygenatedColor;
    UIColor *t_color2 = _oxygenatedColor;
    
    if (system == JSKSystemPulmonaryArtery) {
        t_color1 = _lightDeoxygenatedColor;
        t_color2 = _deoxygenatedColor;
    }
    
    CAShapeLayer *t_layer = [self layerForSystem:system];
    t_layer.strokeColor = t_color1.CGColor;
    CABasicAnimation *t_animation = ({
        CABasicAnimation *t_animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        t_animation.duration = t_speed;
        t_animation.fromValue = [NSNumber numberWithFloat:0.0f];
        t_animation.toValue = [NSNumber numberWithFloat:1.0f];
        t_animation.repeatCount = HUGE_VALF;
        t_animation;
    });
    [t_layer addAnimation:t_animation forKey:@"flow01"];
    [_floorLayer addSublayer:t_layer];
    
    t_layer = [self layerForSystem:system];
    t_layer.strokeColor = t_color2.CGColor;
    t_animation = ({
        CABasicAnimation *t_animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        t_animation.beginTime = t_time + 0.08;
        t_animation.duration = t_speed;
        t_animation.fromValue = [NSNumber numberWithFloat:0.0f];
        t_animation.toValue = [NSNumber numberWithFloat:1.0f];
        t_animation.repeatCount = HUGE_VALF;
        t_animation;
    });
    [t_layer addAnimation:t_animation forKey:@"flow02"];
    [_floorLayer addSublayer:t_layer];
}

- (void)addVeinAnimation:(JSKSystem)system
{
    NSTimeInterval t_time = CACurrentMediaTime();
    CGFloat t_speed = 2.0;
    
    UIColor *t_color1 = _lightDeoxygenatedColor;
    UIColor *t_color2 = _deoxygenatedColor;
    
    if (system == JSKSystemPulmonaryVein) {
        t_color1 = _lightOxygenatedColor;
        t_color2 = _oxygenatedColor;
    }
    
    CAShapeLayer *t_layer = [self layerForSystem:system];
    t_layer.strokeColor = t_color1.CGColor;
    CABasicAnimation *t_animation = ({
        CABasicAnimation *t_animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        t_animation.duration = t_speed;
        t_animation.fromValue = [NSNumber numberWithFloat:0.0f];
        t_animation.toValue = [NSNumber numberWithFloat:1.0f];
        t_animation.repeatCount = HUGE_VALF;
        t_animation;
    });
    [t_layer addAnimation:t_animation forKey:@"flow01"];
    [_floorLayer addSublayer:t_layer];
    
    t_layer = [self layerForSystem:system];
    t_layer.strokeColor = t_color2.CGColor;
    t_animation = ({
        CABasicAnimation *t_animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        t_animation.beginTime = t_time + 0.1;
        t_animation.duration = t_speed;
        t_animation.fromValue = [NSNumber numberWithFloat:0.0f];
        t_animation.toValue = [NSNumber numberWithFloat:1.0f];
        t_animation.repeatCount = HUGE_VALF;
        t_animation;
    });
    [t_layer addAnimation:t_animation forKey:@"flow02"];
    [_floorLayer addSublayer:t_layer];
}

- (void)drawLabels:(CGRect)rect
{
    if (_labelsHidden)
        return;
    
    for (JSKSystem t_system = 0; t_system < JSKSystem_MaxValue; t_system++) {
        NSString *t_string = [self titleForSystem:t_system];
        CGPoint t_origin = [self originForSystem:t_system];
        
        if (t_system == JSKSystemSuperiorVenaCava)
            t_string = NSLocalizedString(@"Superior\nVena Cava", @"Superior\nVena Cava");
        if (t_system == JSKSystemInferiorVenaCava)
            t_string = NSLocalizedString(@"Inferior\nVena Cava", @"Inferior\nVena Cava");
        if (t_system == JSKSystemGonadalArteries || t_system == JSKSystemGonadalVeins)
            t_string = @"";
        
        NSMutableAttributedString *t_attributed = [[NSMutableAttributedString alloc] initWithString:t_string];
        NSRange t_range = NSMakeRange(0, t_string.length);
        [t_attributed addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"Gill Sans" size:14]
                      range:t_range];
        if (self.bounds.size.width <= kPhoneWidth)
            [t_attributed addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:@"Gill Sans" size:10]
                                 range:t_range];

        [t_attributed addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:t_range];
        
        CGSize t_offset = CGSizeMake(4,2);
        switch (t_system) {
            case JSKSystemAorta: {
                CGPoint t_refpoint = [self originForSystem:JSKSystemCeliacArtery];
                t_origin.x = t_refpoint.x;
                t_offset.width = 8;
                t_offset.height = -11;
                break;
            }
            case JSKSystemPulmonaryArtery:
                t_offset.width = -18;
                t_offset.height = -34;
                break;
            case JSKSystemPulmonaryVein:
                t_offset.width = 6;
                t_offset.height = 2;
                break;
            case JSKSystemCarotidArteries:
            case JSKSystemSubclavianArteries:
            case JSKSystemCeliacArtery:
            case JSKSystemRenalArteries:
            case JSKSystemGonadalArteries:
            case JSKSystemIliacArtieries:
                t_offset.width = 8;
                t_offset.height = -11;
                break;
            case JSKSystemHepaticArtery:
                t_offset.width = t_attributed.size.width * -1;
                t_offset.height = (t_attributed.size.height + 4) * -1;
                break;
            case JSKSystemSuperiorVenaCava: {
//                NSMutableParagraphStyle *t_style = [[NSMutableParagraphStyle alloc] init];
//                t_style.alignment = NSTextAlignmentRight;
//                [t_attributed addAttribute:NSParagraphStyleAttributeName value:t_style range:t_range];
                CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
                t_offset.width = (t_attributed.size.width + 6) * -1;
                t_origin.y = t_refPoint.y - 5;
                break;
            }
            case JSKSystemInferiorVenaCava: {
                CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
                t_offset.width = (t_attributed.size.width + 6) * -1;
                t_origin.y = t_refPoint.y + t_attributed.size.height + (t_attributed.size.height / 2) + 5;
                break;
            }
            case JSKSystemJugularVeins:
            case JSKSystemHepaticVeins:
            case JSKSystemGonadalVeins:
                t_offset.width = ((_bufferSize.width + kVesselDiameter + _bufferSize.width) + t_attributed.size.width + 8) * -1;
                t_offset.height = -11;
                break;
            case JSKSystemSubclavianVeins:
            case JSKSystemRenalVeins:
            case JSKSystemIliacVeins: {
                CGPoint t_refPoint = [self originForSystem:JSKSystemSuperiorVenaCava];
                t_origin.x = t_refPoint.x;
                t_offset.width = (t_attributed.size.width + 5) * -1;
                t_offset.height = 11;
                break;
            }
            default:
                break;
        }
        
        [t_attributed drawAtPoint:CGPointMake(t_origin.x + t_offset.width, t_origin.y + t_offset.height)];
    }
}

- (UIBezierPath *)pathForSystem:(JSKSystem)system
{
    UIBezierPath *t_return = nil;
    
    switch (system) {
            
        case JSKSystemHeart: {
            CGFloat t_borderWidth = kWallThickness;
            CGPoint t_origin = [self originForSystem:system];
            CGFloat t_delta = _systemSize.width;
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, t_delta, _systemSize.height);
            UIBezierPath *t_path = [UIBezierPath bezierPathWithRect:t_frame];
            t_path.lineWidth = t_borderWidth;
            [t_path moveToPoint:CGPointMake(CGRectGetMidX(t_frame), t_frame.origin.y + t_borderWidth)];
            [t_path addLineToPoint:CGPointMake(CGRectGetMidX(t_frame), t_frame.origin.y + t_frame.size.height - t_borderWidth)];
            t_return = t_path;
            break;
        }
        
        case JSKSystemPulmonaryArtery: {
            CGFloat t_borderWidth = kVesselDiameter;
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            
            UIBezierPath *t_path = [UIBezierPath bezierPath];
            t_path.lineWidth = t_borderWidth;
            [t_path moveToPoint:CGPointMake(t_origin.x, t_origin.y)];
            
            CGFloat t_delta = kVesselDiameter + _bufferSize.width;
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = _bufferSize.height + kWallThickness + kVesselDiameter + kWallThickness + _bufferSize.height + _systemSize.height + _bufferSize.height;
            t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y - t_delta);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = kVesselDiameter + _bufferSize.width;
            t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = _bufferSize.height + kVesselDiameter;
            t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = _systemTwinSize.width + _bufferSize.width;
            t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y - (_bufferSize.height + kVesselDiameter));
            [t_path moveToPoint:CGPointMake(t_lastPoint.x, t_point.y)];
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            t_lastPoint = t_point;
            
            t_delta = _bufferSize.height + kVesselDiameter;
            t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_return = t_path;
            break;
        }
        
        case JSKSystemLeftLung:
        case JSKSystemRightLung: {
            CGFloat t_borderWidth = kWallThickness;
            CGPoint t_origin = [self originForSystem:system];
            CGFloat t_delta = _systemTwinSize.width;
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, t_delta, _systemSize.height);
            UIBezierPath *t_path = [UIBezierPath bezierPathWithRect:t_frame];
            t_path.lineWidth = t_borderWidth;
            t_return = t_path;
            break;
        }
            
        case JSKSystemPulmonaryVein: {
            CGFloat t_borderWidth = kVesselDiameter;
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            
            UIBezierPath *t_path = [UIBezierPath bezierPath];
            t_path.lineWidth = t_borderWidth;
            [t_path moveToPoint:CGPointMake(t_origin.x, t_origin.y)];
            
            CGFloat t_delta = kVesselDiameter + _bufferSize.height;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = _bufferSize.width + _systemTwinSize.width + _bufferSize.width + kVesselDiameter;
            t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = _bufferSize.height;
            t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = _bufferSize.width + kVesselDiameter;
            t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = _bufferSize.height + kVesselDiameter;
            CGPoint t_refPoint = [self originForSystem:JSKSystemRightLung];
            t_point = CGPointMake(t_refPoint.x + _systemTwinSize.width, t_refPoint.y + _systemTwinSize.height + t_delta);
            [t_path moveToPoint:CGPointMake(t_point.x, t_point.y - t_delta)];
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            t_lastPoint = t_point;
            
            t_return = t_path;
            break;
        }
            
        case JSKSystemAorta: {
            CGFloat t_borderWidth = kVesselDiameter;
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            
            UIBezierPath *t_path = [UIBezierPath bezierPath];
            t_path.lineWidth = t_borderWidth;
            [t_path moveToPoint:CGPointMake(t_origin.x, t_origin.y)];
            
            CGFloat t_delta = kVesselDiameter + _bufferSize.width + _bufferSize.width;
            CGPoint t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            t_refPoint.x += (_systemSize.width + kVesselDiameter + _bufferSize.width);
            t_refPoint.y += (_systemSize.height);
            CGFloat t_minY = t_refPoint.y;
            CGFloat t_maxY = [self originForSystem:JSKSystemIliacArtieries].y;
            t_delta = t_maxY - t_origin.y;
            t_point = CGPointMake(t_lastPoint.x, t_minY);
            CGPoint t_point2 = CGPointMake(t_lastPoint.x, t_maxY);
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            [t_path moveToPoint:CGPointMake(t_lastPoint.x, t_lastPoint.y)];
            [t_path addLineToPoint:CGPointMake(t_point2.x, t_point2.y)];
            t_lastPoint = t_point;
            
            t_return = t_path;
            break;
        }
            
        case JSKSystemCarotidArteries: {
            CGFloat t_borderWidth = kVesselDiameter;
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            
            UIBezierPath *t_path = [UIBezierPath bezierPath];
            t_path.lineWidth = t_borderWidth;
            [t_path moveToPoint:CGPointMake(t_origin.x, t_origin.y)];
            
            CGFloat t_delta = (kVesselDiameter + _bufferSize.width + _bufferSize.width);
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_return = t_path;
            break;
        }
            
        case JSKSystemHead: {
            CGFloat t_borderWidth = kWallThickness;
            CGPoint t_origin = [self originForSystem:system];
            CGFloat t_delta = _systemSize.width;
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, t_delta, _systemSize.height);
            UIBezierPath *t_path = [UIBezierPath bezierPathWithRect:t_frame];
            t_path.lineWidth = t_borderWidth;
            t_return = t_path;
            break;
        }
            
        case JSKSystemJugularVeins: {
            CGFloat t_borderWidth = kVesselDiameter;
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            
            UIBezierPath *t_path = [UIBezierPath bezierPath];
            t_path.lineWidth = t_borderWidth;
            [t_path moveToPoint:CGPointMake(t_origin.x, t_origin.y)];
            
            CGFloat t_delta = (kVesselDiameter + _bufferSize.width) * 2;
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_return = t_path;
            break;
        }
            
        case JSKSystemSuperiorVenaCava: {
            CGFloat t_borderWidth = kVesselDiameter;
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            
            UIBezierPath *t_path = [UIBezierPath bezierPath];
            t_path.lineWidth = t_borderWidth;
            [t_path moveToPoint:CGPointMake(t_origin.x, t_origin.y)];
            
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            CGFloat t_delta = (t_refPoint.y + (_systemSize.height - _bufferSize.height)) - t_origin.y;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = kVesselDiameter + _bufferSize.width + _bufferSize.width + kVesselDiameter;
            t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_return = t_path;
            break;
        }
            
        case JSKSystemSubclavianArteries: {
            CGFloat t_borderWidth = kVesselDiameter;
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            
            UIBezierPath *t_path = [UIBezierPath bezierPath];
            t_path.lineWidth = t_borderWidth;
            [t_path moveToPoint:CGPointMake(t_origin.x, t_origin.y)];
            
            CGFloat t_delta = (kVesselDiameter + _bufferSize.width + _bufferSize.width);
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = _bufferSize.height;
            t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = _bufferSize.width + _systemTwinSize.width;
            t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y - _bufferSize.height);
            [t_path moveToPoint:CGPointMake(t_lastPoint.x, t_lastPoint.y - _bufferSize.height)];
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            t_lastPoint = t_point;
            
            t_delta = _bufferSize.height;
            t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_return = t_path;
            break;
        }
            
        case JSKSystemRightArm:
        case JSKSystemLeftArm: {
            CGFloat t_borderWidth = kWallThickness;
            CGPoint t_origin = [self originForSystem:system];
            CGFloat t_delta = _systemTwinSize.width;
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, t_delta, _systemSize.height);
            UIBezierPath *t_path = [UIBezierPath bezierPathWithRect:t_frame];
            t_path.lineWidth = t_borderWidth;
            t_return = t_path;
            break;
        }
            
        case JSKSystemSubclavianVeins: {
            CGFloat t_borderWidth = kVesselDiameter;
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            
            UIBezierPath *t_path = [UIBezierPath bezierPath];
            t_path.lineWidth = t_borderWidth;
            [t_path moveToPoint:CGPointMake(t_origin.x, t_origin.y)];
            
            CGFloat t_delta = _bufferSize.height + kVesselDiameter;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = t_lastPoint.x - _paddingX;
            t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            t_lastPoint = t_point;
            
            CGPoint t_refPoint = [self originForSystem:JSKSystemLeftArm];
            t_refPoint.y += _systemSize.height;
            t_delta = _bufferSize.height + kVesselDiameter;
            t_point = CGPointMake(t_refPoint.x, t_refPoint.y + t_delta);
            [t_path moveToPoint:CGPointMake(t_refPoint.x, t_refPoint.y)];
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            t_lastPoint = t_point;
            
            t_return = t_path;
            break;
        }
            
        case JSKSystemCeliacArtery: {
            CGFloat t_borderWidth = kVesselDiameter;
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            
            UIBezierPath *t_path = [UIBezierPath bezierPath];
            t_path.lineWidth = t_borderWidth;
            [t_path moveToPoint:CGPointMake(t_origin.x, t_origin.y)];
            
            CGFloat t_delta = (kVesselDiameter + _bufferSize.width + _bufferSize.width);
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = _bufferSize.height;
            t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_return = t_path;
            break;
        }

        case JSKSystemGut: {
            CGFloat t_borderWidth = kWallThickness;
            CGPoint t_origin = [self originForSystem:system];
            CGFloat t_delta = _systemTwinSize.width;
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, t_delta, _systemSize.height);
            UIBezierPath *t_path = [UIBezierPath bezierPathWithRect:t_frame];
            t_path.lineWidth = t_borderWidth;
            t_return = t_path;
            break;
        }
            
        case JSKSystemHepaticPortalVein: {
            CGFloat t_borderWidth = kVesselDiameter;
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            
            UIBezierPath *t_path = [UIBezierPath bezierPath];
            t_path.lineWidth = t_borderWidth;
            [t_path moveToPoint:CGPointMake(t_origin.x, t_origin.y)];
            
            CGFloat t_delta = _bufferSize.height + kVesselDiameter;
            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = _bufferSize.width;
            t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            t_lastPoint = t_point;
            
            t_delta = _bufferSize.height + kVesselDiameter;
            t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y - t_delta);
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            t_lastPoint = t_point;
            
            t_return = t_path;
            break;
        }
            
        case JSKSystemHepaticArtery: {
            CGFloat t_borderWidth = kVesselDiameter;
            CGPoint t_origin = [self originForSystem:system];
            CGPoint t_lastPoint = t_origin;
            
            UIBezierPath *t_path = [UIBezierPath bezierPath];
            t_path.lineWidth = t_borderWidth;
            [t_path moveToPoint:CGPointMake(t_origin.x, t_origin.y)];
            
            CGFloat t_delta = _systemTwinSize.width + _bufferSize.width;
            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_delta = _bufferSize.height;
            t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
            t_lastPoint = t_point;
            [t_path addLineToPoint:CGPointMake(t_point.x, t_point.y)];
            
            t_return = t_path;
            break;
        }
        
        case JSKSystemLiver: {
            CGFloat t_borderWidth = kWallThickness;
            CGPoint t_origin = [self originForSystem:system];
            CGFloat t_delta = _systemTwinSize.width;
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, t_delta, _systemSize.height);
            UIBezierPath *t_path = [UIBezierPath bezierPathWithRect:t_frame];
            t_path.lineWidth = t_borderWidth;
            t_return = t_path;
            break;
        }
//
//        case JSKSystemHepaticVeins: {
//            CGFloat t_borderWidth = kVesselDiameter;
//            UIColor *t_borderColor = _deoxygenatedColor;
//            
//            CGContextSetLineWidth(t_context, t_borderWidth);
//            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
//            
//            CGPoint t_origin = [self originForSystem:system];
//            CGPoint t_lastPoint = t_origin;
//            CGMutablePathRef pathRef = CGPathCreateMutable();
//            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
//            BOOL t_shouldDraw = YES;
//            
//            NSUInteger t_pointCount = 0;
//            CGFloat t_delta = [self systemOriginX] - _paddingX;
//            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
//            t_pointCount += t_delta;
//            if (self.currentPointIndex + t_delta > self.pointIndex) {
//                t_shouldDraw = NO;
//                t_point.x = t_lastPoint.x - t_trim;
//            }
//            self.currentPointIndex += t_delta;
//            t_trim = self.pointIndex - self.currentPointIndex;
//            t_lastPoint = t_point;
//            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//            
//            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
//            
//            CGContextAddPath(t_context, pathRef);
//            CGContextStrokePath(t_context);
//            
//            CGPathRelease(pathRef);
//            break;
//        }
//            
//        case JSKSystemInferiorVenaCava: {
//            CGFloat t_borderWidth = kVesselDiameter;
//            UIColor *t_borderColor = _deoxygenatedColor;
//            
//            CGContextSetLineWidth(t_context, t_borderWidth);
//            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
//            
//            CGPoint t_origin = [self originForSystem:system];
//            CGPoint t_lastPoint = t_origin;
//            CGMutablePathRef pathRef = CGPathCreateMutable();
//            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
//            BOOL t_shouldDraw = YES;
//            
//            NSUInteger t_pointCount = 0;
//            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
//            t_refPoint.y += (_systemSize.height);
//            
//            CGFloat t_minY = t_refPoint.y;
//            CGFloat t_maxY = [self originForSystem:JSKSystemLeftLeg].y + _systemSize.height + _bufferSize.height;
//            
//            CGFloat t_delta = t_maxY - t_origin.y;
//            CGPoint t_point = CGPointMake(t_lastPoint.x, t_minY);
//            CGPoint t_point2 = CGPointZero;
//            t_point2 = CGPointMake(t_lastPoint.x, t_maxY);
//            t_pointCount += t_delta;
//            if (self.currentPointIndex + (t_delta) > self.pointIndex) {
//                t_shouldDraw = NO;
//                if (t_lastPoint.y - t_trim >= t_minY)
//                    t_point.y = t_lastPoint.y - t_trim;
//                t_point2.y = t_lastPoint.y + t_trim;
//            }
//            self.currentPointIndex += t_delta;
//            t_trim = self.pointIndex - self.currentPointIndex;
//            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//            CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_lastPoint.y);
//            CGPathAddLineToPoint(pathRef, nil, t_point2.x, t_point2.y);
//            t_lastPoint = t_point;
//            
//            if (t_shouldDraw) {
//                CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_lastPoint.y);
//                t_delta = [self systemOriginX] - _paddingX;
//                t_point = CGPointMake(t_lastPoint.x + t_delta, t_lastPoint.y);
//                t_pointCount += t_delta;
//                if (self.currentPointIndex + t_delta > self.pointIndex) {
//                    t_shouldDraw = NO;
//                    t_point.x = t_lastPoint.x + t_trim;
//                }
//                self.currentPointIndex += t_delta;
//                t_trim = self.pointIndex - self.currentPointIndex;
//                t_lastPoint = t_point;
//                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//            }
//            
//            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
//            
//            CGContextAddPath(t_context, pathRef);
//            CGContextStrokePath(t_context);
//            
//            CGPathRelease(pathRef);
//            break;
//        }
//            
//        case JSKSystemRenalArteries: {
//            CGFloat t_borderWidth = kVesselDiameter;
//            UIColor *t_borderColor = _oxygenatedColor;
//            
//            CGContextSetLineWidth(t_context, t_borderWidth);
//            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
//            
//            CGPoint t_origin = [self originForSystem:system];
//            CGPoint t_lastPoint = t_origin;
//            CGMutablePathRef pathRef = CGPathCreateMutable();
//            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
//            BOOL t_shouldDraw = YES;
//            
//            NSUInteger t_pointCount = 0;
//            CGFloat t_delta = (kVesselDiameter + _bufferSize.width + _bufferSize.width);
//            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
//            t_pointCount += t_delta;
//            if (self.currentPointIndex + t_delta > self.pointIndex) {
//                t_shouldDraw = NO;
//                t_point.x = t_lastPoint.x - t_trim;
//            }
//            self.currentPointIndex += t_delta;
//            t_trim = self.pointIndex - self.currentPointIndex;
//            t_lastPoint = t_point;
//            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//            
//            if (t_shouldDraw) {
//                t_delta = _bufferSize.height;
//                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
//                t_pointCount += t_delta;
//                if (self.currentPointIndex + t_delta > self.pointIndex) {
//                    t_shouldDraw = NO;
//                    t_point.y = t_lastPoint.y + t_trim;
//                }
//                self.currentPointIndex += t_delta;
//                t_trim = self.pointIndex - self.currentPointIndex;
//                t_lastPoint = t_point;
//                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//            }
//            
//            if (t_shouldDraw) {
//                t_delta = _bufferSize.width + _systemTwinSize.width;
//                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y - _bufferSize.height);
//                t_pointCount += t_delta;
//                if (self.currentPointIndex + t_delta > self.pointIndex) {
//                    t_shouldDraw = NO;
//                    t_point.x = t_lastPoint.x - t_trim;
//                }
//                self.currentPointIndex += t_delta;
//                t_trim = self.pointIndex - self.currentPointIndex;
//                CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_lastPoint.y - _bufferSize.height);
//                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//                t_lastPoint = t_point;
//            }
//            
//            if (t_shouldDraw) {
//                t_delta = _bufferSize.height;
//                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
//                t_pointCount += t_delta;
//                if (self.currentPointIndex + t_delta > self.pointIndex) {
//                    t_shouldDraw = NO;
//                    t_point.y = t_lastPoint.y + t_trim;
//                }
//                self.currentPointIndex += t_delta;
//                t_trim = self.pointIndex - self.currentPointIndex;
//                t_lastPoint = t_point;
//                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//            }
//            
//            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
//            
//            CGContextAddPath(t_context, pathRef);
//            CGContextStrokePath(t_context);
//            
//            CGPathRelease(pathRef);
//            break;
//        }
            
        case JSKSystemRightKidney:
        case JSKSystemLeftKidney: {
            CGFloat t_borderWidth = kWallThickness;
            CGPoint t_origin = [self originForSystem:system];
            CGFloat t_delta = _systemTwinSize.width;
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, t_delta, _systemSize.height);
            UIBezierPath *t_path = [UIBezierPath bezierPathWithRect:t_frame];
            t_path.lineWidth = t_borderWidth;
            t_return = t_path;
            break;
        }
            
//        case JSKSystemRenalVeins: {
//            CGFloat t_borderWidth = kVesselDiameter;
//            UIColor *t_borderColor = _deoxygenatedColor;
//            
//            CGContextSetLineWidth(t_context, t_borderWidth);
//            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
//            
//            CGPoint t_origin = [self originForSystem:system];
//            CGPoint t_lastPoint = t_origin;
//            CGMutablePathRef pathRef = CGPathCreateMutable();
//            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
//            BOOL t_shouldDraw = YES;
//            
//            NSUInteger t_pointCount = 0;
//            CGFloat t_delta = _bufferSize.height + kVesselDiameter;
//            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
//            t_pointCount += t_delta;
//            if (self.currentPointIndex + t_delta > self.pointIndex) {
//                t_shouldDraw = NO;
//                t_point.y = t_lastPoint.y + t_trim;
//            }
//            self.currentPointIndex += t_delta;
//            t_trim = self.pointIndex - self.currentPointIndex;
//            t_lastPoint = t_point;
//            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//            
//            if (t_shouldDraw) {
//                t_delta = t_lastPoint.x - _paddingX;
//                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
//                t_pointCount += t_delta;
//                if (self.currentPointIndex + t_delta > self.pointIndex) {
//                    t_shouldDraw = NO;
//                    t_point.x = t_lastPoint.x - t_trim;
//                }
//                self.currentPointIndex += t_delta;
//                t_trim = self.pointIndex - self.currentPointIndex;
//                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//                t_lastPoint = t_point;
//            }
//            
//            if (t_shouldDraw) {
//                CGPoint t_refPoint = [self originForSystem:JSKSystemLeftKidney];
//                t_refPoint.y += _systemSize.height;
//                t_delta = _bufferSize.height + kVesselDiameter;
//                t_point = CGPointMake(t_refPoint.x, t_refPoint.y + t_delta);
//                t_pointCount += t_delta;
//                if (self.currentPointIndex + t_delta > self.pointIndex) {
//                    t_shouldDraw = NO;
//                    t_point.y = t_refPoint.y + t_trim;
//                }
//                self.currentPointIndex += t_delta;
//                t_trim = self.pointIndex - self.currentPointIndex;
//                CGPathMoveToPoint(pathRef, nil, t_refPoint.x, t_refPoint.y);
//                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//                t_lastPoint = t_point;
//            }
//            
//            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
//            
//            CGContextAddPath(t_context, pathRef);
//            CGContextStrokePath(t_context);
//            
//            CGPathRelease(pathRef);
//            break;
//        }
//            
//        case JSKSystemGonadalArteries: {
//            CGFloat t_borderWidth = kVesselDiameter;
//            UIColor *t_borderColor = _oxygenatedColor;
//            
//            CGContextSetLineWidth(t_context, t_borderWidth);
//            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
//            
//            CGPoint t_origin = [self originForSystem:system];
//            CGPoint t_lastPoint = t_origin;
//            CGMutablePathRef pathRef = CGPathCreateMutable();
//            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
//            BOOL t_shouldDraw = YES;
//            
//            NSUInteger t_pointCount = 0;
//            CGFloat t_delta = (kVesselDiameter + _bufferSize.width + _bufferSize.width);
//            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
//            t_pointCount += t_delta;
//            if (self.currentPointIndex + t_delta > self.pointIndex) {
//                t_shouldDraw = NO;
//                t_point.x = t_lastPoint.x - t_trim;
//            }
//            self.currentPointIndex += t_delta;
//            t_trim = self.pointIndex - self.currentPointIndex;
//            t_lastPoint = t_point;
//            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//            
//            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
//            
//            CGContextAddPath(t_context, pathRef);
//            CGContextStrokePath(t_context);
//            
//            CGPathRelease(pathRef);
//            break;
//        }
            
        case JSKSystemLowerBody: {
            CGFloat t_borderWidth = kWallThickness;
            CGPoint t_origin = [self originForSystem:system];
            CGFloat t_delta = _systemSize.width;
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, t_delta, _systemSize.height);
            UIBezierPath *t_path = [UIBezierPath bezierPathWithRect:t_frame];
            t_path.lineWidth = t_borderWidth;
            t_return = t_path;
            break;
        }
            
//        case JSKSystemGonadalVeins: {
//            CGFloat t_borderWidth = kVesselDiameter;
//            UIColor *t_borderColor = _deoxygenatedColor;
//            
//            CGContextSetLineWidth(t_context, t_borderWidth);
//            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
//            
//            CGPoint t_origin = [self originForSystem:system];
//            CGPoint t_lastPoint = t_origin;
//            CGMutablePathRef pathRef = CGPathCreateMutable();
//            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
//            BOOL t_shouldDraw = YES;
//            
//            NSUInteger t_pointCount = 0;
//            CGFloat t_delta = [self systemOriginX] - _paddingX;
//            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
//            t_pointCount += t_delta;
//            if (self.currentPointIndex + t_delta > self.pointIndex) {
//                t_shouldDraw = NO;
//                t_point.x = t_lastPoint.x - t_trim;
//            }
//            self.currentPointIndex += t_delta;
//            t_trim = self.pointIndex - self.currentPointIndex;
//            t_lastPoint = t_point;
//            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//            
//            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
//            
//            CGContextAddPath(t_context, pathRef);
//            CGContextStrokePath(t_context);
//            
//            CGPathRelease(pathRef);
//            break;
//        }
//            
//        case JSKSystemIliacArtieries: {
//            CGFloat t_borderWidth = kVesselDiameter;
//            UIColor *t_borderColor = _oxygenatedColor;
//            
//            CGContextSetLineWidth(t_context, t_borderWidth);
//            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
//            
//            CGPoint t_origin = [self originForSystem:system];
//            CGPoint t_lastPoint = t_origin;
//            CGMutablePathRef pathRef = CGPathCreateMutable();
//            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
//            BOOL t_shouldDraw = YES;
//            
//            NSUInteger t_pointCount = 0;
//            CGFloat t_delta = (kVesselDiameter + _bufferSize.width + _bufferSize.width);
//            CGPoint t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
//            t_pointCount += t_delta;
//            if (self.currentPointIndex + t_delta > self.pointIndex) {
//                t_shouldDraw = NO;
//                t_point.x = t_lastPoint.x - t_trim;
//            }
//            self.currentPointIndex += t_delta;
//            t_trim = self.pointIndex - self.currentPointIndex;
//            t_lastPoint = t_point;
//            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//            
//            if (t_shouldDraw) {
//                t_delta = _bufferSize.height;
//                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
//                t_pointCount += t_delta;
//                if (self.currentPointIndex + t_delta > self.pointIndex) {
//                    t_shouldDraw = NO;
//                    t_point.y = t_lastPoint.y + t_trim;
//                }
//                self.currentPointIndex += t_delta;
//                t_trim = self.pointIndex - self.currentPointIndex;
//                t_lastPoint = t_point;
//                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//            }
//            
//            if (t_shouldDraw) {
//                t_delta = _bufferSize.width + _systemTwinSize.width;
//                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y - _bufferSize.height);
//                t_pointCount += t_delta;
//                if (self.currentPointIndex + t_delta > self.pointIndex) {
//                    t_shouldDraw = NO;
//                    t_point.x = t_lastPoint.x - t_trim;
//                }
//                self.currentPointIndex += t_delta;
//                t_trim = self.pointIndex - self.currentPointIndex;
//                CGPathMoveToPoint(pathRef, nil, t_lastPoint.x, t_lastPoint.y - _bufferSize.height);
//                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//                t_lastPoint = t_point;
//            }
//            
//            if (t_shouldDraw) {
//                t_delta = _bufferSize.height;
//                t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
//                t_pointCount += t_delta;
//                if (self.currentPointIndex + t_delta > self.pointIndex) {
//                    t_shouldDraw = NO;
//                    t_point.y = t_lastPoint.y + t_trim;
//                }
//                self.currentPointIndex += t_delta;
//                t_trim = self.pointIndex - self.currentPointIndex;
//                t_lastPoint = t_point;
//                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//            }
//            
//            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
//            
//            CGContextAddPath(t_context, pathRef);
//            CGContextStrokePath(t_context);
//            
//            CGPathRelease(pathRef);
//            break;
//        }
            
        case JSKSystemRightLeg:
        case JSKSystemLeftLeg: {
            CGFloat t_borderWidth = kWallThickness;
            CGPoint t_origin = [self originForSystem:system];
            CGFloat t_delta = _systemTwinSize.width;
            CGRect t_frame = CGRectMake(t_origin.x, t_origin.y, t_delta, _systemSize.height);
            UIBezierPath *t_path = [UIBezierPath bezierPathWithRect:t_frame];
            t_path.lineWidth = t_borderWidth;
            t_return = t_path;
            break;
        }
            
//        case JSKSystemIliacVeins: {
//            CGFloat t_borderWidth = kVesselDiameter;
//            UIColor *t_borderColor = _deoxygenatedColor;
//            
//            CGContextSetLineWidth(t_context, t_borderWidth);
//            CGContextSetStrokeColorWithColor(t_context, t_borderColor.CGColor);
//            
//            CGPoint t_origin = [self originForSystem:system];
//            CGPoint t_lastPoint = t_origin;
//            CGMutablePathRef pathRef = CGPathCreateMutable();
//            CGPathMoveToPoint(pathRef, nil, t_origin.x, t_origin.y);
//            BOOL t_shouldDraw = YES;
//            
//            NSUInteger t_pointCount = 0;
//            CGFloat t_delta = _bufferSize.height;
//            CGPoint t_point = CGPointMake(t_lastPoint.x, t_lastPoint.y + t_delta);
//            t_pointCount += t_delta;
//            if (self.currentPointIndex + t_delta > self.pointIndex) {
//                t_shouldDraw = NO;
//                t_point.y = t_lastPoint.y + t_trim;
//            }
//            self.currentPointIndex += t_delta;
//            t_trim = self.pointIndex - self.currentPointIndex;
//            t_lastPoint = t_point;
//            CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//            
//            if (t_shouldDraw) {
//                t_delta = t_lastPoint.x - _paddingX;
//                t_point = CGPointMake(t_lastPoint.x - t_delta, t_lastPoint.y);
//                t_pointCount += t_delta;
//                if (self.currentPointIndex + t_delta > self.pointIndex) {
//                    t_shouldDraw = NO;
//                    t_point.x = t_lastPoint.x - t_trim;
//                }
//                self.currentPointIndex += t_delta;
//                t_trim = self.pointIndex - self.currentPointIndex;
//                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//                t_lastPoint = t_point;
//            }
//            
//            if (t_shouldDraw) {
//                CGPoint t_refPoint = [self originForSystem:JSKSystemLeftLeg];
//                t_refPoint.y += _systemSize.height;
//                t_delta = _bufferSize.height + kVesselDiameter;
//                t_point = CGPointMake(t_refPoint.x, t_refPoint.y + t_delta);
//                t_pointCount += t_delta;
//                if (self.currentPointIndex + t_delta > self.pointIndex) {
//                    t_shouldDraw = NO;
//                    t_point.y = t_refPoint.y + t_trim;
//                }
//                self.currentPointIndex += t_delta;
//                t_trim = self.pointIndex - self.currentPointIndex;
//                CGPathMoveToPoint(pathRef, nil, t_refPoint.x, t_refPoint.y);
//                CGPathAddLineToPoint(pathRef, nil, t_point.x, t_point.y);
//                t_lastPoint = t_point;
//            }
//            
//            [t_magicNumbers setValue:[NSNumber numberWithUnsignedInteger:t_pointCount] forKey:[NSString stringWithFormat:@"%02d", system]];
//            
//            CGContextAddPath(t_context, pathRef);
//            CGContextStrokePath(t_context);
//            
//            CGPathRelease(pathRef);
//            break;
//        }
            
        case JSKSystem_MaxValue:
            break;
    }
    
    return t_return;
}

- (CAShapeLayer *)layerForSystem:(JSKSystem)system
{
    CAShapeLayer *t_return = nil;
    
    switch (system) {
            
        case JSKSystemHeart: {
            UIColor *t_strokeColor = [UIColor clearColor];
            UIColor *t_fillColor = [UIColor colorWithRed:0.5 green:0.4 blue:0.4 alpha:0.4];
            UIBezierPath *t_path = [self pathForSystem:system];
            t_return = ({
                CAShapeLayer *t_layer = [CAShapeLayer layer];
                t_layer.lineWidth = t_path.lineWidth;
                t_layer.strokeColor = t_strokeColor.CGColor;
                t_layer.fillColor = t_fillColor.CGColor;
                t_layer.path = t_path.CGPath;
                t_layer;
            });
            break;
        }
            
        case JSKSystemAorta:
        case JSKSystemCarotidArteries:
        case JSKSystemCeliacArtery:
        case JSKSystemGonadalArteries:
        case JSKSystemHepaticArtery:
        case JSKSystemIliacArtieries:
        case JSKSystemPulmonaryArtery:
        case JSKSystemRenalArteries:
        case JSKSystemSubclavianArteries:
        case JSKSystemGonadalVeins:
        case JSKSystemHepaticPortalVein:
        case JSKSystemHepaticVeins:
        case JSKSystemIliacVeins:
        case JSKSystemInferiorVenaCava:
        case JSKSystemJugularVeins:
        case JSKSystemPulmonaryVein:
        case JSKSystemRenalVeins:
        case JSKSystemSubclavianVeins:
        case JSKSystemSuperiorVenaCava: {
            UIBezierPath *t_path = [self pathForSystem:system];
            t_return = ({
                CAShapeLayer *t_layer = [CAShapeLayer layer];
                t_layer.lineWidth = t_path.lineWidth;
                t_layer.fillColor = [UIColor clearColor].CGColor;
                t_layer.path = t_path.CGPath;
                t_layer;
            });
            break;
        }
        
        case JSKSystem_MaxValue:
            break;
    }
    
    return t_return;
}

- (NSString *)titleForSystem:(JSKSystem)system
{
    NSString *t_return = nil;
    switch (system) {
        case JSKSystemHeart:
            t_return = NSLocalizedString(@"Heart", @"Heart");
            break;
            
        case JSKSystemPulmonaryArtery:
            t_return = NSLocalizedString(@"Pulmonary Artery", @"Pulmonary Artery");
            break;
            
        case JSKSystemLeftLung:
            t_return = NSLocalizedString(@"Left Lung", @"Left Lung");
            break;
            
        case JSKSystemRightLung:
            t_return = NSLocalizedString(@"Right Lung", @"Right Lung");
            break;
            
        case JSKSystemPulmonaryVein:
            t_return = NSLocalizedString(@"Pulmonary Vein", @"Pulmonary Vein");
            break;
            
        case JSKSystemAorta:
            t_return = NSLocalizedString(@"Aorta", @"Aorta");
            break;
            
        case JSKSystemCarotidArteries:
            t_return = NSLocalizedString(@"Carotid Arteries", @"Carotid Arteries");
            break;
            
        case JSKSystemHead:
            t_return = NSLocalizedString(@"Head", @"Head");
            break;
            
        case JSKSystemJugularVeins:
            t_return = NSLocalizedString(@"Jugular Veins", @"Jugular Veins");
            break;
            
        case JSKSystemSuperiorVenaCava:
            t_return = NSLocalizedString(@"Superior Vena Cava", @"Superior Vena Cava");
            break;
            
        case JSKSystemSubclavianArteries:
            t_return = NSLocalizedString(@"Subclavian Arteries", @"Subclavian Arteries");
            break;
            
        case JSKSystemRightArm:
            t_return = NSLocalizedString(@"Right Arm", @"Right Arm");
            break;
            
        case JSKSystemLeftArm:
            t_return = NSLocalizedString(@"Left Arm", @"Left Arm");
            break;
            
        case JSKSystemSubclavianVeins:
            t_return = NSLocalizedString(@"Subclavian Veins", @"Subclavian Veins");
            break;
            
        case JSKSystemCeliacArtery:
            t_return = NSLocalizedString(@"Celiac Artery", @"Celiac Artery");
            break;
            
        case JSKSystemGut:
            t_return = NSLocalizedString(@"Gut", @"Gut");
            break;
            
        case JSKSystemHepaticPortalVein:
            t_return = NSLocalizedString(@"Hepatic Portal Vein", @"Hepatic Portal Vein");
            break;
            
        case JSKSystemHepaticArtery:
            t_return = NSLocalizedString(@"Hepatic Artery", @"Hepatic Artery");
            break;
            
        case JSKSystemLiver:
            t_return = NSLocalizedString(@"Liver", @"Liver");
            break;
            
        case JSKSystemHepaticVeins:
            t_return = NSLocalizedString(@"Hepatic Veins", @"Hepatic Veins");
            break;
            
        case JSKSystemInferiorVenaCava:
            t_return = NSLocalizedString(@"Inferior Vena Cava", @"Inferior Vena Cava");
            break;
            
        case JSKSystemRenalArteries:
            t_return = NSLocalizedString(@"Renal Arteries", @"Renal Arteries");
            break;
            
        case JSKSystemRightKidney:
            t_return = NSLocalizedString(@"Right Kidney", @"Right Kidney");
            break;
            
        case JSKSystemLeftKidney:
            t_return = NSLocalizedString(@"Left Kidney", @"Left Kidney");
            break;
            
        case JSKSystemRenalVeins:
            t_return = NSLocalizedString(@"Renal Veins", @"Renal Veins");
            break;
            
        case JSKSystemGonadalArteries:
            t_return = NSLocalizedString(@"Gonadal Arteries", @"Gonadal Arteries");
            break;
            
        case JSKSystemLowerBody:
            t_return = NSLocalizedString(@"Lower Body", @"Lower Body");
            break;
            
        case JSKSystemGonadalVeins:
            t_return = NSLocalizedString(@"Gonadal Veins", @"Gonadal Veins");
            break;
            
        case JSKSystemIliacArtieries:
            t_return = NSLocalizedString(@"Iliac Arteries", @"Iliac Arteries");
            break;
            
        case JSKSystemRightLeg:
            t_return = NSLocalizedString(@"Right Leg", @"Right Leg");
            break;
            
        case JSKSystemLeftLeg:
            t_return = NSLocalizedString(@"Left Leg", @"Left Leg");
            break;
            
        case JSKSystemIliacVeins:
            t_return = NSLocalizedString(@"Iliac Veins", @"Iliac Veins");
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
            CGFloat t_y = t_refPoint.y + (_systemSize.height * 3) + ((_bufferSize.height + kVesselDiameter + _bufferSize.height) * 3) + (kVesselDiameter + _bufferSize.height);
            t_return = CGPointMake([self systemOriginX], t_y);
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
            CGFloat t_delta = (_bufferSize.height + kVesselDiameter + _bufferSize.height) + _systemSize.height;
            t_return = CGPointMake(t_heartPoint.x, t_heartPoint.y - t_delta);
            break;
        }
        
        case JSKSystemRightLung: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLeftLung];
            t_return = CGPointMake([self systemTwinOriginX], t_refPoint.y);
            break;
        }
        
        case JSKSystemPulmonaryVein: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLeftLung];
            t_return = CGPointMake(t_refPoint.x + _systemTwinSize.width, t_refPoint.y + _systemSize.height);
            break;
        }
            
        case JSKSystemAorta: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            t_return = CGPointMake(t_refPoint.x + _systemSize.width, t_refPoint.y + _systemSize.height);
            break;
        }
        
        case JSKSystemCarotidArteries: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            t_return = CGPointMake(t_refPoint.x + _systemSize.width + (kVesselDiameter + _bufferSize.width + _bufferSize.width), t_refPoint.y + _systemSize.height);
            break;
        }
    
        case JSKSystemHead:
            t_return = CGPointMake([self systemOriginX], kWallThickness + kPaddingY);
            break;
            
        case JSKSystemJugularVeins: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            t_return = CGPointMake([self systemOriginX], t_refPoint.y + _systemSize.height);
            break;
        }
            
        case JSKSystemSuperiorVenaCava: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemJugularVeins];
            t_return = CGPointMake(_paddingX, t_refPoint.y);
            break;
        }
            
        case JSKSystemSubclavianArteries: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemCarotidArteries];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _bufferSize.height + kVesselDiameter);
            break;
        }
            
        case JSKSystemRightArm:{
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            t_return = CGPointMake([self systemTwinOriginX], t_refPoint.y + (_systemSize.height + _bufferSize.height + kVesselDiameter + _bufferSize.height));
            break;
        }
            
        case JSKSystemLeftArm: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHead];
            t_return = CGPointMake([self systemOriginX], t_refPoint.y + (_systemSize.height + _bufferSize.height + kVesselDiameter + _bufferSize.height));
            break;
        }
            
        case JSKSystemSubclavianVeins: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemRightArm];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height);
            break;
        }
        
        case JSKSystemCeliacArtery: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            t_return = CGPointMake(t_refPoint.x + _systemSize.width + (kVesselDiameter + _bufferSize.width) + _bufferSize.width, t_refPoint.y + _systemSize.height + _bufferSize.height + kVesselDiameter);
            break;
        }
            
        case JSKSystemGut: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHeart];
            t_return = CGPointMake([self systemTwinOriginX], t_refPoint.y + _systemSize.height + _bufferSize.height + kVesselDiameter + _bufferSize.height);
            break;
        }
        
        case JSKSystemHepaticPortalVein: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemGut];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height);
            break;
        }
            
        case JSKSystemHepaticArtery: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemGut];
            t_return = CGPointMake(t_refPoint.x + _systemTwinSize.width, t_refPoint.y - _bufferSize.height);
            break;
        }
            
        case JSKSystemLiver: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemGut];
            t_return = CGPointMake([self systemOriginX], t_refPoint.y);
            break;
        }
            
        case JSKSystemHepaticVeins: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLiver];
            t_return = CGPointMake([self systemOriginX], t_refPoint.y + _systemSize.height);
            break;
        }
            
        case JSKSystemInferiorVenaCava: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemHepaticVeins];
            t_return = CGPointMake(_paddingX, t_refPoint.y);
            break;
        }
            
        case JSKSystemRenalArteries: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemCeliacArtery];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height + (_bufferSize.height + kVesselDiameter + _bufferSize.height) + _bufferSize.height);
            break;
        }
        
        case JSKSystemRightKidney: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemRenalArteries];
            t_return = CGPointMake([self systemTwinOriginX], t_refPoint.y + _bufferSize.height);
            break;
        }
        
        case JSKSystemLeftKidney: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemRenalArteries];
            t_return = CGPointMake([self systemOriginX], t_refPoint.y + _bufferSize.height);
            break;
        }
        
        case JSKSystemRenalVeins: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemRightKidney];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height);
            break;
        }
        
        case JSKSystemGonadalArteries: {
            CGPoint t_renalVeinPoint = [self originForSystem:JSKSystemRenalVeins];
            CGPoint t_renalArteryPoint = [self originForSystem:JSKSystemRenalArteries];
            t_return = CGPointMake(t_renalArteryPoint.x, t_renalVeinPoint.y + _bufferSize.height + kVesselDiameter + _bufferSize.height);
            break;
        }
        
        case JSKSystemLowerBody: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLeftKidney];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height + _bufferSize.height + kVesselDiameter + _bufferSize.height);
            break;
        }
            
        case JSKSystemGonadalVeins: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemLowerBody];
            t_return = CGPointMake([self systemOriginX], t_refPoint.y + _systemSize.height);
            break;
        }
        
        case JSKSystemIliacArtieries: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemGonadalArteries];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height + _bufferSize.height);
            break;
        }
        
        case JSKSystemRightLeg: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemIliacArtieries];
            CGFloat t_deltaY = (_bufferSize.height);
            t_return = CGPointMake([self systemTwinOriginX], t_refPoint.y + t_deltaY);
            break;
        }
            
        case JSKSystemLeftLeg: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemRightLeg];
            t_return = CGPointMake([self systemOriginX], t_refPoint.y);
            break;
        }
            
        case JSKSystemIliacVeins: {
            CGPoint t_refPoint = [self originForSystem:JSKSystemRightLeg];
            t_return = CGPointMake(t_refPoint.x, t_refPoint.y + _systemSize.height);
            break;
        }
            
        case JSKSystem_MaxValue:
            break;
    }
    return t_return;
}

- (CGFloat)systemOriginX
{
    return _paddingX + ((kVesselDiameter + _bufferSize.width) * 2);
}

- (CGFloat)systemTwinWidth {
    return (_systemSize.width / 2) - (_bufferSize.width / 2);
}

- (CGFloat)systemTwinOriginX
{
    return [self systemOriginX] + [self systemTwinWidth] + _bufferSize.width;
}

@end
