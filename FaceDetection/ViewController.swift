//
//  ViewController.swift
//  FaceDetection
//
//  Created by Lilly Tong on 2018-03-17.
//  Copyright © 2018 Lilly Tong. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let image = UIImage(named: "lilly") else { return } //so we don't have to use image?
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        let scaledHeight = view.frame.width / image.size.width * image.size.height
        
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scaledHeight)

        let request = VNDetectFaceRectanglesRequest{ (req,err) in
            if let err = err {
                print("failed to detect faces: \(err)")
                return
            }
            
            req.results?.forEach({ (res) in
                print(res)
                
                guard let faceObservation = res as? VNFaceObservation else {
                    return
                }
                
                print(faceObservation.boundingBox)
                
                //Starting Coordinates and dimensions of facial detection object
                let x = self.view.frame.width * faceObservation.boundingBox.origin.x //starting x
                let heightOfBox = scaledHeight * faceObservation.boundingBox.height //we use scaledHeight insteasd of self.view.frame.height since we don't want height of whole view, just the image
                let y = scaledHeight * (1 - faceObservation.boundingBox.origin.y) - heightOfBox //since VNFaceObservation returns lower left corner as starting point
                let widthOfBox = self.view.frame.width * faceObservation.boundingBox.width //width in the x direction
                
                let redView = UIView()
                redView.backgroundColor = .red
                redView.alpha = 0.4
                redView.frame = CGRect(x: x, y: y, width: widthOfBox, height: heightOfBox)
                self.view.addSubview(redView)
                
                guard let resizedImage = self.resizeImage(image: image, newWidth: self.view.frame.width) else { return }
                
                let croppedImage = resizedImage.cgImage?.cropping(to: CGRect(x: x, y: y, width: widthOfBox, height: heightOfBox))
                
                self.imageView.image = UIImage(cgImage: croppedImage!)

            })
        }
        
        guard let cgimage = imageView.image?.cgImage else { return }
        
        let handler = VNImageRequestHandler(cgImage: cgimage, options: [:])
        
        do {
            try handler.perform([request])
        } catch let reqErr {
            print("Failed to perform request :\(reqErr)")
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

