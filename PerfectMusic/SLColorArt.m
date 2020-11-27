//  SLColorArt.m
//  ColorArt
//
//  Created by Aaron Brethorst on 12/11/12.
//
// Copyright (C) 2012 Panic Inc. Code by Wade Cosgrove. All rights reserved.
//
// Redistribution and use, with or without modification, are permitted provided that the following conditions are met:
//
// - Redistributions must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
// - Neither the name of Panic Inc nor the names of its contributors may be used to endorse or promote works derived from this software without specific prior written permission from Panic Inc.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL PANIC INC BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "SLColorArt.h"
#import "math.h"

#define kAnalyzedBackgroundColor @"kAnalyzedBackgroundColor"
#define kAnalyzedPrimaryColor @"kAnalyzedPrimaryColor"
#define kAnalyzedSecondaryColor @"kAnalyzedSecondaryColor"

@interface SLColorArt ()
@property(nonatomic, copy) UIImage *image;
@property(retain, readwrite) UIColor *backgroundColor;
@property(retain, readwrite) UIColor *primaryColor;
@property(retain, readwrite) UIColor *secondaryColor;
@property(nonatomic, readwrite) NSInteger randomColorThreshold;
@end

@interface UIImage (Scale)
- (UIImage*)scaledToSize: (CGSize)newSize;
@end

@interface UIColor (UIColor)
- (BOOL)isDarkColor;
- (BOOL)isDistinct: (UIColor*)compareColor;
- (UIColor*)colorWithMinimumSaturation: (CGFloat)saturation;
- (BOOL)isBlackOrWhite;
- (BOOL)isContrastingColor: (UIColor*)color;
@end

@interface SLCountedColor: NSObject
@property (assign) NSUInteger count;
@property (strong) UIColor *color;
- (id)initWithColor: (UIColor*)color count: (NSUInteger)count;
@end

@implementation SLColorArt

typedef struct RGBAPixel
{
    Byte red;
    Byte green;
    Byte blue;
    Byte alpha;
    
} RGBAPixel;

- (id)initWithImage: (UIImage*)image
{
	self = [super init];
	
	if(self)
	{
		self.randomColorThreshold = 2;
        if(image.size.width > 128) self.image = [image scaledToSize: CGSizeMake(128, 128)];
        else self.image = image;
        [self processImage];
	}
	
	return self;
}

- (void)processImage
{
	NSDictionary *colors = [self analyzeImage: self.image];

    self.backgroundColor = [colors objectForKey: kAnalyzedBackgroundColor];
    self.primaryColor = [colors objectForKey: kAnalyzedPrimaryColor];
    self.secondaryColor = [colors objectForKey: kAnalyzedSecondaryColor];
}

- (NSDictionary*)analyzeImage: (UIImage*)image
{
	NSArray *imageColors = nil;
	UIColor *backgroundColor = [self findEdgeColor: image imageColors: &imageColors];
	UIColor *primaryColor = nil;
	UIColor *secondaryColor = nil;

	if(!backgroundColor) backgroundColor = [UIColor whiteColor];

	BOOL darkBackground = [backgroundColor isDarkColor];
	[self findTextColors: imageColors primaryColor: &primaryColor secondaryColor: &secondaryColor backgroundColor: backgroundColor];

	if(!primaryColor)
	{
		if(darkBackground) primaryColor = [UIColor whiteColor];
		else primaryColor = [UIColor blackColor];
	}
	
	if(!secondaryColor)
	{
		if(darkBackground) secondaryColor = [UIColor whiteColor];
		else secondaryColor = [UIColor blackColor];
	}

	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [dict setObject: backgroundColor forKey: kAnalyzedBackgroundColor];
    [dict setObject: primaryColor forKey: kAnalyzedPrimaryColor];
    [dict setObject: secondaryColor forKey: kAnalyzedSecondaryColor];

	return [NSDictionary dictionaryWithDictionary: dict];
}

- (UIColor*)findEdgeColor: (UIImage*)image imageColors: (NSArray**)colors
{
	CGImageRef imageRep = image.CGImage;
	
	NSUInteger pixelRange = 8;
    NSUInteger scale = 256 / pixelRange;
    NSUInteger rawImageColors[pixelRange][pixelRange][pixelRange];
    NSUInteger rawEdgeColors[pixelRange][pixelRange][pixelRange];
    
    for(NSUInteger b = 0; b < pixelRange; b++)
	{
        for(NSUInteger g = 0; g < pixelRange; g++)
		{
            for(NSUInteger r = 0; r < pixelRange; r++)
			{
                rawImageColors[r][g][b] = 0;
                rawEdgeColors[r][g][b] = 0;
            }
        }
    }
    
    NSInteger width = CGImageGetWidth(imageRep);// [imageRep pixelsWide];
	NSInteger height = CGImageGetHeight(imageRep); //[imageRep pixelsHigh];

    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, cs, kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, image.CGImage);
    CGColorSpaceRelease(cs);
    const RGBAPixel *pixels = (const RGBAPixel*)CGBitmapContextGetData(bmContext);
	int edgeThreshold = 5;
    for (NSUInteger y = 0; y < height; y++)
    {
        for (NSUInteger x = 0; x < width; x++)
        {
            const NSUInteger index = x + y * width;
            RGBAPixel pixel = pixels[index];
            Byte r = pixel.red / scale;
            Byte g = pixel.green / scale;
            Byte b = pixel.blue / scale;
            rawImageColors[r][g][b] = rawImageColors[r][g][b] + 1;
            if(x < edgeThreshold || x > width - edgeThreshold || y < edgeThreshold || y > height - edgeThreshold)
				rawEdgeColors[r][g][b] = rawEdgeColors[r][g][b] + 1;
        }
    }
    CGContextRelease(bmContext);

    NSMutableArray* imageColors = [NSMutableArray array];
    NSMutableArray* edgeColors = [NSMutableArray array];
    
    for(NSUInteger b = 0; b < pixelRange; b++)
	{
        for(NSUInteger g = 0; g < pixelRange; g++)
		{
            for(NSUInteger r = 0; r < pixelRange; r++)
			{
                NSUInteger count = rawImageColors[r][g][b];
                if(count > self.randomColorThreshold)
				{
                    UIColor* color = [UIColor colorWithRed: r / (CGFloat)pixelRange green: g / (CGFloat)pixelRange blue: b / (CGFloat)pixelRange alpha: 1];
                    SLCountedColor* countedColor = [[SLCountedColor alloc] initWithColor: color count: count];
                    [imageColors addObject: countedColor];
                }
                
                count = rawEdgeColors[r][g][b];
                if(count > self.randomColorThreshold)
				{
                    UIColor* color = [UIColor colorWithRed: r / (CGFloat)pixelRange green: g / (CGFloat)pixelRange blue: b / (CGFloat)pixelRange alpha: 1];
                    SLCountedColor* countedColor = [[SLCountedColor alloc] initWithColor: color count: count];
                    [edgeColors addObject: countedColor];
                }
            }
        }
    }
	*colors = imageColors;
    
    NSMutableArray* sortedColors = edgeColors;
	[sortedColors sortUsingSelector: @selector(compare:)];

	SLCountedColor *proposedEdgeColor = nil;
	if([sortedColors count] > 0)
	{
		proposedEdgeColor = [sortedColors objectAtIndex: 0];
		if([proposedEdgeColor.color isBlackOrWhite]) // want to choose color over black/white so we keep looking
		{
			for(NSInteger i = 1; i < [sortedColors count]; i++)
			{
				SLCountedColor *nextProposedColor = [sortedColors objectAtIndex: i];
				if(((double)nextProposedColor.count / (double)proposedEdgeColor.count) > 0.4) // make sure the second choice color is 40% as common as the first choice
				{
					if(![nextProposedColor.color isBlackOrWhite])
					{
						proposedEdgeColor = nextProposedColor;
						break;
					}
				}
				else break; // reached color threshold less than 40% of the original proposed edge color so bail
			}
		}
	}
	return proposedEdgeColor.color;
}

- (void)findTextColors: (NSArray*)colors primaryColor: (UIColor**)primaryColor secondaryColor: (UIColor**)secondaryColor backgroundColor: (UIColor*)backgroundColor
{
	UIColor *curColor = nil;
	NSMutableArray *sortedColors = [NSMutableArray arrayWithCapacity: [colors count]];
	BOOL findDarkTextColor = ![backgroundColor isDarkColor];

	for(SLCountedColor* countedColor in colors)
	{
		curColor = [countedColor.color colorWithMinimumSaturation: 0.15];

		if([curColor isDarkColor] == findDarkTextColor)
		{
			NSUInteger colorCount = countedColor.count;

			SLCountedColor *container = [[SLCountedColor alloc] initWithColor: curColor count: colorCount];
			[sortedColors addObject: container];
		}
	}

	[sortedColors sortUsingSelector: @selector(compare:)];

	for(SLCountedColor *curContainer in sortedColors)
	{
		curColor = curContainer.color;

		if(!*primaryColor)
		{
			if([curColor isContrastingColor: backgroundColor]) *primaryColor = curColor;
		}
		else if(!*secondaryColor)
		{
			if(![*primaryColor isDistinct:curColor] || ![curColor isContrastingColor: backgroundColor]) continue;

			*secondaryColor = curColor;
			break;
		}
	}
}

@end

@implementation UIColor (UIColor)

- (BOOL)isDarkColor
{
	UIColor *convertedColor = self;
	CGFloat r, g, b, a;

	[convertedColor getRed: &r green: &g blue: &b alpha: &a];

	CGFloat lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;

	if(lum < 0.5) return YES;
	else return NO;
}

- (BOOL)isDistinct: (UIColor*)compareColor
{
	UIColor *convertedColor = self;
	UIColor *convertedCompareColor = compareColor;
	CGFloat r, g, b, a;
	CGFloat r1, g1, b1, a1;

	[convertedColor getRed: &r green: &g blue: &b alpha: &a];
	[convertedCompareColor getRed: &r1 green: &g1 blue:&b1 alpha: &a1];

	CGFloat threshold = 0.25; //.15

	if(fabs(r - r1) > threshold || fabs(g - g1) > threshold || fabs(b - b1) > threshold || fabs(a - a1) > threshold)
	{
		// check for grays, prevent multiple gray colors
		if(fabs(r - g) < 0.03 && fabs(r - b) < 0.03)
		{
			if(fabs(r1 - g1) < 0.03 && fabs(r1 - b1) < 0.03) return NO;
		}
		return YES;
	}
	return NO;
}

- (UIColor*)colorWithMinimumSaturation: (CGFloat)minSaturation
{
	UIColor *tempColor = self;

	if(tempColor)
	{
		CGFloat hue = 0.0;
		CGFloat saturation = 0.0;
		CGFloat brightness = 0.0;
		CGFloat alpha = 0.0;

		[tempColor getHue: &hue saturation: &saturation brightness: &brightness alpha: &alpha];

		if(saturation < minSaturation) return [UIColor colorWithHue: hue saturation: minSaturation brightness: brightness alpha: alpha];
	}
	return self;
}

- (BOOL)isBlackOrWhite
{
	if(self)
	{
		CGFloat r, g, b, a;

		[self getRed: &r green: &g blue: &b alpha: &a];

		if(r > 0.91 && g > 0.91 && b > 0.91 || r < 0.09 && g < 0.09 && b < 0.09) return YES;
	}
	return NO;
}

- (BOOL)isContrastingColor: (UIColor*)color
{
	UIColor *backgroundColor = self;
	UIColor *foregroundColor = color;

	if(backgroundColor && foregroundColor)
	{
		CGFloat br, bg, bb, ba;
		CGFloat fr, fg, fb, fa;

		[backgroundColor getRed: &br green: &bg blue: &bb alpha: &ba];
		[foregroundColor getRed: &fr green: &fg blue: &fb alpha: &fa];

		CGFloat bLum = 0.2126 * br + 0.7152 * bg + 0.0722 * bb;
		CGFloat fLum = 0.2126 * fr + 0.7152 * fg + 0.0722 * fb;

		CGFloat contrast = 0;

		if(bLum > fLum) contrast = (bLum + 0.05) / (fLum + 0.05);
		else contrast = (fLum + 0.05) / (bLum + 0.05);

		return contrast > 1.6; //return contrast > 3.0; //3-4.5 W3C recommends 3:1 ratio, but that filters too many colors
	}
	return YES;
}

@end

@implementation UIColor (distanceFromColor)

- (double)distanceFromColor: (UIColor*)color // from 0 to 1
{
	if(color)
	{
		CGFloat r1, g1, b1;
		CGFloat r2, g2, b2;
		
		[self getRed: &r1 green: &g1 blue: &b1 alpha: nil];
		[color getRed: &r2 green: &g2 blue: &b2 alpha: nil];

		return sqrt(pow(fabs(r1 - r2), 2) + pow(fabs(g1 - g2), 2) + pow(fabs(b1 - b2), 2)) / sqrt(3);
	}
	else return 1;
}

@end

@implementation SLCountedColor

- (id)initWithColor: (UIColor*)color count: (NSUInteger)count
{
	self = [super init];

	if(self)
	{
		self.color = color;
		self.count = count;
	}
	return self;
}

- (NSComparisonResult)compare: (SLCountedColor*)object
{
	if([object isKindOfClass: [SLCountedColor class]])
	{
		if(self.count < object.count) return NSOrderedDescending;
		else if(self.count == object.count) return NSOrderedSame;
	}

	return NSOrderedAscending;
}

@end

@implementation UIImage (Scale)

- (UIImage*)scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect: CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end