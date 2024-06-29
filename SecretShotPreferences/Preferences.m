@import Foundation;
@import UIKit;
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSSwitchTableCell.h>
#import <Preferences/PSTableCell.h>
#import <SafariServices/SafariServices.h>
#import <spawn.h>
#include <roothide.h>

#define PREF_PATH jbroot(@"/var/mobile/Library/Preferences/com.eamontracey.secretshotpreferences.plist")
#define Notify_Preferences "com.eamontracey.secretshotpreferences/saved"

static void easy_spawn(const char * args[]) {
    pid_t pid;
    int status;
    posix_spawn(&pid, args[0], NULL, NULL, (char* const*)args, NULL);
    waitpid(pid, &status, WEXITED);
}

@interface SecretShotController : PSListController
@end

@implementation SecretShotController

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specifiers = [NSMutableArray array];
        PSSpecifier *spec;

        spec = [PSSpecifier preferenceSpecifierNamed:@"Enable/Disable"
                                              target:self
                                                 set:Nil
                                                 get:Nil
                                              detail:Nil
                                                cell:PSGroupCell
                                                edit:Nil];
        [spec setProperty:@"Snapchat restart required" forKey:@"footerText"];
        [specifiers addObject:spec];
        
        spec = [PSSpecifier preferenceSpecifierNamed:@"Enable"
                                              target:self
                                                 set:@selector(setPreferenceValue:specifier:)
                                                 get:@selector(readPreferenceValue:)
                                              detail:Nil
                                                cell:PSSwitchCell
                                                edit:Nil];
        [spec setProperty:@"enabled" forKey:@"key"];
        [spec setProperty:@YES forKey:@"default"];
        [spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"icon" ofType:@"png"]] forKey:@"iconImage"];
        [spec setProperty:NSClassFromString(@"YellowInfoSwitchTableCell") forKey:@"cellClass"];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Miscellaneous"
                                              target:self
                                                 set:Nil
                                                 get:Nil
                                              detail:Nil
                                                cell:PSGroupCell
                                                edit:Nil];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Kill Snapchat"
                                              target:self
                                                 set:Nil
                                                 get:Nil
                                              detail:Nil
                                                cell:PSButtonCell
                                                edit:Nil];
        
        spec->action = @selector(killSnapchat);
        [spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"snapchat" ofType:@"png"]] forKey:@"iconImage"];
        [spec setProperty:NSClassFromString(@"RedTextTableCell") forKey:@"cellClass"];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Links"
                                              target:self
                                                 set:Nil
                                                 get:Nil
                                              detail:Nil
                                                cell:PSGroupCell
                                                edit:Nil];
        [spec setProperty:@"© 2021 Eamon Tracey - 2024 ichitaso" forKey:@"footerText"];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Contact Me"
                                              target:self
                                                 set:Nil
                                                 get:Nil
                                              detail:Nil
                                                cell:PSButtonCell
                                                edit:Nil];
        
        spec->action = @selector(openDiscord);
        [spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"discord" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];

        spec = [PSSpecifier preferenceSpecifierNamed:@"Source Code ❤️"
                                              target:self
                                                 set:Nil
                                                 get:Nil
                                              detail:Nil
                                                cell:PSButtonCell
                                                edit:Nil];

        spec->action = @selector(openGithub);
        [spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"github" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];

        _specifiers = [specifiers copy];
	}
	return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    @autoreleasepool {
        NSMutableDictionary *EnablePrefsCheck = [[NSMutableDictionary alloc] initWithContentsOfFile:PREF_PATH]?:[NSMutableDictionary dictionary];
        [EnablePrefsCheck setObject:value forKey:specifier.properties[@"key"]];

        [EnablePrefsCheck writeToFile:PREF_PATH atomically:YES];
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(Notify_Preferences), NULL, NULL, YES);
    }
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    @autoreleasepool {
        NSDictionary *EnablePrefsCheck = [[NSDictionary alloc] initWithContentsOfFile:PREF_PATH];
        return EnablePrefsCheck[specifier.properties[@"key"]]?:[[specifier properties] objectForKey:@"default"];
    }
}

- (void)loadView {
    [super loadView];

    if ([self filesExistAtPaths:@[PREF_PATH, jbroot(@"/Applications/Filza.app")]]) {
        UIBarButtonItem *plistButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(viewPlist)];
        self.navigationItem.rightBarButtonItem = plistButtonItem;
    }
}

- (BOOL)filesExistAtPaths:(NSArray<NSString *> *)paths {
    for (NSString *path in paths) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return NO;
        }
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationController.navigationBar.tintColor = [UIColor systemYellowColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:DBL_MAX animations:^{
        self.navigationController.navigationController.navigationBar.tintColor = nil;
    }];
}

- (void)viewPlist {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"filza://view%@", PREF_PATH]] options:@{} completionHandler:nil];
}

- (void)killSnapchat {
    easy_spawn((const char *[]){jbroot("/usr/bin/killall"), "Snapchat", NULL});
    UINotificationFeedbackGenerator *feedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
    [feedbackGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
}

- (void)openDiscord {
    [self openURLInBrowser:@"https://discord.gg/FuDBaWryge"];
}

- (void)openGithub {
    [self openURLInBrowser:@"https://github.com/ichitaso/SecretShot"];
}

- (void)openURLInBrowser:(NSString *)url {
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
    [self presentViewController:safari animated:YES completion:nil];
}

@end

@interface YellowInfoSwitchTableCell : PSSwitchTableCell
@property (nonatomic, strong) UIButton *infoButton;
@end

@implementation YellowInfoSwitchTableCell

- (UIControl *)control {
    UIControl *control = [super control];
    if ([control isKindOfClass:[UISwitch class]]) {
        ((UISwitch *)control).onTintColor = [UIColor systemYellowColor];
    }
    return control;
}

- (void)setControl:(UIControl *)control {
    [super setControl:control];
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
    [super refreshCellContentsWithSpecifier:specifier];

    self.infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    self.infoButton.tintColor = [UIColor systemGrayColor];
    self.infoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.infoButton addTarget:self action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.infoButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.infoButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.infoButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-4]
    ]];
}

- (void)infoButtonTapped {
    NSString *message = @"Thank you for downloading SecretShot! When enabled, SecretShot will block Snapchat from knowing when you take screenshots and screen recordings. SecretShot does not hook Snapchat classes. This means Snapchat will not detect any tweak injection (thus, you will not be banned). Enjoy!";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tweak Info" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay!" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];

    UIWindow *window = nil;
#if NEW_API
    NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
    for (UIScene *scene in connectedScenes) {
        if ([scene isKindOfClass:UIWindowScene.class]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            window = windowScene.windows.firstObject;
            break;
        }
    }
#else
    window = [[UIApplication sharedApplication].windows firstObject];
#endif
    [window.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end

@interface RedTextTableCell : PSTableCell
@end

@implementation RedTextTableCell

- (UILabel *)textLabel {
    UILabel *label = [super textLabel];
    label.textColor = [UIColor systemRedColor];
    label.highlightedTextColor = [UIColor systemRedColor];
    return label;
}

@end
