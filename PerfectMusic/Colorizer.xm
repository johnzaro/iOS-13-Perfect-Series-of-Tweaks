#import "Colorizer.h"

@implementation Colorizer

+ (instancetype)sharedInstance
{
	static Colorizer *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, 
	^{
		sharedInstance = [[Colorizer alloc] init];
	});
	return sharedInstance;
}

- (void)generateColorsForArtwork: (UIImage*)artworkImage withTitle: (NSString*)title
{
    if(artworkImage && title && (!_title || ![_title isEqualToString: title]))
    {
        _title = title;
		_oldBackgroundColor = [self backgroundColor];
        _colorArt = [[SLColorArt alloc] initWithImage: artworkImage];
		[[NSNotificationCenter defaultCenter] postNotificationName: @"MusicArtworkChanged" object: nil];
    }
}

- (UIColor*)backgroundColor
{
	return _colorArt ? [_colorArt backgroundColor] : nil;
}

- (UIColor*)primaryColor
{
	return _colorArt ? [_colorArt primaryColor] : nil;
}

- (UIColor*)secondaryColor
{
	return _colorArt ? [_colorArt secondaryColor] : nil;
}

- (double)backgroundColorChangeDuration
{
	return [self backgroundColor] ? 0.2 + 0.3 * [[self backgroundColor] distanceFromColor: _oldBackgroundColor] : 0.0;
}

// - (void)resetColors
// {
// 	_title = nil;
// 	_oldBackgroundColor = nil;
// 	_colorArt = nil;
// 	[[NSNotificationCenter defaultCenter] postNotificationName: @"MediaApplicationClosed" object: nil];
// }

@end

// %hook SBMediaController

// - (void)_setNowPlayingApplication: (id)arg1 
// {
// 	if(!arg1)
// 		[[Colorizer sharedInstance] resetColors];
// 	%orig;
// }

// %end