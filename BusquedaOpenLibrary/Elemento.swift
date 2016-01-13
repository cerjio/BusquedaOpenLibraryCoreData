//
//  Elemento.swift
//  BusquedaOpenLibrary
//
//  Created by cerjio on 01/01/16.
//  Copyright © 2016 cerjio. All rights reserved.
//

import UIKit

class Elemento: NSObject {
    
    var autor: String? = ""
    var titulo: String? = ""
    var portada: String? = ""
    var isbn: String? = ""
    
    init(a: String, t: String, p: String?, isbn: String) {
        self.autor = a
        self.titulo = t
        self.portada = p
        self.isbn = isbn
    }

}
