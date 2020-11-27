#import "LowPowerModeModule.h"
#import "../ControlCenterPreferences.h"
#import <objc/runtime.h>

@implementation LowPowerModeModule

- (UIImage*)iconGlyph
{
	return [UIImage imageNamed: @"LowPowerOff" inBundle: [NSBundle bundleForClass: [self class]]];
}

- (UIImage*)selectedIconGlyph
{
	return [UIImage imageNamed: @"LowPowerOn" inBundle: [NSBundle bundleForClass: [self class]]];
}

- (UIColor*)selectedColor
{
	return [UIColor colorWithRed: 0.90 green: 0.71 blue: 0.24 alpha: 1.00];
}

- (BOOL)isSelected
{
    return _selected;
}

- (void)setSelected: (BOOL)selected
{
	_selected = selected;

    if(selected)
		[[objc_getClass("_CDBatterySaver") batterySaver] setPowerMode: 1 error: nil];
	else
		[[objc_getClass("_CDBatterySaver") batterySaver] setPowerMode: 0 error: nil];
}

@end