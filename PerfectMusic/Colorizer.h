#import "SLColorArt.h" 

@interface Colorizer : NSObject
{
    SLColorArt *_colorArt;
    NSString* _title;
    UIColor *_oldBackgroundColor;
    double _backgroundColorChangeDuration;
}
+ (instancetype)sharedInstance;
- (void)generateColorsForArtwork: (UIImage*)artworkImage withTitle: (NSString*)title;
- (UIColor*)backgroundColor;
- (UIColor*)primaryColor;
- (UIColor*)secondaryColor;
- (double)backgroundColorChangeDuration;
- (void)resetColors;
@end
