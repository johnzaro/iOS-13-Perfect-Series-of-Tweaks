#import "PerfectCursor.h"

#import <Cephei/HBPreferences.h>
#import "SparkColourPickerUtils.h"

static HBPreferences *pref;
static BOOL smoothCursorMovement;
static BOOL customCursorColor;
static UIColor *cursorColor;

// ------------------------------ COLOR IN BLINKING CARET & IN TEXT SELECTION ------------------------------

%group customCursorColorGroup

    %hook UITextSelectionView

    - (id)caretViewColor
    {
        return cursorColor;
    }

    - (id)floatingCaretViewColor
    {
        return cursorColor;
    }

    %end

    %hook UITextInputTraits

    - (void)setSelectionBarColor:(id)arg1
    {
        %orig(cursorColor);
    }

    -(UIColor*)selectionHighlightColor
    {
        return [cursorColor colorWithAlphaComponent: 0.3];
    }

    %end

%end

// ------------------------------ ANIMATED MOVEMENT OF SELECTED TEXT CURSORS ------------------------------
// +
// ------------------------------- ANIMATED MOVEMENT OF CURSOR WHILE TYPING -------------------------------

// Original Tweak by @PoomSmart: https://github.com/PoomSmart/SmoothCursor

%group smoothCursorMovementGroup

    %hook UITextSelectionView

    - (void)updateSelectionRects
    {
        [UIView animateWithDuration: 0.2 animations: ^{ %orig; }];
    }

    %end

    %hook UITextSelectionView

    -(id)dynamicCaret
    {
        return self.caretView;
    }

    %end

%end

%ctor
{
    @autoreleasepool
	{
        bool shouldLoad = NO;
        NSString *processName = [NSProcessInfo processInfo].processName;
        bool isSpringboard = [processName isEqualToString: @"SpringBoard"];
        if([[%c(NSProcessInfo) processInfo] arguments].count != 0)
        {
            NSString *executablePath = [[%c(NSProcessInfo) processInfo] arguments][0];
            if(executablePath)
            {
                NSString *processName = [executablePath lastPathComponent];
                BOOL isApplication = [executablePath rangeOfString: @"/Application/"].location != NSNotFound 
                                || [executablePath rangeOfString: @"/Applications/"].location != NSNotFound;
                BOOL isFileProvider = [[processName lowercaseString] rangeOfString: @"fileprovider"].location != NSNotFound;
                BOOL skip = [processName isEqualToString: @"AdSheet"] 
                            || [processName isEqualToString: @"CoreAuthUI"]
                            || [processName isEqualToString: @"InCallService"] 
                            || [processName isEqualToString: @"MessagesNotificationViewService"]
                            || [executablePath rangeOfString: @".appex/"].location != NSNotFound;
                if(isSpringboard || !isFileProvider && isApplication && !skip) 
                    shouldLoad = YES;
            }
        }

        if(shouldLoad)
        {
            pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectcursor13prefs"];
            [pref registerDefaults:
            @{
                @"customCursorColor": @NO,
                @"smoothCursorMovement": @NO
            }];

            customCursorColor = [pref boolForKey: @"customCursorColor"];
            smoothCursorMovement = [pref boolForKey: @"smoothCursorMovement"];

            if(smoothCursorMovement) %init(smoothCursorMovementGroup);
            if(customCursorColor)
            {
                NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.perfectcursor13prefs.colors.plist"];
			    cursorColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"cursorColor"] withFallback: @"#FF9400"];
			
                %init(customCursorColorGroup);
            }
        }
    }
}
