//
//  ViewController.swift
//  Navegador2DAMSwift
//
//  Created by Daniel Queraltó Parra on 14/01/2019.
//  Copyright © 2019 Daniel Queraltó Parra. All rights reserved.
//

import UIKit
import SQLite3
var direccion = ""

class ViewController: UIViewController, UISearchBarDelegate, UIWebViewDelegate{
    //VARIABLES PARA LA BASE DE DATOS Y LOS OBJEROS
    var db: OpaquePointer?
    var historial = [Histo]()
    //COSAS QUE USAREMOS
    @IBOutlet weak var barraDeBusqueda: UISearchBar!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var retroceder: UIBarButtonItem!
    @IBOutlet weak var avanzar: UIBarButtonItem!
    
    @IBOutlet weak var recargar: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barraDeBusqueda.delegate = self
        webView.delegate = self
        webView.loadRequest(URLRequest(url: URL(string: "https://www.google.com")!))
        crearBD()//CREAMOS O ABRIMOS(SI YA EXISTE) LA BASE DE DATOS
    }
    //---------------------------------------------------------------------------------------------------------------
    //BOTONES
    //---------------------------------------------------------------------------------------------------------------
    //RETROCEDEMOS A LA PAGINA ANTERIOR
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
        //ALMACENAMOS EL CONTENIDO DE LA BARRA DE BUSQUEDA
        let barraBusqueda = barraDeBusqueda.text!
        //CREAMOS CONSTANTES CON DIVERSA COSAS QUE USAREMOS PARA TRATAR LA/LAS URL/URLS
        let com: String = ".com"
        let es: String = ".es"
        let net: String = ".net"
        //let http: String = "http://"
        let https: String = "https://"
        let www: String = "www."
        let google: String = "https://www.google.com/search?q="
        //CONVERTIMOS LOS "ESPACIOS"EN LA BARRA DE BUSQUEDA POR "-" Y LA ALMACENAMOS PARA TRABAJAR CON ELLA
        var barraBusquedafinal = barraBusqueda.replacingOccurrences(of: " ", with: "-", options: .literal, range: nil)
        //QUITAMOS LA PRIORIDAD DE LA BARRA
        barraDeBusqueda.resignFirstResponder()
        //PASAMOS A MINUSCULAS EL CONTENIDO DE LA VARIABLE DEFINITIVA(barraBusquedafinal)
        barraBusquedafinal = barraBusquedafinal.lowercased()
        //COMPROBAMOS SI EL CONTENIDO DE LA VARIABLE DEFINITIVA TIENE ".COM", ".ES", ".NET", ""
        if !barraBusquedafinal.contains(com) && !barraBusquedafinal.contains(es) && !barraBusquedafinal.contains(net)
        {
            //SI NO LOS TIENE LE AÑADIMOS LA URL DE BUSQUEDA POR DEFECTO DE GOOGLE
            barraBusquedafinal = google + barraBusquedafinal
            //Y LE DECIMOS QUE PASE NUESTRO STRING A FOMATO URL(ALMACENANDOLO EN UNA CONSTANTE) Y LO USAMOS PARA QUE SI NO SE PUDIERA PASAR NO HICIERA NADA
            if let url = URL(string: barraBusquedafinal)
            {
                let myRequest = URLRequest(url: url)//HACEMOS LA SOLICITUD DE CARGA
                webView.loadRequest(myRequest)//AQUI ES CUANDO LA CARGA
            }
            
        }
        else
        {
            //COMPROBAMOS SI NUESTRA DIRECCION (CONTENIDA EN LA BARRA DE BUSQUEDA) POSEE "WWW."
            if !barraBusquedafinal.contains(www)
            {
                barraBusquedafinal = www + barraBusquedafinal//SI NO LO POSEE SE LO AÑADIMOS
            }
            /*if !barraBusquedafinal.contains(http)
             {
             barraBusquedafinal = http + barraBusquedafinal
             }
             */
            //COMPROBAMOS SI NUESTRA DIRECCION (CONTENIDA EN LA BARRA DE BUSQUEDA) POSEE  "HTTPS://"
            if !barraBusquedafinal.contains(https)
            {
                barraBusquedafinal = https + barraBusquedafinal//SI NO LO TIENE SE LO AÑADIMOS
            }
            //Y LE DECIMOS QUE PASE NUESTRO STRING A FOMATO URL(ALMACENANDOLO EN UNA CONSTANTE) Y LO USAMOS PARA QUE SI NO SE PUDIERA PASAR NO HICIERA NADA
            if let url = URL(string: barraBusquedafinal)
            {
                let myRequest = URLRequest(url: url)//HACEMOS LA SOLICITUD DE CARGA
                webView.loadRequest(myRequest)//AQUI ES CUANDO LA CARGA
            }
            
            
            
        }
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        barraDeBusqueda.text = webView.request?.url?.absoluteString
        insertar()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        activarBotones()
    }

 

    
    
    
    //---------------------------------------------------------------------------------------------------------------
    //FUNCIONALIDADES
    //---------------------------------------------------------------------------------------------------------------
    
    func activarBotones()//HABILITAMOS O DESHABILITAMOS LOS BOTONES DE AVANCE O RETROCESO SEGÚN SE PUEDA
    {
        if webView.canGoForward
        {
            avanzar.isEnabled = true
        }
        else
        {
            avanzar.isEnabled = false
        }
        if webView.canGoBack
        {
            retroceder.isEnabled = true
        }
        else
        {
            retroceder.isEnabled = false
        }
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


