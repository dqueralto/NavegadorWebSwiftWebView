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
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //performSegue(withIdentifier: "historial", sender: self) //usar para tranferir datos entre ViewControllers

        
        webView.loadRequest(URLRequest(url: URL(string: "http://www.google.com")!))
        

        

    }


}

