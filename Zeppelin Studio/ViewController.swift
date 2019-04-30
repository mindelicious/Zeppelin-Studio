//
//  ViewController.swift
//  Zeppelin Studio
//
//  Created by Matt on 29/04/2019.
//  Copyright © 2019 mindelicious. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var card = [String: Card]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()

        guard let trackingImage = ARReferenceImage.referenceImages(inGroupNamed: "image", bundle: nil) else {
            fatalError("Couldn't find tracking image")
        }
        
        configuration.trackingImages = trackingImage
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        guard let name = imageAnchor.referenceImage.name else { return nil }
        guard let cardDesc = card[name] else { return nil }
        
        
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        
        let node = SCNNode()
        node.addChildNode(planeNode)
        
        let spacing: Float = 0.030
        
        // Name
        let titleNode = textNode(cardDesc.name, font: UIFont.boldSystemFont(ofSize: 45))
        titleNode.pivotOnTopLeft()
       
        titleNode.position.x += Float(plane.width / 2) + spacing
        titleNode.position.y += Float(plane.height / 2)
       
         planeNode.addChildNode(titleNode)
        
        //Owner
        let ownerName = textNode(cardDesc.ownerName, font: UIFont.boldSystemFont(ofSize: 40))
        ownerName.pivotOnTopLeft()
        
        ownerName.position.x += Float(plane.width / 2) + spacing
        ownerName.position.y = titleNode.position.y - titleNode.height - spacing
        
        planeNode.addChildNode(ownerName)
        
        //Phone
        let phone = textNode(cardDesc.phone, font: UIFont.boldSystemFont(ofSize: 34))
        phone.pivotOnTopLeft()
        
        phone.position.x += Float(plane.width / 2) + spacing
        phone.position.y = ownerName.position.y - ownerName.height - spacing
        
        planeNode.addChildNode(phone)
        
        //Mail
        let mail = textNode(cardDesc.mail, font: UIFont.boldSystemFont(ofSize: 34))
        mail.pivotOnTopLeft()
        
        mail.position.x += Float(plane.width / 2) + spacing
        mail.position.y = phone.position.y - phone.height - spacing
        
        planeNode.addChildNode(mail)
        
        //Bio
        let bioNode = textNode(cardDesc.bio, font: UIFont.systemFont(ofSize: 30), maxWidth: 500)
        bioNode.pivotOnTopLeft()
        
        bioNode.position.x += Float(plane.width / 2) + spacing
        bioNode.position.y = mail.position.y - mail.height - (spacing * 2)
        
        planeNode.addChildNode(bioNode)
        
        //Video
        var player: AVPlayer!
        
        let fileUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "zeppelinVid", ofType: "mp4")!)
        player = AVPlayer(url: fileUrl)
        
        let video = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.width / 8 * 5)
        video.firstMaterial?.diffuse.contents = player
        
        let videoNode = SCNNode(geometry: video)
        videoNode.pivotOnTopCenter()
        
        videoNode.position.y -= Float(plane.height / 2) + spacing
        
        planeNode.addChildNode(videoNode)
        player.play()
        player.volume = 0
        
//
     
        return node
 
    }
    
    func loadData() {
        guard let url = Bundle.main.url(forResource: "cards", withExtension: "json") else {
            fatalError("Unable find json")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("uanble load json")
        }
        let decoder = JSONDecoder()
        
        guard let loadCard = try? decoder.decode([String: Card].self, from: data) else {
            fatalError("Unnable to Parse json")
        }
         card = loadCard
    }
    func textNode(_ str: String, font: UIFont, maxWidth: Int? = nil) -> SCNNode {
        let text = SCNText(string: str, extrusionDepth: 0)
        
        text.flatness = 0.1
        text.font = font
        
        if let maxWidth = maxWidth {
            text.containerFrame = CGRect(origin: .zero, size: CGSize(width: maxWidth, height: 500))
            text.isWrapped = true
        }
        
        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        
        return textNode
    }

}

extension SCNNode {
    var width: Float {
        return (boundingBox.max.x - boundingBox.min.x) * scale.x
    }
    var height: Float {
        return (boundingBox.max.y - boundingBox.min.y) * scale.y
    }
    func pivotOnTopLeft() {
        let (min, max) = boundingBox
        pivot = SCNMatrix4MakeTranslation(min.x, (max.y - min.y) + min.y, 0)
    }
    func pivotOnTopCenter() {
        let (min, max) = boundingBox
        pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2 + min.x, (max.y - min.y) + min.y, 0)
    }
}
