//
//  ViewController.m
//  Cubes
//
//  Created by Rob Eberhardt on 2/3/16.
//  Copyright © 2016 Rob Eberhardt. All rights reserved.
//

#import "ViewController.h"
#import "ParticleManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _countSlider.value = [ParticleManager sharedInstance].currentCount;
    [self updateUI];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) OnSliderChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    [ParticleManager sharedInstance].currentCount = roundf(slider.value);
    [self updateUI];
}

-(void)updateUI
{
    _countLabel.text = [NSString stringWithFormat:@"%d", [ParticleManager sharedInstance].currentCount];
}

@end
