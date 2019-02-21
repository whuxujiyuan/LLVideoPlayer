//
//  LLViewController.m
//  LLVideoPlayer
//
//  Created by mario on 12/23/2016.
//  Copyright (c) 2016 mario. All rights reserved.
//

#import "LLViewController.h"
#import "LLVideoPlayer.h"
#import "Masonry.h"

#define kTestVideoURL [NSURL URLWithString:@"https://video.wefaceapp.com/video/disucss/2019/2/20/dPwiZBGVm0j0yB0eQ5oJ6A/sd/149555D1-48EA-4D66-BADB-3E2EEFD22741.mp4"]

@interface LLViewController () <LLVideoPlayerDelegate>

@property (nonatomic, strong) LLVideoPlayer *player;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UISwitch *cacheSwitch;
@property (nonatomic, assign) NSTimeInterval beginTime;
@property (nonatomic, assign) NSTimeInterval endTime;

@end

@implementation LLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self createPlayer];
    {
        self.cacheSwitch = [UISwitch new];
        [self.view addSubview:self.cacheSwitch];
        self.cacheSwitch.frame = CGRectMake(10, 30, self.cacheSwitch.frame.size.width, self.cacheSwitch.frame.size.height);
        self.cacheSwitch.on = YES;
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"preload" forState:UIControlStateNormal];
        [self.view addSubview:button];
        button.frame = CGRectMake(100, 30, 60, 40);
        [button addTarget:self action:@selector(preloadAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"clear" forState:UIControlStateNormal];
        [self.view addSubview:button];
        button.frame = CGRectMake(160, 30, 60, 40);
        [button addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"destroy" forState:UIControlStateNormal];
        [self.view addSubview:button];
        button.frame = CGRectMake(220, 30, 60, 40);
        [button addTarget:self action:@selector(destroyAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        self.stateLabel = [UILabel new];
        self.stateLabel.backgroundColor = [UIColor clearColor];
        self.stateLabel.font = [UIFont systemFontOfSize:14];
        self.stateLabel.textColor = [UIColor redColor];
        [self.view addSubview:self.stateLabel];
        self.stateLabel.frame = CGRectMake(10, 300, 300, 20);
        
        self.stateLabel.text = [LLVideoPlayerHelper playerStateToString:self.player.state];
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"load" forState:UIControlStateNormal];
        [self.view addSubview:button];
        button.frame = CGRectMake(10, 340, 50, 40);
        [button addTarget:self action:@selector(loadAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"play" forState:UIControlStateNormal];
        [self.view addSubview:button];
        button.frame = CGRectMake(60, 340, 50, 40);
        [button addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"pause" forState:UIControlStateNormal];
        [self.view addSubview:button];
        button.frame = CGRectMake(110, 340, 50, 40);
        [button addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"dismiss" forState:UIControlStateNormal];
        [self.view addSubview:button];
        button.frame = CGRectMake(160, 340, 60, 40);
        [button addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"loadErr" forState:UIControlStateNormal];
        [self.view addSubview:button];
        button.frame = CGRectMake(220, 340, 60, 40);
        [button addTarget:self action:@selector(loadErrAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        self.currentTimeLabel = [UILabel new];
        self.currentTimeLabel.backgroundColor = [UIColor clearColor];
        self.currentTimeLabel.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:self.currentTimeLabel];
        self.currentTimeLabel.frame = CGRectMake(10, 400, 60, 30);
        
        self.slider = [[UISlider alloc] init];
        [self.view addSubview:self.slider];
        self.slider.frame = CGRectMake(60, 405, 200, 20);
        [self.slider addTarget:self action:@selector(sliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        self.totalTimeLabel = [UILabel new];
        self.totalTimeLabel.backgroundColor = [UIColor clearColor];
        self.totalTimeLabel.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:self.totalTimeLabel];
        self.totalTimeLabel.frame = CGRectMake(270, 400, 60, 30);
        
        self.currentTimeLabel.text = [LLVideoPlayerHelper timeStringFromSecondsValue:0];
        self.totalTimeLabel.text = [LLVideoPlayerHelper timeStringFromSecondsValue:0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createPlayer
{
    if (self.player) {
        self.player.delegate = nil;
        [self.player.view removeFromSuperview];
        self.player = nil;
    }
    
    self.player = [[LLVideoPlayer alloc] init];
    [self.view addSubview:self.player.view];
    self.player.view.frame = CGRectMake(10, 80, 300, 200);
    self.player.delegate = self;
    self.player.cacheSupportEnabled = YES;
    LLVideoPlayerCachePolicy *policy = [LLVideoPlayerCachePolicy defaultPolicy];
    self.player.cachePolicy = policy;
}

- (void)loadAction:(id)sender
{
    NSLog(@"[PRESS] loadAction");
    self.beginTime = CFAbsoluteTimeGetCurrent();
    self.player.cacheSupportEnabled = self.cacheSwitch.on;
    
    [self.player loadVideoWithStreamURL:kTestVideoURL];
}

- (void)playAction:(id)sender
{
    [self.player playContent];
}

- (void)pauseAction:(id)sender
{
    [self.player pauseContent];
}

- (void)dismissAction:(id)sender
{
    [self.player dismissContent];
}

- (void)loadErrAction:(id)sender
{
    NSLog(@"[PRESS] loadErrAction");
    self.player.cacheSupportEnabled = self.cacheSwitch.on;
    [self.player loadVideoWithStreamURL:kTestVideoURL];
    
    // Testing dismiss right after loading
    [self.player dismissContent];
}

- (void)destroyAction:(id)sender
{
    NSLog(@"[PRESS] destroyAction");
    self.player.delegate = nil;
    [self.player.view removeFromSuperview];
    self.player = nil;
}

- (void)sliderTouchUpInside:(UISlider *)sender
{
    float sec = [self.player.track.totalDuration floatValue] * sender.value;
    
    [self.player pauseContent:YES completionHandler:^{
        [self.player seekToTimeInSecond:sec userAction:YES completionHandler:^(BOOL finished) {
            [self.player playContent];
        }];
    }];
}

- (void)clearAction:(id)sender
{
    [LLVideoPlayer clearAllCache];
    NSLog(@"Clear Cache.");
}

- (void)preloadAction:(id)sender
{
    NSLog(@"[PRESS] preloadAction");
    [LLVideoPlayer preloadWithURL:kTestVideoURL];
}

#pragma mark - LLVideoPlayerDelegate

#pragma mark - State Changed

- (BOOL)shouldVideoPlayer:(LLVideoPlayer *)videoPlayer changeStateTo:(LLVideoPlayerState)state
{
    return YES;
}

- (void)videoPlayer:(LLVideoPlayer *)videoPlayer willChangeStateTo:(LLVideoPlayerState)state
{
}

- (void)videoPlayer:(LLVideoPlayer *)videoPlayer didChangeStateFrom:(LLVideoPlayerState)state
{
    if (state == LLVideoPlayerStateContentLoading && videoPlayer.state == LLVideoPlayerStateContentPlaying) {
        self.endTime =CFAbsoluteTimeGetCurrent();
        NSLog(@"time: %f", self.endTime - self.beginTime);
    }
    self.stateLabel.text = [LLVideoPlayerHelper playerStateToString:self.player.state];
}

#pragma mark - Play Control

- (BOOL)shouldVideoPlayerStartVideo:(LLVideoPlayer *)videoPlayer
{
    return YES;
}

- (void)videoPlayerWillStartVideo:(LLVideoPlayer *)videoPlayer
{
    
}

- (void)videoPlayerDidStartVideo:(LLVideoPlayer *)videoPlayer
{
    self.totalTimeLabel.text = [LLVideoPlayerHelper timeStringFromSecondsValue:[videoPlayer.track.totalDuration floatValue]];
}

- (void)videoPlayer:(LLVideoPlayer *)videoPlayer durationDidLoad:(NSNumber *)duration
{
    NSLog(@"durationDidLoad: %@", duration);
}

- (BOOL)videoPlayerShouldReplayOnEnd:(LLVideoPlayer *)videoPlayer {
    return YES;
}

- (BOOL)videoPlayerShouldPauseOnReplay:(LLVideoPlayer *)videoPlayer {
    return YES;
}

- (void)videoPlayer:(LLVideoPlayer *)videoPlayer didPlayFrame:(NSTimeInterval)time
{
    NSLog(@"didPlayFrame: %f", time);
    self.currentTimeLabel.text = [LLVideoPlayerHelper timeStringFromSecondsValue:time];
    self.totalTimeLabel.text = [LLVideoPlayerHelper timeStringFromSecondsValue:[videoPlayer.track.totalDuration floatValue]];
    self.slider.value = time / [videoPlayer.track.totalDuration doubleValue];
}

- (void)videoPlayer:(LLVideoPlayer *)videoPlayer loadedTimeRanges:(NSArray<NSValue *> *)ranges
{
    
}

- (void)videoPlayerDidPlayToEnd:(LLVideoPlayer *)videoPlayer
{
    
}

#pragma mark - Error

- (void)videoPlayer:(LLVideoPlayer *)videoPlayer didFailWithError:(NSError *)error
{
    
}

@end
