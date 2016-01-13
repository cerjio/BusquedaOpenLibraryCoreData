//
//  DetailViewController.swift
//  BusquedaOpenLibrary
//
//  Created by cerjio on 30/12/15.
//  Copyright © 2015 cerjio. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    @IBOutlet weak var autoresLabel: UILabel!
   
    @IBOutlet weak var portada: UIImageView!

    var titulo: String?
    
    var contexto : NSManagedObjectContext? = nil
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        
        
       
        let libros = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        let peticion = libros?.managedObjectModel.fetchRequestFromTemplateWithName("petLibro", substitutionVariables: ["titulo" : titulo!])
        
        do {
            
            let libro = try self.contexto?.executeFetchRequest(peticion!).first
            
            if let label = self.detailDescriptionLabel {
                label.text = libro!.valueForKey("titulo")!.description
            }
            
            if let autor = self.autoresLabel {
                autor.text = libro!.valueForKey("autor")!.description
            }
            
            
            if let portadaImagen = self.portada {
                
                let imageData  = libro!.valueForKey("portada") as? NSData
                
                if imageData != nil {

                    portadaImagen.image = UIImage(data: imageData!, scale: 1.0)
                    
                } else {
                    portadaImagen.image = UIImage(named: "default-placeholder")
                }
                
            }
            
            
        } catch let error as NSError {
            
             print("Fetch failed: \(error.localizedDescription)")
            
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

