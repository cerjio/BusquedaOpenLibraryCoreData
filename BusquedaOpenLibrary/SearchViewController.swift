//
//  SearchViewController.swift
//  BusquedaOpenLibrary
//
//  Created by cerjio on 30/12/15.
//  Copyright © 2015 cerjio. All rights reserved.
//

import UIKit
import CoreData



class SearchViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var scrollResultado: UIScrollView!
    @IBOutlet weak var tituloValor: UILabel!
    @IBOutlet weak var autoresValor: UILabel!
    @IBOutlet weak var portadaImagen: UIImageView!
    var elementoEncontrado : Elemento? = nil

    let urlString : String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    let documentsDirectory : String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
    var fileName : String?
    var contexto : NSManagedObjectContext? = nil
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        searchBar.delegate = self
        
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        
        self.scrollResultado.hidden = true
        
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func dismissModalView() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        
        let entidadLibro = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        
        let peticion = entidadLibro?.managedObjectModel.fetchRequestFromTemplateWithName("petISBN", substitutionVariables: ["isbn" : searchBar.text!])
        
        do {
            let entidadLibroAEncontrar = try self.contexto?.executeFetchRequest(peticion!)
            
            if entidadLibroAEncontrar?.count > 0 {
                
                
                let alertController = UIAlertController(title: "Mensaje", message: "Libro ya agregado ;)", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                searchBar.text = nil
                searchBar.resignFirstResponder()
                
                return

            }
            
        } catch let error as NSError {
            
            print("Save failed: \(error.localizedDescription)")
        }
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate:nil, delegateQueue:NSOperationQueue.mainQueue())
        let finalURL = urlString + searchBar.text!
        let url = NSURL(string: finalURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            if error != nil {
                
                self.resetValues()
                
                let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                
            } else {
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves)
                    
                    if json.count > 0 {
                        
                        let root = json as! NSDictionary
                        let firstItem = root["ISBN:"+searchBar.text!] as! NSDictionary
                        let title = firstItem["title"] as! NSString as String
                        self.tituloValor.text = title
                        
                        let nuevoLibro = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: self.contexto!)
                        
                        //Codigo de referencia http://stackoverflow.com/questions/24231680/loading-image-from-url
                        //print("Begin of code")
                        
                        self.elementoEncontrado = Elemento(a: self.autoresValor.text!, t: self.tituloValor.text!, p: nil, isbn: searchBar.text!)
                        
                         self.fileName = searchBar.text! + ".jpg"
                        
                        if let checkedUrl = NSURL(string: "http://covers.openlibrary.org/b/isbn/" + self.fileName! + "?default=false") {
                            self.portadaImagen.contentMode = .ScaleAspectFit
                            self.downloadImage(checkedUrl, entidad: nuevoLibro)
                        }
                        //print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")
                        
                        let authors = firstItem["authors"] as! [[String: String]]
                        var authorsArray : [String] = []
                        
                        if authors.count > 0 {
                            
                            for(_, element) in authors.enumerate() {
                                let name = element["name"]
                                authorsArray.append(name!)
                                
                            }
                            
                            self.autoresValor.text = authorsArray.joinWithSeparator(",")
                            self.autoresValor.sizeToFit()
                            self.elementoEncontrado?.autor = self.autoresValor.text
                            
                        }
                        
                        
                        
                        nuevoLibro.setValue(self.elementoEncontrado?.autor, forKey: "autor")
                        nuevoLibro.setValue(self.elementoEncontrado?.titulo, forKey: "titulo")
                        nuevoLibro.setValue(self.elementoEncontrado?.isbn, forKey: "isbn")
                       
                        
                        do {
                            try self.contexto?.save()
                            
                        } catch let error as NSError {
                            
                            print("Save failed: \(error.localizedDescription)")
                            abort()
                        }
                        
                        self.showValues()
                        
                        
                        
                    } else {
                        self.resetValues()
                        let alertController = UIAlertController(title: ":(", message: "No hubo resultados", preferredStyle: .Alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                } catch {
                    
                    let alertController = UIAlertController(title: "Oops!", message: "Error serializing JSON: \(error)", preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                
            }
            
            
            searchBar.resignFirstResponder()
            
            
        }
        
        dataTask.resume()
        

    }
    
    func resetValues() {
        
        self.scrollResultado.hidden = true
        self.tituloValor.text = String("")
        self.autoresValor.text = String("")
        self.portadaImagen.image = nil
    }
    
    func showValues() {
        
        self.scrollResultado.hidden = false
        
        
    }
    
    
    /* Funciones de referencia tomadas de http://stackoverflow.com/questions/24231680/loading-image-from-url */
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            
            if let httpResponse = response as? NSHTTPURLResponse {
               
                if httpResponse.statusCode == 404 {
                    return
                }
            }
            
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL, entidad: NSManagedObject){
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                
                self.portadaImagen.image = UIImage(data: data)
                
                entidad.setValue(UIImageJPEGRepresentation(self.portadaImagen.image!, 1.0), forKey: "portada")
                
                do {
                    try self.contexto?.save()
                    
                } catch let error as NSError {
                    
                    print("Save failed: \(error.localizedDescription)")
                    abort()
                }

                
            }
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        
        searchBar.text = nil
        
        return true
    }

    @IBAction func backgroundTap() {
        searchBar.resignFirstResponder()
    }


    @IBAction func addItemToList() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }


}
