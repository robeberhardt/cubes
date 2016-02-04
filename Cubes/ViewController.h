//
//  ViewController.h
//  Cubes
//
//  Created by Rob Eberhardt on 2/3/16.
//  Copyright © 2016 Rob Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UISlider *countSlider;
@property (nonatomic, strong) IBOutlet UILabel *countLabel;

- (IBAction) OnSliderChanged:(id)sender;

@end

