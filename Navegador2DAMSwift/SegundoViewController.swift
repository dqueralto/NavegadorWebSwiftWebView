//
//  SegundoViewController.swift
//  Navegador2DAMSwift
//
//  Created by Daniel Queraltó Parra on 16/01/2019.
//  Copyright © 2019 Daniel Queraltó Parra. All rights reserved.
//

import UIKit
//IMPORTAMOS LAS LIBRERIAS DE LA BASE DE DATOS QUE USAREMOS
import SQLite3

class SegundoViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    var db: OpaquePointer?
    var historial = [Histo]()
    var histo: [String] = []
    
    
    
    @IBOutlet weak var histoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conectarDB()
        
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //---------------------------------------------------------------------------------------------------------------
    //VISUALIZAR HISTORIAL EN TABLEVIEW
    //---------------------------------------------------------------------------------------------------------------
    //INDICAMOS EL NUMERO DE FILAS QUE TENDRA NUESTRA SECCIÓN A PARTIR DEL TOTAL DE OBJETOS QUE SE HABRAN CREADO GRACIAS A NUESTRA BASE DE DATOS
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return historial.count
    }
    //IPOR CADA REGISTRO CREAMOS UNA LINEA Y LA RELLENAMOS CON LOS OBJETOS EXTRAIDOS DE LA BASE DE DATOS
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //INDICAMOS EL ESTILO DE LA CELDA Y EL IDENTIFICADOR DE ESTA
        let celda = UITableViewCell(style: UITableViewCell.CellStyle.default,  reuseIdentifier: "celdilla")
        //RECCOREMOS NUESTRA COLECCIÓN DE OBJETOS Y GUARDAMOS LA URL DE NUESTRO HISTORIAL EN UNA COLECCION DE STRINGS PARA PODER RELLENAR LAS CELDAS A CONTINUACION
        for hi in historial{
            histo.append(hi.url!)//AÑADIMOS EL ESTRING "URL" A LA NUEVA COLECCION
        }
        //RELLENAMOS LAS CELDAS CON NUESTRA NUEVA COLECCION
        celda.textLabel?.text = histo[indexPath.row]//LE INDICAMOS QUE LOS INSERTE SEGUN EL INDICE DE FILAS QUE CREAMOS EN LA FUNCION ANTERIOR CON "historial.count"
        //CARGAMOS LAS CELDAS
        return celda
    }
 
    
    
    
    //---------------------------------------------------------------------------------------------------------------
    //BOTONES
    //---------------------------------------------------------------------------------------------------------------
    
    
    @IBAction func salir(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func eliminar(_ sender: Any) {
        //ELIMINAMOOS TODOS LOS REGISTROS DE LA BASE DE DATOS
        eliminarHistorial()
        //VOLVEMOS A MIRAR SI HAY DATOS EN LA BASE DE DATOS
        leerValores()
        //RECARGAMOS EL TABLEVIEW
        histoTableView.reloadData()
    }
    
    //---------------------------------------------------------------------------------------------------------------
    //BASE DE DATOS
    //---------------------------------------------------------------------------------------------------------------
    
    func conectarDB()
    {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Historial.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        else {
            print("base abierta")
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Historial (id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
        }
        leerValores()
    }
    
    
    func leerValores(){
        
        //PRIMERO LIMPIAMOS LA LISTA "HISTORIAL"
        historial.removeAll()
        
        //GUARDAMOS NUESTRA CONSULTA
        let queryString = "SELECT * FROM Historial"
        
        //PUNTERO DE INSTRUCCIÓN
        var stmt:OpaquePointer?
        
        //PREPARACIÓN DE LA CONSULTA
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //RECORREMOS LOS REGISTROS
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let url = String(cString: sqlite3_column_text(stmt, 1))
            
            
            //AÑADIMOS LOS VALORES A LA LISTA
            historial.append(Histo(id: Int(id), url: String(describing: url)))
            
        }
        
    }
    
    func eliminarHistorial()
    {
        //GUARDAMOS NUESTRA CONSULTA
        let queryString = "DELETE FROM Historial"
        //CREAMOS EL PUNTERO DE INSTRUCCIÓN
        var deleteStatement: OpaquePointer? = nil
        
        //PREPARACIÓN DE LA CONSULTA
        if sqlite3_prepare(db, queryString, -1, &deleteStatement, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print(queryString)
            print("error preparing insert: \(errmsg)")
            return
        }
        //ELIMINAMOS LOS REGISTROS
        if sqlite3_prepare_v2(db, queryString, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        
        //FINALIZAMOS LA SENTENCIA
        sqlite3_finalize(deleteStatement)
        
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
