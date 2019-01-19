//
//  ViewController.swift
//  Navegador2DAMSwift
//
//  Created by Daniel Queraltó Parra on 14/01/2019.
//  Copyright © 2019 Daniel Queraltó Parra. All rights reserved.
//

import UIKit

var direccion = ""

class ViewController: UIViewController, UISearchBarDelegate, UIWebViewDelegate {
    @IBOutlet weak var barraDeBusqueda: UISearchBar!
    @IBOutlet weak var webView: UIWebView!
    
    @IBAction func atras(_ sender: Any)
    {
        if webView.canGoBack
        {
            webView.goBack()
        }
    }
    
    @IBAction func recargar(_ sender: Any)
    {
        webView.reload()
    }
    
    @IBAction func siguiente(_ sender: Any)
    {
        if webView.canGoForward
        {
            webView.goForward()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        barraDeBusqueda.resignFirstResponder()
        
        if let url = URL(string: barraDeBusqueda.text!)
        {
            webView.loadRequest(URLRequest(url: url))
        }
        else
        {
            print("ERROR")
        }
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

 

    @IBAction func historial(_ sender: Any)
    {
        //direccion = barraDeBusqueda.text!
        //performSegue(withIdentifier: "historial", sender: self)
    }
    
    
    
    //---------------------------------------------------------------------------------------------------------------
    //FUNCIONALIDADES
    //---------------------------------------------------------------------------------------------------------------
    
    func activarBotones()//HABILITAMOS O DESHABILITAMOS LOS BOTONES DE AVANCE O RETROCESO SEGÚN SE PUEDA
    {
        if webKitView.canGoForward
        {
            avanzar.isEnabled = true
        }
        else
        {
            avanzar.isEnabled = false
        }
        if webKitView.canGoBack
        {
            retroceder.isEnabled = true
        }
        else
        {
            retroceder.isEnabled = false
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(URLRequest(url: URL(string: "http://www.google.com")!))
    }
    //---------------------------------------------------------------------------------------------------------------
    //GESTION DE BASE DE DATOS
    //---------------------------------------------------------------------------------------------------------------
    func crearBD()
    {
        //INDICAMOS DONDE SE GUARDARA LA BASE DE DATOS Y EL NOMBRE DE ESTAS
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Historial.sqlite")
        //INDICAMOS SI DIERA ALGUN FALLO AL CONECTARSE
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        else {//SI PODEMOS CONECTARNOS A LA BASE DE DATOS CREAREMOS LA ESTRUCTURA DE ESTA, SI NO EXISTIERA NO SE HARIA NADA
            print("base abierta")
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Historial (id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
        }
        
    }

    func insertar()  {
        //CREAMOS EL PUNTERO DE INSTRUCCIÓN
        var stmt: OpaquePointer?
        
        //CREAMOS NUESTRA SENTENCIA
        let queryString = "INSERT INTO Historial (url) VALUES ("+"'"+String(barraDeBusqueda.text!)+"')"
        //PREPARAMOS LA SENTENCIA
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print(queryString)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        
        //EJECUTAMOS LA SENTENCIA PARA INSERTAR LOS VALORES
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("fallo al insertar en historial: \(errmsg)")
            return
        }
        
        //FINALIZAMOS LA SENTENCIA
        sqlite3_finalize(stmt)
        //displaying a success message
        print("Histo saved successfully")
        
    }
}
//---------------------------------------------------------------------------------------------------------------
//OBJETOS
//---------------------------------------------------------------------------------------------------------------

class Histo{
    
    var id: Int
    var url: String?
    
    init (id: Int, url: String?)
    {
        self.id = id
        self.url = url
    }
    
}


