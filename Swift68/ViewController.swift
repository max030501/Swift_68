//
//  ViewController.swift
//  Swift68
//
//  Created by Maxim on 15.06.2021.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource,UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(self.companies.keys)[row]
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.companies.keys.count
    }
    
    private let companies: [String: String] = ["Apple": "AAPL",
                                               "Microsoft": "MSFT",
                                               "Google": "GOOG",
                                               "Amazon": "AMZN",
                                               "Facebook": "FB"]
                                        

    @IBOutlet weak var companyNameLable: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var imageCompany: UIImageView!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self
        self.activityIndicator.hidesWhenStopped = true
        requestQuoteUpdate()
    }
    
    private func requestQuote(for symbol: String){
        let url = URL(string: "https://financialmodelingprep.com/api/v3/profile/\(symbol)?apikey=41d9e859d2b8addf9cb68b2d8d4c8dd1")!
        let dataTask = URLSession.shared.dataTask(with: url){data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                print("Network error")
                return
            }
            self.parseQuote(data: data)
        }
        dataTask.resume()
        }
    private func parseQuote(data: Data){
        do{
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard
                let json = jsonObject as? [Any],
                let json1 = json.first as? [String: Any],
                let companyName = json1["companyName"] as? String,
                let companySymbol = json1["symbol"] as? String,
                let price = json1["price"] as? Double,
                let priceChange = json1["changes"] as? Double,
                let image = json1["image"] as? String
            else{
                print("Invalid JSON format")
                return
            }
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName,
                                      symbol: companySymbol,
                                      price: price,
                                      priceChange: priceChange,
                                      image: image)
            }
            print("Company name is: \(companyName)")
        }catch{
            print("JSON parsing error: " + error.localizedDescription )
        }
    }
    private func displayStockInfo(companyName: String, symbol: String, price: Double, priceChange: Double, image: String){
        self.activityIndicator.stopAnimating()
        self.companyNameLable.text = companyName
        self.companySymbolLabel.text = symbol
        self.priceLabel.text = "\(price)"
        self.priceChangeLabel.text = "\(priceChange)"
        if let image = getImage(from: image){
            self.imageCompany.image = image
        }
        
        if priceChange > 0{
            self.priceChangeLabel.textColor = UIColor.green
        } else if priceChange < 0{
            self.priceChangeLabel.textColor = UIColor.red
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.requestQuoteUpdate()
    }
    private func requestQuoteUpdate(){
        self.activityIndicator.startAnimating()
        self.companyNameLable.text = "-"
        self.companySymbolLabel.text = "-"
        self.priceLabel.text = "-"
        self.priceChangeLabel.text = "-"
        self.priceChangeLabel.textColor = UIColor.black
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        self.requestQuote(for: selectedSymbol)
    }
    func getImage(from string: String) -> UIImage? {
        //2. Get valid URL
        guard let url = URL(string: string)
            else {
                print("Unable to create URL")
                return nil
        }

        var image: UIImage? = nil
        do {
            //3. Get valid data
            let data = try Data(contentsOf: url, options: [])

            //4. Make image
            image = UIImage(data: data)
        }
        catch {
            print(error.localizedDescription)
        }

        return image
    }
    




}
