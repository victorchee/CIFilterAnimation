//
//  ViewController.swift
//  CIFilterAnimation
//
//  Created by qihaijun on 12/3/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var duration = 20.0
    private var transitionStartTime: CFTimeInterval = 0
    private var rippleTransitionFilter: CIFilter!
    private var originalImage: CIImage!
    private var extent = CGRect.zero
    
    private var displayLink: CADisplayLink?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        guard let image = UIImage(named: "stripe") else {
            return
        }
        guard let sourceImage = CIImage(image: image) else {
            return
        }
        originalImage = sourceImage
        imageView.image = UIImage(CIImage: originalImage)
        extent = sourceImage.extent
        
        let inputImage = sourceImage.imageByClampingToExtent()
        rippleTransitionFilter = CIFilter(name: "CIRippleTransition")
        rippleTransitionFilter.setValue(inputImage, forKey: kCIInputImageKey)
        rippleTransitionFilter.setValue(inputImage, forKey: kCIInputTargetImageKey)
        rippleTransitionFilter.setValue(CIImage(), forKey: kCIInputShadingImageKey)
        
        displayLink = CADisplayLink(target: self, selector: "timerFired:")
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink?.paused = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tap(sender: UITapGestureRecognizer) {
        transitionStartTime = CACurrentMediaTime()
        displayLink?.paused = false
    }
    
    func timerFired(displayLink: CADisplayLink) {
        let progress = min((CACurrentMediaTime() - transitionStartTime) / duration, 1.0)
        print(progress)
        rippleTransitionFilter.setValue(progress, forKey: kCIInputTimeKey)
        
        guard let outputImage = rippleTransitionFilter.outputImage?.imageByCroppingToRect(extent) else {
            displayLink.paused = true
            return
        }
        
        /*
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(outputImage, fromRect: extent)
        */
        
        imageView.image = UIImage(CIImage: outputImage, scale: UIScreen.mainScreen().scale, orientation: .Up)
        
        if progress == 1.0 {
            imageView.image = UIImage(CIImage: originalImage)
            displayLink.paused = true
        }
    }
}

